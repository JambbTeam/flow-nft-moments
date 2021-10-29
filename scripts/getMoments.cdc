import NonFungibleToken from "../contracts/standard/NonFungibleToken.cdc"
import Moments from "../contracts/Moments.cdc"

pub fun main(momentIDs: [UInt64]): [Moments.MomentMetadata] {
    var moments:[Moments.MomentMetadata] = []
    for id in momentIDs {
        let metadata = Moments.getMomentMetadata(momentID:id)!
        moments.append(metadata)
    }
    return moments
}
