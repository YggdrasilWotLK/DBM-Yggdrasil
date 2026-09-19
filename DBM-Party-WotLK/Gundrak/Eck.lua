local mod	= DBM:NewMod("Eck", "DBM-Party-WotLK", 5)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("20260919205410")
mod:SetCreatureID(29932)

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 55814 55815"
)

local enrageTimer	= mod:NewBerserkTimer(75)--Core 60-90s

local warnSpit		= mod:NewSpellAnnounce(55814, 2, nil, "Healer")
local warnSpring	= mod:NewSpellAnnounce(55815, 3)

local timerSpitCD		= mod:NewCDRangeTimer(11, 24, 55814, nil, "Healer", nil, 2)--Core 10-37s first, 11-24s repeat
local timerSpringCD	= mod:NewCDRangeTimer(10, 24, 55815, nil, nil, nil, 3)--Core 10-24s first and repeat

function mod:OnCombatStart(delay)
	enrageTimer:Start(75 - delay)--Core 60-90s
	timerSpitCD:StartRange(10-delay, 37-delay)--Core 10-37s first
	timerSpringCD:StartRange(10-delay, 24-delay)--Core 10-24s first
end

function mod:OnCombatEnd()
	timerSpitCD:Cancel()
	timerSpringCD:Cancel()
end

function mod:SPELL_CAST_START(args)
	if args.spellId == 55814 then -- Spit (core 11-24s repeat, healers care)
		warnSpit:Show()
		timerSpitCD:StartRange(11, 24)
	elseif args.spellId == 55815 then -- Spring + threat reset (core 10-24s repeat, was untracked)
		warnSpring:Show()
		timerSpringCD:StartRange(10, 24)
	end
end