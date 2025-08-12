if neutralSpawner == nil then
	neutralSpawner = class({})
end

require("wavesInfo")

-- info
-- 1 - melee
-- 1.1 - tank, 1.1.1 - fire, 1.1.2 - stone
-- 1.2 - berserk, 1.2.1 - swordsman, 1.2.2 - illusion
-- 2 - ranger
-- 2.1 - shooter, 2.1.1 - gunner, 2.1.2 - sniper
-- 2.2 - archer, 2.2.1 - pathfinder, 2.2.2 - huntsman
-- 3 - mage
-- 3.1 - elementalist, 3.1.1 - firestone, 3.1.2 - waterair
-- 3.2 - shaman, 3.2.1 - aura, 3.2.2 - summoner
-- 4 - siege
-- 4.1 - catapult, 4.1.1 - trebuchet, 4.1.2 - ballista
-- 4.2 - bomb, 4.2.1 - miner, 4.2.2 - flamethrower

-- Example as view in player
local upgrades = {
	["melee"] = {{0, 0, 0}, "class", {0, 0, 0}, "subclass", 0},
	["ranger"] = {{0, 0, 0}, "class", {0, 0, 0}, "subclass", 0},
	["mage"] = {{0, 0, 0}, "class", {0, 0, 0}, "subclass", 0},
	["siege"] = {{0, 0, 0}, "class", {0, 0, 0}, "subclass", 0},
}

local units = {
	"melee", "ranger", "mage", "siege", "ranger"
}