if wi == nil then
	wi = class({})
end

local utils = require("utils/utils")

-- info
-- 1 - swordsman
-- 1.1 - tank, 1.1.1 - Veins_fire, 1.1.2 - stone_block
-- 1.2 - berserker, 1.2.1 - melee, 1.2.2 - illusionist
-- 2 - archer
-- 2.1 - shooter, 2.1.1 - gunner, 2.1.2 - sniper
-- 2.2 - ranger, 2.2.1 - pathfinder, 2.2.2 - marksman
-- 3 - mage
-- 3.1 - elementalist, 3.1.1 - fire_mage, 3.1.2 - air_mage
-- 3.2 - shaman, 3.2.1 - def_shaman, 3.2.2 - fight_shaman
-- 4 - catapult
-- 4.1 - siege_tower, 4.1.1 - trebuchet, 4.1.2 - ballista
-- 4.2 - bomber, 4.2.1 - rapid_fire, 4.2.2 - miner

wi.unitTypes = {
	"swordsman", "archer", "mage", "catapult"
}

wi.unitDescription = {
	["tank"] = "Непробиваемая стена на поле боя, способная поглощать как магические, так и физические удары.",
	["berserker"] = "Яростный воин, полагающийся на критические удары и молниеносное уклонение.",
	["shooter"] = "Меткий стрелок, умеющий либо утяжелить залп для мощи, либо облегчить руку ради скорости.",
	["ranger"] = "Мастер выживания, лечит себя природной силой и обрушивает шквал стрел по врагам.",
	["elementalist"] = "Повелитель стихий, усиливает огненные и водные заклинания до разрушительной мощи.",
	["shaman"] = "Духовный вождь, наполняющий союзников чакрой (ну наруто типа, вы поняли) и повышающий их боевой урон.",
	["siege_tower"] = "Орудие разрушения, наносящее урон по площади и ускоряющее осадный обстрел.",
	["bomber"] = "Безумец-взрывник, усиливающий снаряды и способный обрушить на врагов мощные заклинания.",
	
	["Veins_fire"] = "Танк с пламенными венами — его броня раскалена, а удары по нему прожигают вражескую плоть.",
	["stone_block"] = "Живая каменная преграда, усиливающая собственную прочность и защиту.",
	["melee"] = "Берсерк ближнего боя, усиливающий свои сокрушительные удары.",
	["illusionist"] = "Мастер обмана, создающий иллюзии, чтобы сбить врагов с толку.",
	["gunner"] = "Стрелок с огневой мощью, разрывающий врагов градом свинца.",
	["sniper"] = "Хладнокровный охотник, поражающий цель с невероятной точностью.",
	["pathfinder"] = "Следопыт, чьи навыки помогают выжить и доминировать в любой местности.",
	["marksman"] = "Мастер дальнего боя, чей каждый выстрел смертельно точен.",
	["fire_mage"] = "Огненный маг, превращающий поле боя в пылающий ад.",
	["air_mage"] = "Маг воздуха, чьи заклинания быстры, как порыв ветра.",
	["def_shaman"] = "Шаман-защитник, укрепляющий союзников и отражающий удары.",
	["fight_shaman"] = "Боевой шаман, усиливающий атакующую мощь своего войска.",
	["trebuchet"] = "Тяжёлое осадное орудие, разрушающее укрепления с чудовищной силой.",
	["ballista"] = "Дальнобойная машина смерти, пробивающая цели насквозь.",
	["rapid_fire"] = "Огнемётчик, превращающий врагов в пылающее пепелище непрерывным потоком огня.",
	["miner"] = "Подрывник, закладывающий взрывчатку в сердца врагов и собственную грудь ради последнего прикола (чисто поржать).",
}

wi.requirement = {
	["tank"] = {upgs = {{"def", 1}, {"hp", 2}}},
	["berserker"] = {upgs = {{"damage", 5}}},
	["shooter"] = {upgs = {{"agility", 1}, {"strength", 2}}},
	["ranger"] = {upgs = {{"agility", 1}, {"def", 2}}},
	["elementalist"] = {upgs = {{"mana", 1}, {"spell_power", 2}}},
	["shaman"] = {upgs = {{"mana", 1}, {"def", 2}}},
	["siege_tower"] = {upgs = {{"siege", 1}, {"def", 2}}},
	["bomber"] = {upgs = {{"damage", 1}}},
	
	["Veins_fire"] = {class = "tank", upgs = {{"mag_armor", 3}}},
	["stone_block"] = {class = "tank", upgs = {{"phys_armor", 3}}},
	["melee"] = {class = "berserker", upgs = {{"crit", 3}}},
	["illusionist"] = {class = "berserker", upgs = {{"evade", 3}}},
	["gunner"] = {class = "shooter", upgs = {{"heave", 3}}},
	["sniper"] = {class = "shooter", upgs = {{"light", 3}}},
	["pathfinder"] = {class = "ranger", upgs = {{"nature", 3}}},
	["marksman"] = {class = "ranger", upgs = {{"multy", 3}}},
	["fire_mage"] = {class = "elementalist", upgs = {{"fire_upgrade", 3}}},
	["air_mage"] = {class = "elementalist", upgs = {{"water_upgrade", 3}}},
	["def_shaman"] = {class = "shaman", upgs = {{"chakra", 3}}},
	["fight_shaman"] = {class = "shaman", upgs = {{"dmg_boost", 3}}},
	["trebuchet"] = {class = "siege_tower", upgs = {{"splash", 3}}},
	["ballista"] = {class = "siege_tower", upgs = {{"speed_siege", 3}}},
	["rapid_fire"] = {class = "bomber", upgs = {{"dragon_slave", 3}}},
	["miner"] = {class = "bomber", upgs = {{"bombordiro", 3}}},
}

