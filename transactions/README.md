# Transaction Overview
Note: Init steps at bottom


## Init Steps
### Setup Moments
```
flow transactions send ./transactions/setupMoments.cdc \
  --network emulator \
  --signer emulator-account \
  --gas-limit 1000

flow transactions send ./transactions/setupAdminProxy.cdc \
  --network emulator \
  --signer emulator-account \
  --gas-limit 1000

flow transactions send ./transactions/setupCreatorProxy.cdc \
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
  
flow transactions send ./transactions/activateCreatorProxy.cdc <proxyReceiverAddress> \
  --network emulator \
  --signer emulator-account \
  --gas-limit 1000
```
