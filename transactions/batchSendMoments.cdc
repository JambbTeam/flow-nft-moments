import NonFungibleToken from "../contracts/standard/NonFungibleToken.cdc"
import Moments from "../contracts/Moments.cdc"

transaction(recipients: [Address], moments: {Address: [UInt64]}) {
    let senderCollection: &Moments.Collection
    let recipientCollections: {Address: &{Moments.CollectionPublic}}
    prepare(signer: AuthAccount) {
        self.recipientCollections = {}
        // get the recipients public account object
        for address in recipients {
            self.recipientCollections[address] = getAccount(address).getCapability(Moments.CollectionPublicPath).borrow<&{Moments.CollectionPublic}>()
                ?? panic("Could not borrow a reference to the recipient's collection")
        }

        // borrow a reference to the signer's NFT collection
        self.senderCollection = signer.borrow<&Moments.Collection>(from: Moments.CollectionStoragePath)
            ?? panic("Could not borrow a reference to the signer's collection")
    }

    execute {
        for address in recipients {
            if (moments[address] != nil) {
                let moments = moments[address] as! [UInt64]
                for reward in moments {
                    self.recipientCollections[address]!.deposit(token: <- self.senderCollection.withdraw(withdrawID: reward))
                }
            }
        }
        for address in recipients {
            if let moments = moments[address] {
                for moment in moments {
                    self.recipientCollections[address]!.deposit(token: <- self.senderCollection.withdraw(withdrawID: moment)) 
                }
            } else {
                panic("Could not get the rewards for an address")
            }
        }
    }
}
 