wi.specials = {
	-- ["unit"] = {{"replace", "from", "to"}, {"upgrade", "name"}, {"set", "name", 2}}, -- example
	["tank"] = {{"upgrade", "dota_clicker_tidehunter_kraken_shell"}},
	["bomber"] = {{"remove", "creep_siege"}},
	["siege_tower"] = {{"upgrade", "creep_siege"}},
	["sniper"] = {{"upgrade", "dc_sniper_headshot"}},
	["marksman"] = {{"upgrade", "dc_medusa_split_shot"}},
	["fire_mage"] = {{"replace", "dc_winter_wyvern_cold_embrace", "dc_lina_light_strike_array"}},
	["air_mage"] = {{"upgrade", "dc_winter_wyvern_cold_embrace"}, {"replace", "dc_jakiro_liquid_fire", "dc_jakiro_liquid_ice"}},
	["trebuchet"] = {{"upgrade", "black_dragon_splash_attack"}},
	["ballista"] = {{"replace", "black_dragon_splash_attack", "black_dragon_splash_attack_small"}},
	["miner"] = {"replace", "dc_lina_dragon_slave", "dc_techies_suicide_big"}
}

wi.skills = {
  -- ["unit"] = {"spell", "spell"}, -- example
  ["ballista"] = {"dc_windrunner_powershot"},
  ["mage"] = {"dotac_luna_lucent_beam"},
  ["catapult"] = {"creep_siege"},
  ["elementalist"] = {"dc_zuus_arc_lightning"},
  ["shaman"] = {"dc_shadow_shaman_mass_serpent_ward"},
  ["bomber"] = {"dc_techies_suicide"},
  ["Veins_fire"] = {"burning_strikes"},
  ["stone_block"] = {"dc_mars_bulwark"},
  ["fight_shaman"] = {"dc_witch_doctor_death_ward"},
}

wi.units = {
	["swordsman"] = "npc_dota_clicker_main_warrior",
	["archer"] = "npc_dota_clicker_main_archer",
	["mage"] = "npc_dota_clicker_main_mage",
	["catapult"] = "npc_dota_clicker_main_engineer",
	
	["tank"] = "npc_dota_clicker_evol_tank",
	["berserker"] = "npc_dota_clicker_evol_melee",
	["shooter"] = "npc_dota_clicker_evol_shooter",
	["ranger"] = "npc_dota_clicker_evol_ranger",
	["elementalist"] = "npc_dota_clicker_evol_elementalist",
	["shaman"] = "npc_dota_clicker_evol_shaman",
	["siege_tower"] = "npc_dota_clicker_evol_catapult",
	["bomber"] = "npc_dota_clicker_evol_kamikaze",
	
	["Veins_fire"] = "npc_dota_clicker_evol_tank",
	["stone_block"] = "npc_dota_clicker_evol_tank",
	["melee"] = "npc_dota_clicker_evol_melee",
	["illusionist"] = "npc_dota_clicker_evol_melee",
	["gunner"] = "npc_dota_clicker_sub_gunner",
	["sniper"] = "npc_dota_clicker_sub_sniper",
	["pathfinder"] = "npc_dota_clicker_evol_ranger",
	["marksman"] = "npc_dota_clicker_evol_ranger",
	["fire_mage"] = "npc_dota_clicker_evol_elementalist",
	["air_mage"] = "npc_dota_clicker_sub_water_mage",
	["def_shaman"] = "npc_dota_clicker_evol_shaman",
	["fight_shaman"] = "npc_dota_clicker_evol_shaman",
	["trebuchet"] = "npc_dota_clicker_evol_catapult",
	["ballista"] = "npc_dota_clicker_evol_catapult",
	["rapid_fire"] = "npc_dota_clicker_sub_rapid_fire",
	["miner"] = "npc_dota_clicker_sub_miner",
}

