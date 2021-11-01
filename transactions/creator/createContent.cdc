import NonFungibleToken from "../../contracts/standard/NonFungibleToken.cdc"
import Moments from "../../contracts/Moments.cdc"

transaction(contentMetadata: [String]) {
    prepare(signer: AuthAccount) {
        let proxy = signer.borrow<&Moments.CreatorProxy>(from: Moments.CreatorProxyStoragePath)
            ?? panic("cannot get a valid creatorproxy resource for the signer")
        
        let creator = proxy.borrowContentCreator()
        
        // NOTE: we pass id: 0 because we don't know what ID this content will have until it has been successfully
        // added, so it will be replaced by the contract's contentcreator
        let content = Moments.ContentMetadata(id: 0, name: contentMetadata[0], description: contentMetadata[1], source: contentMetadata[2],
                mediaType: contentMetadata[3], mediaHash: contentMetadata[4], mediaURI: contentMetadata[5])

        creator.createContent(content: content)
    }
}