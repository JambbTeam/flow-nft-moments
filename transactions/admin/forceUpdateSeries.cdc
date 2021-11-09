import NonFungibleToken from "../../contracts/standard/NonFungibleToken.cdc"
import Moments from "../../contracts/Moments.cdc"

transaction(seriesID: UInt64, name: String, art: String, description: String) {
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
                art: art,
                description: description)
        
        // set the vars too
        set.contentIDs = oldSeries.contentIDs

        let admin = adminProxy.borrowSudo()
        admin.updateSeriesMetadata(series: series)
    }
}