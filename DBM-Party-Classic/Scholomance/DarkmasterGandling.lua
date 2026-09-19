local mod	= DBM:NewMod("DarkmasterGandling", "DBM-Party-Classic", 13)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("20260914135658")
mod:SetCreatureID(1853)

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 15790 18702 12040 17950"
)

local warnMissiles		= mod:NewSpellAnnounce(15790, 2, nil, "Healer")
local warnCurse			= mod:NewSpellAnnounce(18702, 2)
local warnShield		= mod:NewSpellAnnounce(12040, 2)
local warnPortal		= mod:NewSpellAnnounce(17950, 3)

local timerMissilesCD		= mod:NewCDTimer(11, 15790, nil, "Healer", nil, 3)--Core 8s first, 8-14s repeat
local timerPortalCD		= mod:NewCDTimer(25, 17950, nil, nil, nil, 3)--Core 25s first and repeat

function mod:OnCombatStart(delay)
	timerMissilesCD:Start(8-delay)--Core 8s first
	timerPortalCD:Start(25-delay)--Core 25s first
end

function mod:OnCombatEnd()
	timerMissilesCD:Cancel()
	timerPortalCD:Cancel()
end

function mod:SPELL_CAST_START(args)
	if args.spellId == 15790 then -- Arcane Missiles (core 8-14s repeat)
		warnMissiles:Show()
		timerMissilesCD:Start()
	elseif args.spellId == 18702 then -- Curse of the Darkmaster
		warnCurse:Show()
	elseif args.spellId == 12040 then -- Shadow Shield
		warnShield:Show()
	elseif args.spellId == 17950 then -- Shadow Portal, room change + guardians (core 25s repeat)
		warnPortal:Show()
		timerPortalCD:Start()
	end
end
