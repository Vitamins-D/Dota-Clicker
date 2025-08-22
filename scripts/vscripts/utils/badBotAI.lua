-- badBotAI.lua
-- ИИ для бота волн: экономика, стратегии, покупка юнитов, классы/подклассы и апгрейды.
-- Требует wi (utils/wavesInfo) и предполагает структуру badBot, аналогичную player у wa:InitAddon

if badBotAI == nil then
    badBotAI = class({})
end

local wi    = require("utils/wavesInfo")

--------------------------------------------------------------------------------
-- НАСТРОЙКИ (легко редактировать)
--------------------------------------------------------------------------------

local CFG = {
    BASE_GOLD_PER_WAVE = 500,    -- при 1 игроке и обычной сложности должно быть 500 (см. множители ниже)

    -- Соответствие текстовых уровней сложности → мультипликатор дохода
    -- "обычная"  → 1.0
    -- "сложная"  → 1.3
    -- "очень сложная" → 1.6
    DIFFICULTY_MULT = {1, 1.25, 1.5},

    -- Как ИИ распределяет приоритет юнитов по стратегиям
    STRATEGY_WEIGHTS = {
        mages_focus   = { mage = 0.5,  swordsman = 0.2, archer = 0.15, catapult = 0.15 },
        archers_focus = { mage = 0.15, swordsman = 0.2, archer = 0.5,  catapult = 0.15 },
        balanced      = { mage = 0.25, swordsman = 0.25, archer = 0.25, catapult = 0.25 },
        siege_focus   = { mage = 0.15, swordsman = 0.15, archer = 0.2,  catapult = 0.5  },
    },

    -- Порог «мало юнитов» — приоритет на покупку новых
    LOW_UNITS_THRESHOLD = 0.25,  -- если меньше 70% от лимита, бот старается добрать стак юнитов

    -- Поведение по сложности:
    --  * чем выше сложность, тем больше шанс предпочесть «умный» апгрейд, а не просто штамп юнитов
    SMARTNESS = {0.5, 0.6, 0.75},

    -- Сколько максимум разных «билдов» рассматривать при старте (разнообразие)
    STRATEGY_POOL = { "mages_focus", "archers_focus", "balanced", "siege_focus" },
}

--------------------------------------------------------------------------------
-- УТИЛИТЫ
--------------------------------------------------------------------------------

local function rnd(min, max)
    if RandomInt then
        return RandomInt(min, max)
    else
        return math.random(min, max)
    end
end

local function chooseWeighted(weightsTbl)
    -- weightsTbl: {key=weight}
    local sum = 0
    for _, w in pairs(weightsTbl) do sum = sum + w end
    local r = (RandomFloat and RandomFloat(0, sum)) or (math.random() * sum)
    local acc = 0
    for k, w in pairs(weightsTbl) do
        acc = acc + w
        if r <= acc then
            return k
        end
    end
    -- fallback
    for k, _ in pairs(weightsTbl) do
        return k
    end
end

local function clamp(v, a, b)
    if v < a then return a end
    if v > b then return b end
    return v
end

local function ensureUpgradeSlots(bot, unitType)
    -- гарантируем, что в bot.upgrades есть нужная структура для unitType
    if not bot.upgrades[unitType] then
        -- формат, как в wa:InitAddon
        bot.upgrades[unitType] = {
            {type = "base", levels = {0, 0, 0}},
            {type = "class", levels = {0, 0, 0}},
            {type = "sub",   levels = {0}},
            nil, -- [4] выбранный класс (string)
            nil, -- [5] выбранный подкласс (string)
        }
    else
        -- расширяем уровни, если в wi появилось больше апгрейдов
        local baseArr = wi.base[unitType]
        if baseArr then
            local want = #baseArr
            local have = #bot.upgrades[unitType][1].levels
            for i = have+1, want do
                table.insert(bot.upgrades[unitType][1].levels, 0)
            end
        end
        local classChosen = bot.upgrades[unitType][4]
        if classChosen and wi.classes[classChosen] then
            local want = #wi.classes[classChosen]
            local have = #bot.upgrades[unitType][2].levels
            for i = have+1, want do
                table.insert(bot.upgrades[unitType][2].levels, 0)
            end
        end
        local subChosen = bot.upgrades[unitType][5]
        if subChosen and wi.subClasses[subChosen] then
            local want = #wi.subClasses[subChosen]
            local have = #bot.upgrades[unitType][3].levels
            for i = have+1, want do
                table.insert(bot.upgrades[unitType][3].levels, 0)
            end
        end
    end
