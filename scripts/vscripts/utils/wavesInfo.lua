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
		}},
	},
	["ranger"] =
	{
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
		}},
	},
	["mage"] =
	{
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
		}},
	},
	["siege"] =
	{
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
		}},
	},
}

wi.classes = {
	["tank"] = { -- melee
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
		}},
	},
	["berserk"] = { -- melee
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
		}},
	},
	["shooter"] = { -- ranger
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
		}},
	},
	["archer"] = { -- ranger
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
		}},
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
		}},
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
		}},
	},
	["catapult"] = { -- siege
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
		}},
	},
	["bomb"] = { -- siege
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
		}},
	},
}

wi.subClasses = {
	["fire"] = {type = "cast_speed", levels = {
		{{type = "", value = 0}, {type = "", value = 0}},
		{{type = "", value = 0}, {type = "", value = 0}},
		{{type = "", value = 0}, {type = "", value = 0}},
		{{type = "", value = 0}, {type = "", value = 0}},
		{{type = "", value = 0}, {type = "", value = 0}},
	}}, -- tank
	["stone"] = {type = "cast_speed", levels = {
		{{type = "", value = 0}, {type = "", value = 0}},
		{{type = "", value = 0}, {type = "", value = 0}},
		{{type = "", value = 0}, {type = "", value = 0}},
		{{type = "", value = 0}, {type = "", value = 0}},
		{{type = "", value = 0}, {type = "", value = 0}},
	}}, -- tank
	["swordsman"] = {type = "cast_speed", levels = {
		{{type = "", value = 0}, {type = "", value = 0}},
		{{type = "", value = 0}, {type = "", value = 0}},
		{{type = "", value = 0}, {type = "", value = 0}},
		{{type = "", value = 0}, {type = "", value = 0}},
		{{type = "", value = 0}, {type = "", value = 0}},
	}}, -- berserk
	["illusion"] = {type = "cast_speed", levels = {
		{{type = "", value = 0}, {type = "", value = 0}},
		{{type = "", value = 0}, {type = "", value = 0}},
		{{type = "", value = 0}, {type = "", value = 0}},
		{{type = "", value = 0}, {type = "", value = 0}},
		{{type = "", value = 0}, {type = "", value = 0}},
	}}, -- berserk
	["gunner"] = {type = "cast_speed", levels = {
		{{type = "", value = 0}, {type = "", value = 0}},
		{{type = "", value = 0}, {type = "", value = 0}},
		{{type = "", value = 0}, {type = "", value = 0}},
		{{type = "", value = 0}, {type = "", value = 0}},
		{{type = "", value = 0}, {type = "", value = 0}},
	}}, -- shooter
	["sniper"] = {type = "cast_speed", levels = {
		{{type = "", value = 0}, {type = "", value = 0}},
		{{type = "", value = 0}, {type = "", value = 0}},
		{{type = "", value = 0}, {type = "", value = 0}},
		{{type = "", value = 0}, {type = "", value = 0}},
		{{type = "", value = 0}, {type = "", value = 0}},
	}}, -- shooter
	["pathfinder"] = {type = "cast_speed", levels = {
		{{type = "", value = 0}, {type = "", value = 0}},
		{{type = "", value = 0}, {type = "", value = 0}},
		{{type = "", value = 0}, {type = "", value = 0}},
		{{type = "", value = 0}, {type = "", value = 0}},
		{{type = "", value = 0}, {type = "", value = 0}},
	}}, -- archer
	["huntsman"] = {type = "cast_speed", levels = {
		{{type = "", value = 0}, {type = "", value = 0}},
		{{type = "", value = 0}, {type = "", value = 0}},
		{{type = "", value = 0}, {type = "", value = 0}},
		{{type = "", value = 0}, {type = "", value = 0}},
		{{type = "", value = 0}, {type = "", value = 0}},
	}}, -- archer
	["firestone"] = {type = "cast_speed", levels = {
		{{type = "", value = 0}, {type = "", value = 0}},
		{{type = "", value = 0}, {type = "", value = 0}},
		{{type = "", value = 0}, {type = "", value = 0}},
		{{type = "", value = 0}, {type = "", value = 0}},
		{{type = "", value = 0}, {type = "", value = 0}},
	}}, -- elementalist
	["waterair"] = {type = "cast_speed", levels = {
		{{type = "", value = 0}, {type = "", value = 0}},
		{{type = "", value = 0}, {type = "", value = 0}},
		{{type = "", value = 0}, {type = "", value = 0}},
		{{type = "", value = 0}, {type = "", value = 0}},
		{{type = "", value = 0}, {type = "", value = 0}},
	}}, -- elementalist
	["aura"] = {type = "cast_speed", levels = {
		{{type = "", value = 0}, {type = "", value = 0}},
		{{type = "", value = 0}, {type = "", value = 0}},
		{{type = "", value = 0}, {type = "", value = 0}},
		{{type = "", value = 0}, {type = "", value = 0}},
		{{type = "", value = 0}, {type = "", value = 0}},
	}}, -- shaman
	["summoner"] = {type = "cast_speed", levels = {
		{{type = "", value = 0}, {type = "", value = 0}},
		{{type = "", value = 0}, {type = "", value = 0}},
		{{type = "", value = 0}, {type = "", value = 0}},
		{{type = "", value = 0}, {type = "", value = 0}},
		{{type = "", value = 0}, {type = "", value = 0}},
	}}, -- shaman
	["trebuchet"] = {type = "cast_speed", levels = {
		{{type = "", value = 0}, {type = "", value = 0}},
		{{type = "", value = 0}, {type = "", value = 0}},
		{{type = "", value = 0}, {type = "", value = 0}},
		{{type = "", value = 0}, {type = "", value = 0}},
		{{type = "", value = 0}, {type = "", value = 0}},
	}}, -- catapult
	["ballista"] = {type = "cast_speed", levels = {
		{{type = "", value = 0}, {type = "", value = 0}},
		{{type = "", value = 0}, {type = "", value = 0}},
		{{type = "", value = 0}, {type = "", value = 0}},
		{{type = "", value = 0}, {type = "", value = 0}},
		{{type = "", value = 0}, {type = "", value = 0}},
	}}, -- catapult
	["miner"] = {type = "cast_speed", levels = {
		{{type = "", value = 0}, {type = "", value = 0}},
		{{type = "", value = 0}, {type = "", value = 0}},
		{{type = "", value = 0}, {type = "", value = 0}},
		{{type = "", value = 0}, {type = "", value = 0}},
		{{type = "", value = 0}, {type = "", value = 0}},
	}}, -- bomb
	["flamethrower"] = {type = "cast_speed", levels = {
		{{type = "", value = 0}, {type = "", value = 0}},
		{{type = "", value = 0}, {type = "", value = 0}},
		{{type = "", value = 0}, {type = "", value = 0}},
		{{type = "", value = 0}, {type = "", value = 0}},
		{{type = "", value = 0}, {type = "", value = 0}},
	}}, -- bomb
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


local autoDesc = {
    atks = "Добавляет %d ед. к скорости атаки",
    atk = "Добавляет %d ед. к урону",
    hp = "Добавляет %d ед. к здоровью",
    armor = "Добавляет %d ед. к броне",
    magr = "Добавляет %d%% к магическому сопротивлению",
    aml = "Добавляет %d%% к усилению магического урона",
    hpreg = "Добавляет %d ед. к регенерации здоровья",
    mana = "Добавляет %d ед. к мане",
    manareg = "Добавляет %d ед. к регенерации маны"
}

function wi:getUpgradeDescription(unit, name)
	
	local id = wi:getUpgByName(unit, name)
	local arr = wi:getArrByUnit(unit)
	
	local upgrade = arr[id]
	
    if upgrade.desc then
        return upgrade.desc
    end
    local pattern = autoDesc[upgrade.type]
    if pattern then
        return string.format(pattern, upgrade.value)
    end
    return "Неизвестное улучшение"
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
	return #wi.upgrades[type][unit][id].levels
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