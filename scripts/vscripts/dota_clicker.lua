if dota_clicker == nil then
	dota_clicker = class({})
end

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
end

function dota_clicker:OnTreeCut(event)
	local rnd = math.random(1, 100)
	if rnd <= 60 then
		local tree_x = event.tree_x
		local tree_y = event.tree_y
		local tree_position = Vector(tree_x, tree_y, GetGroundHeight(Vector(tree_x, tree_y, 0), nil))
		
		-- Создаем предмет на месте срубленного дерева
		local item = CreateItem("item_dota_clicker_wood", nil, nil)
		if item then
			-- Создаем физический предмет на карте
			local dropped_item = CreateItemOnPositionSync(tree_position, item)
			
			-- Устанавливаем время создания для системы очистки
			if dropped_item then
				dropped_item.creation_time = GameRules:GetGameTime()
				print("Wood item created at time: " .. dropped_item.creation_time)
			end
		end
	end
end

-- Система автоочистки предметов дерева
function dota_clicker:StartSimpleGroundItemCleanup()
    Timers:CreateTimer(30, function()
        -- Каждые 30 секунд проверяем все предметы на земле
        local all_items = Entities:FindAllByClassname("dota_item_drop")
        
        for _, item_drop in pairs(all_items) do
            if IsValidEntity(item_drop) and not item_drop:IsNull() then
                local item = item_drop:GetContainedItem()
                if item and item:GetAbilityName() == "item_dota_clicker_wood" then
                    -- Проверяем время существования предмета
                    if not item_drop.creation_time then
                        -- Если время не установлено, устанавливаем текущее время
                        item_drop.creation_time = GameRules:GetGameTime()
                    elseif GameRules:GetGameTime() - item_drop.creation_time >= 30 then
                        -- Удаляем предмет, если он лежит дольше 30 секунд
                        UTIL_Remove(item_drop)
                        print("Wood item cleaned up by timer (existed for " .. (GameRules:GetGameTime() - item_drop.creation_time) .. " seconds)")
                    end
                end
            end
        end
        
        return 30 -- Повторяем каждые 30 секунд
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
    
    
end

function dota_clicker:dotaClickerKilled(data)
	local killed_unit = EntIndexToHScript(data.entindex_killed)
	
	
end

function dota_clicker:dotaClickerStart()
	print("DOTA CLICKER START")
	-- local vision_pos = Entities:FindByName(nil, "vision"):GetAbsOrigin()
	-- local vision_unit = CreateUnitByName("npc_dota_clicker_vision", vision_pos, false, nil,nil , DOTA_TEAM_GOODGUYS)
	
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
end

-- Evaluate the state of the game
function dota_clicker:OnThink()
	if GameRules:State_Get() == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
	elseif GameRules:State_Get() >= DOTA_GAMERULES_STATE_POST_GAME then
		return nil
	end
	return 1
end

function dota_clicker:indexOf(t, value)
	for i = 1, #t do
		if t[i] == value then
			return i
		end
	end
	return nil
end

function dota_clicker:OnNpcSpawned(data)
 	local npc = EntIndexToHScript(data.entindex)
	
     
end