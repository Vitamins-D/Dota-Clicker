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
	-- GameRules:SetGoldPerTick(1)
	-- GameRules:SetGoldTickTime(1.0)
	GameRules:GetGameModeEntity():SetFixedRespawnTime( 25 )
	GameRules:GetGameModeEntity():SetFreeCourierModeEnabled(false)
	
	GameRules:GetGameModeEntity():SetUseCustomHeroLevels( true ) -- установка кастомной системы урвоней
	GameRules:GetGameModeEntity():SetCustomXPRequiredToReachNextLevel( HeroExpTable )
	GameRules:GetGameModeEntity():SetUnseenFogOfWarEnabled(false)
	
	GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_GOODGUYS, 10 )
	GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_BADGUYS, 0 )
	
	
	ListenToGameEvent('entity_killed', Dynamic_Wrap(self , 'dotaClickerKilled'), self)
	ListenToGameEvent('game_rules_state_change', Dynamic_Wrap(self, 'dotaClickerStateChange'), self)
	ListenToGameEvent('npc_spawned', Dynamic_Wrap(self, 'OnNpcSpawned'), self)	
	ListenToGameEvent('entity_hurt', Dynamic_Wrap(self, 'dotaClickerHurt'), self)	
	ListenToGameEvent("player_chat", Dynamic_Wrap(self, 'OnPlayerChat'), self)
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