if wi == nil then
	wi = class({})
end

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

wi.base = {
	["melee"] =
	{
		{},
		{},
		{}
	},
	["ranger"] =
	{
		{},
		{},
		{}
	},
	["mage"] =
	{
		{},
		{},
		{}
	},
	["siege"] =
	{
		{},
		{},
		{}
	},
}

wi.classes = {
	["tank"] = { -- melee
		{},
		{},
		{}
	},
	["berserk"] = { -- melee
		{},
		{},
		{}
	},
	["shooter"] = { -- ranger
		{},
		{},
		{}
	},
	["archer"] = { -- ranger
		{},
		{},
		{}
	},
	["elementalist"] = { -- mage
		{},
		{},
		{}
	},
	["shaman"] = { -- mage
		{},
		{},
		{}
	},
	["catapult"] = { -- siege
		{},
		{},
		{}
	},
	["bomb"] = { -- siege
		{},
		{},
		{}
	},
}

wi.subClasses = {
	["fire"] = {}, -- tank
	["stone"] = {}, -- tank
	["swordsman"] = {}, -- berserk
	["illusion"] = {}, -- berserk
	["gunner"] = {}, -- shooter
	["sniper"] = {}, -- shooter
	["pathfinder"] = {}, -- archer
	["huntsman"] = {}, -- archer
	["firestone"] = {}, -- elementalist
	["waterair"] = {}, -- elementalist
	["aura"] = {}, -- shaman
	["summoner"] = {}, -- shaman
	["trebuchet"] = {}, -- catapult
	["ballista"] = {}, -- catapult
	["miner"] = {}, -- bomb
	["flamethrower"] = {}, -- bomb
}

return wi