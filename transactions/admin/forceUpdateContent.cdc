import NonFungibleToken from "../../contracts/standard/NonFungibleToken.cdc"
import Moments from "../../contracts/Moments.cdc"

transaction(contentID: UInt64, contentMetadata: [String], credits: {String:String}) {
    prepare(signer: AuthAccount) {
        let ccProxy = signer.borrow<&Moments.CreatorProxy>(from: Moments.CreatorProxyStoragePath)
            ?? panic("cannot get a valid creatorproxy resource for the signer")
        let adminProxy = signer.borrow<&Moments.AdminProxy>(from: Moments.AdminProxyStoragePath)
            ?? panic("cannot get a valid creatorproxy resource for the signer")
        
        let creator = ccProxy.borrowContentCreator()
        let oldContent = creator.getContentMetadata(contentID: contentID)
        let content = Moments.ContentMetadata(
                id: contentID, 
                name: contentMetadata[0], 
                description: contentMetadata[1], 
                source: contentMetadata[2],
                creator: oldContent.creator,
                credits: credits,
                mediaType: contentMetadata[3], 
                mediaHash: contentMetadata[4], 
                mediaURI: contentMetadata[5],
                previewImage: contentMetadata[6])

        let admin = adminProxy.borrowSudo()!
        admin.updateContentMetadata(content:content)
    }
}