from __future__ import annotations

import hashlib
import re
import sqlite3
import subprocess
import xml.etree.ElementTree as ET
from pathlib import Path

from PIL import Image


MOD_ROOT = Path(__file__).resolve().parents[1]
CIV5_ROOT = MOD_ROOT.parents[1]
BASE_DATABASE = CIV5_ROOT / "cache" / "Civ5DebugDatabase.db"
SQL_PATH = MOD_ROOT / "SQL" / "Prussia.sql"
TEXT_PATH = MOD_ROOT / "Text_en_US.xml"
MANIFEST_PATH = MOD_ROOT / "Prussia.modinfo"


def require(condition: bool, message: str) -> None:
	if not condition:
		raise AssertionError(message)


def scalar(connection: sqlite3.Connection, sql: str, parameters: tuple = ()):
	row = connection.execute(sql, parameters).fetchone()
	require(row is not None, f"Query returned no row: {sql}")
	return row[0]


def row_dict(
	connection: sqlite3.Connection,
	table: str,
	type_name: str,
) -> dict[str, object]:
	row = connection.execute(
		f"SELECT * FROM {table} WHERE Type = ?",
		(type_name,),
	).fetchone()
	require(row is not None, f"Missing {table} row {type_name}")
	return dict(row)


def normalized_support_rows(
	connection: sqlite3.Connection,
	table: str,
	key_column: str,
	type_name: str,
) -> list[tuple]:
	columns = [
		row[1]
		for row in connection.execute(f"PRAGMA table_info({table})")
		if row[1] != key_column
	]
	select_columns = ", ".join(columns)
	return connection.execute(
		f"SELECT {select_columns} FROM {table} WHERE {key_column} = ? ORDER BY {select_columns}",
		(type_name,),
	).fetchall()


def assert_support_parity(
	connection: sqlite3.Connection,
	table: str,
	key_column: str,
	base_type: str,
	custom_type: str,
) -> None:
	base = normalized_support_rows(connection, table, key_column, base_type)
	custom = normalized_support_rows(connection, table, key_column, custom_type)
	require(base == custom, f"{table} parity failed: {base!r} != {custom!r}")


def build_database(remove_ethnic_units_marker: bool = False) -> sqlite3.Connection:
	source = sqlite3.connect(BASE_DATABASE)
	connection = sqlite3.connect(":memory:")
	source.backup(connection)
	source.close()
	connection.row_factory = sqlite3.Row
	connection.execute("PRAGMA foreign_keys = OFF")
	if remove_ethnic_units_marker:
		connection.execute(
			"DELETE FROM ArtDefine_UnitInfos WHERE Type = 'ART_DEF_UNIT_LONGSWORDSMAN_GERMANY'"
		)
	connection.executescript(SQL_PATH.read_text(encoding="utf-8"))
	connection.commit()
	return connection


