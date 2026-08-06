local function requireType(typeName)
	return assert(
		GameInfoTypes[typeName],
		"Prussia: missing database type " .. typeName
	)
end

local CIVILIZATION_PRUSSIA = requireType("CIVILIZATION_PRUSSIA")
requireType("TRAIT_ENLIGHTENED_ABSOLUTISM")
local BUILDING_ENLIGHTENED_ABSOLUTISM = requireType(
	"BUILDING_PRUSSIA_ENLIGHTENED_ABSOLUTISM"
)
local BUILDING_STAFF_COLLEGE = requireType(
	"BUILDING_PRUSSIA_STAFF_COLLEGE"
)
requireType("UNIT_PRUSSIA_GENERAL_STAFF_OFFICER")

local STAFF_COLLEGE_PROMOTIONS = {
	requireType("PROMOTION_MORALE"),
	requireType("PROMOTION_GREAT_GENERAL"),
	requireType("PROMOTION_SPAWN_GENERALS_II"),
}

local DOMAIN_AIR = assert(
	DomainTypes.DOMAIN_AIR,
	"Prussia: DOMAIN_AIR is missing"
)

local function isLivingPrussianPlayer(player)
	return player ~= nil
		and player:IsAlive()
		and not player:IsBarbarian()
		and not player:IsMinorCiv()
		and player:GetCivilizationType() == CIVILIZATION_PRUSSIA
end

local function isStaffCollegeGraduate(unit)
	return unit ~= nil
		and not unit:IsDead()
		and unit:GetBaseCombatStrength() > 0
		and unit:GetDomainType() ~= DOMAIN_AIR
end

local function isGoldenAge(player)
	assert(
		isLivingPrussianPlayer(player),
		"Prussia: Golden Age state requested for an invalid player"
	)
	return player:IsGoldenAge()
end

local function applyScienceModifier(player, enabled)
	local capital = player:GetCapitalCity()
	local capitalID = capital and capital:GetID() or nil

	for city in player:Cities() do
		city:SetNumRealBuilding(BUILDING_ENLIGHTENED_ABSOLUTISM, 0)
	end

	if enabled and capital then
		capital:SetNumRealBuilding(BUILDING_ENLIGHTENED_ABSOLUTISM, 1)
	end

	for city in player:Cities() do
		local expectedCount = enabled
			and city:GetID() == capitalID
			and 1
			or 0
		assert(
			city:GetNumRealBuilding(BUILDING_ENLIGHTENED_ABSOLUTISM)
				== expectedCount,
			"Prussia: science modifier reconciliation failed"
		)
	end
end

local function refreshPrussianPlayer(player)
	assert(
		isLivingPrussianPlayer(player),
		"Prussia: refresh requested for an invalid player"
	)

	applyScienceModifier(player, isGoldenAge(player))
end

local function refreshPlayerByID(playerID)
	if type(playerID) ~= "number" then
		return
	end

	local player = Players[playerID]
	if isLivingPrussianPlayer(player) then
		refreshPrussianPlayer(player)
	end
end

local function applyStaffCollegePromotions(unit)
	assert(
		isStaffCollegeGraduate(unit),
		"Prussia: attempted to promote an ineligible Staff College graduate"
	)

	for _, promotionID in ipairs(STAFF_COLLEGE_PROMOTIONS) do
		unit:SetHasPromotion(promotionID, true)
		assert(
			unit:IsHasPromotion(promotionID),
			"Prussia: Staff College promotion application failed"
		)
	end
end

local function onCityTrained(playerID, cityID, unitID)
	assert(
		type(playerID) == "number"
			and type(cityID) == "number"
			and type(unitID) == "number",
		"Prussia: CityTrained received malformed IDs"
	)

	local player = Players[playerID]
	if not isLivingPrussianPlayer(player) then
		return
	end

	local city = assert(
		player:GetCityByID(cityID),
		"Prussia: CityTrained city does not exist"
	)
	local unit = assert(
		player:GetUnitByID(unitID),
		"Prussia: CityTrained unit does not exist"
	)
	assert(
		city:GetOwner() == playerID and unit:GetOwner() == playerID,
		"Prussia: CityTrained ownership mismatch"
	)

	if city:GetNumRealBuilding(BUILDING_STAFF_COLLEGE) > 0 then
		if isStaffCollegeGraduate(unit) then
			applyStaffCollegePromotions(unit)
		else
			for _, promotionID in ipairs(STAFF_COLLEGE_PROMOTIONS) do
				assert(
					not unit:IsHasPromotion(promotionID),
					"Prussia: excluded Staff College unit received a graduate promotion"
				)
			end
		end
	end

	refreshPrussianPlayer(player)
end

local function reconcileLoadedGame()
	for playerID = 0, GameDefines.MAX_MAJOR_CIVS - 1 do
		local player = Players[playerID]
		if isLivingPrussianPlayer(player) then
			refreshPrussianPlayer(player)
			print("Prussia: gameplay initialized for player " .. playerID)
		end
	end
end

local function onPlayerDoTurn(playerID)
	refreshPlayerByID(playerID)
end

local function onUnitSetXY(playerID)
	refreshPlayerByID(playerID)
end

local function onPlayerCityFounded(playerID)
	refreshPlayerByID(playerID)
end

local function onCityCaptureComplete(
	oldPlayerID,
	isCapital,
	x,
	y,
	newPlayerID
)
	refreshPlayerByID(oldPlayerID)
	refreshPlayerByID(newPlayerID)
end

Events.LoadScreenClose.Add(reconcileLoadedGame)
GameEvents.PlayerDoTurn.Add(onPlayerDoTurn)
GameEvents.UnitSetXY.Add(onUnitSetXY)
GameEvents.PlayerCityFounded.Add(onPlayerCityFounded)
GameEvents.CityCaptureComplete.Add(onCityCaptureComplete)
GameEvents.CityTrained.Add(onCityTrained)
