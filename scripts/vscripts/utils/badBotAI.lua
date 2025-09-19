-- badBotAI.lua (Gold + UP economy, core-pairs strategies, smooth pacing)
-- Требует wi (utils/wavesInfo) и предполагает структуру badBot, аналогичную player у wa:InitAddon

if badBotAI == nil then
    badBotAI = class({})
end

local wi = require("utils/wavesInfo")

--------------------------------------------------------------------------------
-- НАСТРОЙКИ / КАЛИБРОВКА (TUNE)
--------------------------------------------------------------------------------

local CFG = {
    -- Базовая экономика
    BASE_GOLD_PER_WAVE = 600,       -- TUNE: базовый доход золота за волну (1 игрок)
    GOLD_WAVE_GROWTH   = 0.12,      -- TUNE: рост золота по волне: (1 + (wave-1)*GOLD_WAVE_GROWTH)
    BASE_UP_PER_WAVE   = 3,         -- TUNE: базовый доход Upgrade Points за волну (1 игрок)
    UP_LINEAR_ADD      = 0.3,      -- TUNE: линейное ускорение UP: + UP_LINEAR_ADD * wave

    -- «Мягкий» коэффициент за игрока (не линейное умножение на N)
    PLAYERS_MULT_GOLD  = 0.75,      -- на каждого доп. игрока прирост золота: 1 + (p-1)*0.75
    PLAYERS_MULT_UP    = 0.1,      -- на каждого доп. игрока прирост UP:    1 + (p-1)*0.60

    -- Сложность → множитель
    DIFFICULTY_MULT = {1.00, 1.25, 1.50},

    -- Временные цели (в волнах). Допусти, что 1 волна ~ 1 минута. Подкрути под свой тайминг.
    WAVES_TO_FULL_STACK = 20,       -- к этой волне хотим добрать лимит юнитов
    WAVES_TO_STRONG_UPS = 40,       -- к этой волне хотим фулл 1-го и ~½-1 второго ключевого юнита

    -- «Умность» — как часто бот дополнительно делает апгрейды сверх основного плана
    SMARTNESS = {0.55, 0.65, 0.80},

    -- Набор стратегических «ядер» (1–2 ключевых юнита) + флаг «сбалансировано ли»
    -- Если пара сбалансированная → можно играть без третьей поддержки.
    CORE_PAIRS = {
        { core = {"mage", "archer"},      balanced = false }, -- сильный ДПС, хрупкие → обычно добавим танка
        { core = {"swordsman", "mage"},   balanced = true  }, -- танк + дпс → можно без поддержки
        { core = {"archer", "catapult"},  balanced = false }, -- осада + дд → добавим танка/кастера
        { core = {"swordsman", "archer"}, balanced = true  }, -- фронт + даль → ок без поддержки
        { core = {"mage", "catapult"},    balanced = false }, -- магия + осада → добавим фронт
    },

    -- Кто может выступать «танком/фронтом»
    TANK_CANDIDATES = {"swordsman", "archer"}, -- archer при нужных классах/деф апах может быть полутанком
    -- Кто может быть саппортом/кастером (вспомогательная роль)
    SUPPORT_CANDIDATES = {"mage"},

    -- Вес распределения покупки юнитов по выбранной стратегии
    -- Будет динамически собираться после выбора ядра/поддержки
    -- Пример целевых весов: core1 ~ 0.5, core2 ~ 0.3, support ~ 0.2
    BASE_WEIGHTS = { core1 = 0.50, core2 = 0.30, support = 0.20 },

    -- Приоритет прокачки (внутри юнита):
    -- чаще пробуем sub > class > base, если доступны
    UPGRADE_SCOPE_ORDER = {"sub", "class", "base"},
}

--------------------------------------------------------------------------------
-- УТИЛИТЫ
--------------------------------------------------------------------------------

local function rnd(min, max)
    if RandomInt then return RandomInt(min, max) end
    return math.random(min, max)
end

