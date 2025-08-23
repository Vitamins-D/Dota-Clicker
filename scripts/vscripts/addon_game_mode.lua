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
    PrecacheResource("model", "models/courier/defense3_sheep/defense3_sheep.vmdl", context);
	PrecacheResource("model", "models/courier/donkey_crummy_wizard_2014/donkey_crummy_wizard_2014.vmdl", context);
	
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
	
	PrecacheResource("particle", "particles/units/heroes/hero_jakiro/jakiro_base_attack_fire.vpcf", context)
	
	-- Ogre Magi
    PrecacheResource("particle", "particles/units/heroes/hero_ogre_magi/ogre_magi_ignite.vpcf", context)
    PrecacheResource("particle", "particles/units/heroes/hero_ogre_magi/ogre_magi_fireblast.vpcf", context)
    PrecacheResource("particle", "particles/units/heroes/hero_ogre_magi/ogre_magi_bloodlust_buff.vpcf", context)

    -- Pudge
    PrecacheResource("particle", "particles/units/heroes/hero_pudge/pudge_meathook.vpcf", context)
    PrecacheResource("particle", "particles/units/heroes/hero_pudge/pudge_meathook_impact.vpcf", context)
    PrecacheResource("particle", "particles/units/heroes/hero_pudge/pudge_dismember.vpcf", context)

    -- Shredder
    PrecacheResource("particle", "particles/units/heroes/hero_shredder/shredder_reactive_armor.vpcf", context)

    -- Phantom Assassin
    PrecacheResource("particle", "particles/units/heroes/hero_phantom_assassin/phantom_assassin_blur.vpcf", context)
    PrecacheResource("particle", "particles/units/heroes/hero_phantom_assassin/phantom_assassin_blur_active.vpcf", context)

    -- Dazzle
    PrecacheResource("particle", "particles/units/heroes/hero_dazzle/dazzle_poison_touch.vpcf", context)

    -- Tidehunter
    PrecacheResource("particle", "particles/units/heroes/hero_tidehunter/tidehunter_kraken_shell.vpcf", context)

    -- Sniper
    PrecacheResource("particle", "particles/units/heroes/hero_sniper/sniper_headshot.vpcf", context)
    PrecacheResource("particle", "particles/units/heroes/hero_sniper/sniper_take_aim_active.vpcf", context)

    -- Juggernaut
    PrecacheResource("particle", "particles/units/heroes/hero_juggernaut/juggernaut_blade_dance.vpcf", context)

    -- Enchantress
    PrecacheResource("particle", "particles/units/heroes/hero_enchantress/enchantress_natures_attendants.vpcf", context)

    -- Medusa
    PrecacheResource("particle", "particles/units/heroes/hero_medusa/medusa_split_shot.vpcf", context)

    -- Jakiro
    PrecacheResource("particle", "particles/units/heroes/hero_jakiro/jakiro_liquid_fire.vpcf", context)
    PrecacheResource("particle", "particles/units/heroes/hero_jakiro/jakiro_liquid_ice_projectile.vpcf", context)

    -- Winter Wyvern
    PrecacheResource("particle", "particles/units/heroes/hero_winter_wyvern/wyvern_cold_embrace.vpcf", context)

    -- Zeus
    PrecacheResource("particle", "particles/units/heroes/hero_zuus/zuus_arc_lightning.vpcf", context)
    PrecacheResource("particle", "particles/units/heroes/hero_zuus/zuus_arc_lightning_head.vpcf", context)

    -- Shadow Shaman
    PrecacheResource("particle", "particles/units/heroes/hero_shadowshaman/shadowshaman_ward_base_attack.vpcf", context)
    PrecacheResource("particle", "particles/units/heroes/hero_shadowshaman/shadowshaman_ward_cast.vpcf", context)
	PrecacheResource("model", "models/heroes/shadowshaman/shadowshaman_totem.vmdl", context);
	PrecacheResource("particle", "particles/units/heroes/hero_shadowshaman/shadow_shaman_ward_base_attack.vpcf", context);

    -- Keeper of the Light
    PrecacheResource("particle", "particles/units/heroes/hero_keeper_of_the_light/keeper_chakra_magic.vpcf", context)

    -- Black Dragon
    PrecacheResource("particle", "particles/units/heroes/hero_dragon_knight/dragon_knight_splash_attack.vpcf", context)

    -- Techies
    PrecacheResource("particle", "particles/units/heroes/hero_techies/techies_suicide.vpcf", context)
    PrecacheResource("particle", "particles/units/heroes/hero_techies/techies_suicide_explode.vpcf", context)
    PrecacheResource("particle", "particles/units/heroes/hero_techies/techies_sticky_bomb_projectile.vpcf", context)
    PrecacheResource("particle", "particles/units/heroes/hero_techies/techies_sticky_bomb_explosion.vpcf", context)
	PrecacheResource("model", "models/heroes/techies/fx_techies_remote_cart.vmdl", context)
	PrecacheResource("model", "models/heroes/techies/fx_techiesfx_mine.vmdl", context)

    -- Lina
    PrecacheResource("particle", "particles/units/heroes/hero_lina/lina_spell_dragon_slave.vpcf", context)

    -- Mars
    PrecacheResource("particle", "particles/units/heroes/hero_mars/mars_shield_of_mars.vpcf", context)

    -- Weaver
    PrecacheResource("particle", "particles/units/heroes/hero_weaver/weaver_geminate_attack.vpcf", context)

	-- Windranger
	PrecacheResource("particle", "particles/units/heroes/hero_windrunner/windrunner_shackleshot.vpcf", context)

    -- Vengeful Spirit
    PrecacheResource("particle", "particles/units/heroes/hero_vengeful/vengeful_command_aura.vpcf", context)

	--doctor
	PrecacheResource("particle", "particles/units/heroes/hero_witchdoctor/witchdoctor_ward_attack.vpcf", context)
	PrecacheResource("model", "models/heroes/witchdoctor/witchdoctor_ward.vmdl", context)

	-- Beastmaster
	PrecacheResource("model", "models/heroes/beastmaster/beastmaster_bird.vmdl", context)

	PrecacheResource("model", "models/creeps/lane_creeps/creep_radiant_melee/radiant_flagbearer.vmdl", context)
	PrecacheResource("model", "models/creeps/lane_creeps/creep_radiant_melee/radiant_flagbearer.vmdl", context)

    PrecacheResource("model", "models/items/rattletrap/artisan_of_havoc_hook/artisan_of_havoc_hook.vmdl", context)
    PrecacheResource("model", "models/items/rattletrap/artisan_of_havoc_helmet/artisan_of_havoc_helmet.vmdl", context)
    PrecacheResource("model", "models/items/rattletrap/artisan_of_havoc_armor/artisan_of_havoc_armor.vmdl", context)
    PrecacheResource("model", "models/items/rattletrap/artisan_of_havoc_rocket/artisan_of_havoc_rocket.vmdl", context)

    PrecacheResource("model", "models/items/sniper/spring2021_ambush_sniper_sniper_rifle/spring2021_ambush_sniper_sniper_rifle.vmdl", context)
    PrecacheResource("model", "models/items/sniper/spring2021_ambush_sniper_nest_cap/spring2021_ambush_sniper_nest_cap.vmdl", context)
    PrecacheResource("model", "models/items/sniper/spring2021_ambush_sniper_shoulders/spring2021_ambush_sniper_shoulders.vmdl", context)
    PrecacheResource("model", "models/items/sniper/spring2021_ambush_sniper_arms/spring2021_ambush_sniper_arms.vmdl", context)
    PrecacheResource("model", "models/items/sniper/spring2021_ambush_sniper_cape/spring2021_ambush_sniper_cape.vmdl", context)

    PrecacheResource("model", "models/items/sniper/scifi_sniper_test_gun/scifi_sniper_test_gun.vmdl", context)
    PrecacheResource("model", "models/items/sniper/scifi_sniper_test_head/scifi_sniper_test_head.vmdl", context)
    PrecacheResource("model", "models/items/sniper/scifi_sniper_test_shoulder/scifi_sniper_test_shoulder.vmdl", context)
    PrecacheResource("model", "models/items/sniper/scifi_sniper_test_arms/scifi_sniper_test_arms.vmdl", context)
    PrecacheResource("model", "models/items/sniper/scifi_sniper_test_back/scifi_sniper_test_back.vmdl", context)

    PrecacheResource("model", "models/items/techies/techies_ti9_immortal_bazooka/techies_ti9_immortal_bazooka.vmdl", context)
    PrecacheResource("model", "models/items/techies/techies_ti9_immortal_spleen/techies_ti9_immortal_spleen.vmdl", context)
    PrecacheResource("model", "models/items/techies/techies_ti9_immortal_spoon/techies_ti9_immortal_spoon.vmdl", context)
    PrecacheResource("model", "models/items/techies/techies_ti9_immortal_squee/techies_ti9_immortal_squee.vmdl", context)
    PrecacheResource("model", "models/items/techies/techies_ti9_immortal_cart/techies_ti9_immortal_cart.vmdl", context)

    PrecacheResource("model", "models/items/sniper/heavymetal_weapon/heavymetal_weapon.vmdl", context)
    PrecacheResource("model", "models/items/sniper/heavymetal_head/heavymetal_head.vmdl", context)
    PrecacheResource("model", "models/items/sniper/heavymetal_shoulder/heavymetal_shoulder.vmdl", context)
    PrecacheResource("model", "models/items/sniper/heavymetal_arms/heavymetal_arms.vmdl", context)
    PrecacheResource("model", "models/items/sniper/heavymetal_back/heavymetal_back.vmdl", context)

    PrecacheResource("model", "models/items/sniper/heavymetal_weapon/heavymetal_weapon.vmdl", context)
    PrecacheResource("model", "models/items/sniper/heavymetal_head/heavymetal_head.vmdl", context)
    PrecacheResource("model", "models/items/sniper/heavymetal_shoulder/heavymetal_shoulder.vmdl", context)
    PrecacheResource("model", "models/items/sniper/heavymetal_arms/heavymetal_arms.vmdl", context)
    PrecacheResource("model", "models/items/sniper/heavymetal_back/heavymetal_back.vmdl", context)

    PrecacheResource("model", "models/items/rattletrap/artisan_of_havoc_hook/artisan_of_havoc_hook.vmdl", context)
    PrecacheResource("model", "models/items/rattletrap/artisan_of_havoc_helmet/artisan_of_havoc_helmet.vmdl", context)
    PrecacheResource("model", "models/items/rattletrap/artisan_of_havoc_armor/artisan_of_havoc_armor.vmdl", context)
    PrecacheResource("model", "models/items/rattletrap/artisan_of_havoc_rocket/artisan_of_havoc_rocket.vmdl", context)

    PrecacheResource("model", "models/items/shadowshaman/eki_bukaw_bracers/eki_bukaw_bracers.vmdl", context)
    PrecacheResource("model", "models/items/shadowshaman/records_of_the_eki_bukaw/records_of_the_eki_bukaw.vmdl", context)
    PrecacheResource("model", "models/items/shadowshaman/eki_bukaw_wand/eki_bukaw_wand.vmdl", context)
    PrecacheResource("model", "models/items/shadowshaman/eki_bukaw_wand__offhand/eki_bukaw_wand__offhand.vmdl", context)
    PrecacheResource("model", "models/items/shadowshaman/serpent_ward/fiery_ward_of_eki_bukaw/fiery_ward_of_eki_bukaw.vmdl", context)
    PrecacheResource("model", "models/items/shadowshaman/visage_of_eki_bukaw/visage_of_eki_bukaw.vmdl", context)

    PrecacheResource("model", "models/items/sniper/sniper_tallyho_head2/sniper_tallyho_head2.vmdl", context)
    PrecacheResource("model", "models/items/sniper/sniper_tally_ho_back2/sniper_tally_ho_back2.vmdl", context)
    PrecacheResource("model", "models/items/sniper/sniper_tallyho_arms2/sniper_tallyho_arms2.vmdl", context)
    PrecacheResource("model", "models/items/sniper/sniper_tallyho_shoulders3/sniper_tallyho_shoulders3.vmdl", context)
    PrecacheResource("model", "models/items/sniper/sniper_tallyho_weapons1/sniper_tallyho_weapons1.vmdl", context)

    PrecacheResource("model", "models/items/sniper/sniper_tallyho_head2/sniper_tallyho_head2.vmdl", context)
    PrecacheResource("model", "models/items/sniper/sniper_tally_ho_back2/sniper_tally_ho_back2.vmdl", context)
    PrecacheResource("model", "models/items/sniper/sniper_tallyho_arms2/sniper_tallyho_arms2.vmdl", context)
    PrecacheResource("model", "models/items/sniper/sniper_tallyho_shoulders3/sniper_tallyho_shoulders3.vmdl", context)
    PrecacheResource("model", "models/items/sniper/sniper_tallyho_weapons1/sniper_tallyho_weapons1.vmdl", context)
end

-- Create the game mode when we activate
function Activate()
	dota_clicker:InitGameMode()
end