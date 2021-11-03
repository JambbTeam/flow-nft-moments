# Moments.cdc
### A Content Moment Contact
#### Inspired by NBA TopShot

### Implementation Overview
#### Moments

- WIP - will add this later

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
flow transactions send ./transactions/creator/createContent.cdc "[\"one\", \"\", \"\", \"\", \"\", \"\"]" --signer emulator-user;
# that failed

# now let’s create some content
flow transactions send ./transactions/creator/createContent.cdc "[\"First Content\", \"\", \"\", \"\", \"\", \"\"]" --signer emulator-creator;
flow transactions send ./transactions/creator/createContent.cdc "[\"More Content\", \"\", \"\", \"\", \"\", \"\"]" --signer emulator-creator;
flow transactions send ./transactions/creator/createContent.cdc "[\"Additional Content\", \"\", \"\", \"\", \"\", \"\"]" --signer emulator-creator;
flow transactions send ./transactions/creator/createContent.cdc "[\"The Last Content... for now\", \"\", \"\", \"\", \"\", \"\"]" --signer emulator-creator;
flow transactions send ./transactions/creator/createSeries.cdc "Amazing Stuff" --signer emulator-creator;

# oops we misspelled on create
flow transactions send ./transactions/creator/createSeries.cdc "Series Twfo" --signer emulator-creator;
# try to fix it?
# flow transactions send ./transactions/creator/updateSeries.cdc 2 "Two”
# nope, this is not allowed, just make a new series since it has no content yet its worthless
# once a series has content, its name is established and cannot be changed later
# so just make the correct one and carry on!
flow transactions send ./transactions/creator/createSeries.cdc "Series Two" --signer emulator-creator;

# lets make three Sets
flow transactions send ./transactions/creator/createSet.cdc "One Set" --signer emulator-creator;
flow transactions send ./transactions/creator/createSet.cdc "Set Two" --signer emulator-creator;
flow transactions send ./transactions/creator/createSet.cdc "FunSet: Both" --signer emulator-creator;

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
# logically we’ve just minted content 1,2,3 into an edition of set1:series1 
# some things that wont work...
# flow transactions send ./transactions/creator/mintMoment.cdc 1 1 2 --signer emulator-creator; # not in series 2!
# flow transactions send ./transactions/creator/mintMoment.cdc 4 1 1 --signer emulator-creator; # content id 4 is not editioned
# flow transactions send ./transactions/creator/mintMoment.cdc 5 2 1 --signer emulator-creator; # no content id 5!

# now mint from set 2:series 1
flow transactions send ./transactions/creator/mintMoment.cdc 2 2 1 --signer emulator-creator;
# yup thats all that set has!
# set2:series2
flow transactions send ./transactions/creator/mintMoment.cdc 2 2 2 --signer emulator-creator;
# set3:series1
flow transactions send ./transactions/creator/mintMoment.cdc 3 3 1 --signer emulator-creator;
# set3:series2
flow transactions send ./transactions/creator/mintMoment.cdc 2 3 2 --signer emulator-creator;

# ok lets retire set 2
flow transactions send ./transactions/creator/retireSet.cdc 2 --signer emulator-creator;
# try to mint, these both worked, but they fail!
flow transactions send ./transactions/creator/mintMoment.cdc 2 2 1 --signer emulator-creator;
flow transactions send ./transactions/creator/mintMoment.cdc 2 2 2 --signer emulator-creator;

# oh hey we forgot, we are lazy-attributing at the moment, so tell the CC who actually made that content
flow transactions send ./transactions/admin/attributeCreator.cdc 0x01cf0e2f2f715450 1;
flow transactions send ./transactions/admin/attributeCreator.cdc 0x01cf0e2f2f715450 2;
flow transactions send ./transactions/admin/attributeCreator.cdc 0x179b6b1cb6755e31 3; #misattribute on purpose
flow transactions send ./transactions/admin/attributeCreator.cdc 0x01cf0e2f2f715450 4;

# now lets look at some state…
flow scripts execute ./scripts/getAllUserMoments.cdc 0x01cf0e2f2f715450;
flow scripts execute ./scripts/getCreatorMomentIDs.cdc 0x01cf0e2f2f715450;
flow scripts execute ./scripts/getCreatorMomentIDs.cdc 0x179b6b1cb6755e31;
# NOTE: Attribution is ADDITIVE in this system, and can never be undone. 
# You can nuke bad content, but you can’t detach an attribution
# OPEN Q: Is this a bad design? Should it be unique? If so that may take reworking some things.

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

# Looks good, ya!?
```