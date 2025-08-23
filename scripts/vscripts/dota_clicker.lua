if dota_clicker == nil then
	dota_clicker = class({})
end

local neutralSpawner = require("utils/neutralSpawner")
local wi = require("utils/wavesInfo")
local wa = require("utils/wavesAddon")
local utils = require("utils/utils")
local badBotAI = require("utils/badBotAI")

-- константы/настройки
local WAVE_INTERVAL = 60
local LVLUP_INTERVAL = WAVE_INTERVAL
local GOLD_INTERVAL = 120
local MAX_UNITS = 20
local MINE_INTERACTION_DISTANCE = 200
local GOLD_GIVE = 500
local LVL_GIVE = 1
local AI_DIF = 1
local AI_ON = true

local newLevelGive = LVL_GIVE
local playerLevel = 1

local badBot = {}
 
local pathCount = 11

local uiArr
local maxUnitPerPlayer

local PlayerData = {}
-- PlayerData[1] = {
	-- upgrades = {
		-- ["swordsman"] = {
			-- {type = "base", levels = {3, 5, 5}}, 
			-- {type = "class", levels = {3, 1}}, 
			-- {type = "sub", levels = {2}}, 
			-- "tank", "Veins_fire"},
		-- ["archer"] = {
			-- {type = "base", levels = {0, 0, 0}}, 
			-- {type = "class", levels = {0, 0}}, 
			-- {type = "sub", levels = {0}}, 
			-- nil, nil},
		-- ["mage"] = {
			-- {type = "base", levels = {0, 0, 0}}, 
			-- {type = "class", levels = {0, 0}}, 
			-- {type = "sub", levels = {0}}, 
			-- nil, nil},
		-- ["catapult"] = {
			-- {type = "base", levels = {0, 0, 0}}, 
			-- {type = "class", levels = {0, 0}}, 
			-- {type = "sub", levels = {0}}, 
			-- nil, nil},
	-- },
	-- units = {"swordsman", "mage", "mage", "swordsman", "swordsman", "swordsman"}
-- }

local playerCount
local difficulty = 2
local difficulties = {
	{WAVE_INTERVAL = 30, LVLUP_INTERVAL = 30, GOLD_INTERVAL = 60, MAX_UNITS = 30, GOLD_GIVE = 750, LVL_GIVE = 1.5, AI_DIF = 1},
	{WAVE_INTERVAL = 60, LVLUP_INTERVAL = 60, GOLD_INTERVAL = 120, MAX_UNITS = 20, GOLD_GIVE = 500, LVL_GIVE = 1, AI_DIF = 1},
	{WAVE_INTERVAL = 40, LVLUP_INTERVAL = 60, GOLD_INTERVAL = 180, MAX_UNITS = 20, GOLD_GIVE = 450, LVL_GIVE = 0.9, AI_DIF = 2},
	{WAVE_INTERVAL = 30, LVLUP_INTERVAL = 60, GOLD_INTERVAL = 180, MAX_UNITS = 15, GOLD_GIVE = 60, LVL_GIVE = 0.75, AI_DIF = 3},
}

local levelExp = 100
HeroExpTable = {0}
for i=2,30 do 
	HeroExpTable[i] = levelExp*(i-1)
end

