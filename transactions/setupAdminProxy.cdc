import NonFungibleToken from "../contracts/standard/NonFungibleToken.cdc"
import Moments from "../contracts/Moments.cdc"

transaction {

    prepare(signer: AuthAccount) {
        if signer.borrow<&Moments.AdminProxy>(from: Moments.AdminProxyStoragePath) == nil {
            // maybe dont do this by default haha but its harmless mostly
            let adminProxy <- Moments.createAdminProxy()

            signer.save(<-adminProxy, to: Moments.AdminProxyStoragePath)

            // link receiver for admin to activate me as a proxy
            signer.link<&Moments.AdminProxy{Moments.AdminProxyPublic}>(
                Moments.AdminProxyPublicPath, 
                target: Moments.AdminProxyStoragePath)
        }
    }
}
