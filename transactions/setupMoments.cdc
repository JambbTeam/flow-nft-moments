import NonFungibleToken from "../contracts/standard/NonFungibleToken.cdc"
import Moments from "../contracts/Moments.cdc"

transaction {

    prepare(signer: AuthAccount) {
        if signer.borrow<&Moments.Collection>(from: Moments.CollectionStoragePath) == nil {

            let collection <- Moments.createEmptyCollection() as! @Moments.Collection

            signer.save(<-collection, to: Moments.CollectionStoragePath)

            signer.link<&{Moments.CollectionPublic}>(
                Moments.CollectionPublicPath,
                target: Moments.CollectionStoragePath)
            }
    }
}
