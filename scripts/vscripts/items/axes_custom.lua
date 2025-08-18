--==========Axes Custom==========--
-- Wood Axe
item_dotac_axe_wood = class({})
LinkLuaModifier("modifier_item_axe", "items/axes_custom", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_axe_bleed", "items/axes_custom", LUA_MODIFIER_MOTION_NONE)

function item_dotac_axe_wood:GetIntrinsicModifierName()
	return "modifier_item_axe"
end

function item_dotac_axe_wood:OnSpellStart()
	local caster = self:GetCaster()
	local target_point = self:GetCursorPosition()
	
	-- Звук завершения рубки
	EmitSoundOn("Hero_Timbersaw.Chakram.Impact", caster)
	
	-- Срубаем дерево
	GridNav:DestroyTreesAroundPoint(target_point, 50, false)
	
	-- Эффект частиц при рубке
	local tree_pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_furion/furion_force_of_nature_damage.vpcf", PATTACH_WORLDORIGIN, nil)
	ParticleManager:SetParticleControl(tree_pfx, 0, target_point)
	ParticleManager:ReleaseParticleIndex(tree_pfx)
end

function item_dotac_axe_wood:OnChannelStart()
	local caster = self:GetCaster()
	
	-- Анимация рубки дерева
	caster:StartGesture(ACT_DOTA_ATTACK)
	
	-- Звук рубки
	EmitSoundOn("Hero_Furion.ForceOfNature_Damage", caster)
end

-- Stone Axe
item_dotac_axe_stone = item_dotac_axe_wood or class({})
function item_dotac_axe_stone:GetIntrinsicModifierName()
	return "modifier_item_axe"
end

-- Iron Axe
item_dotac_axe_iron = item_dotac_axe_wood or class({})
function item_dotac_axe_iron:GetIntrinsicModifierName()
	return "modifier_item_axe"
end

-- Diamond Axe
item_dotac_axe_diamond = item_dotac_axe_wood or class({})
function item_dotac_axe_diamond:GetIntrinsicModifierName()
	return "modifier_item_axe"
end

-- Netherite Axe
item_dotac_axe_netherite = item_dotac_axe_wood or class({})
function item_dotac_axe_netherite:GetIntrinsicModifierName()
	return "modifier_item_axe"
end

--====================================--
modifier_item_axe = class({})

function modifier_item_axe:IsDebuff() return false end
function modifier_item_axe:IsHidden() return true end
function modifier_item_axe:IsPurgable() return false end
function modifier_item_axe:GetAttributes() return MODIFIER_ATTRIBUTE_PERMANENT + MODIFIER_ATTRIBUTE_MULTIPLE + MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE end

function modifier_item_axe:DeclareFunctions()
	if IsServer() then
		return {
			MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
			MODIFIER_PROPERTY_PROCATTACK_FEEDBACK
		}
	else
		return {
			MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE
		}
	end
end

function modifier_item_axe:OnCreated()
	local ability = self:GetAbility()
	
	self.bonus_damage = ability:GetSpecialValueFor("bonus_damage") or 0
	self.bleed_chance = ability:GetSpecialValueFor("bleed_chance") or 0
	self.bleed_damage = ability:GetSpecialValueFor("bleed_damage") or 0
	self.bleed_duration = ability:GetSpecialValueFor("bleed_duration") or 0
end

function modifier_item_axe:GetModifierPreAttack_BonusDamage() 
	return self.bonus_damage 
end

if not IsServer() then return end

function modifier_item_axe:GetModifierProcAttack_Feedback(keys)
	if not keys.attacker:IsRealHero() then return end
	if keys.attacker:GetTeam() == keys.target:GetTeam() then return end
	if keys.target:IsBuilding() then return end
	
	-- Проверяем шанс кровотечения
	if RandomFloat(0, 100) <= self.bleed_chance then
		-- Применяем кровотечение
		keys.target:AddNewModifier(keys.attacker, self:GetAbility(), "modifier_axe_bleed", {
			duration = self.bleed_duration,
			bleed_damage = self.bleed_damage
		})
		
		-- Звуковой эффект при наложении кровотечения
		EmitSoundOn("Hero_Bloodseeker.Rupture", keys.target)
	end
end

--====================================--
-- Модификатор кровотечения (аналог Rupture)
modifier_axe_bleed = class({})

function modifier_axe_bleed:IsDebuff() return true end
function modifier_axe_bleed:IsHidden() return false end
function modifier_axe_bleed:IsPurgable() return true end
function modifier_axe_bleed:GetTexture() return "bloodseeker_rupture" end

function modifier_axe_bleed:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_OVERRIDE_ANIMATION
	}
end

function modifier_axe_bleed:GetOverrideAnimation()
	return ACT_DOTA_GENERIC_CHANNEL_1
end

function modifier_axe_bleed:OnCreated(kv)
	if not IsServer() then return end
	
	self.bleed_damage = kv.bleed_damage or 5
	self.last_position = self:GetParent():GetAbsOrigin()
	
	-- Создаем основной эффект кровотечения вручную
	self.rupture_pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_bloodseeker/bloodseeker_rupture.vpcf", PATTACH_OVERHEAD_FOLLOW, self:GetParent())
	
	self:StartIntervalThink(0.1)
end

function modifier_axe_bleed:OnDestroy()
	if not IsServer() then return end
	
	-- Принудительно удаляем все эффекты
	if self.rupture_pfx then
		ParticleManager:DestroyParticle(self.rupture_pfx, false)
		ParticleManager:ReleaseParticleIndex(self.rupture_pfx)
		self.rupture_pfx = nil
	end
	
	-- Останавливаем все звуки
	StopSoundOn("Hero_Bloodseeker.Rupture.Cast", self:GetParent())
	StopSoundOn("Hero_Bloodseeker.Rupture", self:GetParent())
end

function modifier_axe_bleed:OnIntervalThink()
	if not IsServer() then return end
	
	local parent = self:GetParent()
	local current_position = parent:GetAbsOrigin()
	
	-- Вычисляем расстояние, которое прошел юнит
	local distance = (current_position - self.last_position):Length2D()
	
	if distance > 0 then
		-- Наносим урон пропорционально пройденному расстоянию
		local damage = self.bleed_damage * (distance / 100) -- урон за каждые 100 единиц
		
		local damage_table = {
			victim = parent,
			attacker = self:GetCaster(),
			damage = damage,
			damage_type = DAMAGE_TYPE_PURE,
			ability = self:GetAbility(),
		}
		
		ApplyDamage(damage_table)
		
		-- Эффект крови при движении
		local blood_impact_pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_bloodseeker/bloodseeker_rupture_hit.vpcf", PATTACH_WORLDORIGIN, nil)
		ParticleManager:SetParticleControl(blood_impact_pfx, 0, current_position)
		ParticleManager:ReleaseParticleIndex(blood_impact_pfx)
	end
	
	self.last_position = current_position
end

-- Убираем GetEffectName и GetEffectAttachType, чтобы не было дублирования эффектов