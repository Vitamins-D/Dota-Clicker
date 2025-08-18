require("dota_clicker")
require("utils/timers")

if dota_clicker == nil then
	dota_clicker = class({})
end

function Precache( context )
	PrecacheResource("model", "models/heroes/beastmaster/beastmaster_beast.vmdl", context);
	PrecacheResource("model", "models/creeps/neutral_creeps/n_creep_worg_small/n_creep_worg_small.vmdl", context);
	PrecacheResource("model", "models/creeps/neutral_creeps/n_creep_tadpole/n_creep_tadpole_v2.vmdl", context);
	PrecacheResource("model", "models/creeps/neutral_creeps/n_creep_tadpole/n_creep_tadpole_ranged_v2.vmdl", context);
	PrecacheResource("model", "models/heroes/lone_druid/spirit_bear.vmdl", context);
	PrecacheResource("model", "models/creeps/lane_creeps/creep_good_siege/creep_good_siege_deathsim.vmdl", context);
	
	-- Звуки для кирок
	PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_earthshaker.vsndevts", context)
	
	-- Звуки для топоров
	PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_bloodseeker.vsndevts", context)
	PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_furion.vsndevts", context)
	PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_timbersaw.vsndevts", context)
	
	-- Частицы для кирок
	PrecacheResource("particle", "particles/generic_gameplay/generic_stunned.vpcf", context)
	
	-- Частицы для топоров
	PrecacheResource("particle", "particles/units/heroes/hero_bloodseeker/bloodseeker_rupture.vpcf", context)
	PrecacheResource("particle", "particles/units/heroes/hero_bloodseeker/bloodseeker_rupture_hit.vpcf", context)
	PrecacheResource("particle", "particles/units/heroes/hero_furion/furion_force_of_nature_damage.vpcf", context)
end

-- Create the game mode when we activate
function Activate()
	dota_clicker:InitGameMode()
end