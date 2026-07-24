INSERT INTO IconTextureAtlases (
	Atlas,
	IconSize,
	Filename,
	IconsPerRow,
	IconsPerColumn
) VALUES
	('JERUSALEM_COLOR_ATLAS', 256, 'Jerusalem_Atlas256.dds', 2, 2),
	('JERUSALEM_COLOR_ATLAS', 128, 'Jerusalem_Atlas128.dds', 2, 2),
	('JERUSALEM_COLOR_ATLAS', 80, 'Jerusalem_Atlas80.dds', 2, 2),
	('JERUSALEM_COLOR_ATLAS', 64, 'Jerusalem_Atlas64.dds', 2, 2),
	('JERUSALEM_COLOR_ATLAS', 48, 'Jerusalem_Atlas48.dds', 2, 2),
	('JERUSALEM_COLOR_ATLAS', 45, 'Jerusalem_Atlas45.dds', 2, 2),
	('JERUSALEM_COLOR_ATLAS', 32, 'Jerusalem_Atlas32.dds', 2, 2),
	('JERUSALEM_COLOR_ATLAS', 24, 'Jerusalem_Atlas24.dds', 2, 2),
	('JERUSALEM_COLOR_ATLAS', 16, 'Jerusalem_Atlas16.dds', 2, 2),
	('JERUSALEM_ALPHA_ATLAS', 256, 'Jerusalem_Alpha256.dds', 2, 2),
	('JERUSALEM_ALPHA_ATLAS', 128, 'Jerusalem_Alpha128.dds', 2, 2),
	('JERUSALEM_ALPHA_ATLAS', 80, 'Jerusalem_Alpha80.dds', 2, 2),
	('JERUSALEM_ALPHA_ATLAS', 64, 'Jerusalem_Alpha64.dds', 2, 2),
	('JERUSALEM_ALPHA_ATLAS', 48, 'Jerusalem_Alpha48.dds', 2, 2),
	('JERUSALEM_ALPHA_ATLAS', 45, 'Jerusalem_Alpha45.dds', 2, 2),
	('JERUSALEM_ALPHA_ATLAS', 32, 'Jerusalem_Alpha32.dds', 2, 2),
	('JERUSALEM_ALPHA_ATLAS', 24, 'Jerusalem_Alpha24.dds', 2, 2),
	('JERUSALEM_ALPHA_ATLAS', 16, 'Jerusalem_Alpha16.dds', 2, 2);

INSERT INTO Colors (Type, Red, Green, Blue, Alpha) VALUES
	('COLOR_PLAYER_JERUSALEM_ICON', 1.0, 0.843137, 0.0, 1.0),
	('COLOR_PLAYER_JERUSALEM_BACKGROUND', 1.0, 1.0, 1.0, 1.0);

INSERT INTO PlayerColors (Type, PrimaryColor, SecondaryColor, TextColor) VALUES
	('PLAYERCOLOR_JERUSALEM', 'COLOR_PLAYER_JERUSALEM_ICON', 'COLOR_PLAYER_JERUSALEM_BACKGROUND', 'COLOR_PLAYER_BLACK_TEXT');

INSERT INTO Traits (Type, Description, ShortDescription) VALUES
	('TRAIT_HOLY_LAND', 'TXT_KEY_TRAIT_HOLY_LAND_DESCRIPTION', 'TXT_KEY_TRAIT_HOLY_LAND');

INSERT INTO BuildingClasses (
	Type,
	Description,
	DefaultBuilding,
	NoLimit
) VALUES (
	'BUILDINGCLASS_JERUSALEM_HOLY_LAND_YIELDS',
	'TXT_KEY_BUILDING_JERUSALEM_HOLY_LAND_YIELDS',
	'BUILDING_JERUSALEM_HOLY_LAND_YIELDS',
	1
);

