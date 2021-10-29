# Moments: Transactions

## Admins
- `activateAdminProxy` expects an address, gives their account's `AdminProxy` the `Administrator` capability.
- `registerCreator` expects an address, gives their account's `CreatorProxy` the `ContentCreator` capability.
- `attributeCreator` expects an address and contentID, stores an attribution of the address (if it is a valid creator) to a given contentID.
- `revokeCreator` expects the address of an *existing* creator, preventing further creation or update
- `reinstateCreator` expects the address of an *existing, revoked* creator, and reinstates their privileges
- `destroyContent` - tba - adding an example of destroying malicious content

## Creators
### Making the Metadata for a Moment to be created from
- `createContent` expects an array of Strings, which is a hacky but functional way of adding static information, and will add that as **ContentMetadata** to **ContentCreator** resource.
- `createSeries` expects a name, and creates a simple **SeriesMetadata** and stores that in the CC
- `createSet` expects a name, and creates a simple **SetMetadata** and stores that in the CC
- `createContentEdition` expects a `contentID` and `setID`, and creates an `edition` of that by adding it to the `set` and allowing **Moments** to be minted from it

### Minting is easy once sets exist to mint from!
- `mintMoment` expects a `contentID` and `setID`, mints a **Moments.NFT** of that `edition`
#### You can retire sets from being minted any further
- `retireSet` expects a `setID`, prevents further minting from that `Set` (aka all `editions` from that set can no longer be minted)

### Updaters
- `updateContent` expects `contentID` and `ContentMetadata`, and replaces that content's metadata in the ContentCreator
- `updateSet` expects `settID` and `SetMetadata`, and replaces that set's metadata in the ContentCreator
- `updateSeries` expects `seriesID` and `SeriesMetadata`, and replaces that series's metadata in the ContentCreator

## Users
- `sendMoment` expects a recipient address and momentID to withdraw
- `batchSendMoment` expects an [address] and {Address: [UInt64]}

## Account Setup
There are three things that are potentially useful to setup.
- `AdminProxy` - This is for privileged users only. Anyone can make one, few can use them.
- `CreatorProxy` - Similarly, this is for privileged users only, and the same stipulation applies, but Admin is sudo, creator just gets to make Content.
- `Moments` - Duh!