if ri == nil then
    ri = class({})
end

local utils = require("utils/utils")

ri.items = {
	["swordsman"] = {
		"item_roshan_bfury",
		"item_roshan_sphere",
		"item_roshan_heart",
		"item_roshan_blade_mail",
		"item_roshan_harpoon",
	},
	["archer"] = {
		"item_roshan_maelstrom",
		"item_roshan_greater_crit",
		"item_roshan_hurricane_pike",
		"item_roshan_revenants_brooch",
		"item_roshan_monkey_king_bar",
	},
	["mage"] = {
		"item_roshan_gungir",
		"item_roshan_arcane_boots",
		"item_roshan_aether_lens",
		"item_roshan_octarine_core",
		"item_roshan_sheepstick",
	},
	["catapult"] = {
		"item_roshan_dragon_lance",
		"item_roshan_aether_lens_2",
		"item_roshan_searing_signet",
		"item_roshan_mask_of_madness",
		"item_roshan_giant_maul",
	},
}


ri.boost = {
	{ type = "atk", value = 20 },
	
}

function ri:getPanoramaArr()
	local arr = {}
	for key,v in pairs(ri.items) do
		arr[key] = {}
		for i = 1, #ri.items[key] do
			arr[key][""..i..""] = ri.items[key][i]
		end
	end
	return arr
end

function ri:setRoshanUpgrade(playerID, unit, upgrade)
	local data = utils:getDataCNT(playerID, "user_stats")
	local upgrades = data.roshan_upgrades
	
	upgrades[unit] = tonumber(upgrade)
	
	utils:setDataKeyCNT(playerID, "user_stats", "roshan_upgrades", upgrades)
	
	local data = utils:getDataCNT(playerID, "user_stats")
	local upgrades = data.roshan_upgrades
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