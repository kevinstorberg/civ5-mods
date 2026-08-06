local TYPE_IDS = {
	CIVILIZATION_PRUSSIA = 100,
	TRAIT_ENLIGHTENED_ABSOLUTISM = 101,
	BUILDING_PRUSSIA_ENLIGHTENED_ABSOLUTISM = 102,
	BUILDING_PRUSSIA_STAFF_COLLEGE = 103,
	UNIT_PRUSSIA_GENERAL_STAFF_OFFICER = 104,
	PROMOTION_MORALE = 200,
	PROMOTION_GREAT_GENERAL = 201,
	PROMOTION_SPAWN_GENERALS_II = 202,
}

GameInfoTypes = TYPE_IDS
DomainTypes = {
	DOMAIN_LAND = 0,
	DOMAIN_SEA = 1,
	DOMAIN_AIR = 2,
}
GameDefines = { MAX_MAJOR_CIVS = 2 }

local function iterator(values)
	local index = 0
	return function()
		index = index + 1
		return values[index]
	end
end

local function newCity(id, ownerID)
	local city = {
		id = id,
		ownerID = ownerID,
		buildings = {},
	}

	function city:GetID()
		return self.id
	end

	function city:GetOwner()
		return self.ownerID
	end

	function city:GetNumRealBuilding(buildingID)
		return self.buildings[buildingID] or 0
	end

	function city:SetNumRealBuilding(buildingID, count)
		self.buildings[buildingID] = count
	end

	return city
end

local function newUnit(id, ownerID, options)
	local unit = {
		id = id,
		ownerID = ownerID,
		baseCombat = options.baseCombat or 0,
		domain = options.domain or DomainTypes.DOMAIN_LAND,
		promotions = {},
	}

	function unit:GetID()
		return self.id
	end

	function unit:GetOwner()
		return self.ownerID
	end

	function unit:IsDead()
		return false
	end

	function unit:GetBaseCombatStrength()
		return self.baseCombat
	end

	function unit:GetDomainType()
		return self.domain
	end

	function unit:SetHasPromotion(promotionID, enabled)
		self.promotions[promotionID] = enabled
	end

	function unit:IsHasPromotion(promotionID)
		return self.promotions[promotionID] == true
	end

	return unit
end

local function newPlayer(id, civilizationType, cities, units)
	local player = {
		id = id,
		civilizationType = civilizationType,
		cities = cities,
		units = units,
		goldenAge = false,
		capital = cities[1],
	}

	function player:IsAlive()
		return true
	end

	function player:IsBarbarian()
		return false
	end

	function player:IsMinorCiv()
		return false
	end

	function player:GetCivilizationType()
		return self.civilizationType
	end

	function player:IsGoldenAge()
		return self.goldenAge
	end

	function player:GetCapitalCity()
		return self.capital
	end

	function player:Cities()
		return iterator(self.cities)
	end

	function player:GetCityByID(cityID)
		for _, city in ipairs(self.cities) do
			if city:GetID() == cityID then
				return city
			end
		end
		return nil
	end

	function player:GetUnitByID(unitID)
		for _, unit in ipairs(self.units) do
			if unit:GetID() == unitID then
				return unit
			end
		end
		return nil
	end

	return player
end

local capital = newCity(10, 0)
local outpost = newCity(11, 0)
local infantry = newUnit(20, 0, {
	baseCombat = 16,
	domain = DomainTypes.DOMAIN_LAND,
})
local prussia = newPlayer(
	0,
	TYPE_IDS.CIVILIZATION_PRUSSIA,
	{ capital, outpost },
	{ infantry }
)
local foreignCapital = newCity(30, 1)
local foreign = newPlayer(1, 999, { foreignCapital }, {})
Players = { [0] = prussia, [1] = foreign }

local handlers = {}
local function event(name)
	return {
		Add = function(handler)
			handlers[name] = handler
		end,
	}
end

GameEvents = {
	PlayerDoTurn = event("playerDoTurn"),
	UnitSetXY = event("unitSetXY"),
	PlayerCityFounded = event("playerCityFounded"),
	CityCaptureComplete = event("cityCaptureComplete"),
	CityTrained = event("cityTrained"),
}
Events = { LoadScreenClose = event("loadScreenClose") }

assert(
	arg and type(arg[1]) == "string" and arg[1] ~= "",
	"Usage: texlua PrussiaRuntimeTest.lua <path-to-Prussia.lua>"
)
dofile(arg[1])

local function has(unit, promotionID)
	return unit:IsHasPromotion(promotionID)
end

local function assertStaffBundle(unit, expected)
	for _, promotionID in ipairs({
		TYPE_IDS.PROMOTION_MORALE,
		TYPE_IDS.PROMOTION_GREAT_GENERAL,
		TYPE_IDS.PROMOTION_SPAWN_GENERALS_II,
	}) do
		assert(
			has(unit, promotionID) == expected,
			"unexpected Staff College promotion state"
		)
	end
end

