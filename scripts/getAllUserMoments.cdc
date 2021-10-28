import NonFungibleToken from "../contracts/standard/NonFungibleToken.cdc"
import Moments from "../contracts/Moments.cdc"

pub fun main(address: Address): [MomentMetadata] {
    let collectionRef = getAccount(address).getCapability(Moments.CollectionPublicPath)
        .borrow<&{Moments.CollectionPublic}>()
        ?? panic("Could not borrow CollectionPublic capability")

    let ids = collectionRef.getIDs()
   
    var moments = []
    for id in ids {
        let publicContent = Moments.account.getCapability<&{Moments.ContentCreatorPublic}>(Moments.ContentCreatorPublicPath)
            ?? panic("Could not get the public content from the contract")
        let moment = collectionRef.borrowMoment(id: id)
            ?? panic("Could not find that Moment in your Collection")
        let metadata = Moments.getMomentMetadata(address, id)!

        moments.append(metadata)
    }
    return moments
}
