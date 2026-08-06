# Prussia for Civilization V: Brave New World

Prussia, led by Frederick the Great, is a single-player BNW civilization mod for macOS. It has no required mod dependencies. Ethnic Units v31 is used automatically when enabled; otherwise the normal European unit family is used.

## Runtime verification

Test with only Prussia and IGE enabled, then repeat the final unit-art check with Ethnic Units v31 enabled.

1. Start a fresh game and confirm Berlin, Agriculture, one Settler, a Palace, a plains-region start, the blue/white palette, and resolved English text.
2. Spawn a General Staff Officer and a Great Scientist on the same turn. Confirm the Officer has Leadership, can build a Citadel, cannot build an Academy, shows the research action, grants the same research amount as the Scientist, and is consumed by the action.
3. Use IGE to place stock Leadership on an ordinary combat unit and confirm that adjacent units receive the normal Great General aura.
4. Build the Staff College. Confirm its Heroic Epic requirements and effects, then train and purchase land, naval, air, and civilian units. Only land and naval combat units should receive Morale, Leadership, and Great Generals II. Upgrade one graduate and confirm all three remain.
5. Enter a Golden Age and confirm exact +20% Science and +20% military Combat Strength. Confirm both bonuses are absent before the Golden Age, remain active throughout it, and disappear when it ends.
6. Save/reload and capture or move the capital during both normal turns and a Golden Age. Confirm the science modifier exists only in the current Prussian capital during a Golden Age and never stacks or lingers.
7. Check `Logs/Database.log` and `Logs/Lua.log` for `error` or `Prussia`. One load diagnostic is expected; recurring debug output is not.

The combat bonus is a native trait effect and activates immediately. Stock BNW has no deterministic Golden-Age-started gameplay event for the Lua science dummy; after starting a Golden Age with a Great Artist mid-turn, move a Prussian unit or wait for the next Prussian refresh before inspecting the Science total.

If the Officer lacks the research action or its value differs from the same-turn Great Scientist, stop testing. Do not substitute a Lua research grant; that result would require a design decision or a custom mission interface.

## Local checks

```sh
python3 MODS/Prussia/tests/validate_package.py
xmllint --noout MODS/Prussia/Prussia.modinfo MODS/Prussia/Text_en_US.xml MODS/Prussia/Art/Frederick_scene.xml
texluac -p MODS/Prussia/Lua/Prussia.lua
texlua MODS/Prussia/tests/PrussiaRuntimeTest.lua MODS/Prussia/Lua/Prussia.lua
```

The comprehensive Python validator requires Pillow and runs the XML, Lua, database-parity, localization, art-dimension, optional-unit-family, and manifest-hash checks.

See `CREDITS.md` for all historical art sources, licenses, and adaptations.
