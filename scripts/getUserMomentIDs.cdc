import NonFungibleToken from "../contracts/standard/NonFungibleToken.cdc"
import Moments from "../contracts/Moments.cdc"

pub fun main(address: Address): [UInt64] {
    let collectionRef = getAccount(address).getCapability(Moments.CollectionPublicPath)
        .borrow<&{Moments.CollectionPublic}>()
        ?? panic("Could not borrow CollectionPublic capability")

    return collectionRef.getIDs()
}
