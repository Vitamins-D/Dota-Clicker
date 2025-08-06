require("dota_clicker")
require("utils/timers")

if dota_clicker == nil then
	dota_clicker = class({})
end

function Precache( context )
	PrecacheResource( "soundfile", "*soundevents/dotatd_osel_sound.vsndevts", context )
end

-- Create the game mode when we activate
function Activate()
	dota_clicker:InitGameMode()
end