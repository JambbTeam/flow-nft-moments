import NonFungibleToken from "../../contracts/standard/NonFungibleToken.cdc"
import Moments from "../../contracts/Moments.cdc"

// in practice, art and description are optional, but CLI will require a value :)
transaction(name: String, art: String, description: String) {
    prepare(signer: AuthAccount) {
        let proxy = signer.borrow<&Moments.CreatorProxy>(from: Moments.CreatorProxyStoragePath)
            ?? panic("cannot get a valid creatorproxy resource for the signer")
        
        let creator = proxy.borrowContentCreator()
        let rarityCaps: {String: UInt64} = {}
        // update to take from args!
        rarityCaps["Common"] = 10000
        rarityCaps["Uncommon"] = 2500
        rarityCaps["Rare"] = 500
        rarityCaps["Legendary"] = 100
        rarityCaps["Exclusive"] = 1

        creator.createSet(name: name, art: art, description: description, rarityCaps: rarityCaps)
    }
}