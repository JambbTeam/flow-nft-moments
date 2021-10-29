import NonFungibleToken from "../../contracts/standard/NonFungibleToken.cdc"
import Moments from "../../contracts/Moments.cdc"

transaction(proxy: Address) {
    prepare(admin: AuthAccount) {
        let proxyAcct = getAccount(proxy)
        let ccCap = admin.getCapability<&Moments.ContentCreator>(Moments.ContentCreatorPrivatePath)
        let adminProxy = admin.getCapability<&Moments.Administrator>(Moments.AdministratorPrivatePath)!.borrow()!
        
        adminProxy.registerCreator(address:proxy, cc: ccCap)
    }
}
