local mod	= DBM:NewMod("SolakarFlamewreath", "DBM-Party-Classic", 4)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("20260914135658")
mod:SetCreatureID(10264)

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 16727"
)

local warnStomp			= mod:NewSpellAnnounce(16727, 3)

local timerStompCD		= mod:NewCDRangeTimer(17, 20, 16727, nil, nil, nil, 3)--Core 17-20s first and repeat

function mod:OnCombatStart(delay)
	timerStompCD:StartRange(17-delay, 20-delay)--Core 17-20s first (mid)
end

function mod:OnCombatEnd()
	timerStompCD:Cancel()
end

function mod:SPELL_CAST_START(args)
	if args.spellId == 16727 then -- War Stomp (core 17-20s repeat; egg hatchers handled via world event)
		warnStomp:Show()
		timerStompCD:StartRange(17, 20)
	end
end
