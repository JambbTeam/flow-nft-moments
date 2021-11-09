import NonFungibleToken from "../contracts/standard/NonFungibleToken.cdc"
import Moments from "../contracts/Moments.cdc"

pub fun main(creator: Address): [UInt64] {
    let moments:[UInt64] = []
    let cc = Moments.getContentCreator()
   
    let attributions = cc.getCreatorAttributions(address: creator)
    for contentID in attributions {
        let contentEditions = cc.getContentEditions(contentID: contentID)
        for setID in contentEditions {
            let set = cc.getSetMetadata(setID: setID)
            if (set.contentEditions.containsKey(contentID)) {
                let ceMoments = set.contentEditions[contentID]!.moments
                for mID in ceMoments {
                    moments.append(mID)
                }
            }
        }
    }
    return moments
}
