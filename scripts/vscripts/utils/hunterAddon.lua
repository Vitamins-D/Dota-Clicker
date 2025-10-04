if ha == nil then
    ha = class({})
end

-- local hi = require("utils/hunterInfo")
local wi = require("utils/wavesInfo")

ha.defaultStats = {
	respawnTime = 2,
	camp_count = 1,
	camp_reward = 0.5,
	respawnHunter = 4,
}

-- ha.upgrades = {
	-- {values = {{type = "atk", value = 20}}, cost = 300},
	-- {values = {{type = "atks", value = 50}}, cost = 450},
	-- {values = {{type = "hp", value = 200}, {type = "hpreg", value = 1}}, cost = 600},
	-- {values = {{type = "armor", value = 2}}, cost = 500},
	-- {values = {{type = "camp_count", value = 1}, {type = "atks", value = 75}}, cost = 750},
	-- {values = {{type = "camp_reward", value = 0.25}}, cost = 800},
	-- {values = {{type = "atk", value = 50}, {type = "atks", value = 75}}, cost = 1100},
	-- {values = {{type = "camp_reward", value = 0.25}}, cost = 700},
	-- {values = {{type = "respawnTime", value = -0.5}, {type = "atks", value = 75}}, cost = 1200},
	-- {values = {{type = "hp", value = 400}, {type = "hpreg", value = 1.5}, {type = "armor", value = 2}}, cost = 1500},
	-- {values = {{type = "respawnTime", value = -1}, {type = "camp_reward", value = 0.25}, {type = "respawnHunter", value = -2}}, cost = 2000},
	-- {values = {{type = "atk", value = 40}}, cost = 1000},
-- }

ha.upgrades = {
    { values = { { type = "camp_reward", value = 0.2 } }, cost = 300 },
    { values = { { type = "atk", value = 18 } }, cost = 310 },
    { values = { { type = "hpreg", value = 3 } }, cost = 320 },
    { values = { { type = "camp_reward", value = 0.2 } }, cost = 330 },
    { values = { { type = "armor", value = 2 } }, cost = 340 },

    { values = { { type = "hp", value = 150 } }, cost = 350 },
    { values = { { type = "atk", value = 18 } }, cost = 360 },
    { values = { { type = "camp_reward", value = 0.2 } }, cost = 370 },
    { values = { { type = "atks", value = 46 } }, cost = 380 },
    { values = { { type = "hpreg", value = 3 } }, cost = 390 },

    { values = { { type = "respawnTime", value = -0.5 } }, cost = 400 },
    { values = { { type = "atk", value = 18 } }, cost = 410 },
    { values = { { type = "camp_reward", value = 0.2 } }, cost = 420 },
    { values = { { type = "hp", value = 150 } }, cost = 430 },
    { values = { { type = "armor", value = 2 } }, cost = 440 },

    { values = { { type = "atk", value = 18 } }, cost = 450 },
    { values = { { type = "hpreg", value = 3 } }, cost = 460 },
    { values = { { type = "camp_reward", value = 0.2 } }, cost = 470 },
    { values = { { type = "atks", value = 45 } }, cost = 480 },
    { values = { { type = "hp", value = 150 } }, cost = 490 },

    { values = { { type = "respawnHunter", value = -1.5 } }, cost = 500 },
    { values = { { type = "atk", value = 18 } }, cost = 510 },
    { values = { { type = "camp_count", value = 1 } }, cost = 520 },
    { values = { { type = "hpreg", value = 3 } }, cost = 530 },
    { values = { { type = "hp", value = 150 } }, cost = 540 },

    { values = { { type = "atk", value = 18 } }, cost = 550 },
    { values = { { type = "atks", value = 46 } }, cost = 560 },
    { values = { { type = "camp_reward", value = 0.2 } }, cost = 580 },
    { values = { { type = "armor", value = 2 } }, cost = 590 },

    { values = { { type = "respawnTime", value = -0.5 } }, cost = 600 },
    { values = { { type = "respawnHunter", value = -1.5 } }, cost = 610 },
    { values = { { type = "atk", value = 18 } }, cost = 620 },
    { values = { { type = "atks", value = 46 } }, cost = 630 },
    { values = { { type = "hp", value = 150 } }, cost = 640 },
    { values = { { type = "hpreg", value = 2 } }, cost = 650 },
}



