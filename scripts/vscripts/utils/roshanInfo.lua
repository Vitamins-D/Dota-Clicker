if ri == nil then
    ri = class({})
end

local utils = require("utils/utils")

ri.items = {
	["swordsman"] = {
		"item_blink",
		"item_heart",
		"item_butterfly",
		"item_shivas_guard",
		"item_satanic",
	},
	["archer"] = {
		"item_blink",
		"item_butterfly",
		"item_assault",
		"item_manta",
		"item_satanic",
	},
	["mage"] = {
		"item_heart",
		"item_ethereal_blade",
		"item_blink",
		"item_butterfly",
		"item_black_king_bar",
	},
	["catapult"] = {
		"item_black_king_bar",
		"item_shivas_guard",
		"item_sphere",
		"item_butterfly",
		"item_blink",
	}
}

ri.boost = {
	{ type = "atk", value = 20 },
	
}

function ri:getPanoramaArr()
	local arr = {}
	for key,v in pairs(ri.items) do
		arr[key] = {}
		for i = 1, #ri.items[key] do
			arr[key][""..i..""] = ri.items[key]
		end
	end
	return arr
end

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