def validate_identity_and_ai(connection: sqlite3.Connection) -> None:
	require(
		scalar(connection, "PRAGMA integrity_check") == "ok",
		"SQLite integrity check failed",
	)
	require(
		scalar(
			connection,
			"SELECT COUNT(*) FROM Civilizations WHERE Type = 'CIVILIZATION_PRUSSIA' AND Playable = 1 AND AIPlayable = 1",
		)
		== 1,
		"Prussia must be playable by humans and AI",
	)
	relationships = (
		(
			"Civilization_Leaders",
			"CivilizationType = 'CIVILIZATION_PRUSSIA' AND LeaderheadType = 'LEADER_FREDERICK_THE_GREAT'",
		),
		(
			"Leader_Traits",
			"LeaderType = 'LEADER_FREDERICK_THE_GREAT' AND TraitType = 'TRAIT_ENLIGHTENED_ABSOLUTISM'",
		),
		(
			"Civilization_UnitClassOverrides",
			"CivilizationType = 'CIVILIZATION_PRUSSIA' AND UnitClassType = 'UNITCLASS_GREAT_GENERAL' AND UnitType = 'UNIT_PRUSSIA_GENERAL_STAFF_OFFICER'",
		),
		(
			"Civilization_BuildingClassOverrides",
			"CivilizationType = 'CIVILIZATION_PRUSSIA' AND BuildingClassType = 'BUILDINGCLASS_HEROIC_EPIC' AND BuildingType = 'BUILDING_PRUSSIA_STAFF_COLLEGE'",
		),
	)
	for table, predicate in relationships:
		require(
			scalar(connection, f"SELECT COUNT(*) FROM {table} WHERE {predicate}") == 1,
			f"Missing or duplicated Prussian relationship in {table}",
		)
	require(
		scalar(
			connection,
			"SELECT COUNT(*) FROM Civilization_Start_Region_Priority WHERE CivilizationType = 'CIVILIZATION_PRUSSIA' AND RegionType = 'REGION_PLAINS'",
		)
		== 1,
		"Prussia must have one plains start priority",
	)
	for table in (
		"Civilization_Start_Along_Ocean",
		"Civilization_Start_Along_River",
		"Civilization_Start_Region_Avoid",
	):
		require(
			scalar(
				connection,
				f"SELECT COUNT(*) FROM {table} WHERE CivilizationType = 'CIVILIZATION_PRUSSIA'",
			)
			== 0,
			f"Prussia has an unexpected row in {table}",
		)

	bootstrap_checks = (
		("Civilization_FreeBuildingClasses", "BuildingClassType", "BUILDINGCLASS_PALACE"),
		("Civilization_FreeTechs", "TechType", "TECH_AGRICULTURE"),
		("Civilization_FreeUnits", "UnitClassType", "UNITCLASS_SETTLER"),
		("Civilization_Religions", "ReligionType", "RELIGION_PROTESTANTISM"),
	)
	for table, column, expected in bootstrap_checks:
		require(
			scalar(
				connection,
				f"SELECT COUNT(*) FROM {table} WHERE CivilizationType = 'CIVILIZATION_PRUSSIA' AND {column} = ?",
				(expected,),
			)
			== 1,
			f"Missing Prussian bootstrap value {expected}",
		)

	city_keys = [
		row[0]
		for row in connection.execute(
			"SELECT CityName FROM Civilization_CityNames WHERE CivilizationType = 'CIVILIZATION_PRUSSIA' ORDER BY rowid"
		)
	]
	require(
		city_keys
		== [
			"TXT_KEY_PRUSSIA_CITY_BERLIN",
			"TXT_KEY_PRUSSIA_CITY_KONIGSBERG",
			"TXT_KEY_PRUSSIA_CITY_POTSDAM",
			"TXT_KEY_PRUSSIA_CITY_BRESLAU",
			"TXT_KEY_PRUSSIA_CITY_MAGDEBURG",
			"TXT_KEY_PRUSSIA_CITY_STETTIN",
			"TXT_KEY_PRUSSIA_CITY_DANZIG",
			"TXT_KEY_PRUSSIA_CITY_HALLE",
			"TXT_KEY_PRUSSIA_CITY_FRANKFURT_ODER",
			"TXT_KEY_PRUSSIA_CITY_MEMEL",
			"TXT_KEY_PRUSSIA_CITY_TILSIT",
			"TXT_KEY_PRUSSIA_CITY_ELBING",
			"TXT_KEY_PRUSSIA_CITY_THORN",
			"TXT_KEY_PRUSSIA_CITY_KOLBERG",
			"TXT_KEY_PRUSSIA_CITY_BRANDENBURG",
			"TXT_KEY_PRUSSIA_CITY_COTTBUS",
			"TXT_KEY_PRUSSIA_CITY_GLOGAU",
			"TXT_KEY_PRUSSIA_CITY_NEISSE",
			"TXT_KEY_PRUSSIA_CITY_GRAUDENZ",
			"TXT_KEY_PRUSSIA_CITY_KUSTRIN",
		],
		"Prussian city order differs from the public contract",
	)

	leader = row_dict(connection, "Leaders", "LEADER_FREDERICK_THE_GREAT")
	require(leader["VictoryCompetitiveness"] == 8, "Victory competitiveness must be 8")
	require(leader["Boldness"] == 8, "Boldness must be 8")
	require(leader["WarmongerHate"] == 5, "Warmonger hate must be 5")
	assert_support_parity(
		connection,
		"Leader_MajorCivApproachBiases",
		"LeaderType",
		"LEADER_BISMARCK",
		"LEADER_FREDERICK_THE_GREAT",
	)
	assert_support_parity(
		connection,
		"Leader_MinorCivApproachBiases",
		"LeaderType",
		"LEADER_BISMARCK",
		"LEADER_FREDERICK_THE_GREAT",
	)
	expected_flavors = {
		"FLAVOR_SCIENCE": 9,
		"FLAVOR_MILITARY_TRAINING": 10,
		"FLAVOR_PRODUCTION": 9,
		"FLAVOR_HAPPINESS": 8,
		"FLAVOR_GREAT_PEOPLE": 7,
		"FLAVOR_OFFENSE": 8,
		"FLAVOR_DEFENSE": 8,
	}
	for flavor_type, expected in expected_flavors.items():
		require(
			scalar(
				connection,
				"SELECT Flavor FROM Leader_Flavors WHERE LeaderType = 'LEADER_FREDERICK_THE_GREAT' AND FlavorType = ?",
				(flavor_type,),
			)
			== expected,
			f"{flavor_type} must be {expected}",
		)


