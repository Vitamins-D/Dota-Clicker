if wa == nil then
	wa = class({})
end

local info = require("utils/wavesInfo")
local utils = require("utils/utils")

-- info
-- 1 - swordsman
-- 1.1 - tank, 1.1.1 - Veins_fire, 1.1.2 - stone_block
-- 1.2 - berserker, 1.2.1 - melee, 1.2.2 - illusionist
-- 2 - archer
-- 2.1 - shooter, 2.1.1 - marksman, 2.1.2 - headhunter
-- 2.2 - ranger, 2.2.1 - forest_guard, 2.2.2 - beast_master
-- 3 - mage
-- 3.1 - elementalist, 3.1.1 - fire_mage, 3.1.2 - air_mage
-- 3.2 - shaman, 3.2.1 - def_shaman, 3.2.2 - fight_shaman
-- 4 - catapult
-- 4.1 - siege_tower, 4.1.1 - fort_breaker, 4.1.2 - wall_crusher
-- 4.2 - mobile_launcher, 4.2.1 - rapid_fire, 4.2.2 - long_range

function wa:sortUnits(array)
	local priority = {
		swordsman = 1,
		archer    = 2,
		mage      = 3,
		catapult  = 4,
	}
	
    table.sort(array, function(a, b)
        return (priority[a] or math.huge) < (priority[b] or math.huge)
    end)
    return array
end

function wa:InitAddon(player, spawnPos, path, team)
	player.units = {}
	
	player.upgrades = {
		["swordsman"] = {
			{type = "base", levels = {0, 0, 0}}, 
			{type = "class", levels = {0, 0, 0}}, 
			{type = "sub", levels = {0}}, 
			nil, nil},
		["archer"] = {
			{type = "base", levels = {0, 0, 0}}, 
			{type = "class", levels = {0, 0, 0}}, 
			{type = "sub", levels = {0}}, 
			nil, nil},
		["mage"] = {
			{type = "base", levels = {0, 0, 0}}, 
			{type = "class", levels = {0, 0, 0}}, 
			{type = "sub", levels = {0}}, 
			nil, nil},
		["catapult"] = {
			{type = "base", levels = {0, 0, 0}}, 
			{type = "class", levels = {0, 0, 0}}, 
			{type = "sub", levels = {0}}, 
			nil, nil},
	}
	
	player.path = path
	player.spawnPos = spawnPos
	player.team = team
end

function wa:spawnWave(player)
	local spawnPos = player.spawnPos
	local units = player.units
	local pUpgrades = player.upgrades
	local team = player.team
	
	units = wa:sortUnits(units)
	
	-- local hero = PlayerResource:GetSelectedHeroEntity(0)
	-- hero.bonus = {}
	-- hero.bonus["spell_amp"] = 50
	-- Timers:CreateTimer(0.5, function()
		-- hero:AddNewModifier(hero, nil, "modifier_buff_stats", {})
	-- end)
	
	for i = 1, #units do
		Timers:CreateTimer(0.5*i, function()
			local name = units[i]
			
			local unitUpg = pUpgrades[name]
			local class = unitUpg[4]
			local subclass = unitUpg[5]
			
			local pathName = name
			if subclass then pathName = subclass
			elseif class then pathName = class end
			local path = info:getUnitByName(pathName)
			
			local unit = CreateUnitByName(path, spawnPos, true, nil, nil, team)
			unit.path = player.path
			
			unit.skills = {}
			unit.bonus = {}
			
			local names = {name, class, subclass}
			for i = 1, #names do
				local pUpgrade = unitUpg[i]
				local type = pUpgrade.type
				local levels = pUpgrade.levels
				local unitType = names[i]
				
				local skills = wi.skills[unitType]
				if skills then
					for k = 1, #skills do
						local skill = skills[k]
						utils:addAbility(unit, skill)
					end
				end
				
				for j = 1, #levels do
					local lvl = levels[j]
					
					if lvl > 0 and unitType then
						local upgrades = info.upgrades[type][unitType][j].levels
						
						for k = 1, lvl do
							local upgradeLevel = upgrades[k]
							
							for n = 1, #upgradeLevel do
								local upgrade = upgradeLevel[n]
								if upgrade.type == "spell" then
									-- print("SPELL:", upgrade.value)
									utils:addAbility(unit, upgrade.value)
									-- unit:AddAbility(upgrade.value)
								elseif upgrade.type == "spell_up" then
									utils:upgradeAbility(unit, upgrade.value)
								elseif upgrade.type == "replace" then
									utils:replaceAbility(unit, upgrade.value[1], upgrade.value[2])
								else
									if upgrade.type == "armor" then
										unit:SetPhysicalArmorBaseValue(unit:GetPhysicalArmorBaseValue() + upgrade.value)
									elseif upgrade.type == "magr" then
										unit:SetBaseMagicalResistanceValue(unit:GetBaseMagicalResistanceValue() + upgrade.value)
									elseif upgrade.type == "hpreg" then
										unit:SetBaseHealthRegen(unit:GetBaseHealthRegen() + upgrade.value)
									else
										-- остальные бонусы в модификатор
										if not unit.bonus[upgrade.type] then unit.bonus[upgrade.type] = 0 end
										unit.bonus[upgrade.type] = unit.bonus[upgrade.type] + upgrade.value
									end
								end
							end
							
						end
					end
					
				end
			end
			
			local special = info.specials[pathName]
			if special then
				for j = 1, #special do
					local arr = special[j]
					if arr[1] == "replace" then
						utils:replaceAbility(unit, arr[2], arr[3])
					elseif arr[1] == "set" then
						local ability = unit:FindAbilityByName(arr[2])
						if ability then
							ability:SetLevel(arr[3])
						end
					elseif arr[1] == "upgrade" then
						utils:upgradeAbility(unit, arr[2])
					end
				end
			end
			
			Timers:CreateTimer(0.5, function()
				unit:AddNewModifier(unit, nil, "modifier_buff_stats", {})
			end)
		end)
	end
end

return wa