if dota_clicker == nil then
	dota_clicker = class({})
end

local neutralSpawner = require("utils/neutralSpawner")
local wi = require("utils/wavesInfo")
local wa = require("utils/wavesAddon")
local utils = require("utils/utils")
local lvlupInterval = 60
local goldInterval = 120
local maxUnits = 20
local playerCount

HeroExpTable = {0}
-- expTable = {0, 240, 640, 1160, 1760, 2440, 3200, 4000, 4900, 5900, 7000, 8200, 9500, 10900, 12400, 14000, 15700, 17500, 19400, 21400, 23600, 26000, 28600, 31400, 34400, 38400, 43400, 49400, 56400, 63900}

for i=2,30 do 
	HeroExpTable[i] = 100*(i-1)
end

function dota_clicker:InitGameMode()
	GameRules:SetStartingGold(1000)
	GameRules:SetUseUniversalShopMode(true)
	GameRules:SetHeroSelectionTime(99999)
	GameRules:SetPreGameTime(0)
	GameRules:SetStrategyTime( 10.0 )
	GameRules:SetShowcaseTime( 0.0 )	
	GameRules:SetTreeRegrowTime(60)
	-- GameRules:SetGoldPerTick(1)
	-- GameRules:SetGoldTickTime(1.0)
	GameRules:GetGameModeEntity():SetFixedRespawnTime( 25 )
	GameRules:GetGameModeEntity():SetFreeCourierModeEnabled(false)
	
	GameRules:GetGameModeEntity():SetUseCustomHeroLevels( true ) -- установка кастомной системы урвоней
	GameRules:GetGameModeEntity():SetCustomXPRequiredToReachNextLevel( HeroExpTable )
	GameRules:GetGameModeEntity():SetUnseenFogOfWarEnabled(true)
	
	GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_GOODGUYS, 10 )
	GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_BADGUYS, 0 )
	
	
	ListenToGameEvent('entity_killed', Dynamic_Wrap(self , 'dotaClickerKilled'), self)
	ListenToGameEvent('game_rules_state_change', Dynamic_Wrap(self, 'dotaClickerStateChange'), self)
	ListenToGameEvent('npc_spawned', Dynamic_Wrap(self, 'OnNpcSpawned'), self)	
	ListenToGameEvent('entity_hurt', Dynamic_Wrap(self, 'dotaClickerHurt'), self)	
	ListenToGameEvent("player_chat", Dynamic_Wrap(self, 'OnPlayerChat'), self)
	ListenToGameEvent('tree_cut', Dynamic_Wrap(self, 'OnTreeCut'), self)
	
	-- Запускаем систему очистки предметов дерева
	self:StartSimpleGroundItemCleanup()
	
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
		if player then
			if type == "base" then
				local upgId, upgType = wi:getUpgByName(unit, upgrade)
				
				local arrId
				if upgType == "base" then arrId = 1
				elseif upgType == "class" then arrId = 2
				elseif upgType == "sub" then arrId = 3
				end
				
				
				
				local baseName = wi:getUnitName(unit)
				local newLevel = player.upgrades[baseName][arrId].levels[upgId]
				local gold = PlayerResource:GetGold(player_id)
				local maxLevel = wi:getMaxLevel(upgType, unit, upgrade)
				local desc = wi:getUpgradeDescription(unit, upgrade, newLevel+1)
				-- local desc = nil
				local cost = wi:getUpgradeCost(unit, upgrade, newLevel+1)
				if gold >= cost and newLevel < maxLevel then
					newLevel = newLevel + 1
					player.upgrades[baseName][arrId].levels[upgId] = newLevel
					desc = wi:getUpgradeDescription(unit, upgrade, newLevel+1)
					GiveGold( -cost, player_id )
				end
				
				CustomGameEventManager:Send_ServerToPlayer(player, "upgrade_success", {unit = unit, upgrade = upgrade, newLevel = newLevel, desc = desc})
			elseif type == "evolution" or type == "subclass" then
				local converter = {
					["evolution"] = "class",
					["subclass"] = "sub",
				}
				local baseName = wi:getUnitName(unit)
				local playerUnit = player.upgrades[baseName]
				local infoUnit = wi.upgrades[converter[type]][upgrade]
				local cost = infoUnit.cost
				
				local gold = PlayerResource:GetGold(player_id)
				if gold >= cost then
					GiveGold( -cost, player_id )
					if type == "evolution" then
						playerUnit[4] = upgrade
					else
						playerUnit[5] = upgrade
					end
					CustomGameEventManager:Send_ServerToPlayer(player, "upgrade_success", {unit = unit, upgrade = upgrade})
				end
			end
		end
	end)
	
	CustomGameEventManager:RegisterListener("buy_unit", function(_, event)
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
			GiveGold( -cost, player_id )
			success = true
			count = count + 1
			table.insert(player.units, unit)
		end
		
		CustomGameEventManager:Send_ServerToPlayer(player, "buy_unit_response", {unit = unit, success = success, new_count = count})
	end)
	
	CustomGameEventManager:RegisterListener("sell_unit", function(_, event)
		local unit = event.unit
		local player_id = event.player_id
		local player = PlayerResource:GetPlayer(player_id)
		
		local baseName = wi:getUnitName(unit)
		local playerUnit = utils:countOf(player.units, unit)
		
		local count = playerUnit-1
		table.remove(player.units, utils:indexOf(player.units, unit))
		
		local cost = wi.base[unit].cost
		GiveGold( cost, player_id )
		CustomGameEventManager:Send_ServerToPlayer(player, "sell_unit_response", {unit = unit, success = true, new_count = count})
	end)
