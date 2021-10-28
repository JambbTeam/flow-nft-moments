import NonFungibleToken from "../contracts/standard/NonFungibleToken.cdc"
import Moments from "../contracts/Moments.cdc"

pub fun main(creator: Address): Bool {
    let revoker = admin.borrow<&{Moments.Revoker}>(Moments.RevokerPublicPath)
        ?? panic("Cannot find the revoker, contract may be deprecated")

    return revoker.revoked(address: creator)
}
