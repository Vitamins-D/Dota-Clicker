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
	
	-- Models for Main Wave Units
    PrecacheResource("model", "models/creeps/lane_creeps/creep_radiant_melee/radiant_flagbearer.vmdl", context);
    PrecacheResource("model", "models/creeps/neutral_creeps/n_creep_gnoll/n_creep_gnoll.vmdl", context);
    PrecacheResource("model", "models/creeps/lane_creeps/creep_radiant_ranged/radiant_ranged.vmdl", context);
    PrecacheResource("model", "models/heroes/rattletrap/rattletrap.vmdl", context);

    -- Models for Evolution Units
    PrecacheResource("model", "models/creeps/lane_creeps/creep_radiant_hulk/creep_radiant_ancient_hulk.vmdl", context);
    PrecacheResource("model", "models/creeps/lane_creeps/creep_radiant_melee/radiant_flagbearer_mega.vmdl", context);
    PrecacheResource("model", "models/heroes/invoker/invoker.vmdl", context);
    PrecacheResource("model", "models/heroes/shadowshaman/shadowshaman.vmdl", context);
    PrecacheResource("model", "models/heroes/sniper/sniper.vmdl", context);
    PrecacheResource("model", "models/creeps/item_creeps/i_creep_necro_archer/necro_archer.vmdl", context);
    PrecacheResource("model", "models/creeps/lane_creeps/creep_good_siege/creep_good_siege.vmdl", context);

    -- Models for Subclass Units
    PrecacheResource("model", "models/creeps/neutral_creeps/n_creep_ancient_frog/n_creep_ancient_frog_mage.vmdl", context);
    PrecacheResource("model", "models/heroes/techies/techies.vmdl", context);
end

-- Create the game mode when we activate
function Activate()
	dota_clicker:InitGameMode()
end