def validate_unique_parts(connection: sqlite3.Connection) -> None:
	require(
		scalar(
			connection,
			"SELECT Yield FROM Building_GlobalYieldModifiers WHERE BuildingType = 'BUILDING_PRUSSIA_ENLIGHTENED_ABSOLUTISM' AND YieldType = 'YIELD_SCIENCE'",
		)
		== 20,
		"Enlightened Absolutism science modifier must be 20",
	)
	require(
		scalar(
			connection,
			"SELECT GoldenAgeCombatModifier FROM Traits WHERE Type = 'TRAIT_ENLIGHTENED_ABSOLUTISM'",
		)
		== 20,
		"Enlightened Absolutism Golden Age combat modifier must be 20",
	)
	require(
		scalar(
			connection,
			"SELECT COUNT(*) FROM UnitPromotions WHERE Type = 'PROMOTION_PRUSSIA_ENLIGHTENED_ABSOLUTISM'",
		)
		== 0,
		"Enlightened Absolutism must use native Golden Age combat, not a promotion",
	)

	base_officer = row_dict(connection, "Units", "UNIT_GREAT_GENERAL")
	expected_officer = dict(base_officer)
	expected_officer.update(
		{
			"ID": None,
			"Type": "UNIT_PRUSSIA_GENERAL_STAFF_OFFICER",
			"Description": "TXT_KEY_UNIT_PRUSSIA_GENERAL_STAFF_OFFICER",
			"Civilopedia": "TXT_KEY_UNIT_PRUSSIA_GENERAL_STAFF_OFFICER_PEDIA",
			"Strategy": "TXT_KEY_UNIT_PRUSSIA_GENERAL_STAFF_OFFICER_STRATEGY",
			"Help": "TXT_KEY_UNIT_PRUSSIA_GENERAL_STAFF_OFFICER_HELP",
			"BaseBeakersTurnsToCount": 8,
			"UnitFlagIconOffset": 0,
			"PortraitIndex": 2,
			"IconAtlas": "PRUSSIA_COLOR_ATLAS",
			"UnitFlagAtlas": "PRUSSIA_ALPHA_ATLAS",
		}
	)
	actual_officer = row_dict(connection, "Units", "UNIT_PRUSSIA_GENERAL_STAFF_OFFICER")
	actual_officer["ID"] = None
	require(actual_officer == expected_officer, "General Staff Officer row is not a complete normalized Great General clone")
	for table in (
		"Unit_AITypes",
		"Unit_Flavors",
		"Unit_FreePromotions",
		"Unit_Builds",
		"UnitGameplay2DScripts",
		"Unit_UniqueNames",
	):
		assert_support_parity(
			connection,
			table,
			"UnitType",
			"UNIT_GREAT_GENERAL",
			"UNIT_PRUSSIA_GENERAL_STAFF_OFFICER",
		)
	require(
		scalar(
			connection,
			"SELECT COUNT(*) FROM Unit_Builds WHERE UnitType = 'UNIT_PRUSSIA_GENERAL_STAFF_OFFICER' AND BuildType = 'BUILD_CITADEL'",
		)
		== 1,
		"Officer must construct one Citadel",
	)
	require(
		scalar(
			connection,
			"SELECT COUNT(*) FROM Unit_Builds WHERE UnitType = 'UNIT_PRUSSIA_GENERAL_STAFF_OFFICER' AND BuildType = 'BUILD_ACADEMY'",
		)
		== 0,
		"Officer must never construct an Academy",
	)
	require(
		scalar(
			connection,
			"SELECT BaseBeakersTurnsToCount FROM Units WHERE Type = 'UNIT_PRUSSIA_GENERAL_STAFF_OFFICER'",
		)
		== scalar(
			connection,
			"SELECT BaseBeakersTurnsToCount FROM Units WHERE Type = 'UNIT_SCIENTIST'",
		),
		"Officer and Great Scientist research-turn values differ",
	)

	base_staff = row_dict(connection, "Buildings", "BUILDING_HEROIC_EPIC")
	expected_staff = dict(base_staff)
	expected_staff.update(
		{
			"ID": None,
			"Type": "BUILDING_PRUSSIA_STAFF_COLLEGE",
			"Description": "TXT_KEY_BUILDING_PRUSSIA_STAFF_COLLEGE",
			"Civilopedia": "TXT_KEY_BUILDING_PRUSSIA_STAFF_COLLEGE_PEDIA",
			"Strategy": "TXT_KEY_BUILDING_PRUSSIA_STAFF_COLLEGE_STRATEGY",
			"Help": "TXT_KEY_BUILDING_PRUSSIA_STAFF_COLLEGE_HELP",
			"PortraitIndex": 3,
			"IconAtlas": "PRUSSIA_COLOR_ATLAS",
		}
	)
	actual_staff = row_dict(connection, "Buildings", "BUILDING_PRUSSIA_STAFF_COLLEGE")
	actual_staff["ID"] = None
	require(actual_staff == expected_staff, "Staff College row is not a complete normalized Heroic Epic clone")
	for table in (
		"Building_ClassesNeededInCity",
		"Building_Flavors",
		"Building_PrereqBuildingClasses",
		"Building_YieldChanges",
	):
		assert_support_parity(
			connection,
			table,
			"BuildingType",
			"BUILDING_HEROIC_EPIC",
			"BUILDING_PRUSSIA_STAFF_COLLEGE",
		)

	for promotion_type in (
		"PROMOTION_MORALE",
		"PROMOTION_GREAT_GENERAL",
		"PROMOTION_SPAWN_GENERALS_II",
	):
		require(
			scalar(
				connection,
				"SELECT LostWithUpgrade FROM UnitPromotions WHERE Type = ?",
				(promotion_type,),
			)
			== 0,
			f"{promotion_type} must survive upgrade",
		)