INSERT INTO Buildings (
	Type,
	Description,
	Help,
	GoldMaintenance,
	NeverCapture,
	NukeImmune,
	Cost,
	HurryCostModifier,
	MinAreaSize,
	ConquestProb,
	BuildingClass,
	PortraitIndex,
	IconAtlas
) VALUES (
	'BUILDING_JERUSALEM_HOLY_LAND_YIELDS',
	'TXT_KEY_BUILDING_JERUSALEM_HOLY_LAND_YIELDS',
	'TXT_KEY_BUILDING_JERUSALEM_HOLY_LAND_YIELDS_HELP',
	0,
	1,
	1,
	-1,
	-1,
	-1,
	0,
	'BUILDINGCLASS_JERUSALEM_HOLY_LAND_YIELDS',
	19,
	'BW_ATLAS_1'
);

INSERT INTO Building_YieldChanges (BuildingType, YieldType, Yield) VALUES
	('BUILDING_JERUSALEM_HOLY_LAND_YIELDS', 'YIELD_FAITH', 2),
	('BUILDING_JERUSALEM_HOLY_LAND_YIELDS', 'YIELD_GOLD', 4);

INSERT INTO Buildings (
	Type,
	Description,
	Civilopedia,
	Strategy,
	Help,
	GoldMaintenance,
	Capital,
	NeverCapture,
	NukeImmune,
	Cost,
	HurryCostModifier,
	MinAreaSize,
	ConquestProb,
	Defense,
	ReligiousPressureModifier,
	BuildingClass,
	ArtDefineTag,
	GreatWorkSlotType,
	GreatWorkCount,
	DisplayPosition,
	PortraitIndex,
	IconAtlas,
	ArtInfoCulturalVariation,
	ArtInfoEraVariation,
	ArtInfoRandomVariation
)
SELECT
	'BUILDING_JERUSALEM_HOLY_SEPULCHER',
	'TXT_KEY_BUILDING_JERUSALEM_HOLY_SEPULCHER',
	'TXT_KEY_BUILDING_JERUSALEM_HOLY_SEPULCHER_PEDIA',
	'TXT_KEY_BUILDING_JERUSALEM_HOLY_SEPULCHER_STRATEGY',
	'TXT_KEY_BUILDING_JERUSALEM_HOLY_SEPULCHER_HELP',
	GoldMaintenance,
	Capital,
	NeverCapture,
	NukeImmune,
	Cost,
	HurryCostModifier,
	MinAreaSize,
	ConquestProb,
	Defense,
	100,
	BuildingClass,
	ArtDefineTag,
	GreatWorkSlotType,
	GreatWorkCount,
	DisplayPosition,
	3,
	'JERUSALEM_COLOR_ATLAS',
	ArtInfoCulturalVariation,
	ArtInfoEraVariation,
	ArtInfoRandomVariation
FROM Buildings
WHERE Type = 'BUILDING_PALACE';

INSERT INTO Building_YieldChanges (BuildingType, YieldType, Yield)
SELECT 'BUILDING_JERUSALEM_HOLY_SEPULCHER', YieldType, Yield
FROM Building_YieldChanges
WHERE BuildingType = 'BUILDING_PALACE';

INSERT INTO Building_YieldChanges (BuildingType, YieldType, Yield) VALUES
	('BUILDING_JERUSALEM_HOLY_SEPULCHER', 'YIELD_FAITH', 1);

INSERT INTO Civilizations (
	Type,
	Description,
	Civilopedia,
	CivilopediaTag,
	Strategy,
	Playable,
	AIPlayable,
	ShortDescription,
	Adjective,
	DefaultPlayerColor,
	ArtDefineTag,
	ArtStyleType,
	ArtStyleSuffix,
	ArtStylePrefix,
	DerivativeCiv,
	PortraitIndex,
	IconAtlas,
	AlphaIconAtlas,
	MapImage,
	DawnOfManQuote,
	DawnOfManImage,
	DawnOfManAudio,
	PackageID,
	SoundtrackTag
)
SELECT
	'CIVILIZATION_JERUSALEM',
	'TXT_KEY_CIV_JERUSALEM_DESC',
	'TXT_KEY_CIV_JERUSALEM_PEDIA',
	'TXT_KEY_CIVILOPEDIA_CIVILIZATIONS_JERUSALEM',
	'TXT_KEY_CIV_JERUSALEM_STRATEGY',
	1,
	1,
	'TXT_KEY_CIV_JERUSALEM_SHORT_DESC',
	'TXT_KEY_CIV_JERUSALEM_ADJECTIVE',
	'PLAYERCOLOR_JERUSALEM',
	ArtDefineTag,
	ArtStyleType,
	ArtStyleSuffix,
	ArtStylePrefix,
	DerivativeCiv,
	0,
	'JERUSALEM_COLOR_ATLAS',
	'JERUSALEM_ALPHA_ATLAS',
	'MapJerusalem.dds',
	'TXT_KEY_CIV_JERUSALEM_DOM',
	'Jerusalem_DOM.dds',
	NULL,
	NULL,
	SoundtrackTag