end

local function getUnitCost(unitType)
    local data = wi.base[unitType]
    if data and data.cost then return data.cost end
    -- если в структуре нет cost сверху, можно безопасно fallback к 300
    return 300
end

local function getClassCandidates(baseUnit)
    -- по строке wi.unitNames берём классы (2 и 3 элементы)
    local classes = {}
    for _, row in ipairs(wi.unitNames) do
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
    -- пройдём все субклассы и проверим requirement.class
    for subName, req in pairs(wi.requirement) do
        if req.class and req.class == classChosen then
            -- и этот subName должен принадлежать этому baseUnit
            if wi:getUnitName(subName) == baseUnit and wi.subClasses[subName] then
                table.insert(subs, subName)
            end
        end
    end
    return subs
end

local function findUpgradeIndex(arrayWithUpgrades, typeName)
    -- ищет индекс апгрейда с данным type в массиве
    for i, upg in ipairs(arrayWithUpgrades or {}) do
        if upg.type == typeName then return i end
    end
    return nil
end

local function currentLevelOf(bot, baseUnit, scope, upgradeType)
    -- scope: "base" | "class" | "sub"
    ensureUpgradeSlots(bot, baseUnit)
    local pack = bot.upgrades[baseUnit]
    local levelArr = nil
    if scope == "base" then
        local idx = findUpgradeIndex(wi.base[baseUnit], upgradeType)
        if not idx then return 0 end
        levelArr = pack[1].levels
        return levelArr[idx] or 0
    elseif scope == "class" then
        local classChosen = pack[4]
        if not classChosen then return 0 end
        local idx = findUpgradeIndex(wi.classes[classChosen], upgradeType)
        if not idx then return 0 end
        levelArr = pack[2].levels
        return levelArr[idx] or 0
    elseif scope == "sub" then
        local subChosen = pack[5]
        if not subChosen then return 0 end
        local idx = findUpgradeIndex(wi.subClasses[subChosen], upgradeType)
        if not idx then return 0 end
        levelArr = pack[3].levels
        return levelArr[idx] or 0
    end
    return 0
end

local function maxLevelOf(baseUnit, scope, ownerName, upgradeType)
    -- ownerName: для base — baseUnit; для class — имя класса; для sub — имя подкласса
    if scope == "base" then
        local arr = wi.base[baseUnit]
        local idx = findUpgradeIndex(arr, upgradeType)
        if idx and arr[idx] then return #arr[idx].levels end
        return 0
    elseif scope == "class" then
        local arr = wi.classes[ownerName]
        local idx = findUpgradeIndex(arr, upgradeType)
        if idx and arr[idx] then return #arr[idx].levels end
        return 0
    elseif scope == "sub" then
        local arr = wi.subClasses[ownerName]
        local idx = findUpgradeIndex(arr, upgradeType)
        if idx and arr[idx] then return #arr[idx].levels end
        return 0
    end
    return 0
end

local function nextUpgradeCost(baseUnit, scope, ownerName, upgradeType, levelNext)
    if scope == "base" then
        local idx = findUpgradeIndex(wi.base[baseUnit], upgradeType)
        if idx then return wi.base[baseUnit][idx].levels[levelNext].cost or 300 end
    elseif scope == "class" then
        local idx = findUpgradeIndex(wi.classes[ownerName], upgradeType)
        if idx then return wi.classes[ownerName][idx].levels[levelNext].cost or 300 end
    elseif scope == "sub" then
        local idx = findUpgradeIndex(wi.subClasses[ownerName], upgradeType)
        if idx then return wi.subClasses[ownerName][idx].levels[levelNext].cost or 300 end
    end
    return 300
