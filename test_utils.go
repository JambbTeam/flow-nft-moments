package test_main

import (
	"fmt"
	"testing"

	"github.com/bjartek/go-with-the-flow/v2/gwtf"
	"github.com/onflow/cadence"
	"github.com/stretchr/testify/assert"
)

type GWTFTestUtils struct {
	T    *testing.T
	GWTF *gwtf.GoWithTheFlow
}

func NewGWTFTest(t *testing.T) *GWTFTestUtils {
	return &GWTFTestUtils{T: t, GWTF: gwtf.NewTestingEmulator()}
}

func (gt *GWTFTestUtils) setup() *GWTFTestUtils {
	//first step create the adminClient as the fin user

	g := gt.GWTF
	//setup vouchers and proxy for service account, it will act as admin
	g.TransactionFromFile("setupMoments").SignProposeAndPayAsService().Test(gt.T).AssertSuccess()
	g.TransactionFromFile("setupMoments").SignProposeAndPayAs("user").Test(gt.T).AssertSuccess()
	g.TransactionFromFile("setupMoments").SignProposeAndPayAs("creator").Test(gt.T).AssertSuccess()

	//Add these if you want to stop to talk
	g.TransactionFromFile("setupAdminProxy").SignProposeAndPayAsService().Test(gt.T).AssertSuccess()
	g.TransactionFromFile("setupCreatorProxy").SignProposeAndPayAs("creator").Test(gt.T).AssertSuccess()

	g.TransactionFromFile("admin/activateAdminproxy").SignProposeAndPayAsService().AccountArgument("account").Test(gt.T).AssertSuccess()

	g.TransactionFromFile("admin/registerCreator").SignProposeAndPayAsService().AccountArgument("creator").Test(gt.T).AssertSuccess()
	return gt
}

func (gt *GWTFTestUtils) createContent(content string, expectedId uint64) *GWTFTestUtils {
	gt.GWTF.TransactionFromFile("creator/createContent").SignProposeAndPayAs("creator").StringArrayArgument(content, "", "", "", "", "").Test(gt.T).AssertSuccess().
		AssertPartialEvent(gwtf.NewTestEvent("A.f8d6e0586b0a20c7.Moments.ContentCreated", map[string]interface{}{
			"contentID": fmt.Sprintf("%d", expectedId),
			//TODO: if the content we sent in in the first arg was part of the event we could assert on that here
		},
		))
	return gt
}

func (gt *GWTFTestUtils) createSeries(content string, expectedId uint64) *GWTFTestUtils {
	gt.GWTF.TransactionFromFile("creator/createSeries").SignProposeAndPayAs("creator").StringArgument(content).Test(gt.T).AssertSuccess().
		AssertPartialEvent(gwtf.NewTestEvent("A.f8d6e0586b0a20c7.Moments.SeriesCreated", map[string]interface{}{
			"seriesID": fmt.Sprintf("%d", expectedId),
			//TODO: if the content we sent in in the first arg was part of the event we could assert on that here
		},
		))
	return gt
}

func (gt *GWTFTestUtils) createSet(content string, expectedId uint64) *GWTFTestUtils {
	gt.GWTF.TransactionFromFile("creator/createSet").SignProposeAndPayAs("creator").StringArgument(content).Test(gt.T).AssertSuccess().
		AssertPartialEvent(gwtf.NewTestEvent("A.f8d6e0586b0a20c7.Moments.SetCreated", map[string]interface{}{
			"setID": fmt.Sprintf("%d", expectedId),
			//TODO: if the content we sent in in the first arg was part of the event we could assert on that here
		},
		))
	return gt
}

func (gt *GWTFTestUtils) addContentToSeries(contentId, seriesId uint64) *GWTFTestUtils {

	gt.GWTF.TransactionFromFile("creator/addContentToSeries").SignProposeAndPayAs("creator").
		UInt64Argument(contentId).
		UInt64Argument(seriesId).
		Test(gt.T).AssertSuccess().
		AssertPartialEvent(gwtf.NewTestEvent("A.f8d6e0586b0a20c7.Moments.ContentAddedToSeries", map[string]interface{}{
			"seriesID":  fmt.Sprintf("%d", seriesId),
			"contentID": fmt.Sprintf("%d", contentId),
		},
		))
	return gt
}

func (gt *GWTFTestUtils) addContentToSet(contentId, setId uint64) *GWTFTestUtils {

	gt.GWTF.TransactionFromFile("creator/addContentToSet").SignProposeAndPayAs("creator").
		UInt64Argument(contentId).
		UInt64Argument(setId).
		Test(gt.T).AssertSuccess().
		AssertPartialEvent(gwtf.NewTestEvent("A.f8d6e0586b0a20c7.Moments.ContentAddedToSet", map[string]interface{}{
			"setID":     fmt.Sprintf("%d", setId),
			"contentID": fmt.Sprintf("%d", contentId),
		},
		))
	return gt
}
func (gt *GWTFTestUtils) mintMoment(contentId, setId, seriesId uint64) *GWTFTestUtils {

	gt.GWTF.TransactionFromFile("creator/mintMoment").SignProposeAndPayAs("creator").
		UInt64Argument(contentId).
		UInt64Argument(setId).
		UInt64Argument(seriesId).
		Test(gt.T).AssertSuccess().
		AssertPartialEvent(gwtf.NewTestEvent("A.f8d6e0586b0a20c7.Moments.MomentMinted", map[string]interface{}{
			"setID":     fmt.Sprintf("%d", setId),
			"seriesID":  fmt.Sprintf("%d", seriesId),
			"contentID": fmt.Sprintf("%d", contentId),
			//here we could assert of more of the fields below if you want
		}))
	return gt
}

