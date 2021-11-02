package test_main

import "testing"

func TestMomentsHappyDay(t *testing.T) {
	NewGWTFTest(t).
		setup().
		createContent("one", 1).
		createSeries("Series one", 1).
		createSet("Set one", 1).
		addContentToSeries(1, 1).
		addContentToSet(1, 1).
		mintMoment(1, 1, 1).
		getAllUserMoments("creator", `[{
			"complete":"false", 
			"contentEdition":"1", 
			"contentID":"1", 
			"description":"", 
			"id":"1", 
			"mediaHash":"", 
			"mediaType":"", 
			"mediaURI":"", 
			"name":"one", 
			"run":"0", 
			"serialNumber":"1", 
			"seriesID":"1", 
			"seriesName":"Series one", 
			"setID":"1", 
			"setName":"Set one"
		}]`)
}
