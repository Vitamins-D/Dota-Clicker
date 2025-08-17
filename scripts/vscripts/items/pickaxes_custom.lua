--==========Pickaxes Custom==========--

-- Wood Pickaxe
item_dotac_pickaxe_wood = class({})
LinkLuaModifier("modifier_item_pickaxe", "items/pickaxes_custom", LUA_MODIFIER_MOTION_NONE)

function item_dotac_pickaxe_wood:GetIntrinsicModifierName()
	return "modifier_item_pickaxe"
end

-- Stone Pickaxe
item_dotac_pickaxe_stone = item_dotac_pickaxe_wood or class({})

function item_dotac_pickaxe_stone:GetIntrinsicModifierName()
	return "modifier_item_pickaxe"
end

-- Iron Pickaxe
item_dotac_pickaxe_iron = item_dotac_pickaxe_wood or class({})

function item_dotac_pickaxe_iron:GetIntrinsicModifierName()
	return "modifier_item_pickaxe"
end

-- Diamond Pickaxe
item_dotac_pickaxe_diamond = item_dotac_pickaxe_wood or class({})

function item_dotac_pickaxe_diamond:GetIntrinsicModifierName()
	return "modifier_item_pickaxe"
end

-- Netherite Pickaxe
item_dotac_pickaxe_netherite = item_dotac_pickaxe_wood or class({})

function item_dotac_pickaxe_netherite:GetIntrinsicModifierName()
	return "modifier_item_pickaxe"
end

--====================================--

modifier_item_pickaxe = class({})

function modifier_item_pickaxe:IsDebuff() return false end
function modifier_item_pickaxe:IsHidden() return true end
function modifier_item_pickaxe:IsPurgable() return false end
function modifier_item_pickaxe:GetAttributes() return MODIFIER_ATTRIBUTE_PERMANENT + MODIFIER_ATTRIBUTE_MULTIPLE + MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE end

function modifier_item_pickaxe:DeclareFunctions()
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

function modifier_item_pickaxe:OnCreated()
	local ability = self:GetAbility()
	
	self.bonus_damage = ability:GetSpecialValueFor("bonus_damage") or 0
	self.stun_chance = ability:GetSpecialValueFor("stun_chance") or 0
	self.stun_duration = ability:GetSpecialValueFor("stun_duration") or 0
end

function modifier_item_pickaxe:GetModifierPreAttack_BonusDamage() 
	return self.bonus_damage 
end

if not IsServer() then return end

function modifier_item_pickaxe:GetModifierProcAttack_Feedback(keys)
	if not keys.attacker:IsRealHero() then return end
	if keys.attacker:GetTeam() == keys.target:GetTeam() then return end
	if keys.target:IsBuilding() then return end

	-- Проверяем шанс оглушения
	if RandomFloat(0, 100) <= self.stun_chance then
		-- Применяем оглушение
		keys.target:AddNewModifier(keys.attacker, self:GetAbility(), "modifier_stunned", {
			duration = self.stun_duration
		})
		
		-- Эффект частицы при оглушении
		local target_loc = keys.target:GetAbsOrigin()
		local stun_pfx = ParticleManager:CreateParticle("particles/generic_gameplay/generic_stunned.vpcf", PATTACH_OVERHEAD_FOLLOW, keys.target)
		ParticleManager:ReleaseParticleIndex(stun_pfx)
		
		-- Звуковой эффект
		EmitSoundOn("Hero_EarthShaker.EchoSlam", keys.target)
	end
end