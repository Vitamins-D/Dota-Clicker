if ra == nil then
    ra = class({})
end

local utils = require("utils/utils")
local ri = require("utils/roshanInfo")
local G = require("utils/globalPrms")

ra.roshanCount = 0

function ra:startRoshanTimer()
	Timers:CreateTimer(G.ROSHAN_SPAWN, function()
		ra:spawnRoshan()
	end)
end

function ra:spawnRoshan()
	local point = Entities:FindByName(nil, "roshan_spawn")
	local unit = CreateUnitByName("npc_dotac_roshan", point:GetAbsOrigin(), true, nil, nil, DOTA_TEAM_NEUTRALS)
	unit.isRoshan = true
	unit.spawnPoint = point:GetAbsOrigin()
	unit.bonus = {}
	
	ra.roshanCount = ra.roshanCount + 1
	
	local boostes = ri.boost
	
	local boostLvl = ra.roshanCount - 1
	for n = 1, #boostes do
		local boost = boostes[n]
		if boost.type == "armor" then
			unit:SetPhysicalArmorBaseValue(unit:GetPhysicalArmorBaseValue() + boost.value * boostLvl)
		elseif boost.type == "magr" then
			unit:SetBaseMagicalResistanceValue(unit:GetBaseMagicalResistanceValue() + boost.value * boostLvl)
		elseif boost.type == "hpreg" then
			unit:SetBaseHealthRegen(unit:GetBaseHealthRegen() + boost.value * boostLvl)
		else
			-- остальные бонусы в модификатор
			if not unit.bonus[boost.type] then unit.bonus[boost.type] = 0 end
			unit.bonus[boost.type] = unit.bonus[boost.type] + boost.value * boostLvl
		end
	end
	
	Timers:CreateTimer(0.5, function()
		unit:AddNewModifier(unit, nil, "modifier_buff_stats", {})
	end)
end

return ra