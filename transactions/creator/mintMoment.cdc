import NonFungibleToken from "../../contracts/standard/NonFungibleToken.cdc"
import Moments from "../../contracts/Moments.cdc"

transaction(contentID: UInt64, setID: UInt64, seriesID: UInt64) {
    prepare(signer: AuthAccount) {
        let proxy = signer.borrow<&Moments.CreatorProxy>(from: Moments.CreatorProxyStoragePath)
            ?? panic("cannot get a valid creatorproxy resource for the signer")
        let receiver = signer.borrow<&{Moments.CollectionPublic}>(from: Moments.CollectionStoragePath)
            ?? panic("Cannot get a reference to the signer's Public Moments Collection")

        let creator = proxy.borrowContentCreator()!
        
        receiver.deposit(token: <- creator.mintMoment(contentID: contentID, setID: setID, seriesID: seriesID))
    }
}