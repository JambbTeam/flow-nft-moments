import NonFungibleToken from "../../contracts/standard/NonFungibleToken.cdc"
import Moments from "../../contracts/Moments.cdc"

transaction(contentID: UInt64, contentMetadata: [String], credits: {String:String}) {
    prepare(signer: AuthAccount) {
        let ccProxy = signer.borrow<&Moments.CreatorProxy>(from: Moments.CreatorProxyStoragePath)
            ?? panic("cannot get a valid creatorproxy resource for the signer")
        
        let creator = ccProxy.borrowContentCreator()
        let oldContent = creator.getContentMetadata(contentID: contentID)
        // NOTE: we pass id: 0 because we don't know what ID this content will have until it has been successfully
        // added, so it will be replaced by the contract's contentcreator
        let content = Moments.ContentMetadata(
                id: contentID, 
                name: contentMetadata[0], 
                description: contentMetadata[1], 
                source: contentMetadata[2],
                creator: oldContent.creator,
                credits: credits,
                previewImage: contentMetadata[3], 
                videoURI: contentMetadata[4], 
                videoHash: contentMetadata[5])

        creator.updateContentMetadata(content: content, creatorProxy: ccProxy)
    }
}