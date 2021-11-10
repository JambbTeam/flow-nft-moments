import NonFungibleToken from "../../contracts/standard/NonFungibleToken.cdc"
import Moments from "../../contracts/Moments.cdc"

transaction(seriesID: UInt64, name: String, description: String, art: String?) {
    prepare(signer: AuthAccount) {
        let ccProxy = signer.borrow<&Moments.CreatorProxy>(from: Moments.CreatorProxyStoragePath)
            ?? panic("cannot get a valid creatorproxy resource for the signer")
        let adminProxy = signer.borrow<&Moments.AdminProxy>(from: Moments.AdminProxyStoragePath)
            ?? panic("cannot get a valid creatorproxy resource for the signer")
        
        let creator = ccProxy.borrowContentCreator()
        let oldSeries = creator.getSeriesMetadata(seriesID: seriesID)
        let series = Moments.SeriesMetadata(
                id: seriesID,
                name: name,
                description: description,
                art: art)
        
        // set the vars too
        series.contentIDs = oldSeries.contentIDs

        let admin = adminProxy.borrowSudo()
        admin.updateSeriesMetadata(series: series)
    }
}