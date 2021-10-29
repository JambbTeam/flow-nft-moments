# Moments - Scripts

## Moments
- `getMoments` expects a `[UInt64]` array, and returns the `MomentMetadata` for those ID's
- `getMomentRun` expects a `UInt64` momentID and returns a `MomentRun` of how many have been minted with the rest of the `MomentMetadata`

### User Moments
- `getUserMomentIDs` expects an `Address` and and returns a `[UInt64]` array of the ID's they own
- `getUserMoments` expects a user `Address` and a `[UInt64]` array of ID's of Moments that they own, and returns a `[MomentData]` array
- `getAllUserMoments` expects an `Address` and returns a dictionary of `{UInt64:MomentMetadata}` momentIDs to their respective metadata
- `addressHasMoment` expects an `Address` an a `UInt64`, returns true if that `Account` has that `Moment`(ID)

## Creator
- `getCreatorMomentIDs` expects an `Address` and returns a `[UInt64]` array of that creatorProxy's attributed `[Moment.id]`
- `isCreatorRevoked` expects an `Address` and checks with the `Moments.Revoker` to see if they are allowed to create or if theyve been revoked (this is mostly useless as a script, it is codified into the `CreatorProxy` as a `pre` for any `ContentCreator` capability usage )

## Content - (TBA)
- `getSetMetadata`
- `getSeriesMetadata`
- `getContentMetadata` 
- `getContentEditions` 
 