import NonFungibleToken from "../contracts/standard/NonFungibleToken.cdc"
import Moments from "../contracts/Moments.cdc"

// must specify revoker resource address to perform this lookup
pub fun main(seriesID: UInt64): Moments.SeriesMetadata {
    let cc = Moments.getContentCreator()

    return cc.getSeriesMetadata(seriesID: seriesID)
}
