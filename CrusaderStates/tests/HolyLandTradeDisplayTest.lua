assert(
	arg and type(arg[1]) == "string" and arg[1] ~= "",
	"Usage: texlua HolyLandTradeDisplayTest.lua <path-to-display-module>"
)
dofile(arg[1])

local GOLD_YIELD = 2
local FAITH_YIELD = 5
local baseGold = 525
local destinationGold = 100

local displayedGold = HolyLandTradeDisplay.GetDisplayedMineYield(
	GOLD_YIELD,
	baseGold,
	true,
	GOLD_YIELD
)
assert(displayedGold == 925, "qualifying route must display +4 Gold")
assert(baseGold == 525, "display calculation must not mutate engine yield")
assert(
	displayedGold - destinationGold == 825,
	"Gold delta must sort by the displayed route total"
)
assert(
	HolyLandTradeDisplay.GetDisplayedMineYield(
		GOLD_YIELD,
		baseGold,
		false,
		GOLD_YIELD
	) == baseGold,
	"nonqualifying Gold must remain unchanged"
)
assert(
	HolyLandTradeDisplay.GetDisplayedMineYield(
		FAITH_YIELD,
	200,
		true,
		GOLD_YIELD
	) == 200,
	"non-Gold yields must remain unchanged"
)

local baseTooltip = "Base route details"
local bonusText = "Holy Land bonus"
local qualifyingTooltip = HolyLandTradeDisplay.AppendTooltip(
	baseTooltip,
	bonusText,
	true
)
assert(
	qualifyingTooltip
		== "Base route details[NEWLINE][NEWLINE]Holy Land bonus",
	"qualifying tooltip must append the bonus exactly once"
)
assert(
	HolyLandTradeDisplay.AppendTooltip(
		baseTooltip,
		bonusText,
		false
	) == baseTooltip,
	"nonqualifying tooltip must remain unchanged"
)

print("Holy Land trade display tests passed")