wi.base = {
	["swordsman"] =
	{
		{type = "hp", levels = {
			{{type = "hp", value = 50}, {type = "hpreg", value = 0.1}, cost = 300},
			{{type = "hp", value = 50}, {type = "hpreg", value = 0.3}, cost = 450},
			{{type = "hp", value = 75}, {type = "hpreg", value = 0.2}, cost = 475},
			{{type = "hp", value = 50}, {type = "hpreg", value = 0.7}, cost = 500},
			{{type = "hp", value = 125}, {type = "hpreg", value = 2.7}, cost = 500},
		}},
		{type = "damage", levels = {
			{{type = "atk", value = 3}, {type = "atks", value = 3}, cost = 300},
			{{type = "atk", value = 5}, {type = "atks", value = 7}, cost = 450},
			{{type = "atk", value = 12}, {type = "atks", value = 5}, cost = 475},
			{{type = "atk", value = 20}, {type = "atks", value = 3}, cost = 500},
			{{type = "atk", value = 14}, {type = "atks", value = 15}, cost = 550},
		}},
		{type = "def", levels = {
			{{type = "magr", value = 1}, {type = "armor", value = 1}, cost = 600},
			{{type = "magr", value = 5}, {type = "armor", value = 1}, cost = 700},
			{{type = "magr", value = 12}, cost = 900},
			{{type = "magr", value = 6}, {type = "armor", value = 1}, cost = 1200},
			{{type = "spell", value = "dota_clicker_tidehunter_kraken_shell"}, {type = "armor", value = 1}, cost = 1200},
		}}, cost = 300
	},
	["archer"] =
	{
		{type = "agility", levels = {
			{{type = "atks", value = 3}, {type = "vision", value = 100}, cost = 300},
			{{type = "atks", value = 6}, cost = 450},
			{{type = "atks", value = 12}, {type = "vision", value = 150}, cost = 450},
			{{type = "atks", value = 7}, cost = 450},
			{{type = "atks", value = 18}, {type = "vision", value = 350}, cost = 750},
		}},
		{type = "strength", levels = {
			{{type = "atk", value = 7}, {type = "atk_dis", value = 30}, cost = 450},
			{{type = "spell", value = "dota_clicker_sniper_take_aim"}, cost = 300},
			{{type = "atk", value = 9}, {type = "atk_dis", value = 40}, cost = 750},
			{{type = "atk", value = 14}, {type = "atk_dis", value = 7}, cost = 300},
			{{type = "atk", value = 22}, {type = "atk_dis", value = 70}, cost = 1200},
		}},
		{type = "def", levels = {
			{{type = "hp", value = 100}, {type = "armor", value = 1}, cost = 800},
			{{type = "hp", value = 25}, cost = 300},
			{{type = "hp", value = 100}, cost = 650},
			{{type = "hp", value = 25}, {type = "armor", value = 1}, cost = 500},
			{{type = "hp", value = 100}, {type = "armor", value = 1}, cost = 800},
		}}, cost = 500
	},
	["mage"] =
	{
		{type = "mana", levels = {
			{{type = "mana", value = 30}, {type = "manareg", value = 0.3}, cost = 400},
			{{type = "mana", value = 60}, {type = "manareg", value = 0.3}, cost = 600},
			{{type = "mana", value = 100}, cost = 400},
			{{type = "mana", value = 100}, cost = 400},
			{{type = "mana", value = 150}, {type = "manareg", value = 2.7}, cost = 900},
		}},
		{type = "spell_power", levels = {
			{{type = "spell_amp", value = 5}, {type = "spell_up", value = "dotac_chaos_knight_chaos_bolt"}, cost = 450},
			{{type = "spell_amp", value = 7}, cost = 400},
			{{type = "spell_amp", value = 7}, {type = "spell_up", value = "dotac_chaos_knight_chaos_bolt"}, cost = 600},
			{{type = "spell_amp", value = 9},cost = 500},
			{{type = "spell_amp", value = 15}, {type = "spell_up", value = "dotac_chaos_knight_chaos_bolt"},cost = 1200},
		}},
		{type = "def", levels = {
			{{type = "spell", value = "dc_frogmen_water_bubble_small"}, cost = 300},
			{{type = "spell_up", value = "dc_frogmen_water_bubble_small"}, {type = "armor", value = 1}, cost = 800},
			{{type = "spell_up", value = "dc_frogmen_water_bubble_small"}, cost = 450},
			{{type = "spell_up", value = "dc_frogmen_water_bubble_small"}, cost = 600},
			{{type = "spell_up", value = "dc_frogmen_water_bubble_small"}, {type = "armor", value = 1}, cost = 1000},
		}}, cost = 700
	},
	["catapult"] =
	{
		{type = "siege", levels = {
			{{type = "spell_up", value = "dota_clicker_creep_siege"}, cost = 600},
			{{type = "atk", value = 60}, cost = 700},
			{{type = "atks", value = -40}, {type = "", value = 0}, cost = 800},
			{{type = "spell_up", value = "dota_clicker_creep_siege"}, {type = "atk", value = 40}, cost = 1200},
			{{type = "spell_up", value = "dota_clicker_creep_siege"}, {type = "atk", value = 40}, cost = 1200},
		}},
		{type = "damage", levels = {
			{{type = "atk", value = 15}, cost = 300},
			{{type = "atk", value = 20}, {type = "spell_amp", value = 7}, cost = 600},
			{{type = "atks", value = 15}, cost = 400},
			{{type = "atk", value = 25}, {type = "atks", value = 15}, cost = 900},
			{{type = "atk", value = 40}, {type = "spell_amp", value = 12}, cost = 1500},
		}},
		{type = "def", levels = {
			{{type = "hp", value = 75}, {type = "def", value = 1}, cost = 700},
			{{type = "hp", value = 75}, {type = "hpreg", value = 0.4}, cost = 500},
			{{type = "hp", value = 100}, cost = 400},
			{{type = "hp", value = 125}, {type = "hpreg", value = 1.4}, cost = 700},
			{{type = "hp", value = 125}, {type = "def", value = 1}, cost = 1000},
		}}, cost = 1200
	},
}

