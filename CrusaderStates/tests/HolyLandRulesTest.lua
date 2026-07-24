assert(
	arg and type(arg[1]) == "string" and arg[1] ~= "",
	"Usage: texlua HolyLandRulesTest.lua <path-to-HolyLandRules.lua>"
)
dofile(arg[1])

local JERUSALEM_CIVILIZATION = 100
local OTHER_CIVILIZATION = 200
local PANTHEON_RELIGION = 0
local JERUSALEM_RELIGION = 1
local OTHER_RELIGION = 2

local function newPlayer(config)
	local capital = config.hasCapital == false and nil or {
		GetReligiousMajority = function()
			return config.majorityReligion
		end,
	}

	return {
		GetID = function()
			return config.id
		end,
		IsAlive = function()
			return config.alive ~= false
		end,
		IsBarbarian = function()
			return config.barbarian == true
		end,
		GetCivilizationType = function()
			return config.civilization
		end,
		GetReligionCreatedByPlayer = function()
			return config.foundedReligion
		end,
		GetCapitalCity = function()
			return capital
		end,
	}
end

local function assertQualification(label, expected, owner, destination)
	assert(
		HolyLandRules.QualifiesForHolyLand(
			owner,
			destination,
			JERUSALEM_CIVILIZATION,
			PANTHEON_RELIGION
		) == expected,
		label
	)
end

local jerusalem = newPlayer({
	id = 0,
	civilization = JERUSALEM_CIVILIZATION,
	foundedReligion = JERUSALEM_RELIGION,
	majorityReligion = JERUSALEM_RELIGION,
})
local sameReligionMajor = newPlayer({
	id = 1,
	civilization = OTHER_CIVILIZATION,
	majorityReligion = JERUSALEM_RELIGION,
})
local sameReligionCityState = newPlayer({
	id = 22,
	civilization = OTHER_CIVILIZATION,
	majorityReligion = JERUSALEM_RELIGION,
})

assertQualification(
	"same-religion major must qualify",
	true,
	jerusalem,
	sameReligionMajor
)
assertQualification(
	"same-religion city-state must qualify",
	true,
	jerusalem,
	sameReligionCityState
)
assertQualification(
	"different-religion destination must not qualify",
	false,
	jerusalem,
	newPlayer({
		id = 2,
		civilization = OTHER_CIVILIZATION,
		majorityReligion = OTHER_RELIGION,
	})
)
assertQualification(
	"religionless destination must not qualify",
	false,
	jerusalem,
	newPlayer({
		id = 3,
		civilization = OTHER_CIVILIZATION,
		majorityReligion = -1,
	})
)
assertQualification(
	"internal route must not qualify",
	false,
	jerusalem,
	jerusalem
)
assertQualification(
	"barbarian destination must not qualify",
	false,
	jerusalem,
	newPlayer({
		id = 63,
		civilization = OTHER_CIVILIZATION,
		majorityReligion = JERUSALEM_RELIGION,
		barbarian = true,
	})
)
assertQualification(
	"dead destination must not qualify",
	false,
	jerusalem,
	newPlayer({
		id = 4,
		civilization = OTHER_CIVILIZATION,
		majorityReligion = JERUSALEM_RELIGION,
		alive = false,
	})
)
assertQualification(
	"Jerusalem without a full religion must not qualify",
	false,
	newPlayer({
		id = 0,
		civilization = JERUSALEM_CIVILIZATION,
		foundedReligion = -1,
		majorityReligion = PANTHEON_RELIGION,
	}),
	sameReligionMajor
)
assertQualification(
	"non-Jerusalem owner must not qualify",
	false,
	newPlayer({
		id = 0,
		civilization = OTHER_CIVILIZATION,
		foundedReligion = JERUSALEM_RELIGION,
		majorityReligion = JERUSALEM_RELIGION,
	}),
	sameReligionMajor
)

print("Holy Land rules tests passed")
