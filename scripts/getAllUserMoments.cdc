import NonFungibleToken from "../contracts/standard/NonFungibleToken.cdc"
import Moments from "../contracts/Moments.cdc"

pub fun main(address: Address): {UInt64: Moments.Metadata} {
    let collectionRef = getAccount(address).getCapability(Moments.CollectionPublicPath)
        .borrow<&{Moments.CollectionPublic}>()
        ?? panic("Could not borrow CollectionPublic capability")

    let ids = collectionRef.getIDs()
   
    var moments: {UInt64: Moments.Metadata} = {}
    for id in ids {
        let moment = collectionRef.borrowMoment(id: id)
            ?? panic("Could not find that Moment in your Collection")
        let metadata = moment.getMetadata()!
        moments[id] = metadata
    }
    return moments
}
