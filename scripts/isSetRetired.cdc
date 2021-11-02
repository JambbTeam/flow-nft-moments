import NonFungibleToken from "../contracts/standard/NonFungibleToken.cdc"
import Moments from "../contracts/Moments.cdc"

// must specify revoker resource address to perform this lookup
pub fun main(setId: UInt64): Bool {
    let cc = Moments.getContentCreator()

    return cc.isSetRetired(setID: setId)
}
