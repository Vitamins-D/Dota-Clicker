LinkLuaModifier( "modifier_burning_strikes", "abilities/creeps/modifier_burning_strikes.lua", LUA_MODIFIER_MOTION_NONE )
burning_strikes = class({})

function burning_strikes:GetIntrinsicModifierName()
    return "modifier_burning_strikes"
end
