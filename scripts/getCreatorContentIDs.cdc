import NonFungibleToken from "../contracts/standard/NonFungibleToken.cdc"
import Moments from "../contracts/Moments.cdc"

pub fun main(creator: Address): [UInt64] {
    let cc = Moments.getContentCreator()
   
    return cc.getCreatorAttributions(address: creator)
}
