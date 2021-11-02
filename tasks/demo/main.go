package main

import (
	"log"

	"github.com/bjartek/go-with-the-flow/v2/gwtf"
	"github.com/onflow/cadence"
)

func main() {

	//this starts in emulator
	//g := gwtf.NewGoWithTheFlowEmulator().InitializeContracts().CreateAccounts("emulator-account")
	//this starts with emulator running in same process
	g := gwtf.NewGoWithTheFlowInMemoryEmulator()

	//setup vouchers and proxy for service account, it will act as admin
	g.TransactionFromFile("setupMoments").SignProposeAndPayAsService().RunPrintEventsFull()
	g.TransactionFromFile("setupMoments").SignProposeAndPayAs("user").RunPrintEventsFull()
	g.TransactionFromFile("setupMoments").SignProposeAndPayAs("creator").RunPrintEventsFull()

	g.TransactionFromFile("setupAdminProxy").SignProposeAndPayAsService().RunPrintEventsFull()
	g.TransactionFromFile("setupCreatorProxy").SignProposeAndPayAs("creator").RunPrintEventsFull()
	g.TransactionFromFile("admin/registerCreator").SignProposeAndPayAsService().AccountArgument("creator").RunPrintEventsFull()

	//# set the emulator as an valid Admin via its Proxy (to test the proxy routes have no issue, these are less easily revoked)
	//flow transactions send ./transactions/admin/activateAdminProxy.cdc 0xf8d6e0586b0a20c7; g.TransactionFromFile("admin/activateAdminproxy").SignProposeAndPayAsService().AccountArgument("service").RunPrintEventsFull() # test the admin proxy by registering a new creator with it, as itself flow transactions send ./transactions/admin/registerCreator.cdc 0x01cf0e2f2f715450; g.TransactionFromFile("admin/registerCreator").SignProposeAndPayAsService().AccountArgument("creator").RunPrintEventsFull()

	/*
		# my user is gunna go rogue and i’ll make a mistake, then fix it
		flow transactions send ./transactions/setupCreatorProxy.cdc --signer emulator-user;
		flow transactions send ./transactions/admin/registerCreator.cdc 0x179b6b1cb6755e31;
	*/

	g.TransactionFromFile("setupCreatorProxy").SignProposeAndPayAs("user").RunPrintEventsFull()
	g.TransactionFromFile("admin/registerCreator").SignProposeAndPayAsService().AccountArgument("user").RunPrintEventsFull()

	/*
		# for the sake of the demo I wont show all the transactions, but let’s assume ole 0x179’er goes hog-wild and makes a bunch of things he should make, lets revoke that
		flow transactions send ./transactions/admin/revokeCreator.cdc 0x01cf0e2f2f715450;
	*/
	g.TransactionFromFile("admin/revokeCreator").SignProposeAndPayAsService().AccountArgument("creator").RunPrintEventsFull()

	/*
		# oops we revoked the wrong one, reinstate him and revoke the right one
		flow transactions send ./transactions/admin/reinstateCreator.cdc 0x01cf0e2f2f715450;
	*/

	g.TransactionFromFile("admin/reinstateCreator").SignProposeAndPayAsService().AccountArgument("creator").RunPrintEventsFull()

	/*
		flow transactions send ./transactions/admin/revokeCreator.cdc 0x179b6b1cb6755e31;
		# you can re-run the above tx’s and observe they error, in that those states are already set
	*/
	g.TransactionFromFile("admin/revokeCreator").SignProposeAndPayAsService().AccountArgument("user").RunPrintEventsFull()
	/*
		# now he cant create

		flow transactions send ./transactions/creator/createContent.cdc "[\"one\", \"\", \"\", \"\", \"\", \"\"]" --signer emulator-user;
		# that failed
	*/

	_, err := g.TransactionFromFile("creator/createContent").SignProposeAndPayAs("user").StringArrayArgument("one", "", "", "", "", "").RunE()
	if err == nil {
		log.Fatal("Should fail")
	}
	/*


		# now let’s create some content
		flow transactions send ./transactions/creator/createContent.cdc "[\"First Content\", \"\", \"\", \"\", \"\", \"\"]" --signer emulator-creator;
		flow transactions send ./transactions/creator/createContent.cdc "[\"More Content\", \"\", \"\", \"\", \"\", \"\"]" --signer emulator-creator;
		flow transactions send ./transactions/creator/createContent.cdc "[\"Additional Content\", \"\", \"\", \"\", \"\", \"\"]" --signer emulator-creator;
		flow transactions send ./transactions/creator/createContent.cdc "[\"The Last Content... for now\", \"\", \"\", \"\", \"\", \"\"]" --signer emulator-creator;

	*/

	g.TransactionFromFile("creator/createContent").SignProposeAndPayAs("creator").StringArrayArgument("First Content", "", "", "", "", "").RunPrintEventsFull()
	g.TransactionFromFile("creator/createContent").SignProposeAndPayAs("creator").StringArrayArgument("More Content", "", "", "", "", "").RunPrintEventsFull()
	g.TransactionFromFile("creator/createContent").SignProposeAndPayAs("creator").StringArrayArgument("Additional Content", "", "", "", "", "").RunPrintEventsFull()
	g.TransactionFromFile("creator/createContent").SignProposeAndPayAs("creator").StringArrayArgument("The last content... for now", "", "", "", "", "").RunPrintEventsFull()

	/*
		flow transactions send ./transactions/creator/createSeries.cdc "Amazing Stuff" --signer emulator-creator;
	*/

	g.TransactionFromFile("creator/createSeries").SignProposeAndPayAs("creator").StringArgument("Amazing Stuff").RunPrintEventsFull()
	/*

		# oops we misspelled on create
		flow transactions send ./transactions/creator/createSeries.cdc "Series Twfo" --signer emulator-creator;

	*/
	g.TransactionFromFile("creator/createSeries").SignProposeAndPayAs("creator").StringArgument("Series Twfo").RunPrintEventsFull()

	//		g.TransactionFromFile("creator/updateSeries").SignProposeAndPayAs("creator").StringArgument("Series Twfo").RunPrintEventsFull()
	//	   # try to fix it?
	//	   # flow transactions send ./transactions/creator/updateSeries.cdc 2 "Two”
	//	   # nope, this is not allowed, just make a new series since it has no content yet its worthless
	//	   # once a series has content, its name is established and cannot be changed later
	//	   # so just make the correct one and carry on!

	//	   flow transactions send ./transactions/creator/createSeries.cdc "Series Two" --signer emulator-creator;
	g.TransactionFromFile("creator/createSeries").SignProposeAndPayAs("creator").StringArgument("Series Two").RunPrintEventsFull()

	/*
		# lets make threes
		flow transactions send ./transactions/creator/createSet.cdc "One Set" --signer emulator-creator;
		flow transactions send ./transactions/creator/createSet.cdc "Set Two" --signer emulator-creator;
		flow transactions send ./transactions/creator/createSet.cdc "FunSet: Both" --signer emulator-creator;
	*/

	g.TransactionFromFile("creator/createSet").SignProposeAndPayAs("creator").StringArgument("One Set").RunPrintEventsFull()
	g.TransactionFromFile("creator/createSet").SignProposeAndPayAs("creator").StringArgument("Set Two").RunPrintEventsFull()
	g.TransactionFromFile("creator/createSet").SignProposeAndPayAs("creator").StringArgument("FUnset: Both").RunPrintEventsFull()

	/*
		# now we need to add the content to their respective Series
		flow transactions send ./transactions/creator/addContentToSeries.cdc 1 1 --signer emulator-creator;
		flow transactions send ./transactions/creator/addContentToSeries.cdc 2 1 --signer emulator-creator;
		flow transactions send ./transactions/creator/addContentToSeries.cdc 3 1 --signer emulator-creator;
		flow transactions send ./transactions/creator/addContentToSeries.cdc 2 2 --signer emulator-creator;
	*/

	g.TransactionFromFile("creator/addContentToSeries").SignProposeAndPayAs("creator").UInt64Argument(1).UInt64Argument(1).RunPrintEventsFull()
	g.TransactionFromFile("creator/addContentToSeries").SignProposeAndPayAs("creator").UInt64Argument(2).UInt64Argument(1).RunPrintEventsFull()
	g.TransactionFromFile("creator/addContentToSeries").SignProposeAndPayAs("creator").UInt64Argument(3).UInt64Argument(1).RunPrintEventsFull()
	g.TransactionFromFile("creator/addContentToSeries").SignProposeAndPayAs("creator").UInt64Argument(2).UInt64Argument(2).RunPrintEventsFull()

	/*
		# now add that content to some sets so that we can edition it into a moment
		flow transactions send ./transactions/creator/addContentToSet.cdc 1 1 --signer emulator-creator;
		flow transactions send ./transactions/creator/addContentToSet.cdc 3 1 --signer emulator-creator;
		flow transactions send ./transactions/creator/addContentToSet.cdc 2 2 --signer emulator-creator;
		flow transactions send ./transactions/creator/addContentToSet.cdc 2 3 --signer emulator-creator;
		flow transactions send ./transactions/creator/addContentToSet.cdc 3 3 --signer emulator-creator;
	*/
	g.TransactionFromFile("creator/addContentToSet").SignProposeAndPayAs("creator").UInt64Argument(1).UInt64Argument(1).RunPrintEventsFull()
	g.TransactionFromFile("creator/addContentToSet").SignProposeAndPayAs("creator").UInt64Argument(3).UInt64Argument(1).RunPrintEventsFull()
	g.TransactionFromFile("creator/addContentToSet").SignProposeAndPayAs("creator").UInt64Argument(2).UInt64Argument(2).RunPrintEventsFull()
	g.TransactionFromFile("creator/addContentToSet").SignProposeAndPayAs("creator").UInt64Argument(2).UInt64Argument(3).RunPrintEventsFull()
	g.TransactionFromFile("creator/addContentToSet").SignProposeAndPayAs("creator").UInt64Argument(3).UInt64Argument(3).RunPrintEventsFull()

	/*
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
	*/

	g.TransactionFromFile("creator/mintMoment").SignProposeAndPayAs("creator").UInt64Argument(3).UInt64Argument(1).UInt64Argument(1).RunPrintEventsFull()

	/*
		# now mint from set 2:series 1
		flow transactions send ./transactions/creator/mintMoment.cdc 2 2 1 --signer emulator-creator;
	*/

	g.TransactionFromFile("creator/mintMoment").SignProposeAndPayAs("creator").UInt64Argument(2).UInt64Argument(2).UInt64Argument(1).RunPrintEventsFull()
	//	# yup thats all that set has!

	/*
		# set2:series2
		flow transactions send ./transactions/creator/mintMoment.cdc 2 2 2 --signer emulator-creator;
		# set3:series1
		flow transactions send ./transactions/creator/mintMoment.cdc 3 3 1 --signer emulator-creator;
		# set3:series2
		flow transactions send ./transactions/creator/mintMoment.cdc 2 3 2 --signer emulator-creator;
	*/

	g.TransactionFromFile("creator/mintMoment").SignProposeAndPayAs("creator").UInt64Argument(2).UInt64Argument(2).UInt64Argument(2).RunPrintEventsFull()
	g.TransactionFromFile("creator/mintMoment").SignProposeAndPayAs("creator").UInt64Argument(3).UInt64Argument(3).UInt64Argument(1).RunPrintEventsFull()
	g.TransactionFromFile("creator/mintMoment").SignProposeAndPayAs("creator").UInt64Argument(2).UInt64Argument(3).UInt64Argument(2).RunPrintEventsFull()

	/*
		# ok lets retire set 2
		flow transactions send ./transactions/creator/retireSet.cdc 2 --signer emulator-creator;
		# try to mint, these both worked, but they fail!
		flow transactions send ./transactions/creator/mintMoment.cdc 2 2 1 --signer emulator-creator;
		flow transactions send ./transactions/creator/mintMoment.cdc 2 2 2 --signer emulator-creator;
	*/

	g.TransactionFromFile("creator/mintMoment").SignProposeAndPayAs("creator").UInt64Argument(2).UInt64Argument(2).UInt64Argument(1).RunPrintEventsFull()
	g.TransactionFromFile("creator/mintMoment").SignProposeAndPayAs("creator").UInt64Argument(2).UInt64Argument(2).UInt64Argument(2).RunPrintEventsFull()

	/*
		# oh hey we forgot, we are lazy-attributing at the moment, so tell the CC who actually made that content
		flow transactions send ./transactions/admin/attributeCreator.cdc 0x01cf0e2f2f715450 1;
		flow transactions send ./transactions/admin/attributeCreator.cdc 0x01cf0e2f2f715450 2;
		flow transactions send ./transactions/admin/attributeCreator.cdc 0x179b6b1cb6755e31 3; #misattribute on purpose
		flow transactions send ./transactions/admin/attributeCreator.cdc 0x01cf0e2f2f715450 4;
	*/

	g.TransactionFromFile("admin/attributeCreator").SignProposeAndPayAsService().AccountArgument("creator").UInt64Argument(1).RunPrintEventsFull()
	g.TransactionFromFile("admin/attributeCreator").SignProposeAndPayAsService().AccountArgument("creator").UInt64Argument(2).RunPrintEventsFull()
	g.TransactionFromFile("admin/attributeCreator").SignProposeAndPayAsService().AccountArgument("user").UInt64Argument(3).RunPrintEventsFull()
	g.TransactionFromFile("admin/attributeCreator").SignProposeAndPayAsService().AccountArgument("creator").UInt64Argument(4).RunPrintEventsFull()

	/*
		# now lets look at some state…
		flow scripts execute ./scripts/getAllUserMoments.cdc 0x01cf0e2f2f715450;
		flow scripts execute ./scripts/getCreatorMomentIDs.cdc 0x01cf0e2f2f715450;
		flow scripts execute ./scripts/getCreatorMomentIDs.cdc 0x179b6b1cb6755e31;
		# NOTE: Attribution is ADDITIVE in this system, and can never be undone.
		# You can nuke bad content, but you can’t detach an attribution
		# OPEN Q: Is this a bad design? Should it be unique? If so that may take reworking some things.
	*/

	g.ScriptFromFile("getAllUserMoments").AccountArgument("creator").Run()
	g.ScriptFromFile("getCreatorMomentIDs").AccountArgument("creator").Run()
	g.ScriptFromFile("getCreatorMomentIDs").AccountArgument("user").Run()

	/*
		# whats up with these sets and moments etc
		flow scripts execute ./scripts/getMoments.cdc “[1,2]”;
		flow scripts execute ./scripts/getContentMetadata.cdc 1;
		flow scripts execute ./scripts/getSeriesMetadata.cdc 2;
		flow scripts execute ./scripts/getSetMetadata.cdc 3;
		flow scripts execute ./scripts/isSetRetired.cdc 2
	*/
	//yuck that is ugly
	g.ScriptFromFile("getMoments").Argument(cadence.NewArray([]cadence.Value{cadence.NewUInt64(1), cadence.NewUInt64(2)})).Run()
	g.ScriptFromFile("getContentMetadata").UInt64Argument(1).Run()
	g.ScriptFromFile("getSeriesMetadata").UInt64Argument(2).Run()
	g.ScriptFromFile("getSetMetadata").UInt64Argument(3).Run()
	g.ScriptFromFile("isSetRetired").UInt64Argument(2).Run()

	/*

			# and for good measure lets distribute these moments
			flow transactions send ./transactions/batchSendMoments.cdc "["0x179b6b1cb6755e31"]" "{0x179b6b1cb6755e31: [1,2]}" --signer emulator-creator;

	flow transactions send ./transactions/sendMoment.cdc “0xf8d6e0586b0a20c7” 3 --signer emulator-creator: */

	userAddressValue := cadence.BytesToAddress([]byte("0x179b6b1cb6755e31"))

	recipients := cadence.NewArray([]cadence.Value{userAddressValue})
	//	35:		dict := cadence.NewDictionary([]cadence.KeyValuePair{{Key: cadence.NewString("foo"), Value: cadence.NewString("bar")}})
	momentIds := cadence.NewArray([]cadence.Value{cadence.NewUInt64(1), cadence.NewUInt64(2)})

	moments := cadence.NewDictionary([]cadence.KeyValuePair{{Key: userAddressValue, Value: momentIds}})

	g.TransactionFromFile("batchSendMoments").SignProposeAndPayAs("creator").Argument(recipients).Argument(moments).RunPrintEventsFull()
	g.TransactionFromFile("sendtMoment").SignProposeAndPayAs("creator").AccountArgument("account").UInt64Argument(3).RunPrintEventsFull()

	/*
		# validate delivery
		flow scripts execute ./scripts/addressHasMoment.cdc 0xf8d6e0586b0a20c7 3;
		flow scripts execute ./scripts/addressHasMoment.cdc 0xf8d6e0586b0a20c7 2; # nope
		flow scripts execute ./scripts/addressHasMoment.cdc 0x179b6b1cb6755e31 2;
		flow scripts execute ./scripts/addressHasMoment.cdc 0x179b6b1cb6755e31 1;

		# Looks good, ya!?
	*/

	g.ScriptFromFile("addressHasMoment").AccountArgument("account").UInt64Argument(3).Run()
	//	g.ScriptFromFile("addressHasMoment").AccountArgument("account").UInt64Argument(2)
	g.ScriptFromFile("addressHasMoment").AccountArgument("user").UInt64Argument(2).Run()
	g.ScriptFromFile("addressHasMoment").AccountArgument("user").UInt64Argument(1).Run()

}
