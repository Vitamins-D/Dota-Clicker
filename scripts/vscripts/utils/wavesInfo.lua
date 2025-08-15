if wi == nil then
	wi = class({})
end

local utils = require("utils/utils")

-- info
-- 1 - swordsman
-- 1.1 - tank, 1.1.1 - Veins_fire, 1.1.2 - stone_block
-- 1.2 - berserker, 1.2.1 - melee, 1.2.2 - illusionist
-- 2 - archer
-- 2.1 - shooter, 2.1.1 - gunner, 2.1.2 - sniper
-- 2.2 - ranger, 2.2.1 - pathfinder, 2.2.2 - marksman
-- 3 - mage
-- 3.1 - elementalist, 3.1.1 - fire_mage, 3.1.2 - air_mage
-- 3.2 - shaman, 3.2.1 - def_shaman, 3.2.2 - fight_shaman
-- 4 - catapult
-- 4.1 - siege_tower, 4.1.1 - trebuchet, 4.1.2 - ballista
-- 4.2 - bomber, 4.2.1 - rapid_fire, 4.2.2 - miner

wi.unitTypes = {
	"swordsman", "archer", "mage", "catapult"
}

wi.unitDescription = {
	["tank"] = "",
	["berserker"] = "",
	["shooter"] = "",
	["ranger"] = "",
	["elementalist"] = "",
	["shaman"] = "",
	["siege_tower"] = "",
	["bomber"] = "",
	
	["Veins_fire"] = "",
	["stone_block"] = "",
	["melee"] = "",
	["illusionist"] = "",
	["gunner"] = "",
	["sniper"] = "",
	["pathfinder"] = "",
	["marksman"] = "",
	["fire_mage"] = "",
	["air_mage"] = "",
	["def_shaman"] = "",
	["fight_shaman"] = "",
	["trebuchet"] = "",
	["ballista"] = "",
	["rapid_fire"] = "",
	["miner"] = "",
}

wi.requirement = {
	["tank"] = {upgs = {{"damage", 1}, {"def", 2}}},
	["berserker"] = {upgs = {{"damage", 1}, {"def", 2}}},
	["shooter"] = {upgs = {{"damage", 1}, {"def", 2}}},
	["ranger"] = {upgs = {{"damage", 1}, {"def", 2}}},
	["elementalist"] = {upgs = {{"damage", 1}, {"def", 2}}},
	["shaman"] = {upgs = {{"damage", 1}, {"def", 2}}},
	["siege_tower"] = {upgs = {{"damage", 1}, {"def", 2}}},
	["bomber"] = {upgs = {{"damage", 1}, {"def", 2}}},
	
	["Veins_fire"] = {class = "berserker", upgs = {{"damage", 1}, {"def", 2}}},
	["stone_block"] = {class = "berserker", upgs = {{"damage", 1}, {"def", 2}}},
	["melee"] = {class = "berserker", upgs = {{"damage", 1}, {"def", 2}}},
	["illusionist"] = {class = "berserker", upgs = {{"damage", 1}, {"def", 2}}},
	["gunner"] = {class = "berserker", upgs = {{"damage", 1}, {"def", 2}}},
	["sniper"] = {class = "berserker", upgs = {{"damage", 1}, {"def", 2}}},
	["pathfinder"] = {class = "berserker", upgs = {{"damage", 1}, {"def", 2}}},
	["marksman"] = {class = "berserker", upgs = {{"damage", 1}, {"def", 2}}},
	["fire_mage"] = {class = "berserker", upgs = {{"damage", 1}, {"def", 2}}},
	["air_mage"] = {class = "berserker", upgs = {{"damage", 1}, {"def", 2}}},
	["def_shaman"] = {class = "berserker", upgs = {{"damage", 1}, {"def", 2}}},
	["fight_shaman"] = {class = "berserker", upgs = {{"damage", 1}, {"def", 2}}},
	["trebuchet"] = {class = "berserker", upgs = {{"damage", 1}, {"def", 2}}},
	["ballista"] = {class = "berserker", upgs = {{"damage", 1}, {"def", 2}}},
	["rapid_fire"] = {class = "berserker", upgs = {{"damage", 1}, {"def", 2}}},
	["miner"] = {class = "berserker", upgs = {{"damage", 1}, {"def", 2}}},
}

wi.units = {
	["swordsman"] = "",
	["archer"] = "",
	["mage"] = "npc_dota_clicker_boar",
	["catapult"] = "",
	
	["tank"] = "",
	["berserker"] = "",
	["shooter"] = "",
	["ranger"] = "",
	["elementalist"] = "",
	["shaman"] = "",
	["siege_tower"] = "",
	["bomber"] = "",
	
}