local function clamp(v, a, b)
    if v < a then return a end
    if v > b then return b end
    return v
end

local function debug(bot, text)
    print(("[BOT %s] %s"):format(bot.name or "AI", text))
end

local function chooseWeighted(weightsTbl)
    -- weightsTbl: {key=weight}
    local sum = 0
    for _, w in pairs(weightsTbl) do sum = sum + w end
    if sum <= 0 then
        for k, _ in pairs(weightsTbl) do return k end
    end
    local r = (RandomFloat and RandomFloat(0, sum)) or (math.random() * sum)
    local acc = 0
    for k, w in pairs(weightsTbl) do
        acc = acc + w
        if r <= acc then return k end
    end
    for k, _ in pairs(weightsTbl) do return k end
end

--------------------------------------------------------------------------------
-- РАБОТА С «СЛОТАМИ» АПГРЕЙДОВ
--------------------------------------------------------------------------------

local function ensureUpgradeSlots(bot, unitType)
    if not bot.upgrades[unitType] then
        bot.upgrades[unitType] = {
            {type = "base", levels = {0, 0, 0}},
            {type = "class", levels = {0, 0, 0}},
            {type = "sub",   levels = {0}},
            nil, -- [4] chosen className
            nil, -- [5] chosen subClassName
        }
    else
        -- Расширяем массивы уровней, если в wi появилась новая длина
        local baseArr = wi.base[unitType]
        if baseArr then
            local want = #baseArr
            local have = #bot.upgrades[unitType][1].levels
            for i = have+1, want do table.insert(bot.upgrades[unitType][1].levels, 0) end
        end
        local classChosen = bot.upgrades[unitType][4]
        if classChosen and wi.classes[classChosen] then
            local want = #wi.classes[classChosen]
            local have = #bot.upgrades[unitType][2].levels
            for i = have+1, want do table.insert(bot.upgrades[unitType][2].levels, 0) end
        end
        local subChosen = bot.upgrades[unitType][5]
        if subChosen and wi.subClasses[subChosen] then
            local want = #wi.subClasses[subChosen]
            local have = #bot.upgrades[unitType][3].levels
            for i = have+1, want do table.insert(bot.upgrades[unitType][3].levels, 0) end
        end
    end
end

local function findUpgradeIndex(arr, typeName)
    if not arr then return nil end
    for i, upg in ipairs(arr) do
        if upg.type == typeName then return i end
    end
    return nil
end

--------------------------------------------------------------------------------
-- ЭКОНОМИКА: GOLD и UP
--------------------------------------------------------------------------------

local function canAffordGold(bot, cost) return (bot.gold or 0) >= cost end
local function payGold(bot, cost) bot.gold = (bot.gold or 0) - cost end

local function canAffordUP(bot, cost) return (bot.up or 0) >= cost end
local function payUP(bot, cost) bot.up = (bot.up or 0) - cost end

local function getUnitCost(unitType)
    local data = wi.base[unitType]
    if data and data.cost then return data.cost end
    return 300
end

-- Все «внутренние» уровни и классы/подклассы — оплачиваются UP.
local function nextUpgradeCost(baseUnit, scope, ownerName, upgradeType, levelNext)
    if scope == "base" then
        local idx = findUpgradeIndex(wi.base[baseUnit], upgradeType)
        if idx then return wi.base[baseUnit][idx].levels[levelNext].cost or 1 end
    elseif scope == "class" then
        local idx = findUpgradeIndex(wi.classes[ownerName], upgradeType)
        if idx then return wi.classes[ownerName][idx].levels[levelNext].cost or 2 end
    elseif scope == "sub" then
        local idx = findUpgradeIndex(wi.subClasses[ownerName], upgradeType)
        if idx then return wi.subClasses[ownerName][idx].levels[levelNext].cost or 3 end
    end
    return 1
end