local autoDesc = {
	camp_count = "#hunter_upg %d #ponints_hunt",
	respawnTime = "#hunter2_upg %.1f #sec",
	camp_reward = "#hunter3_upg %.2f #points",
	respawnHunter = "#hunter4_upg %.1f #sec",
}

for k,v in pairs(wi.autoDesc) do
	autoDesc[k] = v
end

local function costText(cost)
	return "<br><br>#cost_text <font color='#EFBF04'>" .. cost .. "</font>"
end

function ha:getCost(level)
	local upgrades = ha.upgrades[level]
	if upgrades then
		return upgrades.cost
	else return nil end
end

function ha:getUpgradeDescription(level)
	
	local desc = "<font color='#228B22'>#hunter</font><br><br>"
	local maxLevel = #ha.upgrades
	if level > maxLevel then
		desc = desc .. "<font color='#80FF80'>#Max_lvl</font>";
	else
		local upgrades = ha.upgrades[level]
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
			local cost = ha:getCost(level)
			desc = desc .. costText(cost)
		end
	end
    return desc
end

-- print("-------------------------------------------------------------")
-- print("HUNTER UPGRADE DESC")
-- print("-------------------------------------------------------------")
-- for i = 1, #ha.upgrades  do
	-- print(ha:getUpgradeDescription(i))
-- end

function ha:InitAddon(player, camp)
	player.hunterLevel = 0
	-- player.hunterLevel = #ha.upgrades
	player.hunterCamp = camp
	
	ha:spawn(player, camp)
end

function ha:spawn(player, camp)
	local playerID = player:GetPlayerID()
	local team = PlayerResource:GetTeam(playerID)
	local unit = CreateUnitByName("npc_dota_clicker_hunter", camp.trigger:GetAbsOrigin(), true, nil, nil, team)
	
	unit.isHunter = true
	unit.camp = camp
	unit.playerID = playerID
	unit.bonus = {}
	
	-- local name = PlayerResource:GetPlayerName(playerID)
	-- print("Игрок "..playerID.." = "..name)
	-- unit:SetUnitName(name)
	
	function unit:update()
		camp.respawnTime = ha.defaultStats.respawnTime
		camp.camp_count = ha.defaultStats.camp_count
		camp.camp_reward = ha.defaultStats.camp_reward
		camp.playerID = playerID
		unit.respawnHunter = ha.defaultStats.respawnHunter
		
		for i = 1, player.hunterLevel do
			local upgrades = ha.upgrades[i]
			if upgrades then
				for j = 1, #upgrades.values do
					local upgrade = upgrades.values[j]
					-- print("upgrade", upgrade, upgrade.type, upgrade.value)
					if upgrade.type == "armor" then
						unit:SetPhysicalArmorBaseValue(unit:GetPhysicalArmorBaseValue() + upgrade.value)
					elseif upgrade.type == "magr" then
						unit:SetBaseMagicalResistanceValue(unit:GetBaseMagicalResistanceValue() + upgrade.value)
					elseif upgrade.type == "hpreg" then
						unit:SetBaseHealthRegen(unit:GetBaseHealthRegen() + upgrade.value)
					elseif upgrade.type == "respawnHunter" then
						unit.respawnHunter = unit.respawnHunter + upgrade.value
					elseif upgrade.type ~= "respawnTime" and upgrade.type ~= "camp_count" and upgrade.type ~= "camp_reward" then
						if not unit.bonus[upgrade.type] then unit.bonus[upgrade.type] = 0 end
						unit.bonus[upgrade.type] = unit.bonus[upgrade.type] + upgrade.value
					else
						camp[upgrade.type] = camp[upgrade.type] + upgrade.value
					end
				end
			end
		end
		
		local playerKey = "player_" .. playerID
		
		local data = CustomNetTables:GetTableValue("user_stats", playerKey)
		data.camp_count = camp.camp_count
		data.camp_reward = camp.camp_reward
		CustomNetTables:SetTableValue("user_stats", playerKey, data)
	end
	unit:update()
	
	Timers:CreateTimer(0.5, function()
		unit:AddNewModifier(unit, nil, "modifier_buff_stats", {})
	end)
	
	player.hunter = unit
end

return ha