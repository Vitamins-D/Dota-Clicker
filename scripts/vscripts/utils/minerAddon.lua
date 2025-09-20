if ma == nil then
    ma = class({})
end

local mi = require("utils/mineInfo")
local utils = require("utils/utils")

ma.defaultStats = {
	ore_count = 2, -- размер рюкзака
	mine_speed = 3, -- скорость добычи 1 руды (в секундах)
	speed = 400, -- скорость передвижения
	gold_mult = 6.5,
}

-- ma.upgrades = {
	-- {values = {{type = "speed", value = 50}}, cost = 500},
	-- {values = {{type = "mine_speed", value = -0.25}}, cost = 500},
	-- {values = {{type = "ore_count", value = 1}}, cost = 500},
	-- {values = {{type = "gold_mult", value = 1}}, cost = 1000},
	-- {values = {{type = "speed", value = 50}}, cost = 500},
	-- {values = {{type = "mine_speed", value = -0.25}}, cost = 500},
	-- {values = {{type = "mine_speed", value = -0.5}}, cost = 600},
	-- {values = {{type = "ore_count", value = 2}}, cost = 850},
	-- {values = {{type = "mine_speed", value = -0.5}}, cost = 600},
	-- {values = {{type = "ore_count", value = 1}}, cost = 500},
	-- {values = {{type = "speed", value = 50}}, cost = 500},
	-- {values = {{type = "gold_mult", value = 1.5}}, cost = 2000},
-- }

ma.upgrades = {
  { values = { { type = "speed", value = 20 } }, cost = 300 },
  { values = { { type = "mine_speed", value = -0.3 } }, cost = 305 },

  { values = { { type = "speed", value = 20 } }, cost = 310 },
  { values = { { type = "gold_mult", value = 0.25 } }, cost = 315 },
  { values = { { type = "mine_speed", value = -0.3 } }, cost = 320 },
  { values = { { type = "ore_count", value = 1 } }, cost = 325 },
  { values = { { type = "speed", value = 20 } }, cost = 330 },
  { values = { { type = "mine_speed", value = -0.3 } }, cost = 335 },
  { values = { { type = "gold_mult", value = 0.5 } }, cost = 340 },
  { values = { { type = "ore_count", value = 1 } }, cost = 345 },

  { values = { { type = "speed", value = 20 } }, cost = 350 },
  { values = { { type = "mine_speed", value = -0.3 } }, cost = 355 },
  { values = { { type = "gold_mult", value = 0.5 } }, cost = 360 },
  { values = { { type = "ore_count", value = 1 } }, cost = 365 },
  { values = { { type = "mine_speed", value = -0.3 } }, cost = 370 },
  { values = { { type = "speed", value = 20 } }, cost = 375 },
  { values = { { type = "ore_count", value = 1 } }, cost = 380 },
  { values = { { type = "mine_speed", value = -0.25 } }, cost = 385 },
  { values = { { type = "gold_mult", value = 0.25 } }, cost = 390 },
  { values = { { type = "speed", value = 15 } }, cost = 395 },

  { values = { { type = "mine_speed", value = -0.25 } }, cost = 400 },
  { values = { { type = "ore_count", value = 1 } }, cost = 405 },
  { values = { { type = "mine_speed", value = -0.25 } }, cost = 410 },
  { values = { { type = "speed", value = 15 } }, cost = 415 },
  { values = { { type = "gold_mult", value = 0.5 } }, cost = 420 },
  { values = { { type = "mine_speed", value = -0.25 } }, cost = 425 },
  { values = { { type = "gold_mult", value = 0.5 } }, cost = 430 },
  { values = { { type = "mine_speed", value = -0.25 } }, cost = 435 },
  { values = { { type = "ore_count", value = 2 } }, cost = 440 },
  { values = { { type = "gold_mult", value = 0.5 } }, cost = 445 },
}

local autoDesc = {
	ore_count = "#miner_upg %d #ponints_hunt",
	mine_speed = "#miner2_upg %.2f #sec",
	speed = "#miner3_upg %d #ponints_hunt",
	gold_mult = "#miner4_upg %.2f #ponints_hunt",
}

local function costText(cost)
	return "<br><br>#cost_text <font color='#EFBF04'>" .. cost .. "</font>"
end

function ma:getCost(level)
	local upgrades = ma.upgrades[level]
	if upgrades then
		return upgrades.cost
	else return nil end
end

function ma:getUpgradeDescription(level)
	
	local desc = "<font color='#FFD700'>#miner_work</font><br><br>"
	local maxLevel = #ma.upgrades
	local upgrades = ma.upgrades[level]
	if level > maxLevel then
		desc = desc .. "<font color='#80FF80'>#Max_lvl</font>";
	else
		if upgrades then
			for i = 1, #upgrades.values do
				local upgrade = upgrades.values[i]
				if i > 1 then desc = desc .. "<br><br>" end
				if upgrade.desc then
					desc = desc .. upgrade.desc
				else
					local pattern = autoDesc[upgrade.type]
					if pattern then
						desc = desc .. string.format(pattern, upgrade.value)
					end
				end
			end
		end
		
		if level <= maxLevel then
			local cost = ma:getCost(level)
			desc = desc .. costText(cost)
		end
	end
    return desc
end

-- print("-------------------------------------------------------------")
-- print("MINER UPGRADES DESC")
-- print("-------------------------------------------------------------")
-- for i = 1, #ma.upgrades  do
	-- print(ma:getUpgradeDescription(i))
-- end

function ma:InitAddon(player, spawnPos, minePos, homePos)
	player.minerLevel = 0
	-- player.minerLevel = #ma.upgrades
	
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
	
	-- local playerName = PlayerResource:GetPlayerName(playerID)
	-- unit:SetUnitName("addon_game_name")
	
	unit:AddNewModifier(unit, nil, "modifier_mine_protection", {})
	
	function unit:update()
		unit.ore_count = ma.defaultStats.ore_count
		unit.mine_speed = ma.defaultStats.mine_speed
		unit.gold_mult = ma.defaultStats.gold_mult
		unit:SetBaseMoveSpeed(ma.defaultStats.speed)
		
		for i = 1, player.minerLevel do
			local upgrades = ma.upgrades[i]
			if upgrades then
				for j = 1, #upgrades.values do
					local upgrade = upgrades.values[j]
					if upgrade.type == "speed" then
						unit:SetBaseMoveSpeed(unit:GetBaseMoveSpeed() + upgrade.value)
					else
						unit[upgrade.type] = math.floor((unit[upgrade.type] + upgrade.value) * 100 + 0.5) / 100
					end
				end
			end
		end
		
		local playerKey = "player_" .. playerID
		
		local data = CustomNetTables:GetTableValue("user_stats", playerKey)
		data.backpack = unit.ore_count
		data.mine_speed = unit.mine_speed
		data.gold_mult = unit.gold_mult
		CustomNetTables:SetTableValue("user_stats", playerKey, data)
	end
	unit:update()
	
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
				return 0.25
			else
				unit.phase = "goMine"
				return nil
			end

			
		end)
		
	end
	
	player.miner = unit
end

return ma