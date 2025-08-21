-- utils/badBotAI.lua
-- ИИ для бота-противника в кастомке
-- Работает только с badBot.units и badBot.upgrades, которые создаёт wa:InitAddon

if badBotAI == nil then
    badBotAI = class({})
end

local wi    = require("utils/wavesInfo")
local utils = require("utils/utils")

local STAGE_WAVES = {
    class_at    = 6,
    subclass_at = 14,
}

local CLASS_OPTIONS = {
    swordsman = {"tank", "berserker"},
    archer    = {"shooter", "ranger"},
    mage      = {"elementalist", "shaman"},
    catapult  = {"siege_tower", "bomber"},
}

local SUBCLASS_OPTIONS = {
    tank         = {"Veins_fire", "stone_block"},
    berserker    = {"melee", "illusionist"},
    shooter      = {"gunner", "sniper"},
    ranger       = {"pathfinder", "marksman"},
    elementalist = {"fire_mage", "air_mage"},
    shaman       = {"def_shaman", "fight_shaman"},
    siege_tower  = {"trebuchet", "ballista"},
    bomber       = {"rapid_fire", "miner"},
}

local ROLE_ORDER = {"swordsman", "archer", "mage", "catapult"}

local STRATEGIES = {
    balanced = {weights = {swordsman=1, archer=1, mage=1, catapult=1}},
    ranged   = {weights = {swordsman=0.5, archer=2, mage=1.5, catapult=1}},
    magic    = {weights = {swordsman=0.5, archer=0.8, mage=2, catapult=1}},
    tanky    = {weights = {swordsman=2, archer=0.8, mage=1, catapult=1}},
    siege    = {weights = {swordsman=0.8, archer=1, mage=1, catapult=2}},
}

local function targetCountForWave(wave, maxUnits, playerCount, difficulty)
    local base = 2
    local growth = math.floor(wave * 0.7 * difficulty)
    local target = base + growth
    local factor = math.max(1, playerCount / 2)
    target = math.floor(target * factor)
    return math.min(target, maxUnits)
end

local function pickRandom(tbl)
    if not tbl or #tbl == 0 then return nil end
    local id = RandomInt and RandomInt(1, #tbl) or math.random(#tbl)
    return tbl[id]
end

local function pickClassAndSub(bot, wave)
    for baseType, options in pairs(CLASS_OPTIONS) do
        local U = bot.upgrades[baseType]
        if wave >= STAGE_WAVES.class_at and not U[4] then
            U[4] = pickRandom(options)
            print("[BadBotAI] Волна "..wave..": выбрал класс для "..baseType.." -> "..U[4])
        end
        if wave >= STAGE_WAVES.subclass_at and U[4] and not U[5] then
            local subs = SUBCLASS_OPTIONS[U[4]]
            if subs then
                U[5] = pickRandom(subs)
                print("[BadBotAI] Волна "..wave..": выбрал подкласс для "..baseType.." -> "..U[5])
            end
        end
    end
end

local function rampUpgrades(bot, wave, difficulty)
    local budget = math.max(1, math.floor(wave * 0.5 * difficulty))

    for _, baseType in ipairs(wi.unitTypes) do
        local U = bot.upgrades[baseType]
        for i=1,budget do
            local branch = math.random(1,3)
            U[1].levels[branch] = U[1].levels[branch] + 1
        end
        if U[4] then
            for i=1, math.floor(budget/2) do
                local branch = math.random(1,3)
                U[2].levels[branch] = U[2].levels[branch] + 1
            end
        end
        if U[5] then
            U[3].levels[1] = U[3].levels[1] + math.floor(budget/2)
        end
    end
    print("[BadBotAI] Волна "..wave..": прокачал апгрейды (бюджет="..budget..")")
end

local function countByType(units)
    local c = {swordsman=0,archer=0,mage=0,catapult=0}
    for _,u in ipairs(units or {}) do
        c[u] = (c[u] or 0)+1
    end
    return c
end

local function pickNextType(bot)
    local counts = countByType(bot.units or {})
    local weights = bot.__strategy.weights
    local best, bestScore = nil, -1
    for t,_ in pairs(weights) do
        local score = weights[t] / (counts[t] + 1)
        if score > bestScore then
            best, bestScore = t, score
        end
    end
    print("[BadBotAI] Выбирает юнита: "..best)
    return best or "swordsman"
end

function badBotAI:Init(bot, opts)
    bot.__wave = 0
    bot.__difficulty = (opts and opts.difficulty) or 1.0
    bot.__players = (opts and opts.players) or 1
    local keys = {}
    for k,_ in pairs(STRATEGIES) do table.insert(keys, k) end
    local chosen = pickRandom(keys) or "balanced"
    bot.__strategy = STRATEGIES[chosen]
    print("[BadBotAI] Стартует со стратегией: "..chosen)
end

function badBotAI:Tick(bot, maxUnits)
    bot.__wave = (bot.__wave or 0) + 1
    local wave = bot.__wave

    local difficulty = bot.__difficulty or 1.0
    local players = bot.__players or 1

    print("[BadBotAI] --- Волна "..wave.." ---")

    pickClassAndSub(bot, wave)
    rampUpgrades(bot, wave, difficulty)

    local desired = targetCountForWave(wave, maxUnits, players, difficulty)
    local need = math.max(0, desired - #bot.units)
    print("[BadBotAI] Цель по юнитам: "..desired.." (сейчас="..#bot.units..")")
    for i=1,need do
        if #bot.units < maxUnits then
            table.insert(bot.units, pickNextType(bot))
        end
    end
end

return badBotAI