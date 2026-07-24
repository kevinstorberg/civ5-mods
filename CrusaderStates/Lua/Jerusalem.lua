local function requireType(typeName)
	return assert(
		GameInfoTypes[typeName],
		"Kingdom of Jerusalem: missing database type " .. typeName
	)
end

local CIVILIZATION_JERUSALEM = requireType("CIVILIZATION_JERUSALEM")
requireType("TRAIT_HOLY_LAND")

requireType(
	"BUILDING_JERUSALEM_HOLY_SEPULCHER"
)
requireType("UNIT_JERUSALEM_CRUSADER")
local BUILDING_HOLY_LAND_YIELDS = requireType(
	"BUILDING_JERUSALEM_HOLY_LAND_YIELDS"
)
local PROMOTION_CRUSADER_LINEAGE = requireType(
	"PROMOTION_JERUSALEM_CRUSADER_LINEAGE"
)
local PROMOTION_CRUSADER_HOLY_CITY = requireType(
	"PROMOTION_JERUSALEM_CRUSADER_HOLY_CITY"
)
local PROMOTION_CRUSADER_RELIGIOUS_TERRITORY = requireType(
	"PROMOTION_JERUSALEM_CRUSADER_RELIGIOUS_TERRITORY"
)
local PROMOTION_CRUSADER_DIFFERENT_RELIGION = requireType(
	"PROMOTION_JERUSALEM_CRUSADER_DIFFERENT_RELIGION"
)

local PANTHEON_RELIGION = assert(
	ReligionTypes.RELIGION_PANTHEON,
	"Kingdom of Jerusalem: RELIGION_PANTHEON is missing"
)
local HOLY_CITY_RADIUS = 3

include("HolyLandRules")
assert(
	HolyLandRules,
	"Kingdom of Jerusalem: Holy Land rules failed to load"
)

local function isFullReligion(religionID)
	return HolyLandRules.IsFullReligion(
		religionID,
		PANTHEON_RELIGION
	)
end

local function isLivingJerusalemPlayer(player)
	return HolyLandRules.IsLivingJerusalemPlayer(
		player,
		CIVILIZATION_JERUSALEM
	)
end

local function getJerusalemReligion(player)
	assert(
		isLivingJerusalemPlayer(player),
		"Kingdom of Jerusalem: religion requested for an invalid player"
	)

	return HolyLandRules.GetJerusalemReligion(
		player,
		CIVILIZATION_JERUSALEM,
		PANTHEON_RELIGION
	)
end

local function getFollowedReligion(player)
	return HolyLandRules.GetFollowedReligion(
		player,
		PANTHEON_RELIGION
	)
end

local function computeHolyLandPartners(player, jerusalemReligion)
	local partners = {}
	if not isFullReligion(jerusalemReligion) then
		return partners
	end

	local ownerID = player:GetID()
	for _, route in ipairs(player:GetTradeRoutes() or {}) do
		local fromCity = route.FromCity
		local toCity = route.ToCity
		if fromCity
			and toCity
			and fromCity:GetOwner() == ownerID
		then
			local destinationID = toCity:GetOwner()
			local destinationPlayer = Players[destinationID]
			if HolyLandRules.IsQualifyingPartner(
				player,
				destinationPlayer,
				jerusalemReligion,
				PANTHEON_RELIGION
			) then
				partners[destinationID] = true
			end
		end
	end

	return partners
end

local function countSet(values)
	local count = 0
	for _ in pairs(values) do
		count = count + 1
	end
	return count
end

local function applyHolyLandYieldCount(player, partnerCount)
	assert(
		partnerCount >= 0 and partnerCount == math.floor(partnerCount),
		"Kingdom of Jerusalem: Holy Land partner count must be a non-negative integer"
	)

	local capital = player:GetCapitalCity()
	local capitalID = nil
	if not capital then
		partnerCount = 0
	else
		capitalID = capital:GetID()
	end

	for city in player:Cities() do
		local expectedCount =
			city:GetID() == capitalID and partnerCount or 0
		if city:GetNumRealBuilding(BUILDING_HOLY_LAND_YIELDS)
			~= expectedCount
		then
			city:SetNumRealBuilding(
				BUILDING_HOLY_LAND_YIELDS,
				expectedCount
			)
		end
		assert(
			city:GetNumRealBuilding(BUILDING_HOLY_LAND_YIELDS)
				== expectedCount,
			"Kingdom of Jerusalem: Holy Land yield reconciliation failed"
		)
	end
end

local function isWithinHolyCityRadius(unit)
	local unitPlot = unit:GetPlot()
	if not unitPlot then
		return false
	end

	for religion in GameInfo.Religions() do
		if isFullReligion(religion.ID) then
			local holyCity = Game.GetHolyCityForReligion(religion.ID, -1)
			if holyCity
				and Map.PlotDistance(
					unitPlot:GetX(),
					unitPlot:GetY(),
					holyCity:GetX(),
					holyCity:GetY()
				) <= HOLY_CITY_RADIUS
			then
				return true
			end
		end
	end

	return false
end

local function getPlotOwningCity(plot)
	if not plot then
		return nil
	end

	local plotCity = plot:GetPlotCity()
	if plotCity then
		return plotCity
	end

	return plot:GetWorkingCity()
end

