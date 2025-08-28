if ma == nil then
    ma = class({})
end

local mi = require("utils/mineInfo")
local utils = require("utils/utils")

ma.defaultStats = {
	ore_count = 2, -- размер рюкзака
	mine_speed = 1, -- скорость добычи 1 руды (в секундах)
	speed = 300, -- скорость передвижения
	gold_mult = 1,
}

ma.upgrades = {
	{type = "speed", value = 50, cost = 100},
	{type = "mine_speed", value = -2, cost = 100},
	{type = "ore_count", value = 1, cost = 100},
	{type = "ore_count", value = 1, cost = 100},
	{type = "speed", value = 50, cost = 100}
}


function ma:InitAddon(player, spawnPos, minePos, homePos)
	player.minerLevel = 0
	
	ma:spawn(player, spawnPos, minePos, homePos)
end

function ma:getOre()
	local rnd = math.random(1, 100)
	
	local startChance = 0
	for ore,v in pairs(mi.ores) do
		if rnd <= startChance + v.chance then
			return ore
		else
			startChance = startChance + v.chance
		end
	end
	
	return nil
end


function ma:spawn(player, spawnPos, minePos, homePos)
	local playerID = player:GetPlayerID()
	local team = PlayerResource:GetTeam(playerID)
	local unit = CreateUnitByName("npc_dota_clicker_miner", spawnPos, true, nil, nil, team)
	
	unit.mine = minePos
	unit.home = homePos
	unit.playerID = playerID
	
	local playerName = PlayerResource:GetPlayerName(playerID)
	unit:SetUnitName(playerName)
	
	unit:AddNewModifier(unit, nil, "modifier_mine_protection", {})
	
	unit.ore_count = ma.defaultStats.ore_count
	unit.mine_speed = ma.defaultStats.mine_speed
	unit.gold_mult = ma.defaultStats.gold_mult
	unit:SetBaseMoveSpeed(ma.defaultStats.speed)
	
	unit.phase = "goMine"
	
	unit.ores = {}
	
	function unit:mineOre()
		unit.phase = "mining"
		Timers:CreateTimer(unit.mine_speed, function()
			
			local ore = ma:getOre()
			
			local item = CreateItem(mi.ores[ore].item, unit, unit)
			unit:AddItem(item)
			
			table.insert(unit.ores, ore)
			if #unit.ores >= unit.ore_count then
				unit.phase = "goHome"
				return nil
			else
				return unit.mine_speed
			end

			
		end)
	end
	
	function unit:sellOre()
		unit.phase = "sell"
		Timers:CreateTimer(0.5, function()
			
			if #unit.ores > 0 then
				local ore = unit.ores[1]
				table.remove(unit.ores, 1)
				ore = mi.ores[ore]
				utils:RemoveItemByName(unit, ore.item)
				utils:GiveGold(ore.value*unit.gold_mult, unit.playerID)
				return 0.5
			else
				unit.phase = "goMine"
				return nil
			end

			
		end)
		
	end
	
	player.miner = unit
end

return ma