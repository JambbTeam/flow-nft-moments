import NonFungibleToken from "../contracts/standard/NonFungibleToken.cdc"
import Moments from "../contracts/Moments.cdc"

transaction {

    prepare(signer: AuthAccount) {
        if signer.borrow<&Moments.Collection>(from: Moments.CollectionStoragePath) == nil {

            let collection <- Moments.createEmptyCollection() as! @Moments.Collection

            signer.save(<-collection, to: Moments.CollectionStoragePath)

            /*This allows somebody else to make a contract that implements Moments.CollectionPublic and then they can unlink this and relink to theirs, 
            signer.link<&{Moments.CollectionPublic, NonFungibleToken.Receiver}>(
                Moments.CollectionPublicPath,
                target: Moments.CollectionStoragePath)

            */
            //this is very safe, it says it has to be a Moments.Collection and it has to export the two interfaces
             signer.link<&Moments.Collection{Moments.CollectionPublic, NonFungibleToken.Receiver}>(
                Moments.CollectionPublicPath,
                target: Moments.CollectionStoragePath)

        }
    }
}
