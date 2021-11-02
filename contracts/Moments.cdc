import NonFungibleToken from "./standard/NonFungibleToken.cdc"

pub contract Moments: NonFungibleToken {
    // Standard Events
    pub event ContractInitialized()
    pub event Withdraw(id: UInt64, from: Address?)
    pub event Deposit(id: UInt64, to: Address?)

    // Admin-level Creator Events
    pub event CreatorRegistered(creator: Address)
    pub event CreatorRevoked(creator: Address)
    pub event CreatorReinstated(creator: Address)

    // Emitted on Attribution
    pub event CreatorAttributed(creator: Address, momentID: UInt64)

    // Emitted on Creation
    pub event SeriesCreated(seriesID: UInt64)
    pub event SetCreated(setID: UInt64)   
    pub event ContentCreated(contentID: UInt64)
    pub event ContentAddedToSeries(contentID: UInt64, seriesID: UInt64)
    pub event ContentAddedToSet(contentID: UInt64, setID: UInt64, contentEdition: UInt64)

    // Emitted on Updates
    pub event ContentUpdated(contentID: UInt64)
    pub event SetUpdated(setID: UInt64)
    pub event SeriesUpdated(seriesID: UInt64)

    // Emitted on Metadata destruction
    pub event ContentDestroyed(contentID: UInt64)
    
    // Emitted when a Set is retired
    pub event SetRetired(setID: UInt64)

    // Emitted when a Moment is minted
    pub event MomentMinted(momentID: UInt64, contentID: UInt64, setID: UInt64, seriesID: UInt64, contentEdition: UInt64, serialNumber: UInt64)

    // Emitted when a Moment is destroyed
    pub event MomentDestroyed(momentID: UInt64)

    ///////
    // PATHS
    ///////

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
        pub let id: UInt64
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

        init(id: UInt64, name: String, description: String, source: String, mediaType: String, mediaHash: String, mediaURI: String) {
            self.id = id
            self.name = name
            self.description = description
            self.source = source
            self.mediaType = mediaType
            self.mediaHash = mediaHash
            self.mediaURI = mediaURI
        }
    }
    
    // Series Metadata
    // provides a wrapper to all the relevant data of a Series
    pub struct SeriesMetadata {
        pub let id: UInt64
        // name of the series
        pub let name: String
        // content ids in the series
        pub(set) var contentIDs: [UInt64]

        init(id: UInt64, name: String) {
            pre {
                name.length > 0: "New Series name cannot be empty"
            }
            self.id = id
            self.name = name
            self.contentIDs = []
        }
    }
    // Set Metadata
    //  - A Set is a grouping of contentIDs
    pub struct SetMetadata {
        pub let id: UInt64
        // name of set
        pub let name: String

        // map of contentIDs to their current minting
        pub(set) var contentEditions: {UInt64:UInt64}
        
        // moment ids in this set
        pub(set) var momentIDs: [UInt64]
        
        init(id: UInt64, name: String) {
            pre {
                name.length > 0: "New Set name cannot be empty"
            }
            self.id = id
            self.name = name
            self.contentEditions = {}
            self.momentIDs = []
        }
    }


    // Moment Metadata
    // provides a wrapper to all the relevant data of a Moment
    pub struct MomentMetadata {
        pub let id: UInt64
        pub let serialNumber: UInt64
        pub let contentID: UInt64
        pub let contentEdition: UInt64
        pub let name: String
        pub let description: String
        pub let setID: UInt64
        pub let setName: String
        pub let seriesID: UInt64
        pub let seriesName: String
        pub let mediaType: String
        pub let mediaHash: String
        pub let mediaURI: String
        pub(set) var complete: Bool
        pub(set) var run: UInt64
        init(id: UInt64, serialNumber: UInt64, contentID: UInt64, contentEdition: UInt64, name: String, description: String, setID: UInt64, setName: String, seriesID: UInt64, seriesName: String, mediaType: String, mediaHash: String, mediaURI: String, complete: Bool, run: UInt64) {
            self.id = id
            self.serialNumber = serialNumber
            self.contentID = contentID
            self.contentEdition = contentEdition
            self.name = name
            self.description = description
            self.setID = setID
            self.setName = setName
            self.seriesID = seriesID
            self.seriesName = seriesName
            self.mediaType = mediaType
            self.mediaHash = mediaHash
            self.mediaURI = mediaURI
            self.complete = complete
            self.run = run
        }
        
    }

    // public creation for accounts to proxy from
    pub fun createCreatorProxy(): @CreatorProxy {
        return <- create CreatorProxy()
    }
    pub resource interface CreatorProxyPublic {
        pub fun empowerCreatorProxy(_ cap: Capability<&Moments.ContentCreator>)
    }
    pub resource CreatorProxy: CreatorProxyPublic {
        access(self) var powerOfCreation: Capability<&Moments.ContentCreator>?
        init () {
            self.powerOfCreation = nil
        }
        pub fun empowerCreatorProxy(_ cap: Capability<&Moments.ContentCreator>){ 
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
        pub fun getContentEditions(contentID: UInt64): [UInt64]
        pub fun getSetMetadata(setID: UInt64): SetMetadata
        pub fun getSeriesMetadata(seriesID: UInt64): SeriesMetadata
        pub fun getCreatorAttributions(address: Address): [UInt64]
        pub fun isSetRetired(setID:UInt64): Bool
    }

    pub resource ContentCreator: ContentCreatorPublic { 
        // content tracks contentID's to their respective ContentMetadata
        access(self) let content: {UInt64: ContentMetadata}

        // editions tracks the setIDs in which a given piece of Content was minted
        access(self) let editions: {UInt64: [UInt64]}

        // seriesMetadata tracks seriesID's to their respective SeriesMetadata
        // - Series contain an array of [Content]
        access(self) let series: {UInt64: SeriesMetadata}
        
        // sets tracks setID's to their respective SetMetadata
        access(self) let sets: {UInt64: SetMetadata}
        
        // moments tracks momentID's to their respective MomentMetadata
        //  -- MomentMetadata is the aggregate of {Series:Set:Content}
        access(self) let moments: {UInt64: MomentMetadata}
        
        // protected incrementors for new things
        access(contract) var newContentID: UInt64
        access(contract) var newSetID: UInt64
        access(contract) var newSeriesID: UInt64
        
        // creators
        access(self) let creators: {Address:[UInt64]}

        // retire set from further minting
        access(self) let retiredSets: {UInt64: Bool}

        init() {
            self.content = {}
            self.editions = {}
            self.series = {}
            self.sets = {}
            self.moments = {}

            self.newContentID = 1
            self.newSetID = 1
            self.newSeriesID = 1

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
            // create the new contentMetadata at the new ID
            let newID = self.newContentID
            // enforce orderly id's by recreating contentMetadata here            
            let newContentMetadata = ContentMetadata(id:newID, 
                name: content.name, 
                description: content.description,
                source: content.source,
                mediaType: content.mediaType,
                mediaHash: content.mediaHash,
                mediaURI: content.mediaURI)
            
            // increment and emit before giving back the new ID
            self.newContentID = self.newContentID + (1 as UInt64)

            self.editions[newID] = []
            self.content[newID] = newContentMetadata

            emit ContentCreated(contentID: newID)
            return newID
        }
        // createSeries
        //
        pub fun createSeries(name: String): UInt64 {
            // create the new metadata at the new ID
            let newID = self.newSeriesID
            self.series[newID] = SeriesMetadata(id: newID, name: name)

            // increment and emit before giving back the new ID
            self.newSeriesID = self.newSeriesID + (1 as UInt64)
            emit SeriesCreated(seriesID: newID)
            return newID
        }
        // createSet
        //
        pub fun createSet(name: String): UInt64 {
            // create the new setMetadata at the new ID
            let newID = self.newSetID
            self.sets[newID] = SetMetadata(id: newID, name: name)

            // create the retirement flag for this set
            self.retiredSets[newID] = false

            // increment and emit before giving back the new ID
            self.newSetID = self.newSetID + (1 as UInt64)
            emit SetCreated(setID: newID)
            return newID
        }
        ////// CONTENT ADDERS //////
        // Content must be represented within a given Series and Set before
        // it can be minted into a Moment
        ////////////////////////////

        // addContentToSeries
        // - Adds a given ContentID to a given series
        //
        pub fun addContentToSeries(contentID: UInt64, seriesID: UInt64) {
            pre {
                self.content[contentID] != nil: "Cannot add the Content to Series: Content doesn't exist"
                self.series[seriesID] != nil: "Cannot mint Moment from this Series: the Series does not exist"    
                !self.series[seriesID]!.contentIDs.contains(contentID) : "That ContentID is already a part of that Series"
            }
            // add this content to the Series specified by the caller
            self.series[seriesID]!.contentIDs.append(contentID)
            
            emit ContentAddedToSeries(contentID: contentID, seriesID: seriesID)
        }

        pub fun addContentToSet(contentID: UInt64, setID: UInt64) {
            pre {
                self.content[contentID] != nil: "Cannot add the ContentEdition to Set: Content doesn't exist"
                self.sets[setID] != nil: "Cannot add ContentEdition to Set: Set doesn't exist"
                self.sets[setID]!.contentEditions[contentID] == nil : "That ContentID is already a part of that Set"
                self.editions[contentID] != nil : "That edition already contains that ContentID"
                !self.retiredSets[setID]!: "Cannot add ContentEdition to Set after it has been Retired"
                
            }
            // add this content to the set to be minted from as a Moment
            let set = self.sets[setID]!
            set.contentEditions[contentID] = 0
            self.sets[setID] = set

            // establish the minting run of this contentID, aka the edition run
            self.editions[contentID]!.append(setID)

            let edition = self.editions[contentID]!.length
            emit ContentAddedToSet(contentID: contentID, setID: setID, contentEdition: UInt64(edition))
        }

        ////// MINT //////

        // mintMoment
        //
        pub fun mintMoment(contentID: UInt64, setID: UInt64, seriesID: UInt64): @NFT {
            pre {
                self.content[contentID] != nil: "Cannot mint Moment: This Content doesn't exist."
                self.sets[setID] != nil: "Cannot mint Moment from this Set: This Set does not exist."
                self.sets[setID]!.contentEditions[contentID] != nil : "Cannot mint from this Set: it has no Edition of that Content to Mint from"
                !self.retiredSets[setID]!: "Cannot mint Moment from this Set: This Set has been retired."
                self.series[seriesID] != nil: "Cannot mint Moment from this Series: the Series does not exist"    
                self.series[seriesID]!.contentIDs.contains(contentID) : "Cannot mint Moment from this Series: the Series does not contain this Content"
            }
            // get the set from which this is being minted
            let set = self.sets[setID]!
            // get the edition and serial number
            let edition = self.editions[setID]!.length
            // increment the run of this content in the set itself
            set.contentEditions[contentID] = set.contentEditions[contentID]! + (1 as UInt64)
            let serialNumber = set.contentEditions[contentID]!
            

            // Mint the new moment
            let newMoment: @NFT <- create NFT(contentID: contentID,
                                              setID: setID,
                                              seriesID: seriesID,
                                              contentEdition: UInt64(edition),
                                              serialNumber: serialNumber)
            // replace this set with the updated version that knows this was just minted
            self.sets[setID] = set
            // get the other data it takes to create am oment
            let contentMetadata = self.content[contentID]!
            let seriesMetadata = self.series[seriesID]!

            let moment = MomentMetadata(
                id: newMoment.id,
                serialNumber: newMoment.serialNumber,
                contentID: newMoment.contentID,
                contentEdition: newMoment.contentEdition,
                name: contentMetadata.name,
                description: contentMetadata.description,
                setID: newMoment.setID,
                setName: set.name,
                seriesID: seriesID,
                seriesName: seriesMetadata.name,
                mediaType: contentMetadata.mediaType,
                mediaHash: contentMetadata.mediaHash,
                mediaURI: contentMetadata.mediaURI,
                complete: false,
                run: 0
            )
            // we use a 0 run here because the "currentRun" is already indicated
            // by the serialNumber. only fill out 'run' when it is 'complete'
            
            // store a metadata copy to lookup later
            self.moments[newMoment.id] = moment
            return <- newMoment
        }

        // batchMintMoment
        //
        pub fun batchMintMoment(contentID: UInt64, setID: UInt64, seriesID: UInt64, quantity: UInt64): @Collection {
            let newCollection <- create Collection()

            var i: UInt64 = 0
            while i < quantity {
                newCollection.deposit(token: <-self.mintMoment(contentID: contentID, setID: setID, seriesID: seriesID))
                i = i + (1 as UInt64)
            }

            return <- newCollection
        }

        ////// UPDATE & RETIRE //////

        // updateContentMetadata
        // NOTE: we allow the content to be updated in case host changes
        // PRE: must exist, thus cannot bypass creation route
        pub fun updateContentMetadata(content: ContentMetadata) {     
            pre {
                self.content[content.id] != nil: "Cannot update that Content, it doesn't exist!"
            }
            self.content[content.id] = content

            emit ContentUpdated(contentID: content.id)
        }
        // retireSet
        //
        pub fun retireSet(setID: UInt64) {
            pre {
                self.sets[setID] != nil: "Cannot retire that Set, it doesn't exist!"
                !self.retiredSets[setID]!: "Cannot retire that Set, it already is retired!"
            }
            self.retiredSets[setID] = true
            emit SetRetired(setID:setID)
        }

        ////// ADMIN FUNCS //////
        
        // attribute
        //
        access(contract) fun attribute(creator: Address, momentID: UInt64) {
            pre {
                self.creators[creator] != nil : "That creator is unregistered"
                self.moments[momentID] != nil : "That moment does not exist"
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
        
        //////// GETTERS AND SUGAR ////////
        
        // getMomentMetadata
        // - Adds complete & run to existing Metadata if the Set is retired
        //
        pub fun getMomentMetadata(momentID: UInt64): MomentMetadata {
            pre {
                self.moments[momentID] != nil : "That momentID has no metadata associated with it"
            }
            
            var moment = self.moments[momentID]!
            
            if (self.retiredSets[moment.setID]!) {
                let set = self.sets[moment.setID]!
                let run = set.contentEditions[moment.contentID]!
                moment.complete = true
                moment.run = run
            }

            return moment
        }
        pub fun getContentMetadata(contentID: UInt64): ContentMetadata {
            pre {
                self.content[contentID] != nil : "That contentID has no metadata associated with it"
            }
            return self.content[contentID]!
        }
        // responds with an array of SetID's that content can be found
        pub fun getContentEditions(contentID: UInt64): [UInt64] {
            pre {
                self.editions[contentID] != nil : "There are no editions of that content"
            }
            return self.editions[contentID]!
        }
        pub fun getSetMetadata(setID: UInt64): SetMetadata {
            pre {
                self.sets[setID] != nil : "That setID has no metadata associated with it"
            }
            return self.sets[setID]!
        }
        pub fun getSeriesMetadata(seriesID: UInt64): SeriesMetadata {
            pre {
                self.series[seriesID] != nil : "That seriesID has no metadata associated with it"
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
        // The ID of the Content that the Moment references
        pub let contentID: UInt64
        // the edition of the content this Moment references
        pub let contentEdition: UInt64
        // The ID of the Set that the Moment comes from
        pub let setID: UInt64
        // The ID of the Series that the Moment comes from
        pub let seriesID: UInt64 
        // The place in the Edition that this Moment was minted
        pub let serialNumber: UInt64

        init(contentID: UInt64, setID: UInt64, seriesID: UInt64, contentEdition: UInt64, serialNumber: UInt64) {
            Moments.totalSupply = Moments.totalSupply + (1 as UInt64)
            self.id = Moments.totalSupply
            
            self.contentID = contentID
            self.setID = setID
            self.seriesID = seriesID
            self.contentEdition = contentEdition
            self.serialNumber = serialNumber

            emit MomentMinted(momentID: self.id, contentID: self.contentID, setID: self.setID, seriesID: self.seriesID, contentEdition: self.contentEdition, serialNumber: self.serialNumber)
        }

        // sugar func
        pub fun getMetadata(): MomentMetadata {
            return Moments.getContentCreator().getMomentMetadata(momentID: self.id)
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
        access(self) let creators: {Address: Bool}

        init () {
            self.creators = {}
        }

        // registerCreator
        //   - registers a new account's CC Proxy
        //   - does not allow re-registration
        //
        pub fun registerCreator(address: Address, cc: Capability<&Moments.ContentCreator>) { 
            pre {
                getAccount(address).getCapability<&{Moments.CreatorProxyPublic}>(Moments.CreatorProxyPublicPath).check() : "Creator account does not have a valid Proxy"
                self.creators[address] == nil : "That creator has already been registered"
                cc.check(): "that contentcreator is invalid"
            }
            let pCap = getAccount(address).getCapability<&{Moments.CreatorProxyPublic}>(Moments.CreatorProxyPublicPath)
            let proxy = pCap.borrow() ?? panic("failed to borrow the creator's proxy")
            self.creators[address] = true // don't break the rules
            // this will register the proxy with the ContentCreator
            // and that will emit the registration event
            proxy.empowerCreatorProxy(cc)
        }

        // revokeProxy
        //  - revoke's a proxy's ability to borrow its CC cap
        //
        pub fun revokeCreator(address: Address) {
            pre {
                self.creators[address] != nil : "That creator has never been registered"
                self.creators[address]! : "That creator has already been revoked"
            }
            self.creators[address] = false

            emit CreatorRevoked(creator: address)
        }

        // reinstateCreator
        //  - hopefully this never needs to be called :)
        //
        pub fun reinstateCreator(address: Address) {
            pre {
                self.creators[address] != nil : "That creator has never been registered"
                !self.creators[address]! : "That creator has already been reinstated"
            }
            self.creators[address] = true
            
            emit CreatorReinstated(creator: address)
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

        // attributeCreator
        //   - specify what address was involved in creating a given moment 
        //
        pub fun attributeCreator(address: Address, momentID: UInt64) {
            pre {
                self.creators[address] != nil: "That creator has never been registered"
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

    // getContentCreator
    //   - easy route to the CC public path
    //
    pub fun getContentCreator(): &{Moments.ContentCreatorPublic} {
        let publicContent = Moments.account.getCapability<&{Moments.ContentCreatorPublic}>(Moments.ContentCreatorPublicPath).borrow() 
            ?? panic("Could not get the public content from the contract")
        return publicContent
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
 