function dota_clicker:InitGameMode()
	playerCount = DOTA_MAX_TEAM_PLAYERS
	uiArr = wi:convertToUnifiedStructure()
	maxUnitPerPlayer = math.ceil(MAX_UNITS/playerCount)
	
	GameRules:SetStartingGold(1000)
	GameRules:SetUseUniversalShopMode(true)
	GameRules:SetHeroSelectionTime(99999)
	GameRules:SetPreGameTime(0)
	GameRules:SetStrategyTime(10.0)
	GameRules:SetShowcaseTime(0.0)
	GameRules:SetTreeRegrowTime(120)
	GameRules:GetGameModeEntity():SetFixedRespawnTime(25)
	GameRules:GetGameModeEntity():SetFreeCourierModeEnabled(true)
	GameRules:SetGoldPerTick(0) 
	-- GameRules:SetGoldTickTime(5)
	
	GameRules:GetGameModeEntity():SetUseCustomHeroLevels(true)
	GameRules:GetGameModeEntity():SetCustomXPRequiredToReachNextLevel(HeroExpTable)
	GameRules:GetGameModeEntity():SetUnseenFogOfWarEnabled(true)
	
	GameRules:SetCustomGameTeamMaxPlayers(DOTA_TEAM_GOODGUYS, 10)
	GameRules:SetCustomGameTeamMaxPlayers(DOTA_TEAM_BADGUYS, 0)
	
	ListenToGameEvent('entity_killed', Dynamic_Wrap(self, 'dotaClickerKilled'), self)
	ListenToGameEvent('game_rules_state_change', Dynamic_Wrap(self, 'dotaClickerStateChange'), self)
	ListenToGameEvent('npc_spawned', Dynamic_Wrap(self, 'OnNpcSpawned'), self)
	ListenToGameEvent('entity_hurt', Dynamic_Wrap(self, 'dotaClickerHurt'), self)
	ListenToGameEvent("player_chat", Dynamic_Wrap(self, 'OnPlayerChat'), self)
	ListenToGameEvent('tree_cut', Dynamic_Wrap(self, 'OnTreeCut'), self)
	
	-- Игрок отключился (его объект Player удаляется)
	ListenToGameEvent("player_disconnect", Dynamic_Wrap(self, "OnPlayerDisconnect"), self)

	-- Игрок переподключился
	ListenToGameEvent("player_reconnected", Dynamic_Wrap(self, "OnPlayerReconnect"), self)

	-- Игрок подключился первый раз
	ListenToGameEvent("player_connect_full", Dynamic_Wrap(self, "OnPlayerConnectFull"), self)
	
	GameRules:GetGameModeEntity():SetExecuteOrderFilter(Dynamic_Wrap(dota_clicker, "OrderFilter"), self)
	GameRules:GetGameModeEntity():SetDamageFilter(Dynamic_Wrap(dota_clicker, "DamageFilter"), self)
	
	self:StartSimpleGroundItemCleanup()
	
	self:RegisterCustomEventListeners()
end

function dota_clicker:RegisterCustomEventListeners()
	CustomGameEventManager:RegisterListener("Mining", function(_, event)
		local oreType = event.ore_type
		local playerId = event.player_id
		miningDo(oreType, playerId)
	end)
	
	CustomGameEventManager:RegisterListener("upgrade_unit", function(_, event)
		local unit = event.unit
		local upgrade = event.upgrade
		local player_id = event.player_id
		local player = PlayerResource:GetPlayer(player_id)
		local type = event.type
		
		if not player then return end
		
		if type == "base" then
			self:HandleBaseUpgrade(player, player_id, unit, upgrade)
		elseif type == "evolution" or type == "subclass" then
			self:HandleSpecialUpgrade(player, player_id, unit, upgrade, type)
		end
	end)
	
	CustomGameEventManager:RegisterListener("buy_unit", function(_, event)
		self:HandleBuyUnit(event)
	end)

	CustomGameEventManager:RegisterListener("get_data_units", function(_, event)
		local player_id = event.player_id
		local player = PlayerResource:GetPlayer(player_id)
		CustomGameEventManager:Send_ServerToPlayer(player, "SetDataUnits", {dataU = uiArr})
	end)

	CustomGameEventManager:RegisterListener("get_data_currMaxUnits", function(_, event)
		local player_id = event.player_id
		local player = PlayerResource:GetPlayer(player_id)
		self:throughPlayers(function(player, hero)
			CustomGameEventManager:Send_ServerToPlayer(player, "SetDataLimit", {limit = maxUnitPerPlayer})
		end)
	end)
	
	CustomGameEventManager:RegisterListener("sell_unit", function(_, event)
		self:HandleSellUnit(event)
	end)
	
	CustomGameEventManager:RegisterListener("player_selected_difficulty", function(_, event)
		self:HandleDifficulty(event)
	end)
