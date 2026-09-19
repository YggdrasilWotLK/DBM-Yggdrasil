local mod	= DBM:NewMod(384, "DBM-Party-Classic", 2, 228)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("20260914135658")
mod:SetCreatureID(9156)

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 13342"
)

local warnFireblast		= mod:NewSpellAnnounce(13342, 3, nil, "Healer")
local warnSpirits			= mod:NewSpellAnnounce(14744, 3)

local timerFireblastCD	= mod:NewCDTimer(7, 13342, nil, "Healer", nil, 3)--Core 2s first, 7s repeat

function mod:OnCombatStart(delay)
	timerFireblastCD:Start(2-delay)--Core 2s first
end

function mod:OnCombatEnd()
	timerFireblastCD:Cancel()
end

function mod:SPELL_CAST_START(args)
	if args.spellId == 13342 then -- Fireblast (core 7s repeat)
		warnFireblast:Show()
		timerFireblastCD:Start()
	elseif args.spellId == 14744 then -- Burning Spirit adds (every 12-14s summons)
		warnSpirits:Show()
	end
end
