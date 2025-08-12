if wi == nil then
	wi = class({})
end

local utils = require("utils/utils")

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

wi.units = {
	["melee"] = "",
	["ranger"] = "",
	["mage"] = "",
	["siege"] = "",
	
	["tank"] = "",
	["berserk"] = "",
	["shooter"] = "",
	["archer"] = "",
	["elementalist"] = "",
	["shaman"] = "",
	["catapult"] = "",
	["bomb"] = "",
	
}

wi.base = {
	["melee"] =
	{
		{""},
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
		{"mana", {1, 2, 3, 4, 5}},
		{"spell_power", {1, 2, 3, 4, 5}},
		{"cast_speed", {1, 2, 3, 4, 5}}
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

wi.upgrades = {
	["base"] = wi.base,
	["class"] = wi.classes,
	["sub"] = wi.subClasses,
}

wi.unitNames = {
	{"melee", "tank", "berserk", "fire", "stone", "swordsman", "illusion"},
	{"ranger", "shooter", "archer", "gunner", "sniper", "pathfinder", "huntsman"},
	{"mage", "elementalist", "shaman", "firestone", "waterair", "aura", "summoner"},
	{"siege", "catapult", "bomb", "trebuchet", "ballista", "miner", "flamethrower"},
}

function wi:getUnitByName(name)
	return wi.units[name]
end

function wi:getUpgByName(unit, name)
	local function getId(arr, type)
		for i = 1, #arr do
			local upg = arr[i]
			if upg[1] == name then
				return i, type
			end
		end
	end
	
	if wi.base[unit] then
		return getId(wi.base[unit], "base")
	elseif wi.classes[unit] then
		return getId(wi.classes[unit], "class")
	elseif wi.subClasses[unit] then
		return getId(wi.subClasses[unit], "sub")
	end
end

function wi:getMaxLevel(type, unit, name)
	local id, _ = self:getUpgByName(unit, name)
	return #wi.upgrades[type][unit][id][2]
end

function wi:getUnitName(name)
	for i = 1, #wi.unitNames do
		local arr = wi.unitNames[i]
		if utils:indexOf(arr, name) then
			return arr[1]
		end
	end
end

return wi