end

function dota_clicker:HandleDifficulty(event)
	difficulty = event.difficulty
	
	self:throughPlayers(function(player, hero)
		CustomGameEventManager:Send_ServerToPlayer(player, "difficulty_confirmed", {success = true})
	end, true)
end

function dota_clicker:HandleBaseUpgrade(player, player_id, unit, upgrade)
	local upgId, upgType = wi:getUpgByName(unit, upgrade)
	
	local arrId
	if upgType == "base" then arrId = 1
	elseif upgType == "class" then arrId = 2
	elseif upgType == "sub" then arrId = 3
	end
	
	local _, _, currentName = wi:getUpgByName(unit, upgrade)
	local newLevel = player.upgrades[unit][arrId].levels[upgId]
	local gold = PlayerResource:GetGold(player_id)
	local maxLevel = wi:getMaxLevel(upgType, currentName, upgrade)
	local desc = wi:getUpgradeDescription(currentName, upgrade, newLevel+1)
	local cost = wi:getUpgradeCost(currentName, upgrade, newLevel+1)
	
	if gold >= cost and newLevel < maxLevel then
		newLevel = newLevel + 1
		player.upgrades[unit][arrId].levels[upgId] = newLevel
		desc = wi:getUpgradeDescription(currentName, upgrade, newLevel+1)
		GiveGold(-cost, player_id)
	end
	
	CustomGameEventManager:Send_ServerToPlayer(player, "upgrade_success", {
		unit = unit, 
		upgrade = upgrade, 
		newLevel = newLevel, 
		desc = desc
	})
end

function dota_clicker:HandleSpecialUpgrade(player, player_id, unit, upgrade, type)
	local converter = {
		["evolution"] = "class",
		["subclass"] = "sub",
	}
	-- local baseName = wi:getUnitName(unit)
	local playerUnit = player.upgrades[unit]
	local infoUnit = wi.upgrades[converter[type]][upgrade]
	local cost = infoUnit.cost
	
	local gold = PlayerResource:GetGold(player_id)
	if gold >= cost then
		GiveGold(-cost, player_id)
		if type == "evolution" then
			playerUnit[4] = upgrade
		else
			playerUnit[5] = upgrade
		end
		CustomGameEventManager:Send_ServerToPlayer(player, "upgrade_success", {
			unit = unit, 
			upgrade = upgrade
		})
	end
end

function dota_clicker:HandleBuyUnit(event)
	local unit = event.unit
	local player_id = event.player_id
	local player = PlayerResource:GetPlayer(player_id)
	
	local baseName = wi:getUnitName(unit)
	local playerUnit = utils:countOf(player.units, unit)
	
	local success = false
	local count = playerUnit
	
	local gold = PlayerResource:GetGold(player_id)
	local cost = wi.base[unit].cost
	
	if gold >= cost then
		GiveGold(-cost, player_id)
		success = true
		count = count + 1
		table.insert(player.units, unit)
	end
	
	CustomGameEventManager:Send_ServerToPlayer(player, "buy_unit_response", {
		unit = unit, 
		success = success, 
		new_count = count
	})
end

function dota_clicker:HandleSellUnit(event)
	local unit = event.unit
	local player_id = event.player_id
	local player = PlayerResource:GetPlayer(player_id)
	
	local baseName = wi:getUnitName(unit)
	local playerUnit = utils:countOf(player.units, unit)
	
	local count = playerUnit - 1
	table.remove(player.units, utils:indexOf(player.units, unit))
	
	local cost = wi.base[unit].cost
	GiveGold(cost, player_id)
	
	CustomGameEventManager:Send_ServerToPlayer(player, "sell_unit_response", {
		unit = unit, 
		success = true, 
		new_count = count
	})
end

