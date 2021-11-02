import NonFungibleToken from "../contracts/standard/NonFungibleToken.cdc"
import Moments from "../contracts/Moments.cdc"

pub fun main(address: Address): [Moments.MomentMetadata] {
    let collectionRef = getAccount(address).getCapability<&{Moments.CollectionPublic}>(Moments.CollectionPublicPath)
        .borrow() ?? panic("Could not borrow CollectionPublic capability")

    let ids = collectionRef.getIDs()
   
    var moments:[Moments.MomentMetadata] = []
    for id in ids {
        let metadata = Moments.getContentCreator().getMomentMetadata(momentID:id)!
        moments.append(metadata)
    }
    return moments
}