def validate_art_modes() -> None:
	with build_database() as ethnic_units_database:
		require(
			scalar(
				ethnic_units_database,
				"SELECT ArtStyleSuffix FROM Civilizations WHERE Type = 'CIVILIZATION_PRUSSIA'",
			)
			== "_GERMANY",
			"Ethnic Units definitions must select _GERMANY",
		)
	with build_database(remove_ethnic_units_marker=True) as vanilla_database:
		require(
			scalar(
				vanilla_database,
				"SELECT ArtStyleSuffix FROM Civilizations WHERE Type = 'CIVILIZATION_PRUSSIA'",
			)
			== "_EURO",
			"Vanilla mode must retain _EURO",
		)


def validate_localization() -> None:
	root = ET.parse(TEXT_PATH).getroot()
	tags = [row.attrib["Tag"] for row in root.findall("./Language_en_US/Row")]
	require(len(tags) == len(set(tags)), "Text_en_US.xml contains duplicate tags")
	tag_set = set(tags)
	sql_keys = set(re.findall(r"TXT_KEY_[A-Z0-9_]+", SQL_PATH.read_text(encoding="utf-8")))
	missing = []
	for key in sorted(sql_keys):
		if key in tag_set:
			continue
		if key.startswith("TXT_KEY_SPY_NAME_GERMANY_"):
			continue
		if any(tag.startswith(key + "_") for tag in tag_set):
			continue
		missing.append(key)
	require(not missing, f"Custom localization keys are unresolved: {missing}")