capital.buildings[TYPE_IDS.BUILDING_PRUSSIA_ENLIGHTENED_ABSOLUTISM] = 4
outpost.buildings[TYPE_IDS.BUILDING_PRUSSIA_ENLIGHTENED_ABSOLUTISM] = 3
handlers.loadScreenClose()
assert(
	capital:GetNumRealBuilding(
		TYPE_IDS.BUILDING_PRUSSIA_ENLIGHTENED_ABSOLUTISM
	) == 0
		and outpost:GetNumRealBuilding(
			TYPE_IDS.BUILDING_PRUSSIA_ENLIGHTENED_ABSOLUTISM
		) == 0,
	"loading outside a Golden Age must clear every science dummy"
)

prussia.goldenAge = true
handlers.unitSetXY(0, infantry:GetID(), 5, 5)
assert(
	capital:GetNumRealBuilding(
		TYPE_IDS.BUILDING_PRUSSIA_ENLIGHTENED_ABSOLUTISM
	) == 1
		and outpost:GetNumRealBuilding(
			TYPE_IDS.BUILDING_PRUSSIA_ENLIGHTENED_ABSOLUTISM
		) == 0,
	"a Prussian movement refresh must activate Golden Age science"
)

prussia.goldenAge = false
handlers.playerDoTurn(0)
assert(
	capital:GetNumRealBuilding(
		TYPE_IDS.BUILDING_PRUSSIA_ENLIGHTENED_ABSOLUTISM
	) == 0,
	"ending a Golden Age must remove the science modifier"
)

prussia.goldenAge = true
capital.buildings[TYPE_IDS.BUILDING_PRUSSIA_ENLIGHTENED_ABSOLUTISM] = 4
outpost.buildings[TYPE_IDS.BUILDING_PRUSSIA_ENLIGHTENED_ABSOLUTISM] = 3
prussia.capital = nil
handlers.playerDoTurn(0)
assert(
	capital:GetNumRealBuilding(
		TYPE_IDS.BUILDING_PRUSSIA_ENLIGHTENED_ABSOLUTISM
	) == 0
		and outpost:GetNumRealBuilding(
			TYPE_IDS.BUILDING_PRUSSIA_ENLIGHTENED_ABSOLUTISM
		) == 0,
	"a missing capital must clear every science dummy"
)

prussia.capital = outpost
handlers.playerCityFounded(0)
assert(
	capital:GetNumRealBuilding(
		TYPE_IDS.BUILDING_PRUSSIA_ENLIGHTENED_ABSOLUTISM
	) == 0
		and outpost:GetNumRealBuilding(
			TYPE_IDS.BUILDING_PRUSSIA_ENLIGHTENED_ABSOLUTISM
		) == 1,
	"the science modifier must follow the current capital"
)

capital.buildings[TYPE_IDS.BUILDING_PRUSSIA_STAFF_COLLEGE] = 1
local graduate = newUnit(23, 0, {
	baseCombat = 21,
	domain = DomainTypes.DOMAIN_LAND,
})
local purchasedShip = newUnit(24, 0, {
	baseCombat = 25,
	domain = DomainTypes.DOMAIN_SEA,
})
local trainedAircraft = newUnit(25, 0, {
	baseCombat = 0,
	domain = DomainTypes.DOMAIN_AIR,
})
local trainedCivilian = newUnit(26, 0, {
	baseCombat = 0,
	domain = DomainTypes.DOMAIN_LAND,
})
for _, unit in ipairs({
	graduate,
	purchasedShip,
	trainedAircraft,
	trainedCivilian,
}) do
	table.insert(prussia.units, unit)
end

handlers.cityTrained(0, capital:GetID(), graduate:GetID(), false, false)
handlers.cityTrained(0, capital:GetID(), purchasedShip:GetID(), true, false)
handlers.cityTrained(0, capital:GetID(), trainedAircraft:GetID(), false, false)
handlers.cityTrained(0, capital:GetID(), trainedCivilian:GetID(), false, true)
assertStaffBundle(graduate, true)
assertStaffBundle(purchasedShip, true)
assertStaffBundle(trainedAircraft, false)
assertStaffBundle(trainedCivilian, false)

local outsideGraduate = newUnit(27, 0, {
	baseCombat = 18,
	domain = DomainTypes.DOMAIN_LAND,
})
table.insert(prussia.units, outsideGraduate)
handlers.cityTrained(0, outpost:GetID(), outsideGraduate:GetID(), false, false)
assertStaffBundle(outsideGraduate, false)

graduate.ownerID = 1
for index, unit in ipairs(prussia.units) do
	if unit == graduate then
		table.remove(prussia.units, index)
		break
	end
end
table.insert(foreign.units, graduate)
handlers.playerDoTurn(1)
assertStaffBundle(graduate, true)

handlers.unitSetXY(1, graduate:GetID(), 5, 5)
assertStaffBundle(graduate, true)

prussia.goldenAge = false
prussia.capital = nil
outpost.buildings[TYPE_IDS.BUILDING_PRUSSIA_ENLIGHTENED_ABSOLUTISM] = 1
handlers.cityCaptureComplete(0, true, 8, 8, 1, 5, true)
assert(
	outpost:GetNumRealBuilding(
		TYPE_IDS.BUILDING_PRUSSIA_ENLIGHTENED_ABSOLUTISM
	) == 0,
	"capital capture must clear a stale science dummy"
)

print("Prussia runtime tests passed")
