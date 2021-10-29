import NonFungibleToken from "./standard/NonFungibleToken.cdc"

pub contract Moments: NonFungibleToken {
    // Standard Events
    pub event ContractInitialized()
    pub event Withdraw(id: UInt64, from: Address?)
    pub event Deposit(id: UInt64, to: Address?)

    // Emitted when a new ContentCreator is initialized into the system
    pub event CreatorRegistered(creator: Address)
    // Emitted on Attribution
    pub event CreatorAttributed(creator: Address, momentID: UInt64)

    // Emitted on Creation
    pub event SeriesCreated(seriesID: UInt64)
    pub event SetCreated(setID: UInt64)   
    pub event ContentCreated(contentID: UInt64)
    pub event ContentEditionCreated(contentID: UInt64, setID: UInt64)

    // Emitted on Updates
    pub event ContentUpdated(contentID: UInt64)
    pub event SetUpdated(setID: UInt64)
    pub event SeriesUpdated(seriesID: UInt64)

    // Emitted on Metadata destruction
    pub event ContentDestroyed(contentID: UInt64)
    
    // Emitted when a Moment is added to a given Set
    //pub event MomentTypeAddedToSet(momentTypeID: UInt64, contentID: UInt64, setID: UInt64)

    // Emitted when a Set is retired
    pub event SetRetired(setID: UInt64)

    // Emitted when a Moment is minted
    pub event MomentMinted(momentID: UInt64, contentID: UInt64, setID: UInt64, serialNumber: UInt64)

    // Emitted when a Moment is destroyed
    pub event MomentDestroyed(momentID: UInt64)

    // Moment Collection Paths
    pub let CollectionStoragePath: StoragePath
    pub let CollectionPublicPath: PublicPath

    // CreatorProxy Receiver
    pub let CreatorProxyStoragePath: StoragePath
    pub let CreatorProxyPublicPath: PublicPath

    // Contract Owner ContentCreator Resource
    pub let ContentCreatorStoragePath: StoragePath
    pub let ContentCreatorPrivatePath: PrivatePath
    pub let ContentCreatorPublicPath: PublicPath

    // AdminProxy Receiver
    pub let AdminProxyStoragePath: StoragePath
    pub let AdminProxyPublicPath: PublicPath

    // Contract Owner Root Administrator Resource
    pub let AdministratorStoragePath: StoragePath
    pub let AdministratorPrivatePath: PrivatePath
    pub let RevokerPublicPath: PublicPath

    // totalSupply
    // The total number of Moments that have been minted
    //
    pub var totalSupply: UInt64
    
    // Content Metadata
    pub struct ContentMetadata {
        pub let name: String
        pub let description: String

        // descriptor of the source of the content came from
        pub let source: String
        // MIME type: image/png, image/jpeg, video/mp4, audio/mpeg
        pub let mediaType: String 
        // IPFS storage hash
        pub let mediaHash: String
        // URI to NFT media - incase IPFS not in use/avail
        pub let mediaURI: String

        init(name: String, description: String, source: String, mediaType: String, mediaHash: String, mediaURI: String) {
            self.name = name
            self.description = description
            self.source = source
            self.mediaType = mediaType
            self.mediaHash = mediaHash
            self.mediaURI = mediaURI
        }
    }

    // Set Metadata
    pub struct SetMetadata {
        // name of set
        pub let name: String
        // series the set belongs to
        pub let seriesID: UInt64

        init(name: String, seriesID: UInt64) {
            pre {
                name.length > 0: "New Set name cannot be empty"
            }
            self.seriesID = seriesID
            self.name = name
        }
    }

    // Series Metadata
    pub struct SeriesMetadata {
        // name of the series
        pub let name: String

        init(name: String) {
            pre {
                name.length > 0: "New Series name cannot be empty"
            }
            self.name = name
        }
    }

    // Moment Metadata
    // provies a wrapper to all the relevant data of a Moment
    pub struct MomentMetadata {
        pub let id: UInt64
        pub let name: String
        pub let description: String
        pub let setID: UInt64
        pub let setName: String
        pub let seriesID: UInt64
        pub let seriesName: String
        pub let mediaType: String
        pub let mediaHash: String
        pub let mediaURI: String
        init(id: UInt64, name: String, description: String, setID: UInt64, setName: String, seriesID: UInt64, seriesName: String, mediaType: String, mediaHash: String, mediaURI: String) {
                self.id = id
                self.name = name
                self.description = description
                self.setID = setID
                self.setName = setName
                self.seriesID = seriesID
                self.seriesName = seriesName
                self.mediaType = mediaType
                self.mediaHash = mediaHash
                self.mediaURI = mediaURI
            }
    }

    // public creation for accounts to proxy from
    pub fun createCreatorProxy(): @CreatorProxy {
        return <- create CreatorProxy()
    }
    pub resource interface CreatorProxyPublic {
        pub fun registerCreatorProxy(_ cap: Capability<&Moments.ContentCreator>)
    }
    pub resource CreatorProxy: CreatorProxyPublic {
        access(self) var powerOfCreation: Capability<&Moments.ContentCreator>?
        init () {
            self.powerOfCreation = nil
        }
        pub fun registerCreatorProxy(_ cap: Capability<&Moments.ContentCreator>){ 
            pre {
                cap.check() : "Invalid ContentCreator capability"
                self.powerOfCreation == nil : "ContentCreator capability already set"
            }
            self.powerOfCreation = cap
            let creator = self.powerOfCreation!.borrow()!
            creator.registerCreator(creator: self.owner!.address)
        }

        // borrow a reference to the ContentCreator
        // 
        pub fun borrowContentCreator(): &Moments.ContentCreator {
            pre {
                self.powerOfCreation!.check() : "Your CreatorProxy has no capabilities."
            }
            let revoker = Moments.account.getCapability<&{Moments.Revoker}>(Moments.RevokerPublicPath).borrow()
                ?? panic("Can't find the revoker/admin!")

            if (revoker.revoked(address: self.owner!.address)) { panic("Creator privileges revoked") }
                
            let aPowerToBehold = self.powerOfCreation!.borrow()
                ?? panic("Your CreatorProxy has no capabilities.")
            
            return aPowerToBehold
        }
    }
    pub resource interface ContentCreatorPublic {
        // getters
        pub fun getMomentMetadata(momentID: UInt64): MomentMetadata
        pub fun getContentMetadata(contentID: UInt64): ContentMetadata
        pub fun getSetMetadata(setID: UInt64): SetMetadata
        pub fun getSet(setID: UInt64): {UInt64: UInt64}
        pub fun getSeriesMetadata(seriesID: UInt64): SeriesMetadata
        pub fun getSeries(seriesID: UInt64): [UInt64]
        pub fun getCreatorAttributions(address: Address): [UInt64]
        pub fun isSetRetired(setID:UInt64): Bool
    }

    pub resource ContentCreator: ContentCreatorPublic { 
        // metadata and id maps
        access(self) let momentMetadata: {UInt64: MomentMetadata}
        access(self) let contentMetadata: {UInt64: ContentMetadata}
        access(self) let setMetadata: {UInt64: SetMetadata}
        access(self) let sets: {UInt64: {UInt64: UInt64}}
        access(self) let seriesMetadata: {UInt64: SeriesMetadata}
        access(self) let series: {UInt64: [UInt64]}
        
        // incrementors
        access(self) var newContentID: UInt64
        access(self) var newSetID: UInt64
        access(self) var newSeriesID: UInt64
        
        // creators
        access(self) let creators: {Address:[UInt64]}

        // retire set from further minting
        access(self) let retiredSets: {UInt64: Bool}

        init() {
            self.contentMetadata = {}
            self.sets = {}
            self.setMetadata = {}
            self.series = {}
            self.seriesMetadata = {}
            self.momentMetadata = {}          

            self.newContentID = 0
            self.newSetID = 0
            self.newSeriesID = 0

            self.creators = {}
            self.retiredSets = {}
        }

        ///////
        // CREATION FUNCTIONS -> THESE ADD TO ROOT MOMENTS DATA
        //// These are the only mechanisms to create what Content can be minted from and how.
        ///////
        
        // createContent
        // 
        pub fun createContent(content: ContentMetadata): UInt64 {
            let newID = self.newContentID
            self.contentMetadata[newID] = content
            self.newContentID = self.newContentID + (1 as UInt64)

            emit ContentCreated(contentID: newID)
            return newID
        }
        // createSeries
        //
        pub fun createSeries(name: String): UInt64 {
            let newID = self.newSeriesID
            self.seriesMetadata[newID] = SeriesMetadata(name: name)       
            self.newSeriesID = self.newSeriesID + (1 as UInt64)
            self.series[newID] = []

            emit SeriesCreated(seriesID: newID)
            return newID
        }
        // createSet
        //
        pub fun createSet(name: String, seriesID: UInt64): UInt64 {
            pre {
                self.series[seriesID] != nil : "That set contains an invalid series"
            }
            let newID = self.newSetID
            self.setMetadata[newID] = SetMetadata(name: name, seriesID: seriesID)
            self.newSetID = self.newSetID + (1 as UInt64)
            self.sets[newID] = {}
            self.retiredSets[newID] = false
            self.series[seriesID]!.append(newID)

            emit SetCreated(setID: newID)
            return newID
        }
        // createContentEdition
        // use addContentEditionsToSet below to route into add, ensure contract can count the edition
        // creates a Content reference in a given Set, establishing an Edition to mint from
        //
        pub fun createContentEdition(contentID: UInt64, setID: UInt64) {
            pre {
                self.contentMetadata[contentID] != nil: "Cannot add the ContentEdition to Set: Content doesn't exist"
                self.sets[setID] != nil: "Cannot add ContentEdition to Set: Set doesn't exist"
                !self.retiredSets[setID]!: "Cannot add ContentEdition to Set after it has been Retired"
            }
            // add this edition to the set
            let set = self.sets[setID]!
            assert(set[contentID] == nil, message: "That ContentID is already used in this Set")            
            set[contentID] = 0
            self.sets[setID] = set
            
            emit ContentEditionCreated(contentID: contentID, setID: setID)
            // DEVNOTE: There is a deliberate decision here to not track some specific value of "contentEdition" since
            // it does not tack any useful information, it is just a number, and it is one that is deterministic per
            // the number of Editions created with a given contentID - so the chain will tell you the 'order' of the
            // sets in which Moments were released aka Editions were created
        }

        ///////
        // UPDATERS - for a creator to manage their content
        ///////

        // updateSetMetadata
        pub fun updateSetMetadata(setID: UInt64, set: SetMetadata) {            
            self.setMetadata[setID] = set

            emit SetUpdated(setID: setID)
        }
        // updateSeriesMetadata
        pub fun updateSeriesMetadata(seriesID: UInt64, series: SeriesMetadata) {            
            self.seriesMetadata[seriesID] = series

            emit SeriesUpdated(seriesID: seriesID)
        }
        // updateContentMetadata
        pub fun updateContentMetadata(contentID: UInt64, content: ContentMetadata) {            
            self.contentMetadata[contentID] = content

            emit ContentUpdated(contentID: contentID)
        }
        // retireSet
        //
        pub fun retireSet(setID: UInt64) {
            pre {
                self.sets[setID] != nil: "Cannot retire the Set, it doesn't exist!"
            }
            if !self.retiredSets[setID]! {
                self.retiredSets[setID] = true
                emit SetRetired(setID:setID)
            }
        }

        //////
        // ADMIN-MANAGED ATTRIBUTION AND REGISTRATION 
        //////

        // attribute
        //
        access(contract) fun attribute(creator: Address, momentID: UInt64) {
            pre {
                self.creators[creator] != nil : "That creator is unregistered or revoked"
            }
            self.creators[creator]!.append(momentID)
            emit CreatorAttributed(creator: creator, momentID: momentID)
        }
        // registerCreator
        //
        access(contract) fun registerCreator(creator: Address) {
            pre {
                self.creators[creator] == nil : "That creator is already registered"
            }
            self.creators[creator] = []
            emit CreatorRegistered(creator: creator)
        }

        //////
        // MINT
        //////

        // mintMoment
        //
        pub fun mintMoment(contentID: UInt64, setID: UInt64): @NFT {
            pre {
                self.contentMetadata[contentID] != nil: "Cannot mint Moment: This Content doesn't exist."
                self.sets[setID] != nil: "Cannot mint Moment from this Set: This Set does not exist."
                !self.retiredSets[setID]!: "Cannot mint Moment from this Set: This Set has been retired."
            }
            let set = self.sets[setID]!
            let momentsMinted = set[contentID] ?? panic("Cannot mint Moment from this Set: This Content is not a part of that Set")

            // Mint the new moment
            let newMoment: @NFT <- create NFT(contentID: contentID,
                                              setID: setID,
                                              serialNumber: momentsMinted + UInt64(1))

            // Increment the count of Moments minted for this ContentEdition
            set[contentID] = momentsMinted + (1 as UInt64)
            self.sets[setID] = set
            
            let setMetadata = self.setMetadata[setID]!
            let contentMetadata = self.contentMetadata[contentID]!
            let seriesMetadata = self.seriesMetadata[setMetadata.seriesID]!

            let momentMetadata = MomentMetadata(
                id: newMoment.id,
                name: contentMetadata.name,
                description: contentMetadata.description,
                setID: newMoment.setID,
                setName: setMetadata.name,
                seriesID: setMetadata.seriesID,
                seriesName: seriesMetadata.name,
                mediaType: contentMetadata.mediaType,
                mediaHash: contentMetadata.mediaHash,
                mediaURI: contentMetadata.mediaURI
            )
            self.momentMetadata[newMoment.id] = momentMetadata
            return <- newMoment
        }

        // batchMintMoment
        //
        pub fun batchMintMoment(contentID: UInt64, setID: UInt64, quantity: UInt64): @Collection {
            let newCollection <- create Collection()

            var i: UInt64 = 0
            while i < quantity {
                newCollection.deposit(token: <-self.mintMoment(contentID: contentID, setID: setID))
                i = i + (1 as UInt64)
            }

            return <- newCollection
        }
        
        ////////
        // GETTERS AND SUGAR
        ////////
        pub fun getMomentMetadata(momentID: UInt64): MomentMetadata {
            pre {
                self.momentMetadata[momentID] != nil : "That momentID has no metadata associated with it"
            }
            return self.momentMetadata[momentID]!
        }
        pub fun getContentMetadata(contentID: UInt64): ContentMetadata {
            pre {
                self.contentMetadata[contentID] != nil : "That contentID has no metadata associated with it"
            }
            return self.contentMetadata[contentID]!
        }
        pub fun getSetMetadata(setID: UInt64): SetMetadata {
            pre {
                self.setMetadata[setID] != nil : "That setID has no metadata associated with it"
            }
            return self.setMetadata[setID]!
        }
        pub fun getSeriesMetadata(seriesID: UInt64): SeriesMetadata {
            pre {
                self.seriesMetadata[seriesID] != nil : "That seriesID has no metadata associated with it"
            }
            return self.seriesMetadata[seriesID]!
        }
        pub fun getSet(setID: UInt64): {UInt64: UInt64} {
            pre {
                self.sets[setID] != nil : "That set does not exist"
            }
            return self.sets[setID]!
        }
        pub fun getSeries(seriesID: UInt64): [UInt64] {
            pre {
                self.series[seriesID] != nil : "That series does not exist"
            }
            return self.series[seriesID]!
        }
        pub fun getCreatorAttributions(address: Address): [UInt64] {
            pre {
                self.creators[address] != nil : "That creator has never been registered"
            }
            return self.creators[address]!
        }
        pub fun isSetRetired(setID:UInt64): Bool {
            pre {
                self.retiredSets[setID] != nil: "That set does not exist"
            }
            return self.retiredSets[setID]!
        }
    }

    // NFT
    // Moment
    //
    pub resource NFT: NonFungibleToken.INFT {
        // The token's ID per NFT standard
        pub let id: UInt64

        // Note: The combination of Content and Set creates an Edition
        //   the edition of a given moment is tracked by the contract

        // The ID of the Content that the Moment references
        pub let contentID: UInt64
        // The ID of the Set that the Moment comes from
        pub let setID: UInt64
        // The place in the Edition that this Moment was minted
        pub let serialNumber: UInt64

        // init
        //
        init(contentID: UInt64, setID: UInt64, serialNumber: UInt64) {
            Moments.totalSupply = Moments.totalSupply + (1 as UInt64)
            self.id = Moments.totalSupply
            
            self.contentID = contentID
            self.setID = setID
            self.serialNumber = serialNumber

            emit MomentMinted(momentID: self.id, contentID: self.contentID, setID: self.setID, serialNumber: self.serialNumber)
        }

        pub fun getMomentMetadata(): MomentMetadata {
            return Moments.getMomentMetadata(momentID: self.id)
        }

        destroy() {
            emit MomentDestroyed(momentID: self.id)
        }
    }

    pub resource interface CollectionPublic {
        pub fun deposit(token: @NonFungibleToken.NFT)
        pub fun getIDs(): [UInt64]
        pub fun borrowNFT(id: UInt64): &NonFungibleToken.NFT
        pub fun borrowMoment(id: UInt64): &Moments.NFT? {
            // If the result isn't nil, the id of the returned reference
            // should be the same as the argument to the function
            post {
                (result == nil) || (result?.id == id):
                    "Cannot borrow Moments reference: The ID of the returned reference is incorrect"
            }
        }
    }

    // Collection
    // A collection of Moments NFTs owned by an account
    //
    pub resource Collection: NonFungibleToken.Provider, NonFungibleToken.Receiver, NonFungibleToken.CollectionPublic, CollectionPublic {
        // dictionary of NFT conforming tokens
        // NFT is a resource type with an `UInt64` ID field
        //
        pub var ownedNFTs: @{UInt64: NonFungibleToken.NFT}

        // withdraw
        // Removes an NFT from the collection and moves it to the caller
        //
        pub fun withdraw(withdrawID: UInt64): @NonFungibleToken.NFT {
            let token <- self.ownedNFTs.remove(key: withdrawID) ?? panic("missing NFT")

            emit Withdraw(id: token.id, from: self.owner?.address)

            return <-token
        }

        // deposit
        // Takes a NFT and adds it to the collections dictionary
        // and adds the ID to the id array
        //
        pub fun deposit(token: @NonFungibleToken.NFT) {
            let token <- token as! @Moments.NFT

            let id: UInt64 = token.id

            // add the new token to the dictionary which removes the old one
            let oldToken <- self.ownedNFTs[id] <- token

            emit Deposit(id: id, to: self.owner?.address)

            destroy oldToken
        }

        // getIDs
        // Returns an array of the IDs that are in the collection
        //
        pub fun getIDs(): [UInt64] {
            return self.ownedNFTs.keys
        }

        // borrowNFT
        // Gets a reference to an NFT in the collection
        // so that the caller can read its metadata and call its methods
        //
        pub fun borrowNFT(id: UInt64): &NonFungibleToken.NFT {
            return &self.ownedNFTs[id] as &NonFungibleToken.NFT
        }

        // borrowMoment
        // Gets a reference to an NFT in the collection as a Moments.NFT,
        // exposing all of its fields.
        // This is safe as there are no functions that can be called on the Moments.
        //
        pub fun borrowMoment(id: UInt64): &Moments.NFT? {
            if self.ownedNFTs[id] != nil {
                let ref = &self.ownedNFTs[id] as auth &NonFungibleToken.NFT
                return ref as! &Moments.NFT
            } else {
                return nil
            }
        }

        // destructor
        //
        destroy() {
            destroy self.ownedNFTs
        }

        // initializer
        //
        init () {
            self.ownedNFTs <- {}
        }
    }

    // createEmptyCollection
    // public function that anyone can call to create a new empty collection
    //
    pub fun createEmptyCollection(): @NonFungibleToken.Collection {
        return <- create Collection()
    }

    // AdminUsers will create a Proxy and be granted
    // access to the Administrator resource through their receiver, which
    // they can then borrowSudo() to utilize
    //
    pub fun createAdminProxy(): @AdminProxy { 
        return <- create AdminProxy()
    }

    // public receiver for the Administrator capability
    //
    pub resource interface AdminProxyPublic {
        pub fun addCapability(_ cap: Capability<&Moments.Administrator>)
    }

    /// AdminProxy
    /// This is a simple receiver for the Administrator resource, which
    /// can be borrowed if capability has been established.
    ///
    pub resource AdminProxy: AdminProxyPublic {
        // requisite receiver of Administrator capability
        access(self) var sudo: Capability<&Moments.Administrator>?
        
        // initializer
        //
        init () {
            self.sudo = nil
        }

        // must receive capability to take administrator actions
        //
        pub fun addCapability(_ cap: Capability<&Moments.Administrator>){ 
            pre {
                cap.check() : "Invalid Administrator capability"
                self.sudo == nil : "Administrator capability already set"
            }
            self.sudo = cap
        }

        // borrow a reference to the Administrator
        // 
        pub fun borrowSudo(): &Moments.Administrator {
            pre {
                self.sudo != nil : "Your AdminProxy has no Administrator capabilities."
            }
            let sudoReference = self.sudo!.borrow()
                ?? panic("Your AdminProxy has no Administrator capabilities.")

            return sudoReference
        }
    }

    pub resource interface Revoker {
        pub fun revoked(address: Address): Bool
    }

    /// Administrator
    /// Deployer-owned resource that Privately grants Capabilities to Proxies
    pub resource Administrator: Revoker {
        pub let creators: {Address: Bool}

        init () {
            self.creators = {}
        }

        // registerCreator
        //   - registers a new account's CC Proxy
        //   - does not allow re-registration
        //
        pub fun registerCreator(address: Address) { 
            pre {
                getAccount(address).getCapability<&{Moments.CreatorProxyPublic}>(Moments.CreatorProxyPublicPath).check() : "Creator account does not have a valid Proxy"
                self.creators[address] == nil : "That creator has already been registered"
            }
            self.creators[address] = true // don't break the rules
        }

        // revokeProxy
        //  - revoke's a proxy's ability to borrow its CC cap
        //
        pub fun revokeCreator(address: Address) {
            pre {
                self.creators[address] != nil : "That creator has never been registered"
            }
            self.creators[address] = false // naughty
        }

        // reinstateCreator
        //  - hopefully this never needs to be called :)
        //
        pub fun reinstateCreator(address: Address) {
            pre {
                self.creators[address] != nil : "That creator has never been registered"
            }
            self.creators[address] = true // good person
        }

        // revoked
        //  - yes means no!
        //
        pub fun revoked(address: Address): Bool {
            pre {
                self.creators[address] != nil : "That creator has never been registered"
            }
            return !self.creators[address]!
        }

        pub fun attributeCreator(address: Address, momentID: UInt64) {
            pre {
                self.creators[address] != nil: "That creator has never been registereD"
            }
            let cc = Moments.account.borrow<&Moments.ContentCreator>(from: Moments.ContentCreatorStoragePath)
             ?? panic("NO CONTENT CREATOR! What'd you doooo")
            cc.attribute(creator: address, momentID: momentID)
        }
    }

    // fetch
    // Get a reference to a Moments from an account's Collection, if available.
    // If an account does not have a Moments.Collection, panic.
    // If it has a collection but does not contain the momentID, return nil.
    // If it has a collection and that collection contains the momentID, return a reference to that.
    //
    pub fun fetch(_ from: Address, momentID: UInt64): &Moments.NFT? {
        let collection = getAccount(from)
            .getCapability<&{Moments.CollectionPublic}>(Moments.CollectionPublicPath)
            .borrow() ?? panic("Couldn't get collection")
        // We trust Moments.Collection.borrowMoment to get the correct itemID
        // (it checks it before returning it).
        return collection.borrowMoment(id: momentID)
    }

    // getMomentMetadata
    // some sugar for the NFT-holder to get a full metadata set from the contract
    //
    pub fun getMomentMetadata(momentID: UInt64): MomentMetadata {
        let publicContent = Moments.account.getCapability<&{Moments.ContentCreatorPublic}>(Moments.ContentCreatorPublicPath).borrow() 
            ?? panic("Could not get the public content from the contract")
        
        let metadata = publicContent.getMomentMetadata(momentID: momentID)!
        return metadata
    }

    // initializer
    //
    init() {
        self.CollectionStoragePath = /storage/jambbMomentsCollection
        self.CollectionPublicPath = /public/jambbMomentsCollection
		
        // only one content creator should ever exist, in the deployer storage
        self.ContentCreatorStoragePath = /storage/jambbMomentsContentCreator
        self.ContentCreatorPrivatePath = /private/jambbMomentsContentCreator
        self.ContentCreatorPublicPath = /public/jambbMomentsContentCreator

        // users can be proxied in and allowed to create content
        self.CreatorProxyStoragePath = /storage/jambbMomentsCreatorProxy
        self.CreatorProxyPublicPath = /public/jambbMomentsCreatorProxy
        
        // only one Administrator should ever exist, in deployer storage
        self.AdministratorStoragePath = /storage/jambbMomentsAdministrator
        self.AdministratorPrivatePath = /private/jambbMomentsAdministrator
        self.RevokerPublicPath = /public/jambbMomentsAdministrator

        self.AdminProxyStoragePath = /storage/jambbMomentsMomentsAdminProxy
        self.AdminProxyPublicPath = /public/jambbMomentsAdminProxy

        // Initialize the total supply
        self.totalSupply = 0

        // Create a NFTAdministrator resource and save it to storage
        let admin <- create Administrator()
        self.account.save(<- admin, to: self.AdministratorStoragePath)
        // Link it to provide shareable access route to capabilities
        self.account.link<&Moments.Administrator>(self.AdministratorPrivatePath, target: self.AdministratorStoragePath)
        self.account.link<&{Moments.Revoker}>(self.RevokerPublicPath, target: self.AdministratorStoragePath)
        

        // Create a ContentCreator resource and save it to storage
        let cc <- create ContentCreator()
        self.account.save(<- cc, to: self.ContentCreatorStoragePath)
        // Link it to provide shareable access route to capabilities
        self.account.link<&Moments.ContentCreator>(self.ContentCreatorPrivatePath, target: self.ContentCreatorStoragePath)
        self.account.link<&{Moments.ContentCreatorPublic}>(self.ContentCreatorPublicPath, target: self.ContentCreatorStoragePath)

        // create a personal collection just in case contract ever holds Moments to distribute later etc
        let collection <- create Collection()
        self.account.save(<- collection, to: self.CollectionStoragePath)
        self.account.link<&{Moments.CollectionPublic}>(self.CollectionPublicPath, target: self.CollectionStoragePath)
        
        emit ContractInitialized()
    }
}
 
