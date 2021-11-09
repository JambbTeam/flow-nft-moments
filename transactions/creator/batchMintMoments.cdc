import NonFungibleToken from "../../contracts/standard/NonFungibleToken.cdc"
import Moments from "../../contracts/Moments.cdc"

transaction(contentID: UInt64, seriesID: UInt64, setID: UInt64, quantity: UInt64) {
    prepare(signer: AuthAccount) {
        let proxy = signer.borrow<&Moments.CreatorProxy>(from: Moments.CreatorProxyStoragePath)
            ?? panic("cannot get a valid creatorproxy resource for the signer")
        let receiver = signer.borrow<&Moments.Collection{Moments.CollectionPublic}>(from: Moments.CollectionStoragePath)
            ?? panic("Cannot get a reference to the signer's Public Moments Collection")

        let creator = proxy.borrowContentCreator()
        
        let batch <-  <- creator.batchMintMoment(contentID: contentID, seriesID: seriesID, setID: setID, quantity: quantity)
        let newMomentIDs = batch.getIDs()
        for id in newMomentIDs {
            receiver.deposit(token: <- batch.withdraw(withdrawID: id))
        }
        destroy(batch)
    }
}