FROM Civilizations
WHERE Type = 'CIVILIZATION_BYZANTIUM';

-- Ethnic Diversity loads first through the optional reference. Prefer its
-- Levant family only when the Crusader's exact cultural art definition exists.
UPDATE Civilizations
SET ArtStyleSuffix = '_LEVANT'
WHERE Type = 'CIVILIZATION_JERUSALEM'
	AND EXISTS (
		SELECT 1
		FROM ArtDefine_UnitInfos
		WHERE Type = 'ART_DEF_UNIT_LONGSWORDSMAN_LEVANT'
	);

INSERT INTO Leaders (
	Type,
	Description,
	Civilopedia,
	CivilopediaTag,
	ArtDefineTag,
	VictoryCompetitiveness,
	WonderCompetitiveness,
	MinorCivCompetitiveness,
	Boldness,
	DiploBalance,
	WarmongerHate,
	WorkAgainstWillingness,
	WorkWithWillingness,
	DenounceWillingness,
	DoFWillingness,
	Loyalty,
	Neediness,
	Forgiveness,
	Chattiness,
	Meanness,
	PortraitIndex,
	IconAtlas,
	PackageID
)
SELECT
	'LEADER_BALDWIN_IV',
	'TXT_KEY_LEADER_BALDWIN_IV',
	'TXT_KEY_LEADER_BALDWIN_IV_PEDIA',
	'TXT_KEY_CIVILOPEDIA_LEADERS_BALDWIN_IV',
	'BaldwinIV_scene.xml',
	ai.VictoryCompetitiveness,
	ai.WonderCompetitiveness,
	ai.MinorCivCompetitiveness,
	ai.Boldness,
	ai.DiploBalance,
	ai.WarmongerHate,
	ai.WorkAgainstWillingness,
	ai.WorkWithWillingness,
	ai.DenounceWillingness,
	ai.DoFWillingness,
	ai.Loyalty,
	ai.Neediness,
	ai.Forgiveness,
	ai.Chattiness,
	ai.Meanness,
	1,
	'JERUSALEM_COLOR_ATLAS',
	NULL
FROM Leaders AS ai
WHERE ai.Type = 'LEADER_CASIMIR';

INSERT INTO Leader_MajorCivApproachBiases (LeaderType, MajorCivApproachType, Bias)
SELECT 'LEADER_BALDWIN_IV', MajorCivApproachType, Bias
FROM Leader_MajorCivApproachBiases
WHERE LeaderType = 'LEADER_CASIMIR';

INSERT INTO Leader_MinorCivApproachBiases (LeaderType, MinorCivApproachType, Bias)
SELECT 'LEADER_BALDWIN_IV', MinorCivApproachType, Bias
FROM Leader_MinorCivApproachBiases
WHERE LeaderType = 'LEADER_CASIMIR';

INSERT INTO Leader_Flavors (LeaderType, FlavorType, Flavor)
SELECT 'LEADER_BALDWIN_IV', FlavorType, Flavor
FROM Leader_Flavors
WHERE LeaderType = 'LEADER_CASIMIR';

INSERT INTO Civilization_Leaders (CivilizationType, LeaderheadType) VALUES
	('CIVILIZATION_JERUSALEM', 'LEADER_BALDWIN_IV');

INSERT INTO Leader_Traits (LeaderType, TraitType) VALUES
	('LEADER_BALDWIN_IV', 'TRAIT_HOLY_LAND');