wi.classes = {
	["tank"] = { -- swordsman
		{type = "mag_armor", levels = {
			{{type = "magr", value = 5}, cost = 700},
			{{type = "magr", value = 5}, cost = 900},
			{{type = "magr", value = 15}, cost = 2000},
		}},
		{type = "phys_armor", levels = {
			{{type = "armor", value = 1}, {type = "hp", value = 400}, cost = 1200},
			{{type = "armor", value = 1}, {type = "hpreg", value = 20}, cost = 2200},
			{{type = "armor", value = 2}, {type = "hp", value = 600}, cost = 2500},
		}}, cost = 700
	},
	["berserker"] = { -- swordsman
		{type = "crit", levels = {
			{{type = "spell", value = "dota_clicker_juggernaut_blade_dance"}, cost = 1000},
			{{type = "spell_up", value = "dota_clicker_juggernaut_blade_dance"}, {type = "atk", value = 60}, cost = 1600},
			{{type = "spell_up", value = "dota_clicker_juggernaut_blade_dance"}, {type = "atk", value = 100}, cost = 2500},
		}},
		{type = "evade", levels = {
			{{type = "spell", value = "dota_clicker_phantom_assassin_immaterial"}, cost = 1200},
			{{type = "spell_up", value = "dota_clicker_phantom_assassin_immaterial"}, {type = "atks", value = 20}, cost = 1400},
			{{type = "spell_up", value = "dota_clicker_phantom_assassin_immaterial"}, {type = "atks", value = 20}, cost = 2000},
		}}, cost = 850
	},
	["shooter"] = { -- archer
		{type = "heave", levels = { --+atks
			{{type = "hp", value = 100}, {type = "atks", value = 20}, cost = 1000},
			{{type = "hp", value = 150}, {type = "atks", value = 20}, cost = 1200},
			{{type = "hp", value = 250}, {type = "atks", value = 60}, cost = 2000},
		}},
		{type = "light", levels = { -- -atks
			{{type = "atk", value = 100}, {type = "atks", value = -30}, {type = "spell", value = "dc_sniper_headshot"}, cost = 1000},
			{{type = "atk", value = 120}, {type = "atks", value = -30}, {type = "spell_up", value = "dc_sniper_headshot"}, cost = 1400},
			{{type = "atk", value = 140}, {type = "atks", value = -40}, {type = "spell_up", value = "dc_sniper_headshot"}, cost = 1600},
		}}, cost = 500
	},
	["ranger"] = { -- archer
		{type = "nature", levels = {
			{{type = "hp", value = 120}, {type = "hpreg", value = 2}, cost = 600},
			{{type = "hp", value = 160}, {type = "armor", value = 1}, cost = 1200},
			{{type = "hp", value = 200}, {type = "hpreg", value = 9}, cost = 900},
		}},
		{type = "multy", levels = {
			{{type = "spell", value = "dc_medusa_split_shot"}, cost = 900},
			{{type = "spell_up", value = "dc_medusa_split_shot"}, {type = "atks", value = 10}, cost = 1200},
			{{type = "spell_up", value = "dc_medusa_split_shot"}, {type = "atks", value = 30}, cost = 2100},
		}}, cost = 350
	},
	["elementalist"] = { -- mage
		{type = "fire_upgrade", levels = { -- даётся ликвид фаер змея горыныча
			{{type = "spell", value = "dc_jakiro_liquid_fire"}, {type = "spell_amp", value = 10}, cost = 1200},
			{{type = "spell_up", value = "dc_jakiro_liquid_fire"}, cost = 1200},
			{{type = "spell_up", value = "dc_jakiro_liquid_fire"}, {type = "spell_amp", value = 10}, cost = 1900},
		}},
		{type = "water_upgrade", levels = { -- даётся колба виверны, огненный маг потом заменяет на вампиризм заклинанием
			{{type = "spell", value = "dc_winter_wyvern_cold_embrace"}, {type = "hpreg", value = 3}, cost = 1000},
			{{type = "spell_up", value = "dc_winter_wyvern_cold_embrace"}, {type = "hpreg", value = 6}, cost = 1500},
			{{type = "spell_up", value = "dc_winter_wyvern_cold_embrace"}, cost = 1400},
		}}, cost = 900
	},
	["shaman"] = { -- mage
		{type = "chakra", levels = { -- chakra kotla
			{{type = "manareg", value = 12}, {type = "spell", value = "dc_keeper_of_the_light_chakra_magic"}, cost = 300},
			{{type = "manareg", value = 6}, {type = "spell_up", value = "dc_keeper_of_the_light_chakra_magic"}, cost = 300},
			{{type = "mana", value = 300}, {type = "spell_up", value = "dc_keeper_of_the_light_chakra_magic"}, cost = 300},
		}},
		{type = "dmg_boost", levels = { -- aura
			{{type = "spell", value = "dc_vengefulspirit_command_aura"}, cost = 1700},
			{{type = "spell_up", value = "dc_vengefulspirit_command_aura"}, {type = "atk", value = 40}, cost = 2100},
			{{type = "spell_up", value = "dc_vengefulspirit_command_aura"}, {type = "atk", value = 50}, cost = 2200},
		}}, cost = 700
	},
	["siege_tower"] = { -- catapult
		{type = "splash", levels = {
			{{type = "spell", value = "black_dragon_splash_attack"}, cost = 900},
			{{type = "atk_dis", value = 60}, cost = 1200},
			{{type = "spell_up", value = "black_dragon_splash_attack"}, {type = "atk_dis", value = 40}, cost = 2100},
		}},
		{type = "speed_siege", levels = {
			{{type = "atks", value = 20}, cost = 600},
			{{type = "atks", value = 15}, {type = "atk", value = 40}, cost = 1000},
			{{type = "atks", value = 20}, {type = "atk", value = 40}, cost = 1400},
		}}, cost = 500
	},
	["bomber"] = { -- catapult
		{type = "bombordiro", levels = {
			{{type = "spell", value = "dc_techies_sticky_bomb"}, cost = 900},
			{{type = "spell_up", value = "dc_techies_sticky_bomb"}, cost = 1200},
			{{type = "spell_up", value = "dc_techies_sticky_bomb"}, {type = "spell_amp", value = 10}, cost = 2000},
		}},
		{type = "dragon_slave", levels = { -- у минера заменяется на улучшение прыжка
			{{type = "spell", value = "dc_lina_dragon_slave"}, cost = 1000},
			{{type = "spell_up", value = "dc_lina_dragon_slave"}, {type = "mana", value = 200}, cost = 1400},
			{{type = "spell_up", value = "dc_lina_dragon_slave"}, {type = "spell_amp", value = 5}, cost = 2200},
		}}, cost = 650
	},
}

