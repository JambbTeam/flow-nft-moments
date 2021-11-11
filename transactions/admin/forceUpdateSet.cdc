import NonFungibleToken from "../../contracts/standard/NonFungibleToken.cdc"
import Moments from "../../contracts/Moments.cdc"

transaction(setID: UInt64, name: String, art: String, description: String) {
    prepare(signer: AuthAccount) {
        let ccProxy = signer.borrow<&Moments.CreatorProxy>(from: Moments.CreatorProxyStoragePath)
            ?? panic("cannot get a valid creatorproxy resource for the signer")
        let adminProxy = signer.borrow<&Moments.AdminProxy>(from: Moments.AdminProxyStoragePath)
            ?? panic("cannot get a valid creatorproxy resource for the signer")
        
        let creator = ccProxy.borrowContentCreator()
        let oldSet = creator.getSetMetadata(setID: setID)
        let set = Moments.SetMetadata(
                id: setID,
                name: name,
                description: description,
                rarityCaps: oldSet.rarityCaps,
                art: art)
        // set the vars too
        set.contentEditions = oldSet.contentEditions
        set.retired = oldSet.retired

        let admin = adminProxy.borrowSudo()
        admin.updateSetMetadata(set: set)
    }
}