function dota_clicker:OrderFilter(filterTable)
	local order_type = filterTable["order_type"]
	local issuer = PlayerResource:GetPlayer(filterTable["issuer_player_id_const"])
	local target_index = filterTable["entindex_target"]
	local player_id = filterTable["issuer_player_id_const"]
	local units = filterTable["units"]
	
	-- Проверяем только если есть цель
	if target_index and target_index ~= 0 then
		local target = EntIndexToHScript(target_index)
		
		-- Безопасная проверка на существование цели и её методов
		if target and IsValidEntity(target) then
			local target_name = target.GetUnitName and target:GetUnitName() or "unknown"
			
			-- Проверяем только если цель - это шахта
			if target_name == "npc_dotac_mine" then
				local issuer_unit = nil
				if units then
					for i, unit_index in pairs(units) do
						local unit = EntIndexToHScript(unit_index)
						if unit and IsValidEntity(unit) then
							issuer_unit = unit
							break
						end
					end
				end
				
				-- Проверяем только если юнит - это настоящий герой
				if issuer_unit and issuer_unit.IsRealHero and issuer_unit:IsRealHero() then
					-- Проверяем расстояние между героем и шахтой
					local hero_pos = issuer_unit:GetAbsOrigin()
					local mine_pos = target:GetAbsOrigin()
					local distance = (hero_pos - mine_pos):Length2D()
					
					if distance <= MINE_INTERACTION_DISTANCE then
						-- Проверяем наличие кирки у героя
						local has_pickaxe = false
						local pickaxes = {
							"item_dotac_pickaxe_wood",
							"item_dotac_pickaxe_stone", 
							"item_dotac_pickaxe_iron",
							"item_dotac_pickaxe_diamond",
							"item_dotac_pickaxe_netherite"
						}
						
						for _, pickaxe_name in pairs(pickaxes) do
							if issuer_unit:HasItemInInventory(pickaxe_name) then
								has_pickaxe = true
								break
							end
						end
						
						-- Проверяем подходящий тип приказа для взаимодействия с шахтой
						if order_type == DOTA_UNIT_ORDER_MOVE_TO_TARGET or 
						   order_type == DOTA_UNIT_ORDER_ATTACK_TARGET or 
						   order_type == DOTA_UNIT_ORDER_CAST_TARGET then
							
							if has_pickaxe then
								-- Открываем модал шахты
								CustomGameEventManager:Send_ServerToPlayer(issuer, "toggle_mine_modal", {
									mine_id = target:GetEntityIndex()
								})
								return false -- Блокируем этот приказ
							else
								-- Показываем сообщение о необходимости кирки
								CustomGameEventManager:Send_ServerToPlayer(issuer, "show_floating_text", {
									message = "You need a pickaxe to mine!",
									duration = 2.0
								})
								return false -- Блокируем этот приказ
							end
						end
					end
				end
			end
		end
	end
	
	return true -- Разрешаем все остальные приказы
end

function dota_clicker:DamageFilter(filterTable)
	local victim_index = filterTable["entindex_victim_const"]
	
	if victim_index then
		local victim = EntIndexToHScript(victim_index)
		if victim and IsValidEntity(victim) then
			if victim:GetUnitName() == "npc_dotac_mine" or victim.is_mine then
				return false
			end
		end
	end
	
	return true
end

function dota_clicker:OnTreeCut(event)
	local killer = event.killerID
	
	local drop_chance = 60
	
	if killer then
		local player = PlayerResource:GetPlayer(killer)
		if player then 
			local hero = player:GetAssignedHero()
			local ability = hero:FindAbilityByName("shredder_rigid_saws")
			if ability and ability:GetLevel() > 0 then
				drop_chance = ability:GetSpecialValueFor("new_chance")
			end
		end
	end
	
	if math.random(1, 100) <= drop_chance then
		local tree_position = Vector(event.tree_x, event.tree_y, GetGroundHeight(Vector(event.tree_x, event.tree_y, 0), nil))
		
		local item = CreateItem("item_dotac_wood", nil, nil)
		if item then
			local dropped_item = CreateItemOnPositionSync(tree_position, item)
			if dropped_item then
				dropped_item.creation_time = GameRules:GetGameTime()
			end
		end
	end