wi.subClasses = { -- усиляются их способности
	["Veins_fire"] = {
		{type = "Veins_fire_upgrade", levels = {
			{{type = "spell_up", value = "burning_strikes"}, cost = 700},
			{{type = "hp", value = 100}, {type = "magr", value = 5}, cost = 400},
			{{type = "spell_up", value = "burning_strikes"}, cost = 900},
		}}, cost = 500
	}, -- tank
	["stone_block"] = {
		{type = "stone_block_upgrade", levels = {
			{{type = "spell_up", value = "dc_mars_bulwark"}, cost = 700},
			{{type = "hp", value = 150}, {type = "hpreg", value = 1}, cost = 500},
			{{type = "spell_up", value = "dc_mars_bulwark"}, cost = 900},
		}}, cost = 500
	}, -- tank
	["melee"] = {
		{type = "melee_upgrade", levels = {
			{{type = "spell", value = "dc_weaver_geminate_attack"}, cost = 500},
			{{type = "spell_up", value = "dc_weaver_geminate_attack"}, {type = "spell_up", value = "dota_clicker_juggernaut_blade_dance"}, cost = 1000},
			{{type = "spell_up", value = "dc_weaver_geminate_attack"}, {type = "spell_up", value = "dota_clicker_juggernaut_blade_dance"}, cost = 1250},
		}}, cost = 700
	}, -- berserker
	["illusionist"] = {
		{type = "illusionist_upgrade", levels = {
			{{type = "spell", value = "dc_riki_permanent_invisibility"}, cost = 500},
			{{type = "spell_up", value = "melee_spawn_unit"}, cost = 700},
			{{type = "spell_up", value = "melee_spawn_unit"}, cost = 900},
		}}, cost = 700
	}, -- berserker
	["gunner"] = {
		{type = "gunner_upgrade", levels = {
			{{type = "spell", value = "dc_troll_warlord_fervor"}, cost = 500},
			{{type = "spell_up", value = "dc_troll_warlord_fervor"}, cost = 700},
			{{type = "spell_up", value = "dc_troll_warlord_fervor"}, cost = 900},
		}}, cost = 700
	}, -- shooter
	["sniper"] = {
		{type = "sniper_upgrade", levels = {
			{{type = "spell_up", value = "dc_phantom_assassin_coup_de_grace"}, cost = 1000},
			{{type = "spell_up", value = "dc_sniper_headshot"}, cost = 600},
			{{type = "spell_up", value = "dc_phantom_assassin_coup_de_grace"}, cost = 1500},
		}}, cost = 1000
	}, -- shooter
	["pathfinder"] = {
		{type = "pathfinder_upgrade", levels = {
			{{type = "spell_up", value = "pathfinder_spawn_unit"}, cost = 700},
			{{type = "spell", value = "dc_beastmaster_call_of_the_wild_hawk"}, cost = 400},
			{{type = "spell_up", value = "pathfinder_spawn_unit"}, cost = 900},
		}}, cost = 600
	}, -- ranger
	["marksman"] = {
		{type = "marksman_upgrade", levels = {
			{{type = "spell", value = "dc_windrunner_shackleshot"}, cost = 500},
			{{type = "spell_up", value = "dc_medusa_split_shot"}, cost = 700},
			{{type = "spell_up", value = "dc_medusa_split_shot"}, cost = 900},
		}}, cost = 900
	}, -- ranger
	["fire_mage"] = {
		{type = "fire_mage_upgrade", levels = {
			{{type = "spell_up", value = "dc_batrider_flamebreak"}, cost = 700},
			{{type = "spell", value = ""}, cost = 900},
			{{type = "spell_up", value = "dc_lina_light_strike_array"}, cost = 800},
		}}, cost = 1000
	}, -- elementalist
	["air_mage"] = {
		{type = "air_mage_upgrade", levels = {
			{{type = "spell", value = "dc_silencer_last_word"}, cost = 700},
			{{type = "spell_up", value = "dc_winter_wyvern_cold_embrace"}, cost = 700},
			{{type = "spell_up", value = "dc_winter_wyvern_cold_embrace"}, {type = "spell_up", value = "dc_jakiro_liquid_ice"}, cost = 1100},
		}}, cost = 700
	}, -- elementalist
	["def_shaman"] = {
		{type = "def_shaman_upgrade", levels = {
			{{type = "spell_up", value = "dc_witch_doctor_voodoo_restoration"}, {type = "armor", value = 4}, cost = 1000},
			{{type = "spell", value = "dc_witch_doctor_death_ward"}, cost = 700},
			{{type = "hpreg", value = 5}, {type = "spell_up", value = "dc_witch_doctor_voodoo_restoration"}, cost = 1000},
		}}, cost = 500
	}, -- shaman
	["fight_shaman"] = {
		{type = "fight_shaman_upgrade", levels = {
			{{type = "spell_up", value = "dc_vengefulspirit_command_aura"}, cost = 700},
			{{type = "spell_up", value = "dc_witch_doctor_death_ward"}, cost = 500},
			{{type = "spell_up", value = "dc_witch_doctor_death_ward"}, cost = 500},
		}}, cost = 650
	}, -- shaman
	["trebuchet"] = {
		{type = "trebuchet_upgrade", levels = {
			{{type = "spell", value = "dc_earthshaker_enchant_totem"}, cost = 700},
			{{type = "spell_up", value = "black_dragon_splash_attack"}, cost = 700},
			{{type = "spell_up", value = "dc_earthshaker_enchant_totem"}, cost = 900},
		}}, cost = 1200
	}, -- siege_tower
	["ballista"] = {
		{type = "ballista_upgrade", levels = {
			{{type = "spell_up", value = "dc_windrunner_powershot"}, cost = 700},
			{{type = "spell_up", value = "dc_windrunner_powershot"}, cost = 900},
			{{type = "spell_up", value = "dc_windrunner_powershot"}, cost = 1200},
		}}, cost = 900
	}, -- siege_tower
	["rapid_fire"] = {
		{type = "rapid_fire_upgrade", levels = {
			{{type = "spell_up", value = "dc_shredder_flamethrower"}, cost = 500},
			{{type = "spell", value = "dc_batrider_sticky_napalm"}, cost = 500},
			{{type = "spell_up", value = "dc_batrider_sticky_napalm"}, cost = 500},
		}}, cost = 600
	}, -- bomber
	["miner"] = {
		{type = "miner_upgrade", levels = {
			{{type = "spell_up", value = "dc_techies_land_mines"}, cost = 700},
			{{type = "spell_up", value = "dc_techies_sticky_bomb"}, cost = 800},
			{{type = "spell_up", value = "dc_techies_land_mines"}, cost = 900},
		}}, cost = 800
	}, -- bomber
}

