local mod = DBM:NewMod(546, "DBM-Party-BC", 10, 253)
local L = mod:GetLocalizedStrings()

mod:SetRevision("20260914132425")
mod:SetCreatureID(18732)

mod:SetModelID(18535)
mod:SetModelScale(0.7)
mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_SUCCESS 33563"
)

local warnTeleport		= mod:NewSpellAnnounce(33563)

local timerTeleportMin		= mod:NewNextTimer(36.4, 33563, nil, nil, nil, 6)--Core repeat min 36.4s: earliest recast
local timerTeleport		= mod:NewNextTimer(44.95, 33563, nil, nil, nil, 6)--Core 36.4s first, 36.4-44.95s repeat RNG; max bar

function mod:OnCombatStart(delay)
	timerTeleportMin:Start(36-delay)--Core 36.4s first
	timerTeleport:Start(36-delay)--Core 36.4s first
end

function mod:SPELL_CAST_SUCCESS(args)
	if args.spellId == 33563 then
		warnTeleport:Show()
		timerTeleportMin:Cancel()
		timerTeleport:Cancel()
		timerTeleportMin:Start(36.4)
		timerTeleport:Start(44.95)
	end
end