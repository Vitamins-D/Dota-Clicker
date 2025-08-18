--==========Replica Rackatee==========--

item_bfury = class({})

LinkLuaModifier("modifier_item_bfury", "items/battle_fury_custom", LUA_MODIFIER_MOTION_NONE)

function item_bfury:GetIntrinsicModifierName()
	return "modifier_item_bfury"
end

-- Убрана функция OnSpellStart для рубки дерева

--====================================--

modifier_item_bfury = class({})

function modifier_item_bfury:IsDebuff() return false end
function modifier_item_bfury:IsHidden() return true end
function modifier_item_bfury:IsPurgable() return false end
function modifier_item_bfury:GetAttributes() return MODIFIER_ATTRIBUTE_PERMANENT + MODIFIER_ATTRIBUTE_MULTIPLE + MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE end


function modifier_item_bfury:DeclareFunctions()
	if IsServer() then
		return {
			MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
			MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
			MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,
			MODIFIER_PROPERTY_PROCATTACK_FEEDBACK
		}
	else
		return {
			MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
			MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
			MODIFIER_PROPERTY_MANA_REGEN_CONSTANT
		}
	end
end


function modifier_item_bfury:OnCreated()
	local ability = self:GetAbility()
	
	self.bonus_dmg = ability:GetSpecialValueFor("bonus_damage") or 0
	self.health_regen = ability:GetSpecialValueFor("bonus_health_regen") or 0
	self.mana_regen = ability:GetSpecialValueFor("bonus_mana_regen") or 0
	
	-- Убраны переменные для дальности атаки
	self.melee_cleave_dmg = ability:GetSpecialValueFor("melee_cleave_dmg") or 0
	self.range_cleave_dmg = ability:GetSpecialValueFor("range_cleave_dmg") or 0
	self.cleave_radius = ability:GetSpecialValueFor("cleave_radius") or 0
	
	self.effect_last_proc_time = 0
end


function modifier_item_bfury:GetModifierPreAttack_BonusDamage() return self.bonus_dmg end
function modifier_item_bfury:GetModifierConstantHealthRegen() return self.health_regen end
function modifier_item_bfury:GetModifierConstantManaRegen() return self.mana_regen end

-- Убрана функция GetModifierAttackRangeBonusUnique

if not IsServer() then return end

function modifier_item_bfury:GetModifierProcAttack_Feedback(keys)
	if not keys.attacker:IsRealHero() then return end
	if keys.attacker:GetTeam() == keys.target:GetTeam() then return end
	if keys.target:IsBuilding() then return end

	local ability = self:GetAbility()
	local target_loc = keys.target:GetAbsOrigin()
	
	local cleave_pct = self.melee_cleave_dmg
	if self:GetParent():IsRangedAttacker() then
		cleave_pct = self.range_cleave_dmg
	end
	
	if keys.inflictor then
		local inflictor_name = keys.inflictor:GetAbilityName()
		-- Если урон от Tree Volley
		if inflictor_name == "tiny_tree_channel" then
			-- Дополнительная логика для Tree Volley (если нужна)
			cleave_pct = cleave_pct/3
		end
	end

	local damage = keys.original_damage * cleave_pct * 0.01

	-- Эффект частицы при срабатывании (не чаще чем раз в 200 мс)
	local current_time = GetSystemTimeMS()
	if current_time - self.effect_last_proc_time > 200 then
		self.effect_last_proc_time = current_time
		local blast_pfx = ParticleManager:CreateParticle("particles/custom/shrapnel.vpcf", PATTACH_CUSTOMORIGIN, nil)
		ParticleManager:SetParticleControl(blast_pfx, 0, target_loc)
		ParticleManager:ReleaseParticleIndex(blast_pfx)
	end

	-- Поиск и нанесение урона всем врагам в радиусе
	local enemies = FindUnitsInRadius(
		keys.attacker:GetTeamNumber(),
		target_loc,
		nil,
		self.cleave_radius,
		ability:GetAbilityTargetTeam(),
		ability:GetAbilityTargetType(),
		ability:GetAbilityTargetFlags(),
		FIND_ANY_ORDER,
		false
	)
	for _, enemy in pairs(enemies) do
		if enemy ~= keys.target then
			ApplyDamage({
				victim 			= enemy,
				attacker 		= keys.attacker,
				damage 			= damage,
				damage_type 	= ability:GetAbilityDamageType(),
				damage_flags 	= DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION,
				ability 		= ability,
			})
		end
	end
end