wi.upgrades = {
	["base"] = wi.base,
	["class"] = wi.classes,
	["sub"] = wi.subClasses,
}

wi.unitNames = {
	{"swordsman", "tank", "berserker", "Veins_fire", "stone_block", "melee", "illusionist"},
	{"archer", "shooter", "ranger", "gunner", "sniper", "pathfinder", "marksman"},
	{"mage", "elementalist", "shaman", "fire_mage", "air_mage", "def_shaman", "fight_shaman"},
	{"catapult", "siege_tower", "bomber", "trebuchet", "ballista", "rapid_fire", "miner"},
}

local autoDesc = {
    atks = "Добавляет %d ед. к скорости атаки",
    atk = "Добавляет %d ед. к урону",
    atk_dis = "Добавляет %d ед. к дальности атаки",
    vision = "Добавляет %d ед. к дальности обзора",
    hp = "Добавляет %d ед. к здоровью",
    armor = "Добавляет %d ед. к броне",
    magr = "Добавляет %d%% к магическому сопротивлению",
    spell_amp = "Добавляет %d%% к усилению магического урона",
    hpreg = "Добавляет %.1f ед. к регенерации здоровья",
    mana = "Добавляет %d ед. к мане",
    manareg = "Добавляет %.1f ед. к регенерации маны",
    spell = "Открывает способность %s",
    spell_up = "Улучшает способность %s",
}

local abilitiesNames = {
	dc_techies_land_mines = "Land Mines",
	dc_frogmen_water_bubble_small = "Water Bubble",
}

function wi:getUpgradeCost(unit, name, level)
	local upgrades = wi:getUpgrades(unit, name)
	if upgrades then 
		upgrades = upgrades.levels[level]
		if upgrades then
			return upgrades.cost or 300
		end
	end
	return 0
end

local function costText(cost)
	return "<br><br>Стоимость: <font color='#EFBF04'>" .. cost .. "</font>"
end

function wi:getUpgradeDescription(unit, name, level)
	
	local upgrades, type = wi:getUpgrades(unit, name)
	
	local desc = ""
	if upgrades then
		local maxLevel = wi:getMaxLevel(type, unit, name)
		upgrades = upgrades.levels[level]
		if upgrades then
			for i = 1, #upgrades do
				local upgrade = upgrades[i]
				if i > 1 then desc = desc .. "<br><br>" end
				if upgrade.desc then
					desc = desc .. upgrade.desc
				else
					local pattern = autoDesc[upgrade.type]
					if pattern then
						if upgrade.type == "spell" or upgrade.type == "spell_up" then
							-- Берём локализованное имя способности
							desc = desc .. string.format(pattern, abilitiesNames[upgrade.value])
						else
							desc = desc .. string.format(pattern, upgrade.value)
						end
					end
				end
			end
		end
		
		if level <= maxLevel then
			local cost = wi:getUpgradeCost(unit, name, level)
			desc = desc .. costText(cost)
		end
	end
    return desc
