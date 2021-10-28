import NonFungibleToken from "../contracts/standard/NonFungibleToken.cdc"
import Moments from "../contracts/Moments.cdc"

pub fun main(address: Address, momentIDs: [UInt64]): [Moments.MomentMetadata] {
    let collectionRef = getAccount(address).getCapability<&{Moments.CollectionPublic}>(Moments.CollectionPublicPath)
        .borrow() ?? panic("Could not borrow CollectionPublic capability")
   
    var moments:[Moments.MomentMetadata] = []
    for id in momentIDs {
        let metadata = Moments.getMomentMetadata(address, momentID:id)!
        moments.append(metadata)
    }
    return moments
}
