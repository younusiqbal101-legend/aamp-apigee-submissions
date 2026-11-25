# aamp-apigee-submissions

Configuration submitted from the aamp portal. Each submission adds one row to the table below.

Folders:

- `proxy/` one JSON file per API proxy (spec, policies, base path, target server). Jenkins builds the zip from these.
- `kvm/` one JSON file per key value map.
- `sharedflows/` one JSON file per shared flow the proxy uses.
- `targetservers/` one JSON file per target server.

If a file name is already taken, the new file is named `<name>-<request-id>.json`.

<!-- submissions:start -->
| Request ID | Submitted | Environment | API name | Proxy | Target server | Shared flows | KVM |
| --- | --- | --- | --- | --- | --- | --- | --- |
| REQ-1071 | 2026-11-25 | eval | developer-portal-demo-ap | `proxy/developer-portal-demo-ap.json` | `targetservers/mocktarget.json` | `sharedflows/SF-ErrorFramework.json` | — |
| REQ-1072 | 2026-11-25 | eval | developer-portal-demo-ap | `proxy/developer-portal-demo-ap-REQ-1072.json` | `targetservers/mocktarget-REQ-1072.json` | `sharedflows/SF-ErrorFramework-REQ-1072.json` | — |
| REQ-1073 | 2026-11-25 | eval | developer-portal-demo-ap-new | `proxy/developer-portal-demo-ap-new.json` | `targetservers/mocktarget.json` | — | — |
<!-- submissions:end -->