end

local function canAfford(bot, cost) return bot.gold >= cost end
local function pay(bot, cost) bot.gold = bot.gold - cost end

local function debug(bot, text)
    print(("[BOT %s] %s"):format(bot.name or "AI", text))
end

--------------------------------------------------------------------------------
-- ПОКУПКИ
--------------------------------------------------------------------------------

local function buyUnit(bot, unitType)
    ensureUpgradeSlots(bot, unitType)
    local cost = getUnitCost(unitType)
    if not canAfford(bot, cost) then return false end
    if bot._MAX_UNITS and #bot.units >= bot._MAX_UNITS then return false end

    table.insert(bot.units, unitType)
    pay(bot, cost)
    debug(bot, ("Куплен юнит: %s за %d. Остаток золота: %d"):format(unitType, cost, bot.gold))
    return true
end

local function requirementsMetForClass(bot, baseUnit, className)
    local req = wi.requirement[className]
    if not req then return true end
    if req.upgs then
        for _, tup in ipairs(req.upgs) do
            local upName, needLvl = tup[1], tup[2]
            local cur = currentLevelOf(bot, baseUnit, "base", upName)
            if cur < needLvl then
                return false
            end
        end
    end
    return true
end

local function requirementsMetForSubclass(bot, baseUnit, className, subName)
    -- Должен быть выбран нужный класс и у него выполнены апгрейды
    local req = wi.requirement[subName]
    if not req then return true end
    if req.class and req.class ~= className then
        return false
    end
    if req.upgs then
        for _, tup in ipairs(req.upgs) do
            local upName, needLvl = tup[1], tup[2]
            local cur = currentLevelOf(bot, baseUnit, "class", upName)
            if cur < needLvl then
                return false
            end
        end
    end
    return true
end

local function classCost(className)
    local arr = wi.classes[className]
    if arr and wi.classes[className].cost then
        return wi.classes[className].cost
    end
    -- fallback (редко): средняя стоимость первого апа
    if arr and arr[1] and arr[1].levels and arr[1].levels[1] then
        return arr[1].levels[1].cost or 700
    end
    return 700
end

local function subCost(subName)
    local arr = wi.subClasses[subName]
    if arr and wi.subClasses[subName].cost then
        return wi.subClasses[subName].cost
    end
    if arr and arr[1] and arr[1].levels and arr[1].levels[1] then
        return arr[1].levels[1].cost or 700
    end
    return 700
end

local function buyClass(bot, baseUnit, className)
    ensureUpgradeSlots(bot, baseUnit)
    local cost = classCost(className)
    if not canAfford(bot, cost) then return false end
    if not requirementsMetForClass(bot, baseUnit, className) then return false end

    bot.upgrades[baseUnit][4] = className
    -- Инициализируем массив уровней под класс
    bot.upgrades[baseUnit][2].levels = {}
    local wanted = #wi.classes[className]
    for i = 1, wanted do bot.upgrades[baseUnit][2].levels[i] = 0 end
    pay(bot, cost)
    debug(bot, ("Взят КЛАСС %s для %s за %d. Остаток золота: %d"):format(className, baseUnit, cost, bot.gold))
    return true
end

local function buySubclass(bot, baseUnit, subName)
    ensureUpgradeSlots(bot, baseUnit)
    local classChosen = bot.upgrades[baseUnit][4]
    if not classChosen then return false end
    if not requirementsMetForSubclass(bot, baseUnit, classChosen, subName) then return false end

    local cost = subCost(subName)
    if not canAfford(bot, cost) then return false end

    bot.upgrades[baseUnit][5] = subName
    bot.upgrades[baseUnit][3].levels = {}
    local wanted = #wi.subClasses[subName]
    for i = 1, wanted do bot.upgrades[baseUnit][3].levels[i] = 0 end
    pay(bot, cost)
    debug(bot, ("Взят ПОДКЛАСС %s для %s за %d. Остаток золота: %d"):format(subName, baseUnit, cost, bot.gold))
    return true
