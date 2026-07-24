local TYPE_IDS = {
	CIVILIZATION_JERUSALEM = 100,
	TRAIT_HOLY_LAND = 101,
	BUILDING_JERUSALEM_HOLY_SEPULCHER = 102,
	UNIT_JERUSALEM_CRUSADER = 103,
	BUILDING_JERUSALEM_HOLY_LAND_YIELDS = 104,
	PROMOTION_JERUSALEM_CRUSADER_LINEAGE = 201,
	PROMOTION_JERUSALEM_CRUSADER_HOLY_CITY = 202,
	PROMOTION_JERUSALEM_CRUSADER_RELIGIOUS_TERRITORY = 203,
	PROMOTION_JERUSALEM_CRUSADER_DIFFERENT_RELIGION = 204,
}

GameInfoTypes = TYPE_IDS
ReligionTypes = { RELIGION_PANTHEON = 0 }
DirectionTypes = { NUM_DIRECTION_TYPES = 6 }
GameDefines = { MAX_MAJOR_CIVS = 2 }

local religions = { { ID = 1 } }
GameInfo = {
	Religions = function()
		local index = 0
		return function()
			index = index + 1
			return religions[index]
		end
	end,
}

Game = {
	GetHolyCityForReligion = function()
		return nil
	end,
}

local function newCity(id, ownerID, majorityReligion)
	local city = {
		id = id,
		ownerID = ownerID,
		majorityReligion = majorityReligion,
		buildings = {},
	}

	function city:GetID()
		return self.id
	end

	function city:GetOwner()
		return self.ownerID
	end

	function city:GetReligiousMajority()
		return self.majorityReligion
	end

	function city:GetNumRealBuilding(buildingID)
		return self.buildings[buildingID] or 0
	end

	function city:SetNumRealBuilding(buildingID, count)
		self.buildings[buildingID] = count
	end

	return city
end

local jerusalemCapital = newCity(10, 0, 1)
local jerusalemOutpost = newCity(11, 0, 1)
local cityStateCapital = newCity(20, 22, 1)
local sameReligionCapital = newCity(30, 1, 1)
local activeRoutes = {
	{
		FromCity = jerusalemCapital,
		ToCity = cityStateCapital,
	},
}

local adjacentOwnerID = 63
local promotionState = {}
local barbarianUnit = {
	GetOwner = function()
		return adjacentOwnerID
	end,
}
local adjacentPlot = {
	GetPlotCity = function()
		return nil
	end,
	GetNumUnits = function()
		return 1
	end,
	GetUnit = function()
		return barbarianUnit
	end,
}
local crusaderPlot = {
	GetX = function()
		return 0
	end,
	GetY = function()
		return 0
	end,
	GetOwner = function()
		return -1
	end,
	GetPlotCity = function()
		return nil
	end,
	GetWorkingCity = function()
		return nil
	end,
}
local crusader = {
	IsDead = function()
		return false
	end,
	IsHasPromotion = function(_, promotionID)
		return promotionID == TYPE_IDS.PROMOTION_JERUSALEM_CRUSADER_LINEAGE
	end,
	GetOwner = function()
		return 0
	end,
	GetPlot = function()
		return crusaderPlot
	end,
	SetHasPromotion = function(_, promotionID, enabled)
		promotionState[promotionID] = enabled
	end,
}

Map = {
	PlotDistance = function()
		return 99
	end,
	PlotDirection = function(_, _, direction)
		if direction == 0 then
			return adjacentPlot
		end
		return nil
	end,
}

local function iterator(values)
	local index = 0
	return function()
		index = index + 1
		return values[index]
	end
end

local function newPlayer(options)
	local player = options

	function player:IsAlive()
		return true
	end

	function player:GetCivilizationType()
		return self.civilizationType
	end

	function player:GetReligionCreatedByPlayer()
		return self.foundedReligion
	end

	function player:GetCapitalCity()
		return self.capital
	end

	function player:GetID()
		return self.id
	end

	function player:GetTradeRoutes()
		return activeRoutes
	end

	function player:Cities()
		return iterator(self.cities or {})
	end

	function player:Units()
		return iterator(self.units or {})
	end

	function player:IsBarbarian()
		return self.barbarian == true
	end

	function player:IsMinorCiv()
		return self.minor == true
	end

	function player:GetTeam()
		return self.team
	end

	return player