wi.base = {
	["swordsman"] =
	{
		{type = "hp", levels = {
			{{type = "", value = 0}, {type = "", value = 0}, cost = 300},
			{{type = "", value = 0}, {type = "", value = 0}, cost = 300},
			{{type = "", value = 0}, {type = "", value = 0}, cost = 300},
			{{type = "", value = 0}, {type = "", value = 0}, cost = 300},
			{{type = "", value = 0}, {type = "", value = 0}, cost = 300},
		}},
		{type = "damage", levels = {
			{{type = "", value = 0}, {type = "", value = 0}, cost = 300},
			{{type = "", value = 0}, {type = "", value = 0}, cost = 300},
			{{type = "", value = 0}, {type = "", value = 0}, cost = 300},
			{{type = "", value = 0}, {type = "", value = 0}, cost = 300},
			{{type = "", value = 0}, {type = "", value = 0}, cost = 300},
		}},
		{type = "def", levels = {
			{{type = "", value = 0}, {type = "", value = 0}, cost = 300},
			{{type = "", value = 0}, {type = "", value = 0}, cost = 300},
			{{type = "", value = 0}, {type = "", value = 0}, cost = 300},
			{{type = "", value = 0}, {type = "", value = 0}, cost = 300},
			{{type = "", value = 0}, {type = "", value = 0}, cost = 300},
		}}, cost = 300
	},
	["archer"] =
	{
		{type = "mana", levels = {
			{{type = "", value = 0}, {type = "", value = 0}, cost = 300},
			{{type = "", value = 0}, {type = "", value = 0}, cost = 300},
			{{type = "", value = 0}, {type = "", value = 0}, cost = 300},
			{{type = "", value = 0}, {type = "", value = 0}, cost = 300},
			{{type = "", value = 0}, {type = "", value = 0}, cost = 300},
		}},
		{type = "spell_power", levels = {
			{{type = "", value = 0}, {type = "", value = 0}, cost = 300},
			{{type = "", value = 0}, {type = "", value = 0}, cost = 300},
			{{type = "", value = 0}, {type = "", value = 0}, cost = 300},
			{{type = "", value = 0}, {type = "", value = 0}, cost = 300},
			{{type = "", value = 0}, {type = "", value = 0}, cost = 300},
		}},
		{type = "cast_speed", levels = {
			{{type = "", value = 0}, {type = "", value = 0}, cost = 300},
			{{type = "", value = 0}, {type = "", value = 0}, cost = 300},
			{{type = "", value = 0}, {type = "", value = 0}, cost = 300},
			{{type = "", value = 0}, {type = "", value = 0}, cost = 300},
			{{type = "", value = 0}, {type = "", value = 0}, cost = 300},
		}}, cost = 500
	},
	["mage"] =
	{
		{type = "mana", levels = {
			{{type = "mana", value = 100}, {type = "hp", value = 9999}, cost = 300},
			{{type = "spell", value = "dotac_boar_charge"}, cost = 3000},
			{{type = "", value = 0}, {type = "", value = 0}, cost = 300},
			{{type = "", value = 0}, {type = "", value = 0}, cost = 300},
			{{type = "", value = 0}, {type = "", value = 0}, cost = 300},
		}},
		{type = "spell_power", levels = {
			{{type = "", value = 0}, {type = "", value = 0}, cost = 300},
			{{type = "", value = 0}, {type = "", value = 0}, cost = 300},
			{{type = "", value = 0}, {type = "", value = 0}, cost = 300},
			{{type = "", value = 0}, {type = "", value = 0}, cost = 300},
			{{type = "", value = 0}, {type = "", value = 0}, cost = 300},
		}},
		{type = "cast_speed", levels = {
			{{type = "", value = 0}, {type = "", value = 0}, cost = 300},
			{{type = "", value = 0}, {type = "", value = 0}, cost = 300},
			{{type = "", value = 0}, {type = "", value = 0}, cost = 300},
			{{type = "", value = 0}, {type = "", value = 0}, cost = 300, cost = 300},
			{{type = "", value = 0}, {type = "", value = 0}, cost = 300},
		}}, cost = 700
	},
	["catapult"] =
	{
		{type = "mana", levels = {
			{{type = "", value = 0}, {type = "", value = 0}, cost = 300},
			{{type = "", value = 0}, {type = "", value = 0}, cost = 300},
			{{type = "", value = 0}, {type = "", value = 0}, cost = 300},
			{{type = "", value = 0}, {type = "", value = 0}, cost = 300},
			{{type = "", value = 0}, {type = "", value = 0}, cost = 300},
		}},
		{type = "spell_power", levels = {
			{{type = "", value = 0}, {type = "", value = 0}, cost = 300},
			{{type = "", value = 0}, {type = "", value = 0}, cost = 300},
			{{type = "", value = 0}, {type = "", value = 0}, cost = 300},
			{{type = "", value = 0}, {type = "", value = 0}, cost = 300},
			{{type = "", value = 0}, {type = "", value = 0}, cost = 300},
		}},
		{type = "cast_speed", levels = {
			{{type = "", value = 0}, {type = "", value = 0}, cost = 300},
			{{type = "", value = 0}, {type = "", value = 0}, cost = 300},
			{{type = "", value = 0}, {type = "", value = 0}, cost = 300},
			{{type = "", value = 0}, {type = "", value = 0}, cost = 300},
			{{type = "", value = 0}, {type = "", value = 0}, cost = 300},
		}}, cost = 1200
	},
}

