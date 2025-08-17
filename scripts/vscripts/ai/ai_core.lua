AICore = {}

function AICore:getEnemies(radius, tEntity, minDist)
	local enemies = FindUnitsInRadius(
        tEntity:GetTeamNumber(),
        tEntity:GetOrigin(),
        nil,
        radius,
        DOTA_UNIT_TARGET_TEAM_ENEMY,
        DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_CREEP, -- Все юниты кроме построек
        DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE,
        FIND_CLOSEST,
        false
    )
	if minDist then -- Исправлена опечатка: было minRad, должно быть minDist
		for i = #enemies, 1, -1 do
			local enemy = enemies[i]
			local distance = (tEntity:GetAbsOrigin() - enemy:GetAbsOrigin()):Length()
			if distance < minDist then
				table.remove(enemies, i)
			end
		end
	end
	return enemies
end

function AICore:getAllEnemies(radius, tEntity, minDist)
	local enemies = FindUnitsInRadius(
        tEntity:GetTeamNumber(),
        tEntity:GetOrigin(),
        nil,
        radius,
        DOTA_UNIT_TARGET_TEAM_ENEMY,
        DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_CREEP, -- Все юниты кроме построек
        DOTA_UNIT_TARGET_FLAG_NONE,
        FIND_CLOSEST,
        false
    )
	if minDist then -- Исправлена опечатка: было minRad, должно быть minDist
		for i = #enemies, 1, -1 do
			local enemy = enemies[i]
			local distance = (tEntity:GetAbsOrigin() - enemy:GetAbsOrigin()):Length()
			if distance < minDist then
				table.remove(enemies, i)
			end
		end
	end
	return enemies
end

function AICore:getAllies(radius, tEntity)
	local allies = FindUnitsInRadius( -- Переименована переменная: было enemies, теперь allies
        tEntity:GetTeamNumber(),
        tEntity:GetOrigin(),
        nil,
        radius,
        DOTA_UNIT_TARGET_TEAM_FRIENDLY,
		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_CREEP, -- Добавлены герои и крипы
        DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE,
        FIND_CLOSEST,
        false
    )
	return allies
end