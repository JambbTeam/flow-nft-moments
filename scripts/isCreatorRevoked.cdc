import NonFungibleToken from "../contracts/standard/NonFungibleToken.cdc"
import Moments from "../contracts/Moments.cdc"

// must specify revoker resource address to perform this lookup
pub fun main(creator: Address, revokerAddr: Address): Bool {
    let revoker = getAccount(revokerAddr).getCapability<&Moments.Administrator{Moments.Revoker}>(Moments.RevokerPublicPath).borrow()
        ?? panic("Cannot find the revoker, contract may be deprecated")

    return revoker.revoked(address: creator)
}