wi.classes = {
	["tank"] = { -- swordsman
		{type = "mana", levels = {
			{{type = "", value = 0}, {type = "", value = 0}},
			{{type = "", value = 0}, {type = "", value = 0}},
			{{type = "", value = 0}, {type = "", value = 0}},
			{{type = "", value = 0}, {type = "", value = 0}},
			{{type = "", value = 0}, {type = "", value = 0}},
		}},
		{type = "spell_power", levels = {
			{{type = "", value = 0}, {type = "", value = 0}},
			{{type = "", value = 0}, {type = "", value = 0}},
			{{type = "", value = 0}, {type = "", value = 0}},
			{{type = "", value = 0}, {type = "", value = 0}},
			{{type = "", value = 0}, {type = "", value = 0}},
		}},
		{type = "cast_speed", levels = {
			{{type = "", value = 0}, {type = "", value = 0}},
			{{type = "", value = 0}, {type = "", value = 0}},
			{{type = "", value = 0}, {type = "", value = 0}},
			{{type = "", value = 0}, {type = "", value = 0}},
			{{type = "", value = 0}, {type = "", value = 0}},
		}}, cost = 500
	},
	["berserker"] = { -- swordsman
		{type = "mana", levels = {
			{{type = "", value = 0}, {type = "", value = 0}},
			{{type = "", value = 0}, {type = "", value = 0}},
			{{type = "", value = 0}, {type = "", value = 0}},
			{{type = "", value = 0}, {type = "", value = 0}},
			{{type = "", value = 0}, {type = "", value = 0}},
		}},
		{type = "spell_power", levels = {
			{{type = "", value = 0}, {type = "", value = 0}},
			{{type = "", value = 0}, {type = "", value = 0}},
			{{type = "", value = 0}, {type = "", value = 0}},
			{{type = "", value = 0}, {type = "", value = 0}},
			{{type = "", value = 0}, {type = "", value = 0}},
		}},
		{type = "cast_speed", levels = {
			{{type = "", value = 0}, {type = "", value = 0}},
			{{type = "", value = 0}, {type = "", value = 0}},
			{{type = "", value = 0}, {type = "", value = 0}},
			{{type = "", value = 0}, {type = "", value = 0}},
			{{type = "", value = 0}, {type = "", value = 0}},
		}}, cost = 500
	},
	["shooter"] = { -- archer
		{type = "mana", levels = {
			{{type = "", value = 0}, {type = "", value = 0}},
			{{type = "", value = 0}, {type = "", value = 0}},
			{{type = "", value = 0}, {type = "", value = 0}},
			{{type = "", value = 0}, {type = "", value = 0}},
			{{type = "", value = 0}, {type = "", value = 0}},
		}},
		{type = "spell_power", levels = {
			{{type = "", value = 0}, {type = "", value = 0}},
			{{type = "", value = 0}, {type = "", value = 0}},
			{{type = "", value = 0}, {type = "", value = 0}},
			{{type = "", value = 0}, {type = "", value = 0}},
			{{type = "", value = 0}, {type = "", value = 0}},
		}},
		{type = "cast_speed", levels = {
			{{type = "", value = 0}, {type = "", value = 0}},
			{{type = "", value = 0}, {type = "", value = 0}},
			{{type = "", value = 0}, {type = "", value = 0}},
			{{type = "", value = 0}, {type = "", value = 0}},
			{{type = "", value = 0}, {type = "", value = 0}},
		}}, cost = 500
	},
	["ranger"] = { -- archer
		{type = "mana", levels = {
			{{type = "", value = 0}, {type = "", value = 0}},
			{{type = "", value = 0}, {type = "", value = 0}},
			{{type = "", value = 0}, {type = "", value = 0}},
			{{type = "", value = 0}, {type = "", value = 0}},
			{{type = "", value = 0}, {type = "", value = 0}},
		}},
		{type = "spell_power", levels = {
			{{type = "", value = 0}, {type = "", value = 0}},
			{{type = "", value = 0}, {type = "", value = 0}},
			{{type = "", value = 0}, {type = "", value = 0}},
			{{type = "", value = 0}, {type = "", value = 0}},
			{{type = "", value = 0}, {type = "", value = 0}},
		}},
		{type = "cast_speed", levels = {
			{{type = "", value = 0}, {type = "", value = 0}},
			{{type = "", value = 0}, {type = "", value = 0}},
			{{type = "", value = 0}, {type = "", value = 0}},
			{{type = "", value = 0}, {type = "", value = 0}},
			{{type = "", value = 0}, {type = "", value = 0}},
		}}, cost = 500
	},
	["elementalist"] = { -- mage
		{type = "mana", levels = {
			{{type = "", value = 0}, {type = "", value = 0}},
			{{type = "", value = 0}, {type = "", value = 0}},
			{{type = "", value = 0}, {type = "", value = 0}},
			{{type = "", value = 0}, {type = "", value = 0}},
			{{type = "", value = 0}, {type = "", value = 0}},
		}},
		{type = "spell_power", levels = {
			{{type = "", value = 0}, {type = "", value = 0}},
			{{type = "", value = 0}, {type = "", value = 0}},
			{{type = "", value = 0}, {type = "", value = 0}},
			{{type = "", value = 0}, {type = "", value = 0}},
			{{type = "", value = 0}, {type = "", value = 0}},
		}},
		{type = "cast_speed", levels = {
			{{type = "", value = 0}, {type = "", value = 0}},
			{{type = "", value = 0}, {type = "", value = 0}},
			{{type = "", value = 0}, {type = "", value = 0}},
			{{type = "", value = 0}, {type = "", value = 0}},
			{{type = "", value = 0}, {type = "", value = 0}},
		}}, cost = 500
	},
	["shaman"] = { -- mage
		{type = "mana", levels = {
			{{type = "", value = 0}, {type = "", value = 0}},
			{{type = "", value = 0}, {type = "", value = 0}},
			{{type = "", value = 0}, {type = "", value = 0}},
			{{type = "", value = 0}, {type = "", value = 0}},
			{{type = "", value = 0}, {type = "", value = 0}},
		}},
		{type = "spell_power", levels = {
			{{type = "", value = 0}, {type = "", value = 0}},
			{{type = "", value = 0}, {type = "", value = 0}},
			{{type = "", value = 0}, {type = "", value = 0}},
			{{type = "", value = 0}, {type = "", value = 0}},
			{{type = "", value = 0}, {type = "", value = 0}},
		}},
		{type = "cast_speed", levels = {
			{{type = "", value = 0}, {type = "", value = 0}},
			{{type = "", value = 0}, {type = "", value = 0}},
			{{type = "", value = 0}, {type = "", value = 0}},
			{{type = "", value = 0}, {type = "", value = 0}},
			{{type = "", value = 0}, {type = "", value = 0}},
		}}, cost = 500
	},
	["siege_tower"] = { -- catapult
		{type = "mana", levels = {
			{{type = "", value = 0}, {type = "", value = 0}},
			{{type = "", value = 0}, {type = "", value = 0}},
			{{type = "", value = 0}, {type = "", value = 0}},
			{{type = "", value = 0}, {type = "", value = 0}},
			{{type = "", value = 0}, {type = "", value = 0}},
		}},
		{type = "spell_power", levels = {
			{{type = "", value = 0}, {type = "", value = 0}},
			{{type = "", value = 0}, {type = "", value = 0}},
			{{type = "", value = 0}, {type = "", value = 0}},
			{{type = "", value = 0}, {type = "", value = 0}},
			{{type = "", value = 0}, {type = "", value = 0}},
		}},
		{type = "cast_speed", levels = {
			{{type = "", value = 0}, {type = "", value = 0}},
			{{type = "", value = 0}, {type = "", value = 0}},
			{{type = "", value = 0}, {type = "", value = 0}},
			{{type = "", value = 0}, {type = "", value = 0}},
			{{type = "", value = 0}, {type = "", value = 0}},
		}}, cost = 500
	},
	["bomber"] = { -- catapult
		{type = "mana", levels = {
			{{type = "", value = 0}, {type = "", value = 0}},
			{{type = "", value = 0}, {type = "", value = 0}},
			{{type = "", value = 0}, {type = "", value = 0}},
			{{type = "", value = 0}, {type = "", value = 0}},
			{{type = "", value = 0}, {type = "", value = 0}},
		}},
		{type = "spell_power", levels = {
			{{type = "", value = 0}, {type = "", value = 0}},
			{{type = "", value = 0}, {type = "", value = 0}},
			{{type = "", value = 0}, {type = "", value = 0}},
			{{type = "", value = 0}, {type = "", value = 0}},
			{{type = "", value = 0}, {type = "", value = 0}},
		}},
		{type = "cast_speed", levels = {
			{{type = "", value = 0}, {type = "", value = 0}},
			{{type = "", value = 0}, {type = "", value = 0}},
			{{type = "", value = 0}, {type = "", value = 0}},
			{{type = "", value = 0}, {type = "", value = 0}},
			{{type = "", value = 0}, {type = "", value = 0}},
		}}, cost = 500
	},
}

