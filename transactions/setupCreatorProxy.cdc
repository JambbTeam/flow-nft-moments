import NonFungibleToken from "../contracts/standard/NonFungibleToken.cdc"
import Moments from "../contracts/Moments.cdc"

transaction {

    prepare(signer: AuthAccount) {
        if signer.borrow<&Moments.CreatorProxy>(from: Moments.CreatorProxyStoragePath) == nil {
            // maybe dont do this by default haha but its harmless mostly
            let adminProxy <- Moments.createCreatorProxy()

            signer.save(<-adminProxy, to: Moments.CreatorProxyStoragePath)

            // link receiver for admin to activate me as a proxy
            signer.link<&{Moments.CreatorProxyPublic}>(
                Moments.CreatorProxyPublicPath, 
                target: Moments.CreatorProxyStoragePath)
        }
    }
}
