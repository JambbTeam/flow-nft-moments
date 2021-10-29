import NonFungibleToken from "../../contracts/standard/NonFungibleToken.cdc"
import Moments from "../../contracts/Moments.cdc"

transaction(creator: Address, momentID: UInt64) {
    prepare(admin: AuthAccount) {
        let admin = admin.borrow<&Moments.Administrator>(from: Moments.AdministratorStoragePath)
            ?? panic("That user is not the Administrator of this contract, and we've told the authorities on you.")
        admin.attributeCreator(address: creator, momentID: momentID)
    }
}
