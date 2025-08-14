if wa == nil then
	wa = class({})
end

local info = require("utils/wavesInfo")

-- info
-- 1 - melee
-- 1.1 - tank, 1.1.1 - fire, 1.1.2 - stone
-- 1.2 - berserk, 1.2.1 - swordsman, 1.2.2 - illusion
-- 2 - ranger
-- 2.1 - shooter, 2.1.1 - gunner, 2.1.2 - sniper
-- 2.2 - archer, 2.2.1 - pathfinder, 2.2.2 - huntsman
-- 3 - mage
-- 3.1 - elementalist, 3.1.1 - firestone, 3.1.2 - waterair
-- 3.2 - shaman, 3.2.1 - aura, 3.2.2 - summoner
-- 4 - siege
-- 4.1 - catapult, 4.1.1 - trebuchet, 4.1.2 - ballista
-- 4.2 - bomb, 4.2.1 - miner, 4.2.2 - flamethrower

-- Example as view in player
local upgrades = {
	["melee"] = {{0, 0, 0}, "class", {0, 0, 0}, "subclass", 0},
	["ranger"] = {{0, 0, 0}, "class", {0, 0, 0}, "subclass", 0},
	["mage"] = {{0, 0, 0}, "class", {0, 0, 0}, "subclass", 0},
	["siege"] = {{0, 0, 0}, "class", {0, 0, 0}, "subclass", 0},
}

local units = {
	"melee", "ranger", "mage", "siege", "ranger"
}

function wa:InitAddon(player, spawnPos, team)
	player.units = {
		"mage"
	}
	
	player.upgrades = {
		["melee"] = {
			{type = "base", levels = {0, 0, 0}}, 
			{type = "class", levels = {0, 0, 0}}, 
			{type = "sub", levels = {0}}, 
			nil, nil},
		["ranger"] = {
			{type = "base", levels = {0, 0, 0}}, 
			{type = "class", levels = {0, 0, 0}}, 
			{type = "sub", levels = {0}}, 
			nil, nil},
		["mage"] = {
			{type = "base", levels = {2, 0, 0}}, 
			{type = "class", levels = {0, 0, 0}}, 
			{type = "sub", levels = {0}}, 
			nil, nil},
		["siege"] = {
			{type = "base", levels = {0, 0, 0}}, 
			{type = "class", levels = {0, 0, 0}}, 
			{type = "sub", levels = {0}}, 
			nil, nil},
	}
	
	player.spawnPos = spawnPos
	player.team = team
end

function wa:spawnWave(player)
	local spawnPos = player.spawnPos
	local units = player.units
	local pUpgrades = player.upgrades
	local team = player.team
	
	for i = 1, #units do
		local name = units[i]
		
		local unitUpg = pUpgrades[name]
		local class = unitUpg[4]
		local subclass = unitUpg[5]
		
		local pathName = name
		if subclass then pathName = subclass
		elseif class then pathName = class end
		local path = info:getUnitByName(pathName)
		
		local unit = CreateUnitByName(path, spawnPos, true, nil, nil, team)
		
		unit.bonus = {}
		Timers:CreateTimer(0.1, function()
			unit:AddNewModifier(unit, nil, "modifier_buff_stats", {})
		end)
		
		local names = {name, class, subclass}
		for i = 1, 3 do
			local pUpgrade = unitUpg[i]
			local type = pUpgrade.type
			local levels = pUpgrade.levels
			for j = 1, #levels do
				local lvl = levels[j]
				
				local unitType = names[i]
				if lvl > 0 and unitType then
					local upgrades = info.upgrades[type][unitType][j].levels
					
					for k = 1, lvl do
						local upgradeLevel = upgrades[k]
						
						for n = 1, #upgradeLevel do
							local upgrade = upgradeLevel[n]
							if upgrade.type == "spell" then
								-- print("SPELL:", upgrade.value)
								unit:AddAbility(upgrade.value)
							elseif upgrade.type == "spell_up" then
								local ability = unit:FindAbilityByName(upgrade.value)
								if ability then
									ability:SetLevel(ability:GetLevel() + 1)
								end
							else
								unit.bonus[upgrade.type] = upgrade.value
							end
						end
						
					end
				end
				
			end
		end
		
	end
end

return wa