local function classCost(className)
    -- В твоих данных cost у классов — это UP (например 10)
    local arr = wi.classes[className]
    if arr and wi.classes[className].cost then return wi.classes[className].cost end
    -- fallback — возьмём стоимость первого уровня первого апгрейда
    if arr and arr[1] and arr[1].levels and arr[1].levels[1] then
        return arr[1].levels[1].cost or 10
    end
    return 10
end

local function subCost(subName)
    -- В твоих данных cost у подклассов — это UP (например 20)
    local arr = wi.subClasses[subName]
    if arr and wi.subClasses[subName].cost then return wi.subClasses[subName].cost end
    if arr and arr[1] and arr[1].levels and arr[1].levels[1] then
        return arr[1].levels[1].cost or 20
    end
    return 20
end

-- Доход золота за волну
local function IncomeGoldForWave(bot)
    local pMult  = 1 + (bot.players - 1) * CFG.PLAYERS_MULT_GOLD
    local dMult  = CFG.DIFFICULTY_MULT[bot.difficulty] or 1.0
    local growth = 1 + math.max(0, bot._wave - 1) * CFG.GOLD_WAVE_GROWTH
    local gold   = math.floor(CFG.BASE_GOLD_PER_WAVE * pMult * dMult * growth)
    return gold
end

-- Доход UP за волну
local function IncomeUPForWave(bot)
    local pMult = 1 + (bot.players - 1) * CFG.PLAYERS_MULT_UP
    local dMult = CFG.DIFFICULTY_MULT[bot.difficulty] or 1.0
    local upInc = CFG.BASE_UP_PER_WAVE + (bot._wave * CFG.UP_LINEAR_ADD)
    upInc = math.floor(upInc * pMult * dMult)
    return math.max(1, upInc)
end

--------------------------------------------------------------------------------
-- РОЛИ И СТРАТЕГИЯ: ядро из 1–2 юнитов + опциональная поддержка
--------------------------------------------------------------------------------