wi.subClasses = {
	["Veins_fire"] = {type = "cast_speed", levels = {
		{{type = "", value = 0}, {type = "", value = 0}},
		{{type = "", value = 0}, {type = "", value = 0}},
		{{type = "", value = 0}, {type = "", value = 0}},
		{{type = "", value = 0}, {type = "", value = 0}},
		{{type = "", value = 0}, {type = "", value = 0}},
	}, cost = 500}, -- tank
	["stone_block"] = {type = "cast_speed", levels = {
		{{type = "", value = 0}, {type = "", value = 0}},
		{{type = "", value = 0}, {type = "", value = 0}},
		{{type = "", value = 0}, {type = "", value = 0}},
		{{type = "", value = 0}, {type = "", value = 0}},
		{{type = "", value = 0}, {type = "", value = 0}},
	}, cost = 500}, -- tank
	["melee"] = {type = "cast_speed", levels = {
		{{type = "", value = 0}, {type = "", value = 0}},
		{{type = "", value = 0}, {type = "", value = 0}},
		{{type = "", value = 0}, {type = "", value = 0}},
		{{type = "", value = 0}, {type = "", value = 0}},
		{{type = "", value = 0}, {type = "", value = 0}},
	}, cost = 500}, -- berserker
	["illusionist"] = {type = "cast_speed", levels = {
		{{type = "", value = 0}, {type = "", value = 0}},
		{{type = "", value = 0}, {type = "", value = 0}},
		{{type = "", value = 0}, {type = "", value = 0}},
		{{type = "", value = 0}, {type = "", value = 0}},
		{{type = "", value = 0}, {type = "", value = 0}},
	}, cost = 500}, -- berserker
	["gunner"] = {type = "cast_speed", levels = {
		{{type = "", value = 0}, {type = "", value = 0}},
		{{type = "", value = 0}, {type = "", value = 0}},
		{{type = "", value = 0}, {type = "", value = 0}},
		{{type = "", value = 0}, {type = "", value = 0}},
		{{type = "", value = 0}, {type = "", value = 0}},
	}, cost = 500}, -- shooter
	["sniper"] = {type = "cast_speed", levels = {
		{{type = "", value = 0}, {type = "", value = 0}},
		{{type = "", value = 0}, {type = "", value = 0}},
		{{type = "", value = 0}, {type = "", value = 0}},
		{{type = "", value = 0}, {type = "", value = 0}},
		{{type = "", value = 0}, {type = "", value = 0}},
	}, cost = 500}, -- shooter
	["pathfinder"] = {type = "cast_speed", levels = {
		{{type = "", value = 0}, {type = "", value = 0}},
		{{type = "", value = 0}, {type = "", value = 0}},
		{{type = "", value = 0}, {type = "", value = 0}},
		{{type = "", value = 0}, {type = "", value = 0}},
		{{type = "", value = 0}, {type = "", value = 0}},
	}, cost = 500}, -- ranger
	["marksman"] = {type = "cast_speed", levels = {
		{{type = "", value = 0}, {type = "", value = 0}},
		{{type = "", value = 0}, {type = "", value = 0}},
		{{type = "", value = 0}, {type = "", value = 0}},
		{{type = "", value = 0}, {type = "", value = 0}},
		{{type = "", value = 0}, {type = "", value = 0}},
	}, cost = 500}, -- ranger
	["fire_mage"] = {type = "cast_speed", levels = {
		{{type = "", value = 0}, {type = "", value = 0}},
		{{type = "", value = 0}, {type = "", value = 0}},
		{{type = "", value = 0}, {type = "", value = 0}},
		{{type = "", value = 0}, {type = "", value = 0}},
		{{type = "", value = 0}, {type = "", value = 0}},
	}, cost = 500}, -- elementalist
	["air_mage"] = {type = "cast_speed", levels = {
		{{type = "", value = 0}, {type = "", value = 0}},
		{{type = "", value = 0}, {type = "", value = 0}},
		{{type = "", value = 0}, {type = "", value = 0}},
		{{type = "", value = 0}, {type = "", value = 0}},
		{{type = "", value = 0}, {type = "", value = 0}},
	}, cost = 500}, -- elementalist
	["def_shaman"] = {type = "cast_speed", levels = {
		{{type = "", value = 0}, {type = "", value = 0}},
		{{type = "", value = 0}, {type = "", value = 0}},
		{{type = "", value = 0}, {type = "", value = 0}},
		{{type = "", value = 0}, {type = "", value = 0}},
		{{type = "", value = 0}, {type = "", value = 0}},
	}, cost = 500}, -- shaman
	["fight_shaman"] = {type = "cast_speed", levels = {
		{{type = "", value = 0}, {type = "", value = 0}},
		{{type = "", value = 0}, {type = "", value = 0}},
		{{type = "", value = 0}, {type = "", value = 0}},
		{{type = "", value = 0}, {type = "", value = 0}},
		{{type = "", value = 0}, {type = "", value = 0}},
	}, cost = 500}, -- shaman
	["trebuchet"] = {type = "cast_speed", levels = {
		{{type = "", value = 0}, {type = "", value = 0}},
		{{type = "", value = 0}, {type = "", value = 0}},
		{{type = "", value = 0}, {type = "", value = 0}},
		{{type = "", value = 0}, {type = "", value = 0}},
		{{type = "", value = 0}, {type = "", value = 0}},
	}, cost = 500}, -- siege_tower
	["ballista"] = {type = "cast_speed", levels = {
		{{type = "", value = 0}, {type = "", value = 0}},
		{{type = "", value = 0}, {type = "", value = 0}},
		{{type = "", value = 0}, {type = "", value = 0}},
		{{type = "", value = 0}, {type = "", value = 0}},
		{{type = "", value = 0}, {type = "", value = 0}},
	}, cost = 500}, -- siege_tower
	["rapid_fire"] = {type = "cast_speed", levels = {
		{{type = "", value = 0}, {type = "", value = 0}},
		{{type = "", value = 0}, {type = "", value = 0}},
		{{type = "", value = 0}, {type = "", value = 0}},
		{{type = "", value = 0}, {type = "", value = 0}},
		{{type = "", value = 0}, {type = "", value = 0}},
	}, cost = 500}, -- bomber
	["miner"] = {type = "cast_speed", levels = {
		{{type = "", value = 0}, {type = "", value = 0}},
		{{type = "", value = 0}, {type = "", value = 0}},
		{{type = "", value = 0}, {type = "", value = 0}},
		{{type = "", value = 0}, {type = "", value = 0}},
		{{type = "", value = 0}, {type = "", value = 0}},
	}, cost = 500}, -- bomber
}

