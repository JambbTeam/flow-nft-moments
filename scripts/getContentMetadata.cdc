import NonFungibleToken from "../contracts/standard/NonFungibleToken.cdc"
import Moments from "../contracts/Moments.cdc"

// must specify revoker resource address to perform this lookup
pub fun main(contentID: UInt64): Moments.ContentMetadata {
    let cc = Moments.getContentCreator()

    return cc.getContentMetadata(contentID: contentID)
}
