import NonFungibleToken from "../contracts/standard/NonFungibleToken.cdc"
import Moments from "../contracts/Moments.cdc"

pub fun main(momentIDs: [UInt64]): [Moments.MomentMetadata] {
    let cc = Moments.getContentCreator()
    var moments:[Moments.MomentMetadata] = []
    for id in momentIDs {
        let metadata = cc.getMomentMetadata(momentID:id)!
        moments.append(metadata)
    }
    return moments
}