end

function wi:getUnitByName(name)
	return wi.units[name]
end

function wi:getArrByUnit(unit)
	if wi.base[unit] then
		return wi.base[unit], "base"
	elseif wi.classes[unit] then
		return wi.classes[unit], "class"
	elseif wi.subClasses[unit] then
		return wi.subClasses[unit], "sub"
	end
end

function wi:getUpgByName(unit, name)
	local function getId(arr, type)
		for i = 1, #arr do
			local upg = arr[i]
			if upg.type == name then
				return i, type
			end
		end
		return nil
	end
	
	for i = 1, #wi.unitNames do
		local names = wi.unitNames[i]
		if utils:indexOf(names, unit) then
			for j = 1, #names do
				local unitName = names[j]
				local i, type = getId(wi:getArrByUnit(unitName))
				if i then
					return i, type, unitName
				end
			end
		end
	end
	return nil
end

function wi:getMaxLevel(type, unit, name)
	local id, _ = self:getUpgByName(unit, name)
	local upgrade = wi.upgrades[type][unit][id]
	if upgrade then
		return #upgrade.levels
	else
		return 0
	end
end

function wi:getUnitName(name)
	for i = 1, #wi.unitNames do
		local arr = wi.unitNames[i]
		if utils:indexOf(arr, name) then
			return arr[1]
		end
	end
end

function wi:getUpgrades(unit, name)
	local id, type = wi:getUpgByName(unit, name)
	local arr = wi:getArrByUnit(unit)
	
	return arr[id], type
end

-- Добавляем в конец файла wi.lua

-- Маппинг названий
wi.nameMapping = {
	-- Базовые типы
	["swordsman"] = "Мечник",
	["archer"] = "Лучник", 
	["mage"] = "Маг",
	["catapult"] = "Осадная машина",
	
	-- Классы (evolutions)
	["tank"] = "Танк",
	["berserker"] = "Берсерк",
	["shooter"] = "Стрелок",
	["ranger"] = "Лучник",
	["elementalist"] = "Элементалист",
	["shaman"] = "Шаман",
	["siege_tower"] = "Катапульта",
	["bomber"] = "Бомба",
	
	-- Подклассы (subclasses)
	["Veins_fire"] = "Огненные жилы",
	["stone_block"] = "Каменная глыба",
	["melee"] = "Мастер фехтования",
	["illusionist"] = "Мастер иллюзий",
	["gunner"] = "Пулеметчик",
	["sniper"] = "Снайпер",
	["pathfinder"] = "Следопыт",
	["marksman"] = "Егерь",
	["fire_mage"] = "Маг огня и земли",
	["air_mage"] = "Маг воды и ветра",
	["def_shaman"] = "Боевой шаман",
	["fight_shaman"] = "Шаман призыва",
	["trebuchet"] = "Требушет",
	["ballista"] = "Баллиста",
	["rapid_fire"] = "Огнеметчик",
	["miner"] = "Минер",
	
	-- Названия апгрейдов
	["mana"] = "Сила магии",
	["spell_power"] = "Сила заклинаний",
	["cast_speed"] = "Скорость каста",
	["hp"] = "Здоровяк",
	["damage"] = "Урон",
	["armor"] = "Броня",
	["def"] = "Стойкость",
}

