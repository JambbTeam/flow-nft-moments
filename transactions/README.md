# Transaction Overview
Note: Init steps at bottom


## Init Steps
### Setup Moments
```
flow transactions send ./transactions/setupMoments.cdc \
  --network emulator \
  --signer emulator-account \
  --gas-limit 1000

flow transactions send ./transactions/setupMomentsAdminProxy.cdc \
  --network emulator \
  --signer emulator-account \
  --gas-limit 1000

flow transactions send ./transactions/setupMomentsContentCreatorProxy.cdc \
  --network emulator \
  --signer emulator-account \
  --gas-limit 1000
```

### Admin Grants sudo
```
flow transactions send ./transactions/activateAdminProxy.cdc <proxyReceiverAddress> \
  --network emulator \
  --signer emulator-account \
  --gas-limit 1000
```

## Mint Moments and Collectibles
### they take arrays of strings as metadata for now
```
flow transactions send ./transactions/mintMoments.cdc <numToMint> <typeID> '["name","descrip","mediaType","mediaHash","mediaURI"]' --signer <admin-signer>

flow transactions send ./transactions/mintCollectible.cdc '["name","descrip","mediaType","mediaHash","mediaURI"]' --signer <admin-signer>
```