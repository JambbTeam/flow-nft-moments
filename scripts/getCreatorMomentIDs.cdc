import NonFungibleToken from "../contracts/standard/NonFungibleToken.cdc"
import Moments from "../contracts/Moments.cdc"

pub fun main(creator: Address, ccAddress: Address): [UInt64] {
    let cc = getAccount(ccAddress).getCapability<&{Moments.ContentCreatorPublic}>(Moments.ContentCreatorPublicPath)
        .borrow() ?? panic("Could not borrow ContentCreatorPublic capability")
   
    return cc.getCreatorAttributions(address: creator)
}
