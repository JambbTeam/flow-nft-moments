import NonFungibleToken from "../contracts/standard/NonFungibleToken.cdc"
import Moments from "../contracts/Moments.cdc"

pub fun main(address: Address, momentID: UInt64): Bool {
    let nft = Moments.fetch(address, momentID: momentID)
    if (nft == nil) {
        return false
    }
    return true
}
