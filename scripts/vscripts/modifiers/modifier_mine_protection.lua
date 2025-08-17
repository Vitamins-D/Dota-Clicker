modifier_mine_protection = class({})

function modifier_mine_protection:IsHidden() return true end
function modifier_mine_protection:IsPurgable() return false end
function modifier_mine_protection:GetAttributes() return MODIFIER_ATTRIBUTE_PERMANENT end

function modifier_mine_protection:CheckState()
    return {
        [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
        [MODIFIER_STATE_ATTACK_IMMUNE] = true,
        [MODIFIER_STATE_MAGIC_IMMUNE] = true,
        [MODIFIER_STATE_UNSELECTABLE] = false, -- Оставляем выделяемым для клика
    }
end