func (gt *GWTFTestUtils) attributeCreator(account string, momentId uint64) *GWTFTestUtils {
	creatorAddress := fmt.Sprintf("0x%s", gt.GWTF.Account(account).Address().String())

	gt.GWTF.TransactionFromFile("admin/attributeCreator").SignProposeAndPayAsService().
		AccountArgument(account).
		UInt64Argument(momentId).
		Test(gt.T).AssertSuccess().
		AssertPartialEvent(gwtf.NewTestEvent("A.f8d6e0586b0a20c7.Moments.CreatorAttributed", map[string]interface{}{
			"creator":  creatorAddress,
			"momentID": fmt.Sprintf("%d", momentId),
		}))

	return gt
}
func (gt *GWTFTestUtils) getAllUserMoments(account string, expected string) *GWTFTestUtils {

	result := gt.GWTF.ScriptFromFile("getAllUserMoments").AccountArgument(account).RunReturnsJsonString()

	assert.JSONEq(gt.T, expected, result)

	return gt
}
func (gt *GWTFTestUtils) getCreatorMomentIDs(account string, expected string) *GWTFTestUtils {

	result := gt.GWTF.ScriptFromFile("getCreatorMomentIDs").AccountArgument(account).RunReturnsJsonString()

	assert.JSONEq(gt.T, expected, result)

	return gt
}

func (gt *GWTFTestUtils) getMoments(ids []uint64, expected string) *GWTFTestUtils {

	elements := []cadence.Value{}
	for _, id := range ids {
		elements = append(elements, cadence.NewUInt64(id))
	}
	result := gt.GWTF.ScriptFromFile("getMoments").Argument(cadence.NewArray(elements)).RunReturnsJsonString()
	assert.JSONEq(gt.T, expected, result)

	return gt
}
func (gt *GWTFTestUtils) getContentMetadata(contentId uint64, expected string) *GWTFTestUtils {

	result := gt.GWTF.ScriptFromFile("getContentMetadata").UInt64Argument(contentId).RunReturnsJsonString()

	assert.JSONEq(gt.T, expected, result)

	return gt
}

func (gt *GWTFTestUtils) getSeriesMetadata(contentId uint64, expected string) *GWTFTestUtils {

	result := gt.GWTF.ScriptFromFile("getSeriesMetadata").UInt64Argument(contentId).RunReturnsJsonString()

	assert.JSONEq(gt.T, expected, result)

	return gt
}

func (gt *GWTFTestUtils) getSetMetadata(contentId uint64, expected string) *GWTFTestUtils {

	result := gt.GWTF.ScriptFromFile("getSetMetadata").UInt64Argument(contentId).RunReturnsJsonString()

	assert.JSONEq(gt.T, expected, result)

	return gt
}

func (gt *GWTFTestUtils) isSetRetired(contentId uint64, expected string) *GWTFTestUtils {

	result := gt.GWTF.ScriptFromFile("isSetRetired").UInt64Argument(contentId).RunReturnsJsonString()

	assert.JSONEq(gt.T, expected, result)

	return gt
}

func (gt *GWTFTestUtils) addressHasMoment(account string, moment uint64, expected string) *GWTFTestUtils {

	result := gt.GWTF.ScriptFromFile("addressHasMoment").AccountArgument(account).UInt64Argument(moment).RunReturnsJsonString()

	assert.JSONEq(gt.T, expected, result)

	return gt
}

func (gt *GWTFTestUtils) batchSendMoments(from string, recipients map[string][]uint64) *GWTFTestUtils {
	//	recipients := cadence.NewArray([]cadence.Value{userAddressValue})
	//	momentIds := cadence.NewArray([]cadence.Value{cadence.NewUInt64(1), cadence.NewUInt64(2)})

	recipientCadence := []cadence.Value{}
	moments := []cadence.KeyValuePair{}
	for user, ids := range recipients {
		userAddress := cadence.BytesToAddress(gt.GWTF.Account(user).Address().Bytes())
		recipientCadence = append(recipientCadence, userAddress)
		momentIds := []cadence.Value{}
		for _, id := range ids {
			momentIds = append(momentIds, cadence.NewUInt64(id))
		}
		moments = append(moments, cadence.KeyValuePair{Key: userAddress, Value: cadence.NewArray(momentIds)})
	}

	gt.GWTF.TransactionFromFile("batchSendMoments").SignProposeAndPayAs("creator").
		Argument(cadence.NewArray(recipientCadence)).
		Argument(cadence.NewDictionary(moments)).
		Test(gt.T).AssertSuccess()
	//TODO: assert events here
	return gt
}

func (gt *GWTFTestUtils) sendMoment(from, to string, momentId uint64) *GWTFTestUtils {
	fromAddress := fmt.Sprintf("0x%s", gt.GWTF.Account(fmt.Sprintf("emulator-%s", from)).Address().String())
	toAddress := fmt.Sprintf("0x%s", gt.GWTF.Account(fmt.Sprintf("emulator-%s", to)).Address().String())

	gt.GWTF.TransactionFromFile("sendMoment").SignProposeAndPayAs(from).
		AccountArgument(to).
		UInt64Argument(momentId).
		Test(gt.T).AssertSuccess().
		AssertPartialEvent(gwtf.NewTestEvent("A.f8d6e0586b0a20c7.Moments.Withdraw", map[string]interface{}{
			"from": fromAddress,
			"id":   momentId,
		})).
		AssertPartialEvent(gwtf.NewTestEvent("A.f8d6e0586b0a20c7.Moments.Deposit", map[string]interface{}{
			"to": toAddress,
			"id": momentId,
		}))
	return gt
}