end

function dota_clicker:StartSimpleGroundItemCleanup()
	local cleanupItems = {
		"item_dotac_wood",
		"item_dotac_boar_skin",
		"item_dotac_wolf_skin",
		"item_dotac_murloc_skin",
		"item_dotac_bear_skin",
		"item_dotac_cheeter_meat"
	}

	Timers:CreateTimer(30, function()
		local all_items = Entities:FindAllByClassname("dota_item_drop")

		for _, item_drop in pairs(all_items) do
			if IsValidEntity(item_drop) and not item_drop:IsNull() then
				local item = item_drop:GetContainedItem()
				if item then
					local itemName = item:GetAbilityName()
					if utils:indexOf(cleanupItems, itemName) then
						if not item_drop.creation_time then
							item_drop.creation_time = GameRules:GetGameTime()
						elseif GameRules:GetGameTime() - item_drop.creation_time >= 30 then
							UTIL_Remove(item_drop)
						end
					end
				end
			end
		end

		return 30
	end)
end

function miningDo(oreType, playerId)
	local oresValues = {
		["iron"] = 1,
		["silver"] = 3,
		["gold"] = 5,
	}
	
	local player = PlayerResource:GetPlayer(playerId)
	if not player then return end
	
	local hero = player:GetAssignedHero()
	if not hero then return end
	
	-- Список всех кирок
	local pickaxes = {
		"item_dotac_pickaxe_wood",
		"item_dotac_pickaxe_stone", 
		"item_dotac_pickaxe_iron",
		"item_dotac_pickaxe_diamond",
		"item_dotac_pickaxe_netherite"
	}
	
	local goldMultiplier = 1
	local bestPickaxe = nil
	
	-- Ищем лучшую кирку в инвентаре
	for i = 0, 15 do
		local item = hero:GetItemInSlot(i)
		if item then
			local itemName = item:GetAbilityName()
			for _, pickaxeName in pairs(pickaxes) do
				if itemName == pickaxeName then
					local itemMultiplier = item:GetSpecialValueFor("gold_mult")
					if itemMultiplier and itemMultiplier > goldMultiplier then
						goldMultiplier = itemMultiplier
						bestPickaxe = item
					end
				end
			end
		end
	end
	
	-- Рассчитываем финальное количество золота
	local baseGold = oresValues[oreType] or 0
	local finalGold = math.floor(baseGold * goldMultiplier)
	
	local proMiner = hero:FindAbilityByName("dotac_meepo_pro_miner")
	if proMiner and proMiner:GetLevel() > 0 then
		local bonusGold = proMiner:GetSpecialValueFor("bonus_gold")
		finalGold = finalGold + bonusGold
	end
	
	-- Выдаем золото
	GiveGold(finalGold, playerId)
end

function GiveGold(gold, playerId)
	if PlayerResource:HasSelectedHero(playerId) then
		local player = PlayerResource:GetPlayer(playerId)
		local hero = PlayerResource:GetSelectedHeroEntity(playerId)
		hero:ModifyGold(gold, false, 0)
		SendOverheadEventMessage(player, OVERHEAD_ALERT_GOLD, hero, gold, nil)
	end
end

function dota_clicker:dotaClickerStateChange(data)
	local newState = GameRules:State_Get()
	if newState == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
		self:dotaClickerStart() 
	end 
end

function dota_clicker:dotaClickerHurt(event)
	local victim = EntIndexToHScript(event.entindex_killed)
	local attacker = EntIndexToHScript(event.entindex_attacker) -- не использовалась
	local damage = event.damage -- не использовалась	
	
	if victim and victim:GetUnitName() == "npc_dotac_mine" and victim.is_invulnerable then
		victim:SetHealth(victim:GetMaxHealth())
		return false
	end
end