INSERT INTO Civilization_FreeBuildingClasses (CivilizationType, BuildingClassType) VALUES
	('CIVILIZATION_JERUSALEM', 'BUILDINGCLASS_PALACE');

INSERT INTO Civilization_FreeTechs (CivilizationType, TechType) VALUES
	('CIVILIZATION_JERUSALEM', 'TECH_AGRICULTURE');

INSERT INTO Civilization_FreeUnits (CivilizationType, UnitClassType, UnitAIType, Count) VALUES
	('CIVILIZATION_JERUSALEM', 'UNITCLASS_SETTLER', 'UNITAI_SETTLE', 1);

INSERT INTO Civilization_Religions (CivilizationType, ReligionType) VALUES
	('CIVILIZATION_JERUSALEM', 'RELIGION_CHRISTIANITY');

INSERT INTO Civilization_SpyNames (CivilizationType, SpyName) VALUES
	('CIVILIZATION_JERUSALEM', 'TXT_KEY_SPY_NAME_JERUSALEM_0'),
	('CIVILIZATION_JERUSALEM', 'TXT_KEY_SPY_NAME_JERUSALEM_1'),
	('CIVILIZATION_JERUSALEM', 'TXT_KEY_SPY_NAME_JERUSALEM_2'),
	('CIVILIZATION_JERUSALEM', 'TXT_KEY_SPY_NAME_JERUSALEM_3'),
	('CIVILIZATION_JERUSALEM', 'TXT_KEY_SPY_NAME_JERUSALEM_4'),
	('CIVILIZATION_JERUSALEM', 'TXT_KEY_SPY_NAME_JERUSALEM_5'),
	('CIVILIZATION_JERUSALEM', 'TXT_KEY_SPY_NAME_JERUSALEM_6'),
	('CIVILIZATION_JERUSALEM', 'TXT_KEY_SPY_NAME_JERUSALEM_7'),
	('CIVILIZATION_JERUSALEM', 'TXT_KEY_SPY_NAME_JERUSALEM_8'),
	('CIVILIZATION_JERUSALEM', 'TXT_KEY_SPY_NAME_JERUSALEM_9');

INSERT INTO Civilization_CityNames (CivilizationType, CityName) VALUES
	('CIVILIZATION_JERUSALEM', 'TXT_KEY_JERUSALEM_CITY_JERUSALEM'),
	('CIVILIZATION_JERUSALEM', 'TXT_KEY_JERUSALEM_CITY_ANTIOCH'),
	('CIVILIZATION_JERUSALEM', 'TXT_KEY_JERUSALEM_CITY_ACRE'),
	('CIVILIZATION_JERUSALEM', 'TXT_KEY_JERUSALEM_CITY_EDESSA'),
	('CIVILIZATION_JERUSALEM', 'TXT_KEY_JERUSALEM_CITY_TRIPOLI'),
	('CIVILIZATION_JERUSALEM', 'TXT_KEY_JERUSALEM_CITY_ASCALON'),
	('CIVILIZATION_JERUSALEM', 'TXT_KEY_JERUSALEM_CITY_JAFFA'),
	('CIVILIZATION_JERUSALEM', 'TXT_KEY_JERUSALEM_CITY_CAESAREA'),
	('CIVILIZATION_JERUSALEM', 'TXT_KEY_JERUSALEM_CITY_TYRE'),
	('CIVILIZATION_JERUSALEM', 'TXT_KEY_JERUSALEM_CITY_SIDON'),
	('CIVILIZATION_JERUSALEM', 'TXT_KEY_JERUSALEM_CITY_BEIRUT'),
	('CIVILIZATION_JERUSALEM', 'TXT_KEY_JERUSALEM_CITY_TORTOSA'),
	('CIVILIZATION_JERUSALEM', 'TXT_KEY_JERUSALEM_CITY_LATAKIA'),
	('CIVILIZATION_JERUSALEM', 'TXT_KEY_JERUSALEM_CITY_MARGAT'),
	('CIVILIZATION_JERUSALEM', 'TXT_KEY_JERUSALEM_CITY_KRAK_DES_CHEVALIERS'),
	('CIVILIZATION_JERUSALEM', 'TXT_KEY_JERUSALEM_CITY_MONTFORT'),
	('CIVILIZATION_JERUSALEM', 'TXT_KEY_JERUSALEM_CITY_KERAK'),
	('CIVILIZATION_JERUSALEM', 'TXT_KEY_JERUSALEM_CITY_MONTREAL'),
	('CIVILIZATION_JERUSALEM', 'TXT_KEY_JERUSALEM_CITY_BETHLEHEM'),
	('CIVILIZATION_JERUSALEM', 'TXT_KEY_JERUSALEM_CITY_HEBRON');