end

Players = {
	[0] = newPlayer({
		id = 0,
		team = 0,
		civilizationType = TYPE_IDS.CIVILIZATION_JERUSALEM,
		foundedReligion = 1,
		capital = jerusalemCapital,
		cities = { jerusalemCapital, jerusalemOutpost },
		units = { crusader },
	}),
	[1] = newPlayer({
		id = 1,
		team = 1,
		civilizationType = 999,
		foundedReligion = 1,
		capital = sameReligionCapital,
	}),
	[22] = newPlayer({
		id = 22,
		team = 22,
		civilizationType = 998,
		foundedReligion = -1,
		capital = cityStateCapital,
		minor = true,
	}),
	[63] = newPlayer({
		id = 63,
		team = 63,
		civilizationType = 997,
		foundedReligion = -1,
		barbarian = true,
	}),
}

Teams = {
	[0] = {
		IsAtWar = function(_, otherTeam)
			return otherTeam ~= 0
		end,
	},
}

local handlers = {}
GameEvents = {
	PlayerDoTurn = {
		Add = function(handler)
			handlers.playerDoTurn = handler
		end,
	},
	UnitSetXY = {
		Add = function(handler)
			handlers.unitSetXY = handler
		end,
	},
}
Events = {
	LoadScreenClose = {
		Add = function(handler)
			handlers.loadScreenClose = handler
		end,
	},
}

assert(
	arg and type(arg[1]) == "string" and arg[1] ~= "",
	"Usage: texlua JerusalemRuntimeTest.lua <path-to-Jerusalem.lua>"
)
dofile(arg[1])

jerusalemOutpost.buildings[
	TYPE_IDS.BUILDING_JERUSALEM_HOLY_LAND_YIELDS
] = 2
handlers.unitSetXY(0)
assert(
	jerusalemCapital:GetNumRealBuilding(
		TYPE_IDS.BUILDING_JERUSALEM_HOLY_LAND_YIELDS
	) == 1,
	"an outbound route to a same-religion city-state must grant one bonus"
)
assert(
	jerusalemOutpost:GetNumRealBuilding(
		TYPE_IDS.BUILDING_JERUSALEM_HOLY_LAND_YIELDS
	) == 0,
	"Holy Land yield buildings must exist only in the current capital"
)
assert(
	promotionState[
		TYPE_IDS.PROMOTION_JERUSALEM_CRUSADER_DIFFERENT_RELIGION
	] == true,
	"an adjacent barbarian must activate Holy War"
)

adjacentOwnerID = 1
handlers.unitSetXY(1)
assert(
	promotionState[
		TYPE_IDS.PROMOTION_JERUSALEM_CRUSADER_DIFFERENT_RELIGION
	] == false,
	"an adjacent same-religion major must not activate Holy War"
)

sameReligionCapital.majorityReligion = -1
handlers.unitSetXY(1)
assert(
	promotionState[
		TYPE_IDS.PROMOTION_JERUSALEM_CRUSADER_DIFFERENT_RELIGION
	] == true,
	"an adjacent at-war major with no full religion must activate Holy War"
)

activeRoutes = {}
handlers.unitSetXY(1)
assert(
	jerusalemCapital:GetNumRealBuilding(
		TYPE_IDS.BUILDING_JERUSALEM_HOLY_LAND_YIELDS
	) == 1,
	"foreign movement must not perform unrelated Holy Land reconciliation"
)
handlers.unitSetXY(0)
assert(
	jerusalemCapital:GetNumRealBuilding(
		TYPE_IDS.BUILDING_JERUSALEM_HOLY_LAND_YIELDS
	) == 0,
	"Jerusalem movement must reconcile a changed route set immediately"
)

print("Jerusalem runtime tests passed")