function dota_clicker:OnPlayerChat(event)
	local player_id = event.playerid
	local text = event.text
	
	if text == "-rich" or text == "-кшср" then
		GiveGoldPlayers(999999)
	elseif text == "-lvl" or text == "-дмд" then
		GiveExpPlayers(levelExp*30)
	end
end

function dota_clicker:dotaClickerKilled(data)
	local killed_unit = EntIndexToHScript(data.entindex_killed)
	if not killed_unit or not killed_unit.GetUnitName then return end

	local unitName = killed_unit:GetUnitName()
	local dropPos = killed_unit:GetAbsOrigin()

	local dropTable = neutralSpawner.dropTable

	if dropTable[unitName] then
		for _, drop in pairs(dropTable[unitName]) do
			if RandomInt(1, 100) <= drop.chance then
				local item = CreateItem(drop.item, nil, nil)
				if item then
					local dropped_item = CreateItemOnPositionSync(dropPos, item)
					if dropped_item then
						dropped_item.creation_time = GameRules:GetGameTime()
					end
				end
			end
		end
	end
end

function dota_clicker:SpawnMines()
	local spawn_points = Entities:FindAllByName("mine_spawn")
	for _, point in pairs(spawn_points) do
		local pos = point:GetAbsOrigin()
		local mine = CreateUnitByName("npc_dotac_mine", pos, false, nil, nil, DOTA_TEAM_GOODGUYS)
		mine:SetForwardVector(Vector(0,1,0))
		
		mine:SetCanSellItems(false)
		mine:SetUnitCanRespawn(false)
		mine:SetDeathXP(0)
		mine:SetMinimumGoldBounty(0)
		mine:SetMaximumGoldBounty(0)
		
		mine:AddNewModifier(mine, nil, "modifier_mine_protection", {})
		
		mine.is_invulnerable = true
		mine.is_mine = true
	end
end

function dota_clicker:dotaClickerStart()
	print("DOTA CLICKER START")
	
	local prms = difficulties[difficulty]
	
	WAVE_INTERVAL = prms.WAVE_INTERVAL
	LVLUP_INTERVAL = prms.LVLUP_INTERVAL
	GOLD_INTERVAL = prms.GOLD_INTERVAL
	MAX_UNITS = prms.MAX_UNITS
	GOLD_GIVE = prms.GOLD_GIVE
	LVL_GIVE = prms.LVL_GIVE
	AI_DIF = prms.AI_DIF
	
	neutralSpawner:InitNeutralCamps()
	
	local vision_pos = Entities:FindByName(nil, "vision"):GetAbsOrigin()
	local vision_unit = CreateUnitByName("npc_dota_clicker_vision", vision_pos, false, nil, nil, DOTA_TEAM_GOODGUYS)
	
	playerCount = PlayerResource:GetPlayerCountForTeam(DOTA_TEAM_GOODGUYS) + PlayerResource:GetPlayerCountForTeam(DOTA_TEAM_BADGUYS)
	
	Timers:CreateTimer(1, function()
		local damage_table = {
			victim = vision_unit,          
			attacker = vision_unit,        
			damage = vision_unit:GetMaxHealth()*1.5,        
			damage_type = DAMAGE_TYPE_PURE, 
			ability = nil,      
		}
		ApplyDamage(damage_table)
		return
	end)
	
	dota_clicker:SpawnMines()
	
	self:throughPlayers(function(player, hero)
		CustomGameEventManager:Send_ServerToPlayer(player, "SetTransMap", {transMap = wi.nameMapping})
	end)
	
	uiArr = wi:convertToUnifiedStructure()
	self:throughPlayers(function(player, hero)
		CustomGameEventManager:Send_ServerToPlayer(player, "SetDataUnits", {dataU = uiArr})
	end)
	
	maxUnitPerPlayer = math.ceil(MAX_UNITS/playerCount)
	self:throughPlayers(function(player, hero)
		CustomGameEventManager:Send_ServerToPlayer(player, "SetDataLimit", {limit = maxUnitPerPlayer})
	end)
	
	-- local badPath = getPaths("wave_path_", pathCount, false)
	-- local bad_start = badPath[1]:GetAbsOrigin()
	-- self:throughPlayers(function(player, hero)
		-- wa:InitAddon(player, bad_start, badPath, DOTA_TEAM_BADGUYS)
	-- end)
	
	local path = getPaths("wave_path_", pathCount, true)
	local wave_start = path[1]:GetAbsOrigin()
	self:throughPlayers(function(player, hero)
		wa:InitAddon(player, wave_start, path, DOTA_TEAM_GOODGUYS)
	end)
	
	
	local badPath = getPaths("wave_path_", pathCount, false)
	local bad_start = badPath[1]:GetAbsOrigin()
	wa:InitAddon(badBot, bad_start, badPath, DOTA_TEAM_BADGUYS)
	if AI_ON then
		badBot.gold = PlayerResource:GetPlayerCount()*1000
		badBotAI:Init(badBot, { difficulty = 1.0, players = PlayerResource:GetPlayerCount(), difficulty = AI_DIF })
	end
	-- wa:spawnWave(badBot)
	
	newLevelGive = LVL_GIVE
	Timers:CreateTimer(LVLUP_INTERVAL, function()
		GiveExpPlayers(newLevelGive*levelExp)
		playerLevel = playerLevel + newLevelGive
		if math.floor(playerLevel) == 5 then
			newLevelGive = LVL_GIVE*0.75
		elseif math.floor(playerLevel) == 15 then
			newLevelGive = LVL_GIVE*0.5
		end
		return LVLUP_INTERVAL
	end)
	
	Timers:CreateTimer(GOLD_INTERVAL, function()
		GiveGoldPlayers(GOLD_GIVE)
		return GOLD_INTERVAL
	end)
	
	Timers:CreateTimer(WAVE_INTERVAL, function()
		self:throughPlayers(function(player, hero)
			wa:spawnWave(player)
		end)

		-- бот думает, как развиваться
		if AI_ON then
			badBotAI:Tick(badBot, MAX_UNITS)
		end
		wa:spawnWave(badBot)

		return WAVE_INTERVAL
	end)

