HolyLandRules = HolyLandRules or {}

function HolyLandRules.IsFullReligion(religionID, pantheonReligionID)
	assert(
		type(pantheonReligionID) == "number",
		"Holy Land rules: pantheon religion ID must be numeric"
	)
	return religionID ~= nil and religionID > pantheonReligionID
end

function HolyLandRules.IsLivingJerusalemPlayer(
	player,
	jerusalemCivilizationID
)
	assert(
		type(jerusalemCivilizationID) == "number",
		"Holy Land rules: Jerusalem civilization ID must be numeric"
	)
	return player ~= nil
		and player:IsAlive()
		and player:GetCivilizationType() == jerusalemCivilizationID
end

function HolyLandRules.GetFollowedReligion(player, pantheonReligionID)
	if not player or not player:IsAlive() then
		return nil
	end

	local capital = player:GetCapitalCity()
	if not capital then
		return nil
	end

	local majorityReligion = capital:GetReligiousMajority()
	if HolyLandRules.IsFullReligion(
		majorityReligion,
		pantheonReligionID
	) then
		return majorityReligion
	end

	return nil
end

function HolyLandRules.GetJerusalemReligion(
	player,
	jerusalemCivilizationID,
	pantheonReligionID
)
	if not HolyLandRules.IsLivingJerusalemPlayer(
		player,
		jerusalemCivilizationID
	) then
		return nil
	end

	local foundedReligion = player:GetReligionCreatedByPlayer()
	if HolyLandRules.IsFullReligion(
		foundedReligion,
		pantheonReligionID
	) then
		return foundedReligion
	end

	return HolyLandRules.GetFollowedReligion(
		player,
		pantheonReligionID
	)
end

function HolyLandRules.IsQualifyingPartner(
	ownerPlayer,
	destinationPlayer,
	jerusalemReligion,
	pantheonReligionID
)
	if not HolyLandRules.IsFullReligion(
		jerusalemReligion,
		pantheonReligionID
	) or not ownerPlayer
		or not destinationPlayer
		or not destinationPlayer:IsAlive()
		or destinationPlayer:IsBarbarian()
		or destinationPlayer:GetID() == ownerPlayer:GetID()
	then
		return false
	end

	return HolyLandRules.GetFollowedReligion(
		destinationPlayer,
		pantheonReligionID
	) == jerusalemReligion
end

function HolyLandRules.QualifiesForHolyLand(
	ownerPlayer,
	destinationPlayer,
	jerusalemCivilizationID,
	pantheonReligionID
)
	local jerusalemReligion = HolyLandRules.GetJerusalemReligion(
		ownerPlayer,
		jerusalemCivilizationID,
		pantheonReligionID
	)
	return HolyLandRules.IsQualifyingPartner(
		ownerPlayer,
		destinationPlayer,
		jerusalemReligion,
		pantheonReligionID
	)
end
