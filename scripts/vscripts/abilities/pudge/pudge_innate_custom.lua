LinkLuaModifier( "modifier_pudge_innate_custom", "abilities/pudge/pudge_innate_custom", LUA_MODIFIER_MOTION_NONE )


pudge_innate_custom = class({})



function pudge_innate_custom:GetIntrinsicModifierName()
if not self:GetCaster():IsRealHero() then return end 
return "modifier_pudge_innate_custom"
end


modifier_pudge_innate_custom = class({})
function modifier_pudge_innate_custom:IsHidden() return false end
function modifier_pudge_innate_custom:IsPurgable() return false end
function modifier_pudge_innate_custom:RemoveOnDeath() return false end
function modifier_pudge_innate_custom:OnCreated(table)
self.parent = self:GetParent()
self.ability = self:GetAbility()

self.str = self.ability:GetSpecialValueFor("str")
self.radius = self.ability:GetSpecialValueFor("radius")

self.stack = 0

if not IsServer() then return end
end

function modifier_pudge_innate_custom:OnRefresh(table)
self.str = self.ability:GetSpecialValueFor("str")
end


function modifier_pudge_innate_custom:DeclareFunctions()
return
{
    MODIFIER_EVENT_ON_DEATH,
	MODIFIER_PROPERTY_STATS_STRENGTH_BONUS
}
end

function modifier_pudge_innate_custom:GetModifierBonusStats_Strength()
return self.str * self:GetStackCount()
end


function modifier_pudge_innate_custom:OnStackCountChanged(iStackCount)
if not IsServer() then return end
self.parent:CalculateStatBonus(true)
end

function modifier_pudge_innate_custom:AddStack()

self:SetStackCount(self:GetStackCount() + 1)
self.stack = self.stack + 1

-- self.parent:GenericParticle("particles/units/heroes/hero_pudge/pudge_fleshheap_count.vpcf")

end


function modifier_pudge_innate_custom:OnDeath(params)
	if not IsServer() then return end

	local target = params.unit
	
	if self.parent:GetTeamNumber() == target:GetTeamNumber() then return end
	if target:IsReincarnating() then return end
	

	if ((self.parent:GetAbsOrigin() - target:GetAbsOrigin()):Length2D() <= self.radius) or (params.attacker and params.attacker == self.parent) then
		self:AddStack()
	end



end





-- modifier_pudge_innate_custom_creeps = class({})
-- function modifier_pudge_innate_custom_creeps:IsHidden() return true end
-- function modifier_pudge_innate_custom_creeps:IsPurgable() return false end
-- function modifier_pudge_innate_custom_creeps:RemoveOnDeath() return false end
-- function modifier_pudge_innate_custom_creeps:GetTexture() return "buffs/flesh_creep" end
