# Moments.cdc
## A Content Moment Contact

# Implementation Overview
## Moments

**Moments**, as inspired by the popular dapp NBA TopShot, implement an NFT standard that revolves around Content that is served in Moments that are unique members of Sets and Series. Content editions are minted in batches of “Moment” NFT’s, with serial numbers, that share metadata and have a toggleable minting run.

Within the contract, I’ve introduced the concept of a **ContentCreator**, which is a singleton resource in the contract-deployer’s account (akin to the Administrator) and it has taken over the rights to Mint from the Administrator, but with some added tools at its disposal. 

The ContentCreator resource is responsible for _creating and managing the content_ that lives inside of the Moment NFTs. It uses a Proxy (cap/receiver) pattern to grant accounts the ability to operate on behalf of the ContentCreator. Which is to say, grant them the ability to create awesome content. Additionally, the CC is solely capable of updating the Metadata of the Content itself. This power is revocable by the Admin, but is designed to support extensible and updateable content over time rather than over-rotating into purist-decentraland and requiring all NFTs be minted with never-changing data. The vast majority of data is immutable in this contract, but the source **ContentMetadata** will be managed by the CC's to ensure a great viewing experience for their audience! The distribution and control of the NFT’s is still fully non-custodial and ID’s can never be changed, but if say a link goes bad or a creator posts malicious content - those can be updated and fixed on the fly with ease in this contract.

The full process of minting a Moment involves the following steps: 
(Key: italics means its a struct or data, bold means its a resource)
1. A **CreatorProxy** account creates some _Content_ in the contract to be utilized by the NFTs.
2. The **Creator** goes on to create a _Series_ from which that content was from.
3. Then they create the _Set_, in which the _Content_ will be minted as a **Moment** and given a _contentEdition_.

Which is to say... 

_Content_ must be added to both a _Series_ and a _Set_ for it to be mintable as a **Moment**

In the demo laid out below, I create 2 Series, 3 Sets, and add the Content to both, and show what Moments can then be minted accordingly.

### Prior Design
In the original design, we restricted Sets to _specific_ Series, they were dependents, however we have opened up that restriction and made the requirement only that Content be added distinctly to a given Set and Series combination in order to create a ContentEdition from which to mint Moments.