wi.upgrades = {
	["base"] = wi.base,
	["class"] = wi.classes,
	["sub"] = wi.subClasses,
}

wi.unitNames = {
	{"swordsman", "tank", "berserker", "Veins_fire", "stone_block", "melee", "illusionist"},
	{"archer", "shooter", "ranger", "gunner", "sniper", "pathfinder", "marksman"},
	{"mage", "elementalist", "shaman", "fire_mage", "air_mage", "def_shaman", "fight_shaman"},
	{"catapult", "siege_tower", "bomber", "trebuchet", "ballista", "rapid_fire", "miner"},
}

local autoDesc = {
    atks = "Добавляет %d ед. к скорости атаки",
    atk = "Добавляет %d ед. к урону",
    hp = "Добавляет %d ед. к здоровью",
    armor = "Добавляет %d ед. к броне",
    magr = "Добавляет %d%% к магическому сопротивлению",
    spell_amp = "Добавляет %d%% к усилению магического урона",
    hpreg = "Добавляет %d ед. к регенерации здоровья",
    mana = "Добавляет %d ед. к мане",
    manareg = "Добавляет %d ед. к регенерации маны",
    spell = "Открывает способность %s",
    spell_up = "Улучшает способность %s",
}

function wi:getUpgradeCost(unit, name, level)
	local upgrades = wi:getUpgrades(unit, name)
	if upgrades then 
		upgrades = upgrades.levels[level]
		if upgrades then
			return upgrades.cost or 300
		end
	end
	return 0
