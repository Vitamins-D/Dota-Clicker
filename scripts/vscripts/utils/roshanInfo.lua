if ri == nil then
    ri = class({})
end

local utils = require("utils/utils")

ri.items = {
	["swordsman"] = {
		"",
		"",
		"",
		"",
		"",
	},
	["archer"] = {
		"",
		"",
		"",
		"",
		"",
	},
	["mage"] = {
		"",
		"",
		"",
		"",
		"",
	},
	["catapult"] = {
		"",
		"",
		"",
		"",
		"",
	}
}

function ri:setRoshanUpgrade(playerID, unit, upgrade)
	local id = utils:indexOf(ri.items[unit], upgrade)
	local data = utils:getDataCNT(playerID, "user_stats")
	local upgrades = data.roshan_upgrades
	
	upgrades[unit] = id
	
	utils:setDataKeyCNT(playerID, "user_stats", roshan_upgrades, upgrades)
end

function ri:getRoshanUpgrade(playerID, unit)
	local data = utils:getDataCNT(playerID, "user_stats")
	local upgrades = data.roshan_upgrades
	return upgrades[unit]
end

function ri:getRoshanItem(playerID, unit)
	local id = ri:getRoshanUpgrade(playerID, unit)
	return ri.items[unit][id]
end

return ri