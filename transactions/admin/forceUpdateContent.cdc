import NonFungibleToken from "../../contracts/standard/NonFungibleToken.cdc"
import Moments from "../../contracts/Moments.cdc"

// this tx is a bit lame, hacked so that CLI can use it, credits are always empty right now too
// dicts cant be used in CLI, but the apps can use this
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
                previewImage: contentMetadata[3], 
                videoURI: contentMetadata[4], 
                videoHash: contentMetadata[5])

        let admin = adminProxy.borrowSudo()
        admin.updateContentMetadata(content:content)
    }
}