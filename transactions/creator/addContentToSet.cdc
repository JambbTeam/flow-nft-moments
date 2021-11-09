import NonFungibleToken from "../../contracts/standard/NonFungibleToken.cdc"
import Moments from "../../contracts/Moments.cdc"

transaction(contentID: UInt64, setID: UInt64, rarity: String) {
    prepare(signer: AuthAccount) {
        let proxy = signer.borrow<&Moments.CreatorProxy>(from: Moments.CreatorProxyStoragePath)
            ?? panic("cannot get a valid creatorproxy resource for the signer")
        
        let creator = proxy.borrowContentCreator()

        creator.addContentToSet(contentID: contentID, setID: setID, rarity: rarity)
    }
}