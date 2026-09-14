local mod	= DBM:NewMod(388, "DBM-Party-Classic", 3, 229)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("20220518110528")
mod:SetCreatureID(9196)

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 8269 10101"
)

local warnFrenzy		= mod:NewSpellAnnounce(8269, 3)
local warnKnock			= mod:NewSpellAnnounce(10101, 3, nil, "Tank")

local timerFrenzyCD		= mod:NewCDTimer(60, 8269, nil, nil, nil, 2)--Core 20s first, 60s repeat
local timerKnockCD		= mod:NewCDTimer(12, 10101, nil, "Tank", nil, 3)--Core 18s first, 12s repeat

function mod:OnCombatStart(delay)
	timerFrenzyCD:Start(20-delay)--Core 20s first
	timerKnockCD:Start(18-delay)--Core 18s first
end

function mod:OnCombatEnd()
	timerFrenzyCD:Cancel()
	timerKnockCD:Cancel()
end

function mod:SPELL_CAST_START(args)
	if args.spellId == 8269 then -- Frenzy (core 60s repeat)
		warnFrenzy:Show()
		timerFrenzyCD:Start()
	elseif args.spellId == 10101 then -- Knock Away (core 12s repeat)
		warnKnock:Show()
		timerKnockCD:Start()
	end
end
