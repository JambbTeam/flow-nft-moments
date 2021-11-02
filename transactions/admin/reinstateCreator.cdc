import NonFungibleToken from "../../contracts/standard/NonFungibleToken.cdc"
import Moments from "../../contracts/Moments.cdc"

transaction(creator: Address) {
    prepare(admin: AuthAccount) {
        let administrator = admin.borrow<&Moments.Administrator>(from: Moments.AdministratorStoragePath)
            ?? panic("That user is not the Administrator of this contract, and we've told the authorities on you.")
        let ccCap = admin.getCapability<&Moments.ContentCreator>(Moments.ContentCreatorPrivatePath)

        administrator.reinstateCreator(address: creator)
    }
}
