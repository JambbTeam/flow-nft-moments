# Moments: Transactions

## Admin
### Transaction Summaries
- `activateAdminProxy` expects an address, gives their account's `AdminProxy` the `Administrator` capability.
- `registerCreator` expects an address, gives their account's `CreatorProxy` the `ContentCreator` capability.
- `attributeCreator` expects an address and contentID, stores an attribution of the address (if it is a valid creator) to a given contentID.
- `revokeCreator` expects the address of an *existing* creator, preventing further creation or update
- `reinstateCreator` expects the address of an *existing, revoked* creator, and reinstates their privileges
- `destroyContent` - tba - adding an example of destroying malicious content

## Creator
- `createContent` expects an array of Strings, which is a hacky but functional way of adding static information, and will add that as **ContentMetadata** to **ContentCreator** resource.
- `createSeries` expects a name, and creates a simple **SeriesMetadata** and stores that in the CC
- `createSet` expects a name, and creates a simple **SetMetadata** and stores that in the CC
- `createContentEdition` expects a `contentID` and `setID`, and creates an `edition` of that by adding it to the `set` and allowing **Moments** to be minted from it
- `mintMoment` expects a `contentID` and `setID`, mints a **Moments.NFT** of that `edition`

- `retireSet` tba

## User
- `sendMoment` expects a recipient address and momentID to withdraw
- `batchSendMoment` expects an [address] and {Address: [UInt64]}



## Setup
There are three things that are potentially useful to setup.
- `AdminProxy` - This is for privileged users only. Anyone can make one, few can use them.
- `CreatorProxy` - Similarly, this is for privileged users only, and the same stipulation applies, but Admin is sudo, creator just gets to make Content.
- `Moments` - Duh!