end

function dota_clicker:OnThink()
	if GameRules:State_Get() == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
	elseif GameRules:State_Get() >= DOTA_GAMERULES_STATE_POST_GAME then
		return nil
	end
	return 1
end

function dota_clicker:OnNpcSpawned(data)
	local npc = EntIndexToHScript(data.entindex)
    if not npc or not npc:IsRealHero() then return end

    -- Проверяем, есть ли способность
	do
		local ability = npc:FindAbilityByName("neutral_damage_bonus")
		if ability and ability:GetLevel() < 1 then
			ability:SetLevel(1)
		end
	end
	do
		local ability = npc:FindAbilityByName("shredder_rigid_saws")
		if ability and ability:GetLevel() < 1 then
			ability:SetLevel(1)
		end
	end
end

function dota_clicker:throughPlayers(callback, notHero)
	for index = 0, playerCount - 1 do
		if notHero or PlayerResource:HasSelectedHero(index)then
			local player = PlayerResource:GetPlayer(index)
			if player then
				local hero = PlayerResource:GetSelectedHeroEntity(index)
				callback(player, hero)
			end
		end
	end
end

function GiveExpPlayers(expVal)
	dota_clicker:throughPlayers(function(_, hero)
		hero:AddExperience(expVal, false, false)
	end)
end

function GiveGoldPlayers(gold)	
	dota_clicker:throughPlayers(function(player, hero)
		hero:ModifyGold(gold, false, 0)
		SendOverheadEventMessage(player, OVERHEAD_ALERT_GOLD, hero, gold, nil)
	end)
end

function getPaths(name, count, revers)
	local path = {}
	for i = 1, count do
		local point = Entities:FindByName(nil, name..i)
		table.insert(path, point)
	end
	if revers then
		local newPath = {}
		for i = #path, 1, -1 do
			table.insert(newPath, path[i])
		end
		path = newPath
	end
	return path