local function pickCorePair()
    local i = rnd(1, #CFG.CORE_PAIRS)
    return CFG.CORE_PAIRS[i]
end

local function buildWeightsFromCore(corePair, needSupport)
    -- Сбор весов покупки юнитов под стратегию
    -- Пример: core1=0.5, core2=0.3, support=0.2 (если support нужен)
    local w = { swordsman = 0, archer = 0, mage = 0, catapult = 0 }
    local c1, c2 = corePair.core[1], corePair.core[2]
    local baseW = CFG.BASE_WEIGHTS

    w[c1] = w[c1] + baseW.core1
    if c2 then w[c2] = w[c2] + baseW.core2 end

    if needSupport then
        -- В приоритете танк или саппорт (микс), но не повторять уже выбранные
        local supportPick = nil
        local tries = 4
        while tries > 0 and not supportPick do
            tries = tries - 1
            -- 50/50 танк или саппорт
            if math.random() < 0.5 then
                supportPick = CFG.TANK_CANDIDATES[rnd(1, #CFG.TANK_CANDIDATES)]
            else
                supportPick = CFG.SUPPORT_CANDIDATES[rnd(1, #CFG.SUPPORT_CANDIDATES)]
            end
            if supportPick == c1 or supportPick == c2 then supportPick = nil end
        end
        if not supportPick then supportPick = "swordsman" end -- дефолт фронт

        w[supportPick] = (w[supportPick] or 0) + baseW.support
    end
    return w
end

--------------------------------------------------------------------------------
-- ПОКУПКИ / УЛУЧШЕНИЯ
--------------------------------------------------------------------------------

local function buyUnit(bot, unitType)
    ensureUpgradeSlots(bot, unitType)
    local cost = getUnitCost(unitType)
    if not canAffordGold(bot, cost) then return false end
    if bot._MAX_UNITS and #bot.units >= bot._MAX_UNITS then return false end

    table.insert(bot.units, unitType)
    payGold(bot, cost)
    debug(bot, ("Buy UNIT: %s for %d Gold. Gold=%d, UP=%d"):format(unitType, cost, bot.gold, bot.up))
    return true
end

local function currentLevelOf(bot, baseUnit, scope, upgradeType)
    ensureUpgradeSlots(bot, baseUnit)
    local pack = bot.upgrades[baseUnit]
    if scope == "base" then
        local idx = findUpgradeIndex(wi.base[baseUnit], upgradeType)
        if not idx then return 0 end
        return pack[1].levels[idx] or 0
    elseif scope == "class" then
        local classChosen = pack[4]
        if not classChosen then return 0 end
        local idx = findUpgradeIndex(wi.classes[classChosen], upgradeType)
        if not idx then return 0 end
        return pack[2].levels[idx] or 0
    elseif scope == "sub" then
        local subChosen = pack[5]
        if not subChosen then return 0 end
        local idx = findUpgradeIndex(wi.subClasses[subChosen], upgradeType)
        if not idx then return 0 end
        return pack[3].levels[idx] or 0
    end
    return 0
end

local function requirementsMetForClass(bot, baseUnit, className)
    local req = wi.requirement and wi.requirement[className]
    if not req then return true end
    if req.upgs then
        for _, tup in ipairs(req.upgs) do
            local upName, needLvl = tup[1], tup[2]
            local cur = currentLevelOf(bot, baseUnit, "base", upName)
            if cur < needLvl then return false end
        end
    end
    return true
end

local function requirementsMetForSubclass(bot, baseUnit, className, subName)
    local req = wi.requirement and wi.requirement[subName]
    if not req then return true end
    if req.class and req.class ~= className then return false end
    if req.upgs then
        for _, tup in ipairs(req.upgs) do
            local upName, needLvl = tup[1], tup[2]
            local cur = currentLevelOf(bot, baseUnit, "class", upName)
            if cur < needLvl then return false end
        end
    end
    return true
end

local function getClassCandidates(baseUnit)
    -- по wi.unitNames находим 2 класса базового юнита
    local classes = {}
    for _, row in ipairs(wi.unitNames or {}) do
        if row[1] == baseUnit then
            if wi.classes[row[2]] then table.insert(classes, row[2]) end
            if wi.classes[row[3]] then table.insert(classes, row[3]) end
            break
        end
    end
    return classes
end

local function getSubclassCandidates(baseUnit, classChosen)
    local subs = {}
    for subName, req in pairs(wi.requirement or {}) do
        if req.class and req.class == classChosen then
            if wi:getUnitName(subName) == baseUnit and wi.subClasses[subName] then
                table.insert(subs, subName)
            end
        end
    end
    return subs
end

local function buyClass(bot, baseUnit, className)
    ensureUpgradeSlots(bot, baseUnit)
    local cost = classCost(className) -- UP
    if not canAffordUP(bot, cost) then return false end
    if not requirementsMetForClass(bot, baseUnit, className) then return false end

    bot.upgrades[baseUnit][4] = className
    bot.upgrades[baseUnit][2].levels = {}
    local wanted = #wi.classes[className]
    for i = 1, wanted do bot.upgrades[baseUnit][2].levels[i] = 0 end
    payUP(bot, cost)
    debug(bot, ("Take CLASS %s for %s (UP=%d). Gold=%d, UP=%d"):
        format(className, baseUnit, cost, bot.gold, bot.up))
    return true
end

local function buySubclass(bot, baseUnit, subName)
    ensureUpgradeSlots(bot, baseUnit)
    local classChosen = bot.upgrades[baseUnit][4]
    if not classChosen then return false end
    if not requirementsMetForSubclass(bot, baseUnit, classChosen, subName) then return false end

    local cost = subCost(subName) -- UP
    if not canAffordUP(bot, cost) then return false end

    bot.upgrades[baseUnit][5] = subName
    bot.upgrades[baseUnit][3].levels = {}
    local wanted = #wi.subClasses[subName]
    for i = 1, wanted do bot.upgrades[baseUnit][3].levels[i] = 0 end
    payUP(bot, cost)
    debug(bot, ("Take SUBCLASS %s for %s (UP=%d). Gold=%d, UP=%d"):
        format(subName, baseUnit, cost, bot.gold, bot.up))
    return true
end

local function buyNextUpgrade(bot, baseUnit, scope)
    ensureUpgradeSlots(bot, baseUnit)
    local pack = bot.upgrades[baseUnit]

    local function doScope(arr, levelsArr, ownerNameLabel)
        -- собираем кандидатов, где уровень не максимум
        local candidates = {}
        for i, upg in ipairs(arr or {}) do
            local cur = levelsArr[i] or 0
            local max = #upg.levels
            if cur < max then
                table.insert(candidates, {i=i, upg=upg})
            end
        end
        if #candidates == 0 then return false end

        local pick = candidates[rnd(1, #candidates)]
        local nextLevel = (levelsArr[pick.i] or 0) + 1
        local ownerName = ownerNameLabel
        local cost = nextUpgradeCost(baseUnit, scope, ownerName, pick.upg.type, nextLevel) -- UP

        if not canAffordUP(bot, cost) then return false end
        levelsArr[pick.i] = nextLevel
        payUP(bot, cost)

        if scope == "base" then
            debug(bot, ("UPGRADE BASE %s(%d/%d) for %s (UP=%d). Gold=%d, UP=%d"):
                format(pick.upg.type, nextLevel, #pick.upg.levels, baseUnit, cost, bot.gold, bot.up))
        elseif scope == "class" then
            debug(bot, ("UPGRADE CLASS %s(%d/%d) [%s] for %s (UP=%d). Gold=%d, UP=%d"):
                format(pick.upg.type, nextLevel, #pick.upg.levels, ownerName, baseUnit, cost, bot.gold, bot.up))
        else
            debug(bot, ("UPGRADE SUB %s(%d/%d) [%s] for %s (UP=%d). Gold=%d, UP=%d"):
                format(pick.upg.type, nextLevel, #pick.upg.levels, ownerName, baseUnit, cost, bot.gold, bot.up))
        end
        return true
    end

    if scope == "base" then
        return doScope(wi.base[baseUnit], pack[1].levels, baseUnit)
    elseif scope == "class" then
        local classChosen = pack[4]
        if not classChosen then return false end
        return doScope(wi.classes[classChosen], pack[2].levels, classChosen)
    elseif scope == "sub" then
        local subChosen = pack[5]
        if not subChosen then return false end
        return doScope(wi.subClasses[subChosen], pack[3].levels, subChosen)
    end
    return false
end

--------------------------------------------------------------------------------
-- ВЫБОР ДЕЙСТВИЙ
--------------------------------------------------------------------------------

-- Целевое число юнитов к текущей волне: растёт линейно до лимита к WAVES_TO_FULL_STACK
local function targetUnitsByWave(bot, MAX_UNITS)
    local t = clamp(bot._wave / CFG.WAVES_TO_FULL_STACK, 0, 1)
    return math.floor(MAX_UNITS * t + 0.0001)
end

local function wantBuyMoreUnits(bot, MAX_UNITS)
    local cur = #bot.units
    local target = targetUnitsByWave(bot, MAX_UNITS)
    return cur < target
end

local function pickUnitTypeForStrategy(bot)
    local w = bot._weights or {swordsman=0.25, archer=0.25, mage=0.25, catapult=0.25}
    return chooseWeighted(w)
end

local function tryDevelopEvolution(bot)
    -- Пытаемся продвинуться: класс → подкласс для ключевых баз
    local bases = {"swordsman", "archer", "mage", "catapult"}
    -- Сортируем по весам стратегии (важнее ядро)
    table.sort(bases, function(a,b)
        local wa = (bot._weights and bot._weights[a]) or 0
        local wb = (bot._weights and bot._weights[b]) or 0
        return wa > wb
    end)

    for _, baseUnit in ipairs(bases) do
        ensureUpgradeSlots(bot, baseUnit)
        local pack = bot.upgrades[baseUnit]
        -- 1) Нет класса → попытаться взять
        if not pack[4] then
            local cls = getClassCandidates(baseUnit)
            if #cls > 0 then
                -- фильтруем выполнимые
                local pool = {}
                for _, c in ipairs(cls) do
                    if requirementsMetForClass(bot, baseUnit, c) then table.insert(pool, c) end
                end
                if #pool > 0 then
                    local pick = pool[rnd(1, #pool)]
                    if buyClass(bot, baseUnit, pick) then return true end
                end
            end
        else
            -- 2) Класс есть, нет подкласса → взять подкласс
            if not pack[5] then
                local subs = getSubclassCandidates(baseUnit, pack[4])
                if #subs > 0 then
                    local pool = {}
                    for _, s in ipairs(subs) do
                        if requirementsMetForSubclass(bot, baseUnit, pack[4], s) then table.insert(pool, s) end
                    end
                    if #pool > 0 then
                        local pick = pool[rnd(1, #pool)]
                        if buySubclass(bot, baseUnit, pick) then return true end
                    end
                end
            end
        end
    end
    return false
end

function canDevelopEvolution(bot)
    -- Если ещё нет класса или подкласса — значит можем накапливать
    if not bot.hasClass then return true end
    if bot.hasClass and not bot.hasSubclass then return true end
    return false
end

local function tryDoUpgrades(bot)
    local bases = {"swordsman", "archer", "mage", "catapult"}
    table.sort(bases, function(a,b)
        local wa = (bot._weights and bot._weights[a]) or 0
        local wb = (bot._weights and bot._weights[b]) or 0
        return wa > wb
    end)

    -- Сначала субкласс → класс → база (если доступны)
    for _, base in ipairs(bases) do
        for _, scope in ipairs(CFG.UPGRADE_SCOPE_ORDER) do
            if buyNextUpgrade(bot, base, scope) then return true end
        end
    end
    -- Если ничего не вышло — любой базовый ап
    for _, base in ipairs(bases) do
        if buyNextUpgrade(bot, base, "base") then return true end
    end
    return false
end

local function tryBuyUnits(bot, MAX_UNITS)
    -- Покупаем несколько раз за тик, пока хватает золота и есть место
    -- Количество попыток растёт к 20 волне (плавное ускорение)
    local accel = clamp(bot._wave / CFG.WAVES_TO_FULL_STACK, 0.1, 1.0)
    local attempts = 1 + math.floor(3 * accel)
    local any = false
    while attempts > 0 do
        attempts = attempts - 1
        if bot._MAX_UNITS and #bot.units >= bot._MAX_UNITS then break end
        local t = pickUnitTypeForStrategy(bot)
        if not buyUnit(bot, t) then break end
        any = true
    end
    return any
end

--------------------------------------------------------------------------------
-- ПУБЛИЧНЫЕ ФУНКЦИИ
--------------------------------------------------------------------------------

function badBotAI:Init(bot, params)
    bot.name     = bot.name or "AI"
    bot.units    = bot.units or {}
    bot.upgrades = bot.upgrades or {
        ["swordsman"] = { {type="base", levels={0,0,0}}, {type="class", levels={0,0,0}}, {type="sub", levels={0}}, nil, nil },
        ["archer"]    = { {type="base", levels={0,0,0}}, {type="class", levels={0,0,0}}, {type="sub", levels={0}}, nil, nil },
        ["mage"]      = { {type="base", levels={0,0,0}}, {type="class", levels={0,0,0}}, {type="sub", levels={0}}, nil, nil },
        ["catapult"]  = { {type="base", levels={0,0,0}}, {type="class", levels={0,0,0}}, {type="sub", levels={0}}, nil, nil },
    }

    bot.players    = clamp(tonumber(params.players or 1) or 1, 1, 10)
    local diff     = (params.difficulty or 1)
    if not CFG.DIFFICULTY_MULT[diff] then diff = 1 end
    bot.difficulty = diff

    -- Стартовые ресурсы
    -- Немного золота под ранние покупки и немного UP под ранние базовые апы
    bot.gold = bot.gold or math.floor(1000 * (1 + (bot.players - 1) * CFG.PLAYERS_MULT_GOLD))
    bot.up   = bot.up   or 3  -- стартовый «задел» апгрейд-поинтов (TUNE)

    bot._wave = 0
    bot._MAX_UNITS = nil

    -- Выбор ядра
    local corePair = pickCorePair()
    bot.core = corePair.core
    bot.coreBalanced = corePair.balanced

    -- Нужна ли поддержка? Если ядро не сбалансировано — да.
    local needSupport = not bot.coreBalanced
    bot._weights = buildWeightsFromCore(corePair, needSupport)

    debug(bot, ("Init. Difficulty=%d, Players=%d, Core={%s,%s}, Balanced=%s; Weights: SW=%.2f, AR=%.2f, MG=%.2f, CT=%.2f; Start Gold=%d, UP=%d"):
        format(bot.difficulty, bot.players, bot.core[1] or "nil", bot.core[2] or "nil",
               tostring(bot.coreBalanced),
               bot._weights.swordsman or 0, bot._weights.archer or 0, bot._weights.mage or 0, bot._weights.catapult or 0,
               bot.gold, bot.up))
end

function badBotAI:Tick(bot, MAX_UNITS)
    bot._MAX_UNITS = MAX_UNITS
    bot._wave = bot._wave + 1

    -- Доход за волну
    local goldInc = IncomeGoldForWave(bot)
    local upInc   = IncomeUPForWave(bot)
    if bot._wave > 1 then
        bot.gold = bot.gold + goldInc
        bot.up   = bot.up   + upInc
        debug(bot, ("INCOME wave=%d: +Gold=%d, +UP=%d => Gold=%d, UP=%d"):
            format(bot._wave, goldInc, upInc, bot.gold, bot.up))
    else
        debug(bot, ("START wave=%d: Gold=%d, UP=%d"):format(bot._wave, bot.gold, bot.up))
    end

    -- Фаза — управляет балансом «покупка юнитов vs апы»
    local phase = clamp(bot._wave / CFG.WAVES_TO_STRONG_UPS, 0, 1)
    local chanceExtraUp = (CFG.SMARTNESS[bot.difficulty] or 0.6) * (0.35 + 0.65 * phase)
    local needUnits = wantBuyMoreUnits(bot, MAX_UNITS)

    -- === 1) Сначала, если отстаём от плана, добираем юниты (можно несколько за тик)
    if needUnits then
        local bought = tryBuyUnits(bot, MAX_UNITS)
        if not bought then
            debug(bot, "No unit bought (insufficient Gold or stack full).")
        end
    end

    -- === 2) Всегда пытаемся развить эволюцию (класс/подкласс), если хватает UP
    -- (не блокирует дальнейшие действия)
    local evolved = tryDevelopEvolution(bot)

    -- === 3) Тратим все доступные UP, пока есть что апать
	local anyUp = false
	while bot.up > 0 do
		-- если можем взять класс или подкласс — приоритет
		if tryDevelopEvolution(bot) then
			anyUp = true
		else
			-- если эволюции не вышло, пробуем апгрейды
			if tryDoUpgrades(bot) then
				anyUp = true
			else
				break
			end
		end
	end
	if not anyUp then
		debug(bot, "No upgrades possible now (or saving UP for evolution).")
	end

    -- === 4) Дополнительные покупки юнитов даже если лимит «по плану» достигнут:
    -- на высоких сложностях/позже по времени бот активнее докупает
    if math.random() < chanceExtraUp then
        tryBuyUnits(bot, MAX_UNITS)
    end

    debug(bot, ("STATE: units=%d/%d, Gold=%d, UP=%d"):
        format(#bot.units, MAX_UNITS, bot.gold, bot.up))
end

return badBotAI
