import NonFungibleToken from "../../contracts/standard/NonFungibleToken.cdc"
import Moments from "../../contracts/Moments.cdc"

transaction(contentMetadata: [String]) {
    prepare(signer: AuthAccount) {
        let proxy = signer.borrow<&Moments.CreatorProxy>(from: Moments.CreatorProxyStoragePath)
            ?? panic("cannot get a valid creatorproxy resource for the signer")
        
        let creator = proxy.borrowContentCreator()
        
        let content = Moments.ContentMetadata(name: contentMetadata[0], description: contentMetadata[1], source: contentMetadata[2],
                mediaType: contentMetadata[3], mediaHash: contentMetadata[4], mediaURI: contentMetadata[5])

        creator.createContent(content: content)
    }
}