import NonFungibleToken from "../../contracts/standard/NonFungibleToken.cdc"
import Moments from "../../contracts/Moments.cdc"

transaction(proxy: Address) {
    prepare(admin: AuthAccount) {
        let proxyAcct = getAccount(proxy)
        let client = proxyAcct.getCapability<&{Moments.CreatorProxyPublic}>(Moments.CreatorProxyPublicPath)
            .borrow()!
        let ccCap = admin.getCapability<&Moments.ContentCreator>(Moments.ContentCreatorPrivatePath)
        client.registerCreatorProxy(ccCap)
        let adminProxy = admin.getCapability<&Moments.Administrator>(Moments.AdministratorPrivatePath)!.borrow()!
        adminProxy.registerCreator(address:proxy)
    }
}