INSERT INTO Civilization_Start_Along_Ocean (CivilizationType, StartAlongOcean) VALUES
	('CIVILIZATION_JERUSALEM', 1);

INSERT INTO Civilization_Start_Region_Priority (CivilizationType, RegionType) VALUES
	('CIVILIZATION_JERUSALEM', 'REGION_PLAINS');

INSERT INTO Civilization_BuildingClassOverrides (CivilizationType, BuildingClassType, BuildingType) VALUES
	('CIVILIZATION_JERUSALEM', 'BUILDINGCLASS_PALACE', 'BUILDING_JERUSALEM_HOLY_SEPULCHER');

INSERT INTO UnitPromotions (
	Type,
	Description,
	Help,
	CannotBeChosen,
	LostWithUpgrade,
	CombatPercent,
	PortraitIndex,
	IconAtlas,
	PediaType,
	PediaEntry
) VALUES
	(
		'PROMOTION_JERUSALEM_CRUSADER_LINEAGE',
		'TXT_KEY_PROMOTION_JERUSALEM_CRUSADER_LINEAGE',
		'TXT_KEY_PROMOTION_JERUSALEM_CRUSADER_LINEAGE_HELP',
		1,
		0,
		0,
		0,
		'JERUSALEM_COLOR_ATLAS',
		'PEDIA_SHARED',
		'TXT_KEY_PROMOTION_JERUSALEM_CRUSADER_LINEAGE'
	),
	(
		'PROMOTION_JERUSALEM_CRUSADER_HOLY_CITY',
		'TXT_KEY_PROMOTION_JERUSALEM_CRUSADER_HOLY_CITY',
		'TXT_KEY_PROMOTION_JERUSALEM_CRUSADER_HOLY_CITY_HELP',
		1,
		0,
		15,
		3,
		'JERUSALEM_COLOR_ATLAS',
		'PEDIA_SHARED',
		'TXT_KEY_PROMOTION_JERUSALEM_CRUSADER_HOLY_CITY'
	),
	(
		'PROMOTION_JERUSALEM_CRUSADER_RELIGIOUS_TERRITORY',
		'TXT_KEY_PROMOTION_JERUSALEM_CRUSADER_RELIGIOUS_TERRITORY',
		'TXT_KEY_PROMOTION_JERUSALEM_CRUSADER_RELIGIOUS_TERRITORY_HELP',
		1,
		0,
		15,
		10,
		'EXPANSION2_PROMOTION_ATLAS',
		'PEDIA_SHARED',
		'TXT_KEY_PROMOTION_JERUSALEM_CRUSADER_RELIGIOUS_TERRITORY'
	),
	(
		'PROMOTION_JERUSALEM_CRUSADER_DIFFERENT_RELIGION',
		'TXT_KEY_PROMOTION_JERUSALEM_CRUSADER_DIFFERENT_RELIGION',
		'TXT_KEY_PROMOTION_JERUSALEM_CRUSADER_DIFFERENT_RELIGION_HELP',
		1,
		0,
		15,
		44,
		'PROMOTION_ATLAS',
		'PEDIA_SHARED',
		'TXT_KEY_PROMOTION_JERUSALEM_CRUSADER_DIFFERENT_RELIGION'
	);

