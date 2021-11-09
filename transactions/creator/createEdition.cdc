import NonFungibleToken from "../../contracts/standard/NonFungibleToken.cdc"
import Moments from "../../contracts/Moments.cdc"

transaction(contentMetadata: [String], credits: {String:String}, seriesID: UInt64, setID: UInt64) {
    prepare(signer: AuthAccount) {
        let proxy = signer.borrow<&Moments.CreatorProxy>(from: Moments.CreatorProxyStoragePath)
            ?? panic("cannot get a valid creatorproxy resource for the signer")
        
        let creator = proxy.borrowContentCreator()
        
        // NOTE: we pass id: 0 because we don't know what ID this content will have until it has been successfully
        // added, so it will be replaced by the contract's contentcreator
        let content = Moments.ContentMetadata(
                id: 0, 
                name: contentMetadata[0], 
                description: contentMetadata[1], 
                source: contentMetadata[2],
                creator: signer.address,
                credits: credits,
                previewImage: contentMetadata[3], 
                videoURI: contentMetadata[4], 
                videoHash: contentMetadata[5])

        let contentID = creator.createContent(content: content, creator: proxy)

        creator.addContentToSeries(contentID: contentID, seriesID: seriesID)
        creator.addContentToSet(contentID: contentID, setID: setID)
        // now you can mint
        // mintMoment <contentID> <seriesID> <setID>
    }
}