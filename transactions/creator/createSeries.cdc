import NonFungibleToken from "../../contracts/standard/NonFungibleToken.cdc"
import Moments from "../../contracts/Moments.cdc"

// in practice, art and description are optional, but CLI will require a value :)
transaction(name: String, description: String, art: String?) {
    prepare(signer: AuthAccount) {
        let proxy = signer.borrow<&Moments.CreatorProxy>(from: Moments.CreatorProxyStoragePath)
            ?? panic("cannot get a valid creatorproxy resource for the signer")
        
        let creator = proxy.borrowContentCreator()
        
        creator.createSeries(name: name, description: description, art: art)
    }
}