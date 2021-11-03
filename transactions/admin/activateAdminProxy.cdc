import NonFungibleToken from "../../contracts/standard/NonFungibleToken.cdc"
import Moments from "../../contracts/Moments.cdc"

transaction(proxy: Address) {
    prepare(admin: AuthAccount) {
        let proxyAcct = getAccount(proxy)
        let client = proxyAcct.getCapability<&Moments.AdminProxy{Moments.AdminProxyPublic}>(Moments.AdminProxyPublicPath)
            .borrow()!
        let adminCap = admin.getCapability<&Moments.Administrator>(Moments.AdministratorPrivatePath)
        
        client.addCapability(adminCap)
    }
}
