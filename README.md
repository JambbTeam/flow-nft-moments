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
flow transactions send ./transactions/setupCreatorProxy.cdc;
flow transactions send ./transactions/setupCreatorProxy.cdc --signer emulator-creator;

# set the emulator as an valid Admin via its Proxy (to test the proxy routes have no issue, these are less easily revoked)
flow transactions send ./transactions/admin/activateAdminProxy.cdc 0xf8d6e0586b0a20c7;

# test the admin proxy by registering a new creator with it, as itself
flow transactions send ./transactions/admin/registerCreator.cdc 0x01cf0e2f2f715450;

# this user is gunna go rogue and make a mistake, then admin will fix it 
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

######

# now let’s create some content
flow transactions send ./transactions/creator/createContent.cdc "[\"The First Name\", \"Descriptions\", \"Source is a String\", \"previewImg1\", \"videoURI1\", \"0x1\"]" "{}" --signer emulator-creator;
flow transactions send ./transactions/creator/createContent.cdc "[\"A Better Name\", \"Can\", \"It can be the NAme of an Entity\", \"previewImg2\", \"videoURI2\", \"0x2\"]" "{}" --signer emulator-creator;
flow transactions send ./transactions/creator/createContent.cdc "[\"Probably a Bad Name\", \"Be\", \"That this Content is Sourced from\", \"previewImg3\", \"videoURI3\", \"0x3\"]" "{}" --signer emulator-creator;
flow transactions send ./transactions/creator/createContent.cdc "[\"The Last Content... for now\", \"Useful\", \"https://www.oralink.com/to/the/source/content/this?derivative-came-from\", \"previewImg4\", \"videoURI4\", \"0x4\"]" "{}" --signer emulator-creator;

# and a series
flow transactions send ./transactions/creator/createSeries.cdc "Series One" "The First Series, As Described" nil --signer emulator-creator;

# oops we misspelled on create
flow transactions send ./transactions/creator/createSeries.cdc "Series Twfo" "kek" nil --signer emulator-creator;
# try to fix it? guess what, CREATOR CANT! only ADMIN can update Series and Sets, as they are more persistent and should rarely need changing

# admin will fix this right up :) need to activate his creatorproxy, but only so the scripts work, not because the contract requires it
# admittedly, some things do require it, so... always keep both on hand. I could bump this higher, but its a learning moment here, maybe.
flow transactions send ./transactions/admin/registerCreator.cdc 0xf8d6e0586b0a20c7;
flow transactions send ./transactions/admin/forceUpdateSeries.cdc 2 "Series Two" "A Better Descrip" nil; 

# lets make three Sets
flow transactions send ./transactions/creator/createSet.cdc "One Set" "OneDescrip" nil nil --signer emulator-creator;
flow transactions send ./transactions/creator/createSet.cdc "Set Two" "Dont use set two" nil nil --signer emulator-creator;
flow transactions send ./transactions/creator/createSet.cdc "FunSet: Both" "Wow cool set broh" nil nil --signer emulator-creator;
### Elephant in the room: nil nil? Those are `art` and `rarityCaps`. ART is optional, but rarityCaps uses a default because CLI cant handle dictionaries :)

# now we need to add the content to their respective Series
flow transactions send ./transactions/creator/addContentToSeries.cdc 1 1 --signer emulator-creator;
flow transactions send ./transactions/creator/addContentToSeries.cdc 2 1 --signer emulator-creator;
flow transactions send ./transactions/creator/addContentToSeries.cdc 3 1 --signer emulator-creator;
flow transactions send ./transactions/creator/addContentToSeries.cdc 2 2 --signer emulator-creator;

# now add that content to some sets so that we can edition it into a moment
flow transactions send ./transactions/creator/addContentToSet.cdc 1 1 Common --signer emulator-creator;
flow transactions send ./transactions/creator/addContentToSet.cdc 3 1 Uncommon --signer emulator-creator;
flow transactions send ./transactions/creator/addContentToSet.cdc 2 2 Rare --signer emulator-creator;
flow transactions send ./transactions/creator/addContentToSet.cdc 2 3 Legendary --signer emulator-creator;
flow transactions send ./transactions/creator/addContentToSet.cdc 3 3 Exclusive --signer emulator-creator;

#########

# after all this config, we have a few options to create Moments from
flow transactions send ./transactions/creator/mintMoment.cdc 1 1 1 --signer emulator-creator;

# this fails! Not in the set!
# flow transactions send ./transactions/creator/mintMoment.cdc 2 1 1 --signer emulator-creator;

# this works
flow transactions send ./transactions/creator/mintMoment.cdc 3 1 1 --signer emulator-creator;

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

# ok lets try to mint some more copies of our exclusives...
flow transactions send ./transactions/creator/mintMoment.cdc 3 1 3 --signer emulator-creator;
# !! THIS FAILS! only 1 of these can exist for that rarity! you can mint more of the others, but this is the easiest cap to show :)

# misattribute on purpose
flow transactions send ./transactions/admin/addCreatorAttribution.cdc 0x179b6b1cb6755e31 3; 
# lets fix that misattribution
flow transactions send ./transactions/admin/removeCreatorAttribution.cdc 0x179b6b1cb6755e31 3;

# we can check by content
flow scripts execute ./scripts/getCreatorContentIDs.cdc 0x01cf0e2f2f715450;
# or by moment
flow scripts execute ./scripts/getCreatorMomentIDs.cdc 0x01cf0e2f2f715450;
flow scripts execute ./scripts/getCreatorMomentIDs.cdc 0x179b6b1cb6755e31;

# or by user account holdings
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
flow transactions send ./transactions/admin/forceUpdateContent.cdc 1 "[\"FORCED UPDATE\", \"BEFORE I WAS BAD, NOW I AM GOOD\", \"\", \"\", \"\", \"\"]" "{}"
# and the underlord
flow transactions send ./transactions/creator/updateContent.cdc 2 "[\"regularly updated lol\", \"not as cool as the other guy\", \"\", \"\", \"\", \"\"]" "{}" --signer emulator-creator
# see: doesnt work for user
flow transactions send ./transactions/creator/updateContent.cdc 3 "[\"\", \"\", \"\", \"\", \"\", \"\"]" "{}" --signer emulator-user

# see: funny enough it doesnt work for the admin, THROUGH THE CC, that is!
flow transactions send ./transactions/creator/updateContent.cdc 3 "[\"\", \"\", \"\", \"\", \"\", \"\"]" "{}" --signer emulator-account

# how did these moments shape up?
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