end

function dota_clicker:OnPlayerConnectFull(keys)
    local player_id = keys.PlayerID
    if player_id == nil or player_id == -1 then return end

	local pdata = PlayerData[player_id+1]
	if not pdata then
        PlayerData[player_id+1] = {
            units = {},
            upgrades = {},
			path = {},
			spawnPos = 0,
			team = DOTA_TEAM_GOODGUYS,
            disconnected = false
        }
	else
		pdata.disconnected = false

        local player = PlayerResource:GetPlayer(player_id)
        if player then
			for k,v in pairs(pdata) do
				player[k] = v
			end
			
			local playerUpgrades = {}
			for unit,v in pairs(player.upgrades) do
				local upgrades = player.upgrades[unit][1].levels
				local arr = {}
				for i = 1, #wi.base[unit] do
					local upgrade = wi.base[unit][i]
					arr[upgrade.type] = upgrades[i]
				end
				
				playerUpgrades[unit] = arr
			end
			
			local chosenEvolutions = {}
			for unit,v in pairs(player.upgrades) do
				local class = player.upgrades[unit][4]
				chosenEvolutions[unit] = class
			end
			
			local chosenSubclasses = {}
			for unit,v in pairs(player.upgrades) do
				local subclass = player.upgrades[unit][5]
				chosenSubclasses[unit] = subclass
			end
			
			local evolutionSkills = {}
			for unit,v in pairs(player.upgrades) do
				local class = player.upgrades[unit][4]
				local upgrades = player.upgrades[unit][2].levels
				local arr = {}
				if wi.classes[class] then
					for i = 1, #wi.classes[class] do
						local upgrade = wi.classes[class][i]
						arr[upgrade.type] = upgrades[i]
					end
					
				
					local classSkills = {}
					
					classSkills[class] = arr
					evolutionSkills[unit] = classSkills
				end
			end
			
			local chosenSubclasses = {}
			for unit,v in pairs(player.upgrades) do
				local subclass = player.upgrades[unit][5]
				local upgrades = player.upgrades[unit][3].levels
				local arr = {}
				
				if wi.subClasses[subclass] then
					for i = 1, #wi.subClasses[subclass] do
						local upgrade = wi.subClasses[subclass][i]
						arr[upgrade.type] = upgrades[i]
					end
					
					local subclassSkills = {}
					
					subclassSkills[class] = arr
					chosenSubclasses[unit] = subclassSkills
				end
			end
			
			CustomGameEventManager:Send_ServerToPlayer(player, "Get_user_info", {
				playerUpgrades = playerUpgrades,
				chosenEvolutions = chosenEvolutions,
				chosenSubclasses = chosenSubclasses,
				evolutionSkills = evolutionSkills,
				subclassSkills = subclassSkills,
			})
			
			local units = {}
			for i = 1, #wi.unitTypes do
				local name = wi.unitTypes[i]
				units[name] = utils:countOf(player.units, name)
			end
			
			CustomGameEventManager:Send_ServerToPlayer(player, "SetDataCurrUnits", {units = units})
        end
    end
	
	GameRules:SendCustomMessageToTeam("Player "..player_id.." подключился", 0, 255, 0)
end

function dota_clicker:OnPlayerDisconnect(keys)
    local player_id = keys.PlayerID
    if player_id == nil or player_id == -1 then return end
	
	local player = PlayerResource:GetPlayer(player_id)
	local pdata = PlayerData[player_id+1]
    if pdata then
        pdata.disconnected = true
		for k,v in pairs(pdata) do
			pdata[k] = player[k]
		end
    end
	
	GameRules:SendCustomMessageToTeam("Player "..player_id.." отключился", 0, 255, 0)
end

function dota_clicker:OnPlayerReconnect(keys)
    local player_id = keys.PlayerID
    if player_id == nil or player_id == -1 then return end
	

	GameRules:SendCustomMessageToTeam("Player "..player_id.." переподключился", 0, 255, 0)
end