end

local function costText(cost)
	return "<br><br>Стоимость: <font color='#EFBF04'>" .. cost .. "</font>"
end

function wi:getUpgradeDescription(unit, name, level)
	
	local upgrades = wi:getUpgrades(unit, name)
	
	local desc = ""
	if upgrades then
		upgrades = upgrades.levels[level]
		if upgrades then
			for i = 1, #upgrades do
				local upgrade = upgrades[i]
				if i > 1 then desc = desc .. "<br><br>" end
				if upgrade.desc then
					desc = desc .. upgrade.desc
				else
					local pattern = autoDesc[upgrade.type]
					if pattern then
						if upgrade.type == "spell" or upgrade.type == "spell_up" then
							-- Берём локализованное имя способности
							desc = desc .. string.format(pattern, "#DOTA_Tooltip_ability_" .. upgrade.value)
						else
							desc = desc .. string.format(pattern, upgrade.value)
						end
					end
				end
			end
		end
		
		local cost = wi:getUpgradeCost(unit, name, level)
		desc = desc .. costText(cost)
	end
    return desc
end

function wi:getUnitByName(name)
	return wi.units[name]
end

function wi:getArrByUnit(unit)
	if wi.base[unit] then
		return wi.base[unit], "base"
	elseif wi.classes[unit] then
		return wi.classes[unit], "class"
	elseif wi.subClasses[unit] then
		return wi.subClasses[unit], "sub"
	end