INSERT INTO Units (
	Type,
	Description,
	Civilopedia,
	Strategy,
	Help,
	Combat,
	RangedCombat,
	Cost,
	FaithCost,
	RequiresFaithPurchaseEnabled,
	PurchaseOnly,
	MoveAfterPurchase,
	Moves,
	Range,
	BaseSightRange,
	Class,
	CombatClass,
	Domain,
	DefaultUnitAI,
	MilitarySupport,
	MilitaryProduction,
	Pillage,
	PrereqResources,
	PrereqTech,
	ObsoleteTech,
	GoodyHutUpgradeUnitClass,
	HurryCostModifier,
	AdvancedStartCost,
	MinAreaSize,
	NukeDamageLevel,
	CombatLimit,
	XPValueAttack,
	XPValueDefense,
	Conscription,
	UnitArtInfo,
	UnitArtInfoCulturalVariation,
	UnitArtInfoEraVariation,
	ShowInPedia,
	MoveRate,
	UnitFlagIconOffset,
	PortraitIndex,
	IconAtlas,
	UnitFlagAtlas
)
SELECT
	'UNIT_JERUSALEM_CRUSADER',
	'TXT_KEY_UNIT_JERUSALEM_CRUSADER',
	'TXT_KEY_UNIT_JERUSALEM_CRUSADER_PEDIA',
	'TXT_KEY_UNIT_JERUSALEM_CRUSADER_STRATEGY',
	'TXT_KEY_UNIT_JERUSALEM_CRUSADER_HELP',
	Combat,
	RangedCombat,
	Cost,
	FaithCost,
	RequiresFaithPurchaseEnabled,
	PurchaseOnly,
	MoveAfterPurchase,
	Moves,
	Range,
	BaseSightRange,
	Class,
	CombatClass,
	Domain,
	DefaultUnitAI,
	MilitarySupport,
	MilitaryProduction,
	Pillage,
	PrereqResources,
	PrereqTech,
	ObsoleteTech,
	GoodyHutUpgradeUnitClass,
	HurryCostModifier,
	AdvancedStartCost,
	MinAreaSize,
	NukeDamageLevel,
	CombatLimit,
	XPValueAttack,
	XPValueDefense,
	Conscription,
	UnitArtInfo,
	UnitArtInfoCulturalVariation,
	UnitArtInfoEraVariation,
	ShowInPedia,
	MoveRate,
	0,
	2,
	'JERUSALEM_COLOR_ATLAS',
	'JERUSALEM_ALPHA_ATLAS'
FROM Units
WHERE Type = 'UNIT_LONGSWORDSMAN';

INSERT INTO Unit_AITypes (UnitType, UnitAIType)
SELECT 'UNIT_JERUSALEM_CRUSADER', UnitAIType
FROM Unit_AITypes
WHERE UnitType = 'UNIT_LONGSWORDSMAN';

INSERT INTO Unit_Flavors (UnitType, FlavorType, Flavor)
SELECT 'UNIT_JERUSALEM_CRUSADER', FlavorType, Flavor
FROM Unit_Flavors
WHERE UnitType = 'UNIT_LONGSWORDSMAN';

INSERT INTO Unit_ResourceQuantityRequirements (UnitType, ResourceType, Cost)
SELECT 'UNIT_JERUSALEM_CRUSADER', ResourceType, Cost
FROM Unit_ResourceQuantityRequirements
WHERE UnitType = 'UNIT_LONGSWORDSMAN';

INSERT INTO Unit_ClassUpgrades (UnitType, UnitClassType)
SELECT 'UNIT_JERUSALEM_CRUSADER', UnitClassType
FROM Unit_ClassUpgrades
WHERE UnitType = 'UNIT_LONGSWORDSMAN';

INSERT INTO Unit_FreePromotions (UnitType, PromotionType) VALUES
	('UNIT_JERUSALEM_CRUSADER', 'PROMOTION_JERUSALEM_CRUSADER_LINEAGE');

INSERT INTO Civilization_UnitClassOverrides (
	CivilizationType,
	UnitClassType,
	UnitType
) VALUES (
	'CIVILIZATION_JERUSALEM',
	'UNITCLASS_LONGSWORDSMAN',
	'UNIT_JERUSALEM_CRUSADER'
);