def validate_manifest_and_art() -> None:
	manifest = ET.parse(MANIFEST_PATH).getroot()
	properties = manifest.find("Properties")
	require(properties is not None, "Manifest has no Properties")
	for field in ("Name", "Teaser", "Description"):
		value = properties.findtext(field, "")
		require("TXT_KEY_" not in value, f"Manifest {field} must be literal")

	file_elements = manifest.findall("./Files/File")
	manifest_paths = set()
	for element in file_elements:
		relative = element.text
		require(relative is not None, "Manifest contains an empty File entry")
		manifest_paths.add(relative)
		path = MOD_ROOT / relative
		require(path.is_file(), f"Manifest file is missing: {relative}")
		digest = hashlib.md5(path.read_bytes()).hexdigest()
		require(digest == element.attrib["md5"], f"Manifest hash mismatch: {relative}")
	require("PENDING" not in MANIFEST_PATH.read_text(encoding="utf-8"), "Manifest contains a pending hash")

	art_files = {str(path.relative_to(MOD_ROOT)) for path in (MOD_ROOT / "Art").iterdir() if path.is_file()}
	require(art_files <= manifest_paths, f"Art files missing from manifest: {sorted(art_files - manifest_paths)}")

	for size in (256, 128, 80, 64, 48, 45, 32, 24, 16):
		for stem in ("Prussia_Atlas", "Prussia_Alpha"):
			path = MOD_ROOT / "Art" / f"{stem}{size}.dds"
			with Image.open(path) as image:
				require(image.size == (size * 2, size * 2), f"Wrong atlas dimensions: {path.name}")
	for filename, expected in (
		("Frederick_scene.dds", (1600, 900)),
		("Prussia_DOM.dds", (1600, 900)),
		("MapPrussia.dds", (512, 512)),
	):
		with Image.open(MOD_ROOT / "Art" / filename) as image:
			require(image.size == expected, f"Wrong dimensions: {filename}")


def validate_xml_and_lua() -> None:
	for path in (MANIFEST_PATH, TEXT_PATH, MOD_ROOT / "Art" / "Frederick_scene.xml"):
		subprocess.run(["xmllint", "--noout", str(path)], check=True)
	subprocess.run(["texluac", "-p", str(MOD_ROOT / "Lua" / "Prussia.lua")], check=True)
	subprocess.run(
		[
			"texlua",
			str(MOD_ROOT / "tests" / "PrussiaRuntimeTest.lua"),
			str(MOD_ROOT / "Lua" / "Prussia.lua"),
		],
		check=True,
	)


def main() -> None:
	require(BASE_DATABASE.is_file(), f"Missing BNW debug database: {BASE_DATABASE}")
	with build_database() as connection:
		validate_identity_and_ai(connection)
		validate_unique_parts(connection)
	validate_art_modes()
	validate_localization()
	validate_manifest_and_art()
	validate_xml_and_lua()
	print("Prussia package validation passed")


if __name__ == "__main__":
	main()