end

function wi:getUpgByName(unit, name)
	local function getId(arr, type)
		for i = 1, #arr do
			local upg = arr[i]
			if upg.type == name then
				return i, type
			end
		end
	end
	
	return getId(wi:getArrByUnit(unit))
end

function wi:getMaxLevel(type, unit, name)
	local id, _ = self:getUpgByName(unit, name)
	local upgrade = wi.upgrades[type][unit][id]
	if upgrade then
		return #upgrade.levels
	else
		return 0
	end
end

function wi:getUnitName(name)
	for i = 1, #wi.unitNames do
		local arr = wi.unitNames[i]
		if utils:indexOf(arr, name) then
			return arr[1]
		end
	end
end

function wi:getUpgrades(unit, name)
	local id = wi:getUpgByName(unit, name)
	local arr = wi:getArrByUnit(unit)
	
	return arr[id]
end

-- Добавляем в конец файла wi.lua

-- Маппинг названий
wi.nameMapping = {
	-- Базовые типы
	["swordsman"] = "Мечник",
	["archer"] = "Лучник", 
	["mage"] = "Маг",
	["catapult"] = "Осадная машина",
	
	-- Классы (evolutions)
	["tank"] = "Танк",
	["berserker"] = "Берсерк",
	["shooter"] = "Стрелок",
	["ranger"] = "Лучник",
	["elementalist"] = "Элементалист",
	["shaman"] = "Шаман",
	["siege_tower"] = "Катапульта",
	["bomber"] = "Бомба",
	
	-- Подклассы (subclasses)
	["Veins_fire"] = "Огненные жилы",
	["stone_block"] = "Каменная глыба",
	["melee"] = "Мастер фехтования",
	["illusionist"] = "Мастер иллюзий",
	["gunner"] = "Пулеметчик",
	["sniper"] = "Снайпер",
	["pathfinder"] = "Следопыт",
	["marksman"] = "Егерь",
	["fire_mage"] = "Маг огня и земли",
	["air_mage"] = "Маг воды и ветра",
	["def_shaman"] = "Боевой шаман",
	["fight_shaman"] = "Шаман призыва",
	["trebuchet"] = "Требушет",
	["ballista"] = "Баллиста",
	["rapid_fire"] = "Минер",
	["miner"] = "Огнеметчик",
	
	-- Названия апгрейдов
	["mana"] = "Сила магии",
	["spell_power"] = "Сила заклинаний",
	["cast_speed"] = "Скорость каста",
	["hp"] = "Здоровяк",
	["damage"] = "Урон",
	["armor"] = "Броня",
	["def"] = "Стойкость"
}

-- Функция преобразования всех данных в один большой массив
function wi:convertToUnifiedStructure()
  local result = {}
  
  local function newArray()
    return setmetatable({}, { __jsontype = 'array' })
  end

  -- Проходим по базовым типам юнитов
  for _, unitType in ipairs(wi.unitTypes) do
    local unitData = {
      name = wi.nameMapping[unitType] or unitType,
      baseUpgrades = newArray(),
      evolutions = newArray(),
      subclasses = newArray()
    }
    
    -- Получаем базовые апгрейды
    if wi.base[unitType] then
      for _, upgrade in ipairs(wi.base[unitType]) do
        local upgradeData = {
          id = upgrade.type,
          name = wi.nameMapping[upgrade.type] or upgrade.type,
          description = wi:getUpgradeDescription(unitType, upgrade.type, 1),
          level = 0,
          maxLevel = #upgrade.levels
        }
        table.insert(unitData.baseUpgrades, upgradeData)
      end
    end
    
    -- Находим все классы (evolutions) для данного базового типа
    for className, classData in pairs(wi.classes) do
      local parentType = wi:getUnitName(className)
      if parentType == unitType then
        local evolution = {
          id = className,
          name = wi.nameMapping[className] or className,
          description = wi.unitDescription[className] .. costText(wi.classes[className].cost) .. "<br>" or "",
          requirement = {},
          skills = newArray()
        }
        
        -- Парсим требования из wi.requirement
        if wi.requirement[className] and wi.requirement[className].upgs then
          local reqs = wi.requirement[className].upgs
          for i = 1, #reqs do
            if reqs[i] then
              evolution.requirement[reqs[i][1]] = reqs[i][2]
            end
          end
        end
        
        -- Преобразуем levels в skills
        for _, skill in ipairs(classData) do
          local skillData = {
            id = skill.type,
            name = wi.nameMapping[skill.type] or skill.type,
            description = wi:getUpgradeDescription(className, skill.type, 1),
            level = 0,
            maxLevel = #skill.levels
          }
          table.insert(evolution.skills, skillData)
        end
        
        table.insert(unitData.evolutions, evolution)
      end
    end
    
    -- Находим все подклассы (subclasses) для данного базового типа
    for subClassName, subClassData in pairs(wi.subClasses) do
      local parentType = wi:getUnitName(subClassName)
      if parentType == unitType then
        local subclass = {
          id = subClassName,
          name = wi.nameMapping[subClassName] or subClassName,
          description = wi.unitDescription[subClassName] .. costText(wi.subClasses[subClassName].cost) or "",
          requirement = {},
          skills = newArray()
        }
        
        -- Парсим требования из wi.requirement для подклассов
        if wi.requirement[subClassName] then
          local req = wi.requirement[subClassName]
          if req.class then
            -- Структура: { evolutions: { class_name: { upgrade_requirements } } }
            subclass.requirement.evolutions = {}
            subclass.requirement.evolutions[req.class] = {}
            
            if req.upgs then
              for i = 1, #req.upgs do
                if req.upgs[i] then
                  subclass.requirement.evolutions[req.class][req.upgs[i][1]] = req.upgs[i][2]
                end
              end
            end
          end
        end
        
        -- Преобразуем levels в skills (берем структуру из subClassData напрямую)
        local skillData = {
          id = subClassData.type,
          name = wi.nameMapping[subClassData.type] or subClassData.type,
          description = wi:getUpgradeDescription(subClassName, subClassData.type, 1),
          level = 0,
          maxLevel = #subClassData.levels
        }
        table.insert(subclass.skills, skillData)
        
        table.insert(unitData.subclasses, subclass)
      end
    end
    
    result[unitType] = unitData
  end
  
  return result
