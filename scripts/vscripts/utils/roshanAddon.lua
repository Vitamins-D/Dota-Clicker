if ra == nil then
    ra = class({})
end

local utils = require("utils/utils")
local ri = require("utils/roshanInfo")
local G = require("utils/globalPrms")

function ra:startRoshanTimer()
	Timers:CreateTimer(G.ROSHAN_SPAWN, function()
		ra:spawnRoshan()
	end)
end

function ra:spawnRoshan()
	local point = Entities:FindByName(nil, "roshan_spawn")
	local unit = CreateUnitByName("npc_dota_roshan", point:GetAbsOrigin(), true, nil, nil, DOTA_TEAM_NEUTRALS)
	unit.isRoshan = true
end

return ra