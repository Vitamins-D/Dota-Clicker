itemCore = {}
require('ai/ai_core')

function bladeMail(prms)
	local thisEntity = prms.thisEntity
	local hitem = prms.item
	
	if not hitem or not hitem:IsFullyCastable() then
		return
	end
	
	local enemies = AICore:getEnemies(600, thisEntity)
	
	if enemies and #enemies > 0 then
		thisEntity:CastAbilityNoTarget(hitem, -1)
		return
	end
end

function roshanHarpoon(prms)
	local thisEntity = prms.thisEntity
	local hitem = prms.item
	
	if not hitem or not hitem:IsFullyCastable() then
		return
	end
	
	-- Получаем радиус применения предмета (обычно 700 для harpoon)
	local castRange = hitem:GetCastRange(hitem:GetAbsOrigin(), nil)
	local enemies = AICore:getEnemies(castRange, thisEntity)
	
	if enemies and #enemies > 0 then
		local lowestHPEnemy = nil
		local lowestHP = math.huge
		
		for _, enemy in ipairs(enemies) do
			local currentHP = enemy:GetHealth()
			if currentHP < lowestHP then
				lowestHP = currentHP
				lowestHPEnemy = enemy
			end
		end
		
		if lowestHPEnemy then
			thisEntity:CastAbilityOnTarget(lowestHPEnemy, hitem, -1)
		end
	end
end

function roshanHurricanePike(prms)
	local thisEntity = prms.thisEntity
	local hitem = prms.item
	
	if not hitem or not hitem:IsFullyCastable() then
		return
	end
	
	local enemies = AICore:getEnemies(250, thisEntity)
	
	if enemies and #enemies > 0 then
		-- Используем на ближайшего врага
		thisEntity:CastAbilityOnTarget(enemies[1], hitem, -1)
		return
	end
end

function roshanGungir(prms)
	local thisEntity = prms.thisEntity
	local hitem = prms.item
	
	if not hitem or not hitem:IsFullyCastable() then
		return
	end
	
	-- Получаем радиус применения предмета
	local castRange = hitem:GetCastRange(hitem:GetAbsOrigin(), nil)
	local enemies = AICore:getEnemies(castRange, thisEntity)
	
	if enemies and #enemies > 0 then
		-- Ищем врага без дебаффа оцепенения (stun)
		for _, enemy in ipairs(enemies) do
			if not enemy:IsStunned() and not enemy:HasModifier("modifier_stunned") then
				thisEntity:CastAbilityOnTarget(enemy, hitem, -1)
				return
			end
		end
	end
end

function roshanArcaneBoots(prms)
	local thisEntity = prms.thisEntity
	local hitem = prms.item
	
	if not hitem or not hitem:IsFullyCastable() then
		return
	end
	
	-- Получаем радиус применения (обычно 1200 для arcane boots)
	local castRange = hitem:GetCastRange(hitem:GetAbsOrigin(), nil) or 1200
	local allies = AICore:getAllies(castRange, thisEntity)
	
	-- Проверяем себя тоже
	table.insert(allies, thisEntity)
	
	for _, ally in ipairs(allies) do
		local currentMana = ally:GetMana()
		local maxMana = ally:GetMaxMana()
		
		if maxMana > 0 and (currentMana / maxMana) < 0.5 then
			thisEntity:CastAbilityNoTarget(hitem, -1)
			return
		end
	end
end

function roshanSheepstick(prms)
	local thisEntity = prms.thisEntity
	local hitem = prms.item
	
	if not hitem or not hitem:IsFullyCastable() then
		return
	end
	
	-- Получаем радиус применения предмета (обычно 800 для scythe)
	local castRange = hitem:GetCastRange(hitem:GetAbsOrigin(), nil)
	local enemies = AICore:getEnemies(castRange, thisEntity)
	
	if enemies and #enemies > 0 then
		local highestDamageEnemy = nil
		local highestDamage = 0
		
		for _, enemy in ipairs(enemies) do
			-- Проверяем, что у врага нет эффекта hex/sheep
			if not enemy:HasModifier("modifier_sheepstick_debuff") and 
			   not enemy:HasModifier("modifier_hex") then
				
				-- Получаем урон врага (базовый + дополнительный)
				local damage = enemy:GetBaseDamageMin() + enemy:GetBaseDamageMax()
				
				if damage > highestDamage then
					highestDamage = damage
					highestDamageEnemy = enemy
				end
			end
		end
		
		if highestDamageEnemy then
			thisEntity:CastAbilityOnTarget(highestDamageEnemy, hitem, -1)
		end
	end
end

function roshanMaskOfMadness(prms)
	local thisEntity = prms.thisEntity
	local hitem = prms.item
	
	if not hitem or not hitem:IsFullyCastable() then
		return
	end
	
	local enemies = AICore:getEnemies(1000, thisEntity)
	
	if enemies and #enemies > 0 then
		thisEntity:CastAbilityNoTarget(hitem, -1)
		return
	end
end

itemCore.pattern = {
	["item_roshan_blade_mail"] = bladeMail,
	["item_roshan_harpoon"] = roshanHarpoon,
	["item_roshan_hurricane_pike"] = roshanHurricanePike,
	["item_roshan_gungir"] = roshanGungir,
	["item_roshan_arcane_boots"] = roshanArcaneBoots,
	["item_roshan_sheepstick"] = roshanSheepstick,
	["item_roshan_mask_of_madness"] = roshanMaskOfMadness,
}

return itemCore