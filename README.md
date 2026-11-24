# aamp-apigee-submissions

Holds Apigee configuration submitted from the aamp portal. Submitting a request
writes its files here instead of changing Apigee directly.

## Layout

    <environment>/<api-name>/<request-id>/
      proxy/          API proxy bundle
      kvm/            key value map entries
      targetservers/  target server definitions
      sharedflows/    shared flows used by the proxy

Example: test-env/shipment-api/REQ-1048/proxy/

This repository is a test layout. The folders contain placeholder files only.
