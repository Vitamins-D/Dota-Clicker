if dota_clicker == nil then
	dota_clicker = class({})
end

local neutralSpawner = require("utils/neutralSpawner")
local wi = require("utils/wavesInfo")
local wa = require("utils/wavesAddon")
local utils = require("utils/utils")

-- константы/настройки
local LVLUP_INTERVAL = 60
local GOLD_INTERVAL = 120
local MAX_UNITS = 20
local MINE_INTERACTION_DISTANCE = 200

local uiArr

local playerCount

HeroExpTable = {0}
for i=2,30 do 
	HeroExpTable[i] = 100*(i-1)
end

function dota_clicker:InitGameMode()
	GameRules:SetStartingGold(1000)
	GameRules:SetUseUniversalShopMode(true)
	GameRules:SetHeroSelectionTime(99999)
	GameRules:SetPreGameTime(0)
	GameRules:SetStrategyTime(10.0)
	GameRules:SetShowcaseTime(0.0)
	GameRules:SetTreeRegrowTime(60)
	GameRules:GetGameModeEntity():SetFixedRespawnTime(25)
	GameRules:GetGameModeEntity():SetFreeCourierModeEnabled(false)
	
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
	
	CustomGameEventManager:RegisterListener("sell_unit", function(_, event)
		self:HandleSellUnit(event)
	end)
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
	if math.random(1, 100) <= 60 then
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
	
	if text == "-rich" then
		GiveGoldPlayers(999999)
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
	neutralSpawner:InitNeutralCamps()
	
	local vision_pos = Entities:FindByName(nil, "vision"):GetAbsOrigin()
	local vision_unit = CreateUnitByName("npc_dota_clicker_vision", vision_pos, false, nil, nil, DOTA_TEAM_GOODGUYS)
	
	-- Timers:CreateTimer(1, function()
		-- local damage_table = {
			-- victim = vision_unit,          
			-- attacker = vision_unit,        
			-- damage = vision_unit:GetMaxHealth()*1.5,        
			-- damage_type = DAMAGE_TYPE_PURE, 
			-- ability = nil,      
		-- }
		-- ApplyDamage(damage_table)
		-- return
	-- end)
	
	playerCount = PlayerResource:GetPlayerCountForTeam(DOTA_TEAM_GOODGUYS) + PlayerResource:GetPlayerCountForTeam(DOTA_TEAM_BADGUYS)
	
	dota_clicker:SpawnMines()
	
	self:throughPlayers(function(player, hero)
		CustomGameEventManager:Send_ServerToPlayer(player, "SetTransMap", {transMap = wi.nameMapping})
	end)
	
	uiArr = wi:convertToUnifiedStructure()
	self:throughPlayers(function(player, hero)
		CustomGameEventManager:Send_ServerToPlayer(player, "SetDataUnits", {dataU = uiArr})
	end)
	
	local maxUnitPerPlayer = math.ceil(MAX_UNITS/playerCount)
	self:throughPlayers(function(player, hero)
		CustomGameEventManager:Send_ServerToPlayer(player, "SetDataLimit", {limit = maxUnitPerPlayer})
	end)
	
	local wave_start = Entities:FindByName(nil, "good_path"):GetAbsOrigin()
	self:throughPlayers(function(player, hero)
		wa:InitAddon(player, wave_start, DOTA_TEAM_BADGUYS)
		wa:spawnWave(player)
	end)
	
	Timers:CreateTimer(LVLUP_INTERVAL, function()
		GiveExpPlayers(100)
		return LVLUP_INTERVAL
	end)
	
	Timers:CreateTimer(GOLD_INTERVAL, function()
		GiveGoldPlayers(500)
		return GOLD_INTERVAL
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
end

function dota_clicker:throughPlayers(callback)
	for index = 0, playerCount - 1 do
		if PlayerResource:HasSelectedHero(index) then
			local player = PlayerResource:GetPlayer(index)
			local hero = PlayerResource:GetSelectedHeroEntity(index)
			callback(player, hero)
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