end


-- Функция для вывода структуры в консоль для проверки
function wi:printUnifiedStructure()
	local data = wi:convertToUnifiedStructure()
	
	print("=== UNIFIED UNIT STRUCTURE ===")
	
	for unitType, unitData in pairs(data) do
		print("\n" .. unitType .. ": {")
		print("  name: \"" .. unitData.name .. "\",")
		
		-- Выводим базовые апгрейды
		print("  baseUpgrades: [")
		for _, upgrade in ipairs(unitData.baseUpgrades) do
			print("    { id: \"" .. upgrade.id .. "\", name: \"" .. upgrade.name .. "\", level: " .. upgrade.level .. ", maxLevel: " .. upgrade.maxLevel .. " },")
		end
		print("  ],")
		
		-- Выводим эволюции
		print("  evolutions: [")
		for _, evolution in ipairs(unitData.evolutions) do
			print("    {")
			print("      id: \"" .. evolution.id .. "\",")
			print("      name: \"" .. evolution.name .. "\",")
			print("      description: \"" .. evolution.description .. "\",")
			
			-- Выводим требования
			print("      requirement: {")
			local reqCount = 0
			for reqKey, reqValue in pairs(evolution.requirement) do
				if reqCount > 0 then print(", ") end
				print(" " .. reqKey .. ": " .. reqValue)
				reqCount = reqCount + 1
			end
			print(" },")
			
			-- Выводим скиллы
			print("      skills: [")
			for _, skill in ipairs(evolution.skills) do
				print("        { id: \"" .. skill.id .. "\", name: \"" .. skill.name .. "\", level: " .. skill.level .. ", maxLevel: " .. skill.maxLevel .. " },")
			end
			print("      ]")
			print("    },")
		end
		print("  ],")
		
		-- Выводим подклассы
		print("  subclasses: [")
		for _, subclass in ipairs(unitData.subclasses) do
			print("    {")
			print("      id: \"" .. subclass.id .. "\",")
			print("      name: \"" .. subclass.name .. "\",")
			print("      description: \"" .. subclass.description .. "\",")
			
			-- Выводим требования для подклассов
			print("      requirement: {")
			if subclass.requirement.evolutions then
				print("        evolutions: {")
				for evolName, evolReqs in pairs(subclass.requirement.evolutions) do
					print("          " .. evolName .. ": {")
					local reqCount = 0
					for reqKey, reqValue in pairs(evolReqs) do
						if reqCount > 0 then print(", ") end
						print(" " .. reqKey .. ": " .. reqValue)
						reqCount = reqCount + 1
					end
					print(" }")
				end
				print("        }")
			end
			print("      },")
			
			-- Выводим скиллы
			print("      skills: [")
			for _, skill in ipairs(subclass.skills) do
				print("        { id: \"" .. skill.id .. "\", name: \"" .. skill.name .. "\", level: " .. skill.level .. ", maxLevel: " .. skill.maxLevel .. " },")
			end
			print("      ]")
			print("    },")
		end
		print("  ]")
		print("},")
	end
	
	print("\n=== END STRUCTURE ===")
end

return wi