-- Функция преобразования всех данных в один большой массив
function wi:convertToUnifiedStructure()
  local result = {}
  
  local function newArray()
    return setmetatable({}, { __jsontype = 'array' })
  end

  -- Проходим по базовым типам юнитов
  for _, unitType in ipairs(wi.unitTypes) do
    local unitData = {
      name = wi.nameMapping[unitType] or unitType,
      baseUpgrades = newArray(),
      evolutions = newArray(),
      subclasses = newArray()
    }
    
    -- Получаем базовые апгрейды
    if wi.base[unitType] then
      for _, upgrade in ipairs(wi.base[unitType]) do
        local upgradeData = {
          id = upgrade.type,
          name = wi.nameMapping[upgrade.type] or upgrade.type,
          description = wi:getUpgradeDescription(unitType, upgrade.type, 1),
          level = 0,
          maxLevel = #upgrade.levels
        }
        table.insert(unitData.baseUpgrades, upgradeData)
      end
    end
    
    -- Находим все классы (evolutions) для данного базового типа
    for className, classData in pairs(wi.classes) do
      local parentType = wi:getUnitName(className)
      if parentType == unitType then
        local evolution = {
          id = className,
          name = wi.nameMapping[className] or className,
          description = wi.unitDescription[className] .. costText(wi.classes[className].cost) .. "<br>" or "",
          requirement = {},
          skills = newArray()
        }
        
        -- Парсим требования из wi.requirement
        if wi.requirement[className] and wi.requirement[className].upgs then
          local reqs = wi.requirement[className].upgs
          for i = 1, #reqs do
            if reqs[i] then
              evolution.requirement[reqs[i][1]] = reqs[i][2]
            end
          end
        end
        
        -- Преобразуем levels в skills
        for _, skill in ipairs(classData) do
          local skillData = {
            id = skill.type,
            name = wi.nameMapping[skill.type] or skill.type,
            description = wi:getUpgradeDescription(className, skill.type, 1),
            level = 0,
            maxLevel = #skill.levels
          }
          table.insert(evolution.skills, skillData)
        end
        
        table.insert(unitData.evolutions, evolution)
      end
    end
    
    -- Находим все подклассы (subclasses) для данного базового типа
    for subClassName, subClassData in pairs(wi.subClasses) do
      local parentType = wi:getUnitName(subClassName)
      if parentType == unitType then
        local subclass = {
          id = subClassName,
          name = wi.nameMapping[subClassName] or subClassName,
          description = wi.unitDescription[subClassName] .. costText(wi.subClasses[subClassName].cost) .. "<br>" or "",
          requirement = {},
          skills = newArray()
        }
        
        -- Парсим требования из wi.requirement для подклассов
        if wi.requirement[subClassName] then
          local req = wi.requirement[subClassName]
          if req.class then
            -- Структура: { evolutions: { class_name: { upgrade_requirements } } }
            subclass.requirement.evolutions = {}
            subclass.requirement.evolutions[req.class] = {}
            
            if req.upgs then
              for i = 1, #req.upgs do
                if req.upgs[i] then
                  subclass.requirement.evolutions[req.class][req.upgs[i][1]] = req.upgs[i][2]
                end
              end
            end
          end
        end
        
		for _, skill in ipairs(subClassData) do
          local skillData = {
            id = skill.type,
            name = wi.nameMapping[skill.type] or skill.type,
            description = wi:getUpgradeDescription(subClassName, skill.type, 1),
            level = 0,
            maxLevel = #skill.levels
          }
          table.insert(subclass.skills, skillData)
        end
        
        table.insert(unitData.subclasses, subclass)
      end
    end
    
    result[unitType] = unitData
  end
  
  return result
end


-- Функция для вывода структуры в консоль для проверки
function wi:printUnifiedStructure()
	local data = wi:convertToUnifiedStructure()
	
	print("=== UNIFIED UNIT STRUCTURE ===")
	
	for unitType, unitData in pairs(data) do
		print("\n" .. unitType .. ": {")
		print("  name: \"" .. unitData.name .. "\",")
		
		-- Выводим базовые апгрейды
		print("  baseUpgrades: [")
		for _, upgrade in ipairs(unitData.baseUpgrades) do
			print("    { id: \"" .. upgrade.id .. "\", name: \"" .. upgrade.name .. "\", level: " .. upgrade.level .. ", maxLevel: " .. upgrade.maxLevel .. " },")
		end
		print("  ],")
		
		-- Выводим эволюции
		print("  evolutions: [")
		for _, evolution in ipairs(unitData.evolutions) do
			print("    {")
			print("      id: \"" .. evolution.id .. "\",")
			print("      name: \"" .. evolution.name .. "\",")
			print("      description: \"" .. evolution.description .. "\",")
			
			-- Выводим требования
			print("      requirement: {")
			local reqCount = 0
			for reqKey, reqValue in pairs(evolution.requirement) do
				if reqCount > 0 then print(", ") end
				print(" " .. reqKey .. ": " .. reqValue)
				reqCount = reqCount + 1
			end
			print(" },")
			
			-- Выводим скиллы
			print("      skills: [")
			for _, skill in ipairs(evolution.skills) do
				print("        { id: \"" .. skill.id .. "\", name: \"" .. skill.name .. "\", level: " .. skill.level .. ", maxLevel: " .. skill.maxLevel .. " },")
			end
			print("      ]")
			print("    },")
		end
		print("  ],")
		
		-- Выводим подклассы
		print("  subclasses: [")
		for _, subclass in ipairs(unitData.subclasses) do
			print("    {")
			print("      id: \"" .. subclass.id .. "\",")
			print("      name: \"" .. subclass.name .. "\",")
			print("      description: \"" .. subclass.description .. "\",")
			
			-- Выводим требования для подклассов
			print("      requirement: {")
			if subclass.requirement.evolutions then
				print("        evolutions: {")
				for evolName, evolReqs in pairs(subclass.requirement.evolutions) do
					print("          " .. evolName .. ": {")
					local reqCount = 0
					for reqKey, reqValue in pairs(evolReqs) do
						if reqCount > 0 then print(", ") end
						print(" " .. reqKey .. ": " .. reqValue)
						reqCount = reqCount + 1
					end
					print(" }")
				end
				print("        }")
			end
			print("      },")
			
			-- Выводим скиллы
			print("      skills: [")
			for _, skill in ipairs(subclass.skills) do
				print("        { id: \"" .. skill.id .. "\", name: \"" .. skill.name .. "\", level: " .. skill.level .. ", maxLevel: " .. skill.maxLevel .. " },")
			end
			print("      ]")
			print("    },")
		end
		print("  ]")
		print("},")
	end
	
	print("\n=== END STRUCTURE ===")
end

print("ZXCZXCZXC", "#neutral_damage_bonus")

return wi