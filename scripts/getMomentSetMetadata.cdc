import NonFungibleToken from "../contracts/standard/NonFungibleToken.cdc"
import Moments from "../contracts/Moments.cdc"

// DISCLAIMER :: STRUCTS DONT WORK FROM CLI
// ONLY WORKS IN FCL
pub struct SharedMomentMetadata { 
    pub let ids: [UInt64]
    pub let metadata: Moments.Metadata
    init(ids: [UInt64], metadata: Moments.Metadata) {
       self.ids = ids
       self.metadata = metadata
    }
}

pub fun main(address: String): SharedMomentMetadata {
    let collectionRef = getAccount(Address.parseAddress(address)).getCapability(Moments.CollectionPublicPath)
        .borrow<&{Moments.CollectionPublic}>()
        ?? panic("Could not borrow CollectionPublic capability")

    let ids = collectionRef.getIDs()
    let sharedMetadata = SharedMomentMetadata(ids: ids, metadata: collectionRef.borrowMoment(id: ids[0])!.getMetadata()!)
    
    return sharedMetadata
}
