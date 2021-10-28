import NonFungibleToken from "../contracts/standard/NonFungibleToken.cdc"
import Moments from "../contracts/Moments.cdc"

pub fun main(address: Address, momentID: UInt64): Moments.Metadata? {
    let collectionRef = getAccount(address).getCapability(Moments.CollectionPublicPath)
        .borrow<&{Moments.CollectionPublic}>()
        ?? panic("Could not borrow CollectionPublic capability")

    let ids = collectionRef.getIDs()
    let moment = collectionRef.borrowMoment(id: ids[momentID])
        ?? panic("Could not find that Moment in your Collection")

    return moment.getMetadata()
}