end

function dota_clicker:OnTreeCut(event)
	local rnd = math.random(1, 100)
	if rnd <= 60 then
		local tree_x = event.tree_x
		local tree_y = event.tree_y
		local tree_position = Vector(tree_x, tree_y, GetGroundHeight(Vector(tree_x, tree_y, 0), nil))
		
		-- Создаем предмет на месте срубленного дерева
		local item = CreateItem("item_dotac_wood", nil, nil)
		if item then
			-- Создаем физический предмет на карте
			local dropped_item = CreateItemOnPositionSync(tree_position, item)
			
			-- Устанавливаем время создания для системы очистки
			if dropped_item then
				dropped_item.creation_time = GameRules:GetGameTime()
				-- print("Wood item created at time: " .. dropped_item.creation_time)
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
	GiveGold( oresValues[oreType], playerId )
end

function GiveGold( gold, playerId )
	if PlayerResource:HasSelectedHero(playerId) then
		local player = PlayerResource:GetPlayer(playerId)
		local hero = PlayerResource:GetSelectedHeroEntity(playerId)
		hero:ModifyGold(gold, false, 0)
		SendOverheadEventMessage( player, OVERHEAD_ALERT_GOLD, hero, gold, nil )
	end
end

function dota_clicker:dotaClickerStateChange(data)
	local newState = GameRules:State_Get()
	if newState == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
		self:dotaClickerStart() 
	end 
end

function dota_clicker:dotaClickerHurt(event)
	local attacker = EntIndexToHScript(event.entindex_attacker)
    local victim = EntIndexToHScript(event.entindex_killed)
    local damage = event.damage -- Урон, нанесённый атакой
	
	
end

function dota_clicker:OnPlayerChat(event)
    local player_id = event.playerid
    local text = event.text
    
    if text == "-rich" then
		GiveGoldPlayers( 999999 )	
	end
end

function dota_clicker:dotaClickerKilled(data)
    local killed_unit = EntIndexToHScript(data.entindex_killed)
    if not killed_unit or not killed_unit.GetUnitName then return end

    local unitName = killed_unit:GetUnitName()
    local dropPos = killed_unit:GetAbsOrigin()

    -- Таблица для шансов дропа
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


function AttachDireTeam()
    local entities = Entities:FindAllByName("dire_team")
    for _, ent in pairs(entities) do
        if ent.SetTeam then
            ent:SetTeam(DOTA_TEAM_BADGUYS)
        end
    end
end

function dota_clicker:dotaClickerStart()
	print("DOTA CLICKER START")
	neutralSpawner:InitNeutralCamps()
	local vision_pos = Entities:FindByName(nil, "vision"):GetAbsOrigin()
	local vision_unit = CreateUnitByName("npc_dota_clicker_vision", vision_pos, false, nil,nil , DOTA_TEAM_GOODGUYS)
	playerCount = PlayerResource:GetPlayerCountForTeam(DOTA_TEAM_GOODGUYS) + PlayerResource:GetPlayerCountForTeam(DOTA_TEAM_BADGUYS)
	
	-- Timers:CreateTimer(1, function()
        -- local damage_table = {
			-- victim = vision_unit,          -- Юнит, который получает урон
			-- attacker = vision_unit,        -- Юнит, который наносит урон
			-- damage = vision_unit:GetMaxHealth()*1.5,        -- Количество урона
			-- damage_type = DAMAGE_TYPE_PURE, -- Тип урона (магический, физический или чистый)
			-- ability = nil,      -- Способность, связанная с уроном (может быть nil)
		-- }

		-- ApplyDamage(damage_table)
        -- return
    -- end)
	
	local uiArr = wi:convertToUnifiedStructure()
	self:throughPlayers(function(player, hero)
		CustomGameEventManager:Send_ServerToPlayer(player, "SetDataUnits", {dataU = uiArr})
	end)
	
	
	local maxUnitPerPlayer = math.ceil(maxUnits/playerCount)
	self:throughPlayers(function(player, hero)
		CustomGameEventManager:Send_ServerToPlayer(player, "SetDataLimit", {limit = maxUnitPerPlayer})
	end)
	
	local wave_start = Entities:FindByName(nil, "good_path"):GetAbsOrigin()
	self:throughPlayers(function(player, hero)
		wa:InitAddon(player, wave_start, DOTA_TEAM_BADGUYS)
		wa:spawnWave(player)
	end)
	
	Timers:CreateTimer(lvlupInterval, function()
        GiveExpPlayers(100)
        return lvlupInterval
    end)
	
	Timers:CreateTimer(goldInterval, function()
		GiveGoldPlayers( 500 )
        return goldInterval
    end)
end

-- Evaluate the state of the game
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

function GiveGoldPlayers( gold )	
	dota_clicker:throughPlayers(function(player, hero)
		hero:ModifyGold(gold, false, 0)
		SendOverheadEventMessage( player, OVERHEAD_ALERT_GOLD, hero, gold, nil )
	end)
end