if ha == nil then
    ha = class({})
end

-- local hi = require("utils/hunterInfo")
local wi = require("utils/wavesInfo")

ha.defaultStats = {
	respawnTime = 5,
	camp_count = 1,
	camp_reward = 0.5,
	respawnHunter = 10,
}

ha.upgrades = {
	{values = {{type = "atk", value = 20}}, cost = 300},
	{values = {{type = "atks", value = 50}}, cost = 450},
	{values = {{type = "hp", value = 200}, {type = "hpreg", value = 1}}, cost = 600},
	{values = {{type = "armor", value = 2}}, cost = 500},
	{values = {{type = "camp_count", value = 1}, {type = "atks", value = 75}}, cost = 750},
	{values = {{type = "camp_reward", value = 0.25}}, cost = 800},
	{values = {{type = "atk", value = 50}, {type = "atks", value = 75}}, cost = 1100},
	{values = {{type = "camp_reward", value = 0.25}}, cost = 700},
	{values = {{type = "respawnTime", value = -1.5}, {type = "atks", value = 75}}, cost = 1200},
	{values = {{type = "hp", value = 400}, {type = "hpreg", value = 1.5}, {type = "armor", value = 2}}, cost = 1500},
	{values = {{type = "respawnTime", value = -1.5}, {type = "camp_reward", value = 0.25}, {type = "respawnHunter", value = -5}}, cost = 2000},
	{values = {{type = "atk", value = 40}}, cost = 1000},
}

local autoDesc = {
	camp_count = "Увеличивает количество мобов в лесу на %d ед.",
	respawnTime = "Уменьшает время возрождения лесных крипов на %.1f сек.",
	camp_reward = "Увеличивает награду за лесных крипов на %.2f ОУ",
	respawnHunter = "Уменьшает время возрождения охотника на %.1f сек.",
}

for k,v in pairs(wi.autoDesc) do
	autoDesc[k] = v
end

local function costText(cost)
	return "<br><br>Стоимость: <font color='#EFBF04'>" .. cost .. "</font>"
end

function ha:getCost(level)
	local upgrades = ha.upgrades[level]
	if upgrades then
		return upgrades.cost
	else return nil end
end

function ha:getUpgradeDescription(level)
	
	local desc = "<font color='#228B22'>Охотник</font><br><br>"
	local maxLevel = #ha.upgrades
	if level > maxLevel then
		desc = desc .. "<font color='#80FF80'>Достигнут максимальный уровень</font>";
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
	
	local name = PlayerResource:GetPlayerName(playerID)
	print("Игрок "..playerID.." = "..name)
	unit:SetUnitName(playerName)
	
	function unit:update()
		camp.respawnTime = ha.defaultStats.respawnTime
		camp.camp_count = ha.defaultStats.camp_count
		camp.camp_reward = ha.defaultStats.camp_reward
		unit.respawnHunter = ha.defaultStats.respawnHunter
		
		for i = 1, player.hunterLevel do
			local upgrades = ha.upgrades[i]
			if upgrades then
				for j = 1, #upgrades.values do
					local upgrade = upgrades.values[j]
					print("upgrade", upgrade, upgrade.type, upgrade.value)
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