local function isInJerusalemReligiousTerritory(unit, jerusalemReligion)
	if not isFullReligion(jerusalemReligion) then
		return false
	end

	local plot = unit:GetPlot()
	if not plot or plot:GetOwner() < 0 then
		return false
	end

	local owningCity = getPlotOwningCity(plot)
	return owningCity ~= nil
		and owningCity:GetOwner() == plot:GetOwner()
		and owningCity:GetReligiousMajority() == jerusalemReligion
end

local function qualifiesForHolyWar(
	jerusalemPlayer,
	otherPlayerID,
	jerusalemReligion
)
	if not isFullReligion(jerusalemReligion)
		or otherPlayerID == nil
		or otherPlayerID < 0
		or otherPlayerID == jerusalemPlayer:GetID()
	then
		return false
	end

	local otherPlayer = Players[otherPlayerID]
	if not otherPlayer
		or not otherPlayer:IsAlive()
	then
		return false
	end

	if otherPlayer:IsBarbarian() then
		return true
	end

	if otherPlayer:IsMinorCiv() then
		return false
	end

	if not Teams[jerusalemPlayer:GetTeam()]:IsAtWar(otherPlayer:GetTeam()) then
		return false
	end

	local otherReligion = getFollowedReligion(otherPlayer)
	return not isFullReligion(otherReligion)
		or otherReligion ~= jerusalemReligion
end

local function isNearDifferentReligionEnemy(
	unit,
	jerusalemPlayer,
	jerusalemReligion
)
	local unitPlot = unit:GetPlot()
	if not unitPlot then
		return false
	end

	for direction = 0, DirectionTypes.NUM_DIRECTION_TYPES - 1 do
		local adjacentPlot = Map.PlotDirection(
			unitPlot:GetX(),
			unitPlot:GetY(),
			direction
		)
		if adjacentPlot then
			local adjacentCity = adjacentPlot:GetPlotCity()
			if adjacentCity
				and qualifiesForHolyWar(
					jerusalemPlayer,
					adjacentCity:GetOwner(),
					jerusalemReligion
				)
			then
				return true
			end

			for unitIndex = 0, adjacentPlot:GetNumUnits() - 1 do
				local adjacentUnit = adjacentPlot:GetUnit(unitIndex)
				if adjacentUnit
					and qualifiesForHolyWar(
						jerusalemPlayer,
						adjacentUnit:GetOwner(),
						jerusalemReligion
					)
				then
					return true
				end
			end
		end
	end

	return false
end

local function computeCrusaderFlags(unit, player, jerusalemReligion)
	return {
		holyCity = isWithinHolyCityRadius(unit),
		religiousTerritory = isInJerusalemReligiousTerritory(
			unit,
			jerusalemReligion
		),
		differentReligion = isNearDifferentReligionEnemy(
			unit,
			player,
			jerusalemReligion
		),
	}
end

local function applyCrusaderFlags(unit, flags)
	unit:SetHasPromotion(
		PROMOTION_CRUSADER_HOLY_CITY,
		flags.holyCity
	)
	unit:SetHasPromotion(
		PROMOTION_CRUSADER_RELIGIOUS_TERRITORY,
		flags.religiousTerritory
	)
	unit:SetHasPromotion(
		PROMOTION_CRUSADER_DIFFERENT_RELIGION,
		flags.differentReligion
	)
end

local function refreshCrusader(unit)
	if not unit
		or unit:IsDead()
		or not unit:IsHasPromotion(PROMOTION_CRUSADER_LINEAGE)
	then
		return
	end

	local player = Players[unit:GetOwner()]
	if not isLivingJerusalemPlayer(player) then
		applyCrusaderFlags(unit, {
			holyCity = false,
			religiousTerritory = false,
			differentReligion = false,
		})
		return
	end

	applyCrusaderFlags(
		unit,
		computeCrusaderFlags(unit, player, getJerusalemReligion(player))
	)
end

local function refreshJerusalemUnits(player)
	for unit in player:Units() do
		refreshCrusader(unit)
	end
end

local function refreshJerusalemPlayer(player)
	assert(
		isLivingJerusalemPlayer(player),
		"Kingdom of Jerusalem: refresh requested for an invalid player"
	)

	local jerusalemReligion = getJerusalemReligion(player)
	local partners = computeHolyLandPartners(player, jerusalemReligion)
	applyHolyLandYieldCount(player, countSet(partners))
	refreshJerusalemUnits(player)
end

local function refreshAllJerusalemPlayers()
	for playerID = 0, GameDefines.MAX_MAJOR_CIVS - 1 do
		local player = Players[playerID]
		if isLivingJerusalemPlayer(player) then
			refreshJerusalemPlayer(player)
		end
	end
end

local function onPlayerDoTurn(playerID)
	local player = Players[playerID]
	if isLivingJerusalemPlayer(player) then
		refreshJerusalemPlayer(player)
	end
end

local function onUnitSetXY(movedPlayerID)
	-- UnitSetXY has no old coordinates, so a live full refresh is the only
	-- cache-free way to clear adjacency bonuses when an enemy moves away.
	for playerID = 0, GameDefines.MAX_MAJOR_CIVS - 1 do
		local player = Players[playerID]
		if isLivingJerusalemPlayer(player) then
			if movedPlayerID == playerID then
				refreshJerusalemPlayer(player)
			else
				refreshJerusalemUnits(player)
			end
		end
	end
end

GameEvents.PlayerDoTurn.Add(onPlayerDoTurn)
GameEvents.UnitSetXY.Add(onUnitSetXY)
Events.LoadScreenClose.Add(refreshAllJerusalemPlayers)

print("Kingdom of Jerusalem: gameplay loaded")
