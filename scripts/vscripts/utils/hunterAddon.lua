if ha == nil then
    ha = class({})
end

-- local hi = require("utils/hunterInfo")

ha.defaultStats = {
	respawnTime = 15,
	camp_count = 2,
	camp_reward = 1,
	respawnHunter = 10,
}

ha.upgrades = {
	{values = {{type = "atks", value = 50}}, cost = 100},
	{values = {{type = "respawnTime", value = -15}}, cost = 100},
	{values = {{type = "camp_count", value = 2}}, cost = 100},
	{values = {{type = "camp_reward", value = 1}}, cost = 100},
	{values = {{type = "atk", value = 20}}, cost = 100},
	{values = {{type = "hp", value = 300}}, cost = 100},
	{values = {{type = "armor", value = 5}}, cost = 100},
	{values = {{type = "hpreg", value = 4}}, cost = 100}
}

function ha:InitAddon(player, camp)
	player.hunterLevel = 0
	player.hunterCamp = camp
	
	ha:spawn(player, camp)
end

function ha:spawn(player, camp)
	local playerID = player:GetPlayerID()
	local team = PlayerResource:GetTeam(playerID)
	local unit = CreateUnitByName("npc_dota_clicker_hunter", camp:GetAbsOrigin(), true, nil, nil, team)
	
	unit.isHunter = true
	unit.camp = camp
	unit.playerID = playerID
	
	local playerName = PlayerResource:GetPlayerName(playerID)
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
		data.camp_count = unit.camp_count
		data.camp_reward = unit.camp_reward
		CustomNetTables:SetTableValue("user_stats", playerKey, data)
	end
	unit:update()
	
	Timers:CreateTimer(0.5, function()
		unit:AddNewModifier(unit, nil, "modifier_buff_stats", {})
	end)
	
	player.hunter = unit
end

return hi