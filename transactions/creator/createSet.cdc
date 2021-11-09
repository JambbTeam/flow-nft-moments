import NonFungibleToken from "../../contracts/standard/NonFungibleToken.cdc"
import Moments from "../../contracts/Moments.cdc"

// in practice, art and description are optional, but CLI will require a value :)
transaction(name: String, description: String, art: String?, rarityCaps: {String:UInt64}?) {
    prepare(signer: AuthAccount) {
        let proxy = signer.borrow<&Moments.CreatorProxy>(from: Moments.CreatorProxyStoragePath)
            ?? panic("cannot get a valid creatorproxy resource for the signer")
        
        let creator = proxy.borrowContentCreator()
        var myRarityCaps: {String: UInt64} = {}
        if (rarityCaps != nil) {
            myRarityCaps = rarityCaps!
        } else {
            // some defaults for easy testing
            myRarityCaps["Common"] = 10000
            myRarityCaps["Uncommon"] = 2500
            myRarityCaps["Rare"] = 500
            myRarityCaps["Legendary"] = 100
            myRarityCaps["Exclusive"] = 1
        }

        creator.createSet(name: name, description: description, art: art, rarityCaps: myRarityCaps)
    }
}