## Testing
Note: Demo tx's written using Emulator accounts in Flow.json
```
# create and setup accounts for the emulator users
flow accounts create --key 685e19937f19ecd33409b8b6762359a96324e08484d55ed320dd0e127d33d6a02e28562e81a4988c8ca75329ad654dcac20d8e27b6981e78ddf3093ea16a98f4 --signer emulator-account;
flow accounts create --key 33afe244905612765db99475dc6c89567c9ea208609b54a5dbb290f8d1d73e5649d327e237125b56204c2d7ab83e8957d48837a8b76005fc13b97f55255209e1 --signer emulator-account;
flow transactions send ./transactions/setupMoments.cdc;
flow transactions send ./transactions/setupMoments.cdc --signer emulator-user;
flow transactions send ./transactions/setupMoments.cdc --signer emulator-creator;
flow transactions send ./transactions/setupAdminProxy.cdc;
flow transactions send ./transactions/setupCreatorProxy.cdc --signer emulator-creator;

# set the emulator as an valid Admin via its Proxy (to test the proxy routes have no issue, these are less easily revoked)
flow transactions send ./transactions/admin/activateAdminProxy.cdc 0xf8d6e0586b0a20c7;


# test the admin proxy by registering a new creator with it, as itself
flow transactions send ./transactions/admin/registerCreator.cdc 0x01cf0e2f2f715450;

# my user is gunna go rogue and i’ll make a mistake, then fix it 
flow transactions send ./transactions/setupCreatorProxy.cdc --signer emulator-user;
flow transactions send ./transactions/admin/registerCreator.cdc 0x179b6b1cb6755e31;


# for the sake of the demo I wont show all the transactions, but let’s assume ole 0x179’er goes hog-wild and makes a bunch of things he should make, lets revoke that
flow transactions send ./transactions/admin/revokeCreator.cdc 0x01cf0e2f2f715450;
# oops we revoked the wrong one, reinstate him and revoke the right one
flow transactions send ./transactions/admin/reinstateCreator.cdc 0x01cf0e2f2f715450;
flow transactions send ./transactions/admin/revokeCreator.cdc 0x179b6b1cb6755e31;
# you can re-run the above tx’s and observe they error, in that those states are already set

# now he cant create
flow transactions send ./transactions/creator/createContent.cdc "[\"one\", \"\", \"\", \"\", \"\", \"\"]" "{}" --signer emulator-user;
# that failed

# now let’s create some content
flow transactions send ./transactions/creator/createContent.cdc "[\"First Content\", \"\", \"\", \"\", \"\", \"\", \"\"]" "{}" --signer emulator-creator;
flow transactions send ./transactions/creator/createContent.cdc "[\"More Content\", \"\", \"\", \"\", \"\", \"\", \"\"]" "{}" --signer emulator-creator;
flow transactions send ./transactions/creator/createContent.cdc "[\"Additional Content\", \"\", \"\", \"\", \"\", \"\", \"\"]" "{}" --signer emulator-creator;
flow transactions send ./transactions/creator/createContent.cdc "[\"The Last Content... for now\", \"\", \"\", \"\", \"\", \"\", \"\"]" "{}" --signer emulator-creator;


flow transactions send ./transactions/creator/createSeries.cdc "Amazing Stuff" "a" "d" --signer emulator-creator;

# oops we misspelled on create
flow transactions send ./transactions/creator/createSeries.cdc "Series Twfo" "a" "d" --signer emulator-creator;
# try to fix it?
# flow transactions send ./transactions/creator/updateSeries.cdc 2 "Two” "a" "d"
# nope, this is not allowed, just make a new series since it has no content yet its worthless
# once a series has content, its name is established and cannot be changed later
# so just make the correct one and carry on!
flow transactions send ./transactions/creator/createSeries.cdc "Series Two" "a" "d" --signer emulator-creator;

# lets make three Sets
flow transactions send ./transactions/creator/createSet.cdc "One Set" "a" "d" --signer emulator-creator;
flow transactions send ./transactions/creator/createSet.cdc "Set Two" "a" "d" --signer emulator-creator;
flow transactions send ./transactions/creator/createSet.cdc "FunSet: Both" "a" "d" --signer emulator-creator;

# now we need to add the content to their respective Series
flow transactions send ./transactions/creator/addContentToSeries.cdc 1 1 --signer emulator-creator;
flow transactions send ./transactions/creator/addContentToSeries.cdc 2 1 --signer emulator-creator;
flow transactions send ./transactions/creator/addContentToSeries.cdc 3 1 --signer emulator-creator;
flow transactions send ./transactions/creator/addContentToSeries.cdc 2 2 --signer emulator-creator;

# now add that content to some sets so that we can edition it into a moment
flow transactions send ./transactions/creator/addContentToSet.cdc 1 1 --signer emulator-creator;
flow transactions send ./transactions/creator/addContentToSet.cdc 3 1 --signer emulator-creator;
flow transactions send ./transactions/creator/addContentToSet.cdc 2 2 --signer emulator-creator;
flow transactions send ./transactions/creator/addContentToSet.cdc 2 3 --signer emulator-creator;
flow transactions send ./transactions/creator/addContentToSet.cdc 3 3 --signer emulator-creator;

# after all this config, we have a few options to create Moments from:
flow transactions send ./transactions/creator/mintMoment.cdc 1 1 1 --signer emulator-creator;
# this fails! Not in the set!
# flow transactions send ./transactions/creator/mintMoment.cdc 2 1 1 --signer emulator-creator;
flow transactions send ./transactions/creator/mintMoment.cdc 3 1 1 --signer emulator-creator;
# logically we’ve just minted content 1,2,3 into an edition of series1:set1
# some things that wont work...
# flow transactions send ./transactions/creator/mintMoment.cdc 1 1 2 --signer emulator-creator; # not in series 2!
# flow transactions send ./transactions/creator/mintMoment.cdc 4 1 1 --signer emulator-creator; # content id 4 is not editioned
# flow transactions send ./transactions/creator/mintMoment.cdc 5 2 1 --signer emulator-creator; # no content id 5!

# now mint from series 1: set 2
flow transactions send ./transactions/creator/mintMoment.cdc 2 1 2 --signer emulator-creator;
# yup thats all that set has!
# c2:series2:set2
flow transactions send ./transactions/creator/mintMoment.cdc 2 2 2 --signer emulator-creator;
# c3:series1:set3
flow transactions send ./transactions/creator/mintMoment.cdc 3 1 3 --signer emulator-creator;
# c2:series2:set3
flow transactions send ./transactions/creator/mintMoment.cdc 2 2 3 --signer emulator-creator;

# ok lets retire set 2
flow transactions send ./transactions/creator/retireSet.cdc 2 --signer emulator-creator;
# try to mint, these both worked, but they fail!
flow transactions send ./transactions/creator/mintMoment.cdc 2 1 2 --signer emulator-creator;
flow transactions send ./transactions/creator/mintMoment.cdc 2 2 2 --signer emulator-creator;

# misattribute on purpose
flow transactions send ./transactions/admin/addCreatorAttribution.cdc 0x179b6b1cb6755e31 3; 
# lets fix that misattribution
flow transactions send ./transactions/admin/removeCreatorAttribution.cdc 0x179b6b1cb6755e31 3;

# we can check by content
flow scripts execute ./scripts/getCreatorContentIDs.cdc 0x01cf0e2f2f715450;
# or by moment
flow scripts execute ./scripts/getCreatorMomentIDs.cdc 0x01cf0e2f2f715450;
flow scripts execute ./scripts/getCreatorMomentIDs.cdc 0x179b6b1cb6755e31;


# now lets look at some state…
flow scripts execute ./scripts/getAllUserMoments.cdc 0x01cf0e2f2f715450;

# whats up with these sets and moments etc
flow scripts execute ./scripts/getMoments.cdc “[1,2]”;
flow scripts execute ./scripts/getContentMetadata.cdc 1;
flow scripts execute ./scripts/getSeriesMetadata.cdc 2;
flow scripts execute ./scripts/getSetMetadata.cdc 3;
flow scripts execute ./scripts/isSetRetired.cdc 2

# and for good measure lets distribute these moments
flow transactions send ./transactions/batchSendMoments.cdc "["0x179b6b1cb6755e31"]" "{0x179b6b1cb6755e31: [1,2]}" --signer emulator-creator;
flow transactions send ./transactions/sendMoment.cdc 0xf8d6e0586b0a20c7 3 --signer emulator-creator;
# validate delivery
flow scripts execute ./scripts/addressHasMoment.cdc 0xf8d6e0586b0a20c7 3;
flow scripts execute ./scripts/addressHasMoment.cdc 0xf8d6e0586b0a20c7 2; # nope
flow scripts execute ./scripts/addressHasMoment.cdc 0x179b6b1cb6755e31 2;
flow scripts execute ./scripts/addressHasMoment.cdc 0x179b6b1cb6755e31 1;

# test the power of the overlord
flow transactions send ./transactions/admin/forceUpdateContent.cdc 1 "[\"FORCED UPDATE\", \"BEFORE I WAS BAD, NOW I AM GOOD\", \"\", \"\", \"\", \"\", \"YAY.lyfe\"]" "{}"
# and the underlord
flow transactions send ./transactions/creator/updateContent.cdc 2 "[\"regularly updated lol\", \"not as cool as the other guy\", \"\", \"\", \"\", \"\", \"doh.lyfe\"]" "{}" --signer emulator-creator
# doesnt work for user
flow transactions send ./transactions/creator/updateContent.cdc 3 "[\"7\", \"7\", \"7\", \"7\", \"7\", \"7\", \"7\"]" "{}" --signer emulator-user
# funny enough it doesnt work for the admin, THROUGH THE CC, that is!
flow transactions send ./transactions/creator/updateContent.cdc 3 "[\"7\", \"7\", \"7\", \"7\", \"7\", \"7\", \"7\"]" "{}" --signer emulator-account
flow scripts execute ./scripts/getMoments.cdc "[1,2,3]"

## This nuance is worth highlighting, that the ACTUAL CREATOR of a given content is
## the lord over the content updates, but ADMIN can FORCIBLY UPDATE the CREATOR if 
## they are REALLY THAT BAD (the script right now maintains the CREATOR!)

# Looks good, ya!?
```

## Unit tests
install go
install gotestsum `go get gotest.tools/gotestsum`
`go mod tidy`
`gotestsum -f testname --hide-summary output`
