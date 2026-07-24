HolyLandTradeDisplay = HolyLandTradeDisplay or {}

HolyLandTradeDisplay.GOLD_BONUS_HUNDREDTHS = 400

function HolyLandTradeDisplay.GetDisplayedMineYield(
	yieldID,
	mineYield,
	isQualifying,
	goldYieldID
)
	assert(
		type(mineYield) == "number",
		"Holy Land trade display: mine yield must be numeric"
	)
	assert(
		type(goldYieldID) == "number",
		"Holy Land trade display: Gold yield ID must be numeric"
	)

	if isQualifying and yieldID == goldYieldID then
		return mineYield
			+ HolyLandTradeDisplay.GOLD_BONUS_HUNDREDTHS
	end

	return mineYield
end

function HolyLandTradeDisplay.AppendTooltip(
	baseTooltip,
	bonusText,
	isQualifying
)
	assert(
		type(baseTooltip) == "string",
		"Holy Land trade display: base tooltip must be text"
	)
	assert(
		type(bonusText) == "string" and bonusText ~= "",
		"Holy Land trade display: bonus tooltip must be non-empty text"
	)

	if not isQualifying then
		return baseTooltip
	end

	return baseTooltip .. "[NEWLINE][NEWLINE]" .. bonusText
end