end

local function buyNextUpgrade(bot, baseUnit, scope)
    ensureUpgradeSlots(bot, baseUnit)
    local pack = bot.upgrades[baseUnit]

    if scope == "base" then
        local arr = wi.base[baseUnit]
        if not arr then return false end
        -- соберём список апгрейдов, где не достигнут макс. уровень
        local candidates = {}
        for i, upg in ipairs(arr) do
            local cur = pack[1].levels[i] or 0
            local max = #upg.levels
            if cur < max then
                table.insert(candidates, {i=i, upg=upg})
            end
        end
        if #candidates == 0 then return false end
        local pick = candidates[rnd(1, #candidates)]
        local nextLevel = (pack[1].levels[pick.i] or 0) + 1
        local cost = pick.upg.levels[nextLevel].cost or 300
        if not canAfford(bot, cost) then return false end
        pack[1].levels[pick.i] = nextLevel
        pay(bot, cost)
        debug(bot, ("БАЗОВЫЙ апгрейд %s(%d/%d) для %s за %d. Остаток золота: %d"):
            format(pick.upg.type, nextLevel, #pick.upg.levels, baseUnit, cost, bot.gold))
        return true

    elseif scope == "class" then
        local classChosen = pack[4]
        if not classChosen then return false end
        local arr = wi.classes[classChosen]
        local candidates = {}
        for i, upg in ipairs(arr) do
            local cur = pack[2].levels[i] or 0
            local max = #upg.levels
            if cur < max then
                table.insert(candidates, {i=i, upg=upg})
            end
        end
        if #candidates == 0 then return false end
        local pick = candidates[rnd(1, #candidates)]
        local nextLevel = (pack[2].levels[pick.i] or 0) + 1
        local cost = pick.upg.levels[nextLevel].cost or 300
        if not canAfford(bot, cost) then return false end
        pack[2].levels[pick.i] = nextLevel
        pay(bot, cost)
        debug(bot, ("КЛАССОВЫЙ апгрейд %s(%d/%d) [%s] для %s за %d. Остаток золота: %d"):
            format(pick.upg.type, nextLevel, #pick.upg.levels, classChosen, baseUnit, cost, bot.gold))
        return true

    elseif scope == "sub" then
        local subChosen = pack[5]
        if not subChosen then return false end
        local arr = wi.subClasses[subChosen]
        local candidates = {}
        for i, upg in ipairs(arr) do
            local cur = pack[3].levels[i] or 0
            local max = #upg.levels
            if cur < max then
                table.insert(candidates, {i=i, upg=upg})
            end
        end
        if #candidates == 0 then return false end
        local pick = candidates[rnd(1, #candidates)]
        local nextLevel = (pack[3].levels[pick.i] or 0) + 1
        local cost = pick.upg.levels[nextLevel].cost or 300
        if not canAfford(bot, cost) then return false end
        pack[3].levels[pick.i] = nextLevel
        pay(bot, cost)
        debug(bot, ("ПОДКЛАСС апгрейд %s(%d/%d) [%s] для %s за %d. Остаток золота: %d"):
            format(pick.upg.type, nextLevel, #pick.upg.levels, subChosen, baseUnit, cost, bot.gold))
        return true
    end
    return false
end

--------------------------------------------------------------------------------
-- РЕШЕНИЕ ДЕЙСТВИЙ
--------------------------------------------------------------------------------

local function wantBuyUnits(bot, MAX_UNITS)
    local cur = #bot.units
    local thresh = math.floor(MAX_UNITS * CFG.LOW_UNITS_THRESHOLD + 0.5)
    return cur < thresh
end

local function pickUnitTypeForStrategy(bot)
    local w = CFG.STRATEGY_WEIGHTS[bot.strategy] or CFG.STRATEGY_WEIGHTS.balanced
    return chooseWeighted(w)
end

local function tryDevelopEvolution(bot)
    -- пытаемся продвинуться по эволюции (класс/подкласс) у одного из базовых типов, которые уже есть или планируются
    -- Приоритет: под текущую стратегию
    local candidates = { "swordsman", "archer", "mage", "catapult" }
    -- слегка перемешаем приоритет согласно весам
    table.sort(candidates, function(a,b)
        local w = CFG.STRATEGY_WEIGHTS[bot.strategy] or CFG.STRATEGY_WEIGHTS.balanced
        return (w[a] or 0) > (w[b] or 0)
    end)

    for _, baseUnit in ipairs(candidates) do
        ensureUpgradeSlots(bot, baseUnit)
        local pack = bot.upgrades[baseUnit]
        -- 1) если класса нет — попробовать взять класс, если требования выполнены
        if not pack[4] then
            local cls = getClassCandidates(baseUnit)
            -- лёгкая «уникальность»: случайно выбрать из подходящих
            if #cls > 0 then
                -- Сначала отфильтруем выполнимые по требованиям
                local pool = {}
                for _, c in ipairs(cls) do
                    if requirementsMetForClass(bot, baseUnit, c) then table.insert(pool, c) end
                end
                if #pool > 0 then
                    local pick = pool[rnd(1, #pool)]
                    if buyClass(bot, baseUnit, pick) then
                        return true
                    end
                end
            end
        else
            -- 2) класс есть — попробуем взять подкласс (если ещё нет)
            if not pack[5] then
                local subs = getSubclassCandidates(baseUnit, pack[4])
                if #subs > 0 then
                    -- выполнимые
                    local pool = {}
                    for _, s in ipairs(subs) do
                        if requirementsMetForSubclass(bot, baseUnit, pack[4], s) then
                            table.insert(pool, s)
                        end
                    end
                    if #pool > 0 then
                        local pick = pool[rnd(1, #pool)]
                        if buySubclass(bot, baseUnit, pick) then
                            return true
                        end
                    end
                end
            end
        end
    end
    return false
end

local function tryDoUpgrades(bot)
    -- чередуем базовые/классовые/подклассовые апгрейды «умно»
    -- Выберем приоритетную базу под стратегию
    local bases = { "swordsman", "archer", "mage", "catapult" }
    table.sort(bases, function(a,b)
        local w = CFG.STRATEGY_WEIGHTS[bot.strategy] or CFG.STRATEGY_WEIGHTS.balanced
        return (w[a] or 0) > (w[b] or 0)
    end)

    -- Сформируем список возможных целей апгрейда по убыванию «важности»
    local scopesOrder = { "sub", "class", "base" }  -- если есть субкласс — чаще апаем суб; затем класс; затем база

    for _, base in ipairs(bases) do
        ensureUpgradeSlots(bot, base)
        for _, scope in ipairs(scopesOrder) do
            if buyNextUpgrade(bot, base, scope) then
                return true
            end
        end
    end

    -- если ничего не получилось по приоритетам, попробуем любой доступный базовый апгрейд
    for _, base in ipairs(bases) do
        if buyNextUpgrade(bot, base, "base") then
            return true
        end
    end

    return false
end

local function tryBuyUnits(bot, MAX_UNITS)
    -- покупаем юниты по весам стратегии, пока можем и есть места
    local attempts = 3
    while attempts > 0 do
        attempts = attempts - 1
        if bot._MAX_UNITS and #bot.units >= bot._MAX_UNITS then return false end
        local t = pickUnitTypeForStrategy(bot)
        local ok = buyUnit(bot, t)
        if ok then return true end
    end
    return false
end

--------------------------------------------------------------------------------
-- ПУБЛИЧНЫЕ ФУНКЦИИ
--------------------------------------------------------------------------------

function badBotAI:Init(bot, params)
    bot.name       = (bot.name or "AI")
    bot.units      = bot.units or {}
    bot.upgrades   = bot.upgrades or {
        ["swordsman"] = { {type="base", levels={0,0,0}}, {type="class", levels={0,0,0}}, {type="sub", levels={0}}, nil, nil },
        ["archer"]    = { {type="base", levels={0,0,0}}, {type="class", levels={0,0,0}}, {type="sub", levels={0}}, nil, nil },
        ["mage"]      = { {type="base", levels={0,0,0}}, {type="class", levels={0,0,0}}, {type="sub", levels={0}}, nil, nil },
        ["catapult"]  = { {type="base", levels={0,0,0}}, {type="class", levels={0,0,0}}, {type="sub", levels={0}}, nil, nil },
    }
    bot.gold       = bot.gold or 0
    bot.players    = clamp(tonumber(params.players or 1) or 1, 1, 10)

    -- поддерживаем русские и английские варианты сложности
    local diff = (params.difficulty or 1)
    if not CFG.DIFFICULTY_MULT[diff] then diff = 1 end
    bot.difficulty = diff

    -- выберем стратегию «случайно» из пула
    local pool = CFG.STRATEGY_POOL
    bot.strategy = pool[rnd(1, #pool)]
	bot._wave = 0

    debug(bot, ("Инициализация. Сложность: %s, Игроков: %d, Стратегия: %s"):format(bot.difficulty, bot.players, bot.strategy))
end

function badBotAI.IncomeForWave(bot)
    local mult = CFG.DIFFICULTY_MULT[bot.difficulty] or 1.0
    -- более чем в 1 игрок усиливаем доход линейно, как ты просил
    local gold = math.floor(CFG.BASE_GOLD_PER_WAVE * mult * bot.players)
    return gold
end

function badBotAI:Tick(bot, MAX_UNITS)
    -- запоминаем лимит, чтобы проверки покупки знали верхнюю границу
    bot._MAX_UNITS = MAX_UNITS
	bot._wave = bot._wave + 1

    -- выдаём доход
	if bot._wave > 1 then
		local income = badBotAI.IncomeForWave(bot)
		bot.gold = bot.gold + income
		debug(bot, ("Доход за волну: +%d золота. Сейчас золота: %d"):format(income, bot.gold))
	end

    -- высокоуровневая логика:
    -- 1) если мало юнитов, добираем стак
    -- 2) если юнитов достаточно — пытаемся взять класс/подкласс (если доступны)
    -- 3) если есть класс/подкласс — чередуем апгрейды
    -- 4) иногда, в зависимости от «умности», всё равно купим ещё юниты (разнообразие)

    local needUnits = wantBuyUnits(bot, MAX_UNITS)
    local smartChance = CFG.SMARTNESS[bot.difficulty] or 0.45

    if needUnits then
        -- приоритет добрать юниты
        local bought = true
        local guard = 8
        while bought and guard > 0 do
            guard = guard - 1
            bought = tryBuyUnits(bot, MAX_UNITS)
        end
    else
        -- развиваем эволюции (класс/подкласс), если можем
        local evolved = tryDevelopEvolution(bot)

        -- чередуем апгрейды
        if not evolved or math.random() < 0.65 then
            local upgraded = tryDoUpgrades(bot)
            if not upgraded then
                -- если апать нечего — купим юнит
                tryBuyUnits(bot, MAX_UNITS)
            end
        end

        -- на высоких сложностях ИИ чаще докупает юниты дополнительно
        if math.random() < smartChance then
            tryBuyUnits(bot, MAX_UNITS)
        end
    end

    -- финальный лог состояния
    debug(bot, ("Итого: юнитов= %d / %d, золото= %d"):format(#bot.units, MAX_UNITS, bot.gold))
end

return badBotAI
