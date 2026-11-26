param(
    [Parameter(Mandatory = $true)][string]$Org,
    [Parameter(Mandatory = $true)][string]$Env,
    [Parameter(Mandatory = $true)][string]$TokenFile,
    [Parameter(Mandatory = $true)][string]$KvmDir,
    [switch]$DryRun
)

# Creates or updates each KVM in PPD/kvm/*.json in one Apigee environment.
# A KVM file looks like: { "name": "...", "encrypted": false, "entries": [ { "name": "...", "value": "..." } ] }
# Nothing is changed in Apigee when -DryRun is given.

$ErrorActionPreference = 'Stop'
$base = "https://apigee.googleapis.com/v1/organizations/$Org/environments/$Env/keyvaluemaps"
$token = (Get-Content -Raw -Path $TokenFile).Trim()
$headers = @{ Authorization = "Bearer $token" }

function Get-StatusCode($err) {
    if ($err.Exception.Response) { return [int]$err.Exception.Response.StatusCode }
    return 0
}

function Test-Exists($url) {
    try {
        Invoke-RestMethod -Method Get -Uri $url -Headers $headers | Out-Null
        return $true
    } catch {
        if ((Get-StatusCode $_) -eq 404) { return $false }
        throw
    }
}

function Send-Json($method, $url, $body) {
    $json = $body | ConvertTo-Json -Depth 10
    Invoke-RestMethod -Method $method -Uri $url -Headers $headers -ContentType 'application/json' -Body $json | Out-Null
}

$files = Get-ChildItem -Path $KvmDir -Filter *.json -File
if (-not $files) {
    Write-Output "No KVM files in $KvmDir. Nothing to deploy."
    exit 0
}

$failed = 0
foreach ($file in $files) {
    try {
        $kvm = Get-Content -Raw -Path $file.FullName | ConvertFrom-Json
        if (-not $kvm.name) { throw "missing 'name'" }
        $encrypted = [bool]$kvm.encrypted
        $entries = @($kvm.entries)
        $kvmUrl = "$base/$($kvm.name)"

        if (Test-Exists $kvmUrl) {
            $existing = Invoke-RestMethod -Method Get -Uri $kvmUrl -Headers $headers
            if ([bool]$existing.encrypted -ne $encrypted) {
                throw "KVM '$($kvm.name)' already exists with encrypted=$([bool]$existing.encrypted). Encryption cannot be changed; use a new name."
            }
            Write-Output "[$($file.Name)] KVM '$($kvm.name)' exists in $Env; updating entries."
        } else {
            Write-Output "[$($file.Name)] KVM '$($kvm.name)' will be created in $Env (encrypted=$encrypted)."
            if (-not $DryRun) {
                Send-Json 'Post' $base @{ name = $kvm.name; encrypted = $encrypted }
            }
        }

        foreach ($entry in $entries) {
            if (-not $entry.name) { throw "an entry in '$($kvm.name)' has no 'name'" }
            $entryUrl = "$kvmUrl/entries/$($entry.name)"
            $body = @{ name = $entry.name; value = [string]$entry.value }
            if (Test-Exists $entryUrl) {
                Write-Output "    update entry '$($entry.name)'"
                if (-not $DryRun) { Send-Json 'Put' $entryUrl $body }
            } else {
                Write-Output "    add entry '$($entry.name)'"
                if (-not $DryRun) { Send-Json 'Post' "$kvmUrl/entries" $body }
            }
        }
    } catch {
        $failed++
        Write-Output "FAILED [$($file.Name)]: $($_.Exception.Message)"
    }
}

if ($DryRun) { Write-Output "DRY RUN: nothing was changed in Apigee." }
if ($failed -gt 0) { Write-Output "$failed KVM file(s) failed."; exit 1 }
Write-Output "KVM deploy finished."
exit 0
