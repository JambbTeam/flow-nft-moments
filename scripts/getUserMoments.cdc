import NonFungibleToken from "../contracts/standard/NonFungibleToken.cdc"
import Moments from "../contracts/Moments.cdc"

pub fun main(address: Address, momentIDs: [UInt64]): [Moments.MomentMetadata] {
    let collectionRef = getAccount(address).getCapability<&Moments.Collection{Moments.CollectionPublic}>(Moments.CollectionPublicPath)
        .borrow() ?? panic("Could not borrow CollectionPublic capability")
   
    var moments:[Moments.MomentMetadata] = []
    for id in momentIDs {
        let moment = collectionRef.borrowMoment(id: id)!
        let metadata = moment.getMomentMetadata()
        moments.append(metadata)
    }
    return moments
}
