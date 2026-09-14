local mod	= DBM:NewMod("Eck", "DBM-Party-WotLK", 5)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("20220518110528")
mod:SetCreatureID(29932)

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 55814 55815"
)

local enrageTimer	= mod:NewBerserkTimer(75)--Core 60-90s

local warnSpit		= mod:NewSpellAnnounce(55814, 2, nil, "Healer")
local warnSpring	= mod:NewSpellAnnounce(55815, 3)

local timerSpitCD		= mod:NewCDTimer(17, 55814, nil, "Healer", nil, 2)--Core 10-37s first, 11-24s repeat
local timerSpringCD	= mod:NewCDTimer(17, 55815, nil, nil, nil, 3)--Core 10-24s first and repeat

function mod:OnCombatStart(delay)
	enrageTimer:Start(75 - delay)--Core 60-90s
	timerSpitCD:Start(23-delay)--Core 10-37s first (mid)
	timerSpringCD:Start(17-delay)--Core 10-24s first (mid)
end

function mod:OnCombatEnd()
	timerSpitCD:Cancel()
	timerSpringCD:Cancel()
end

function mod:SPELL_CAST_START(args)
	if args.spellId == 55814 then -- Spit (core 11-24s repeat, healers care)
		warnSpit:Show()
		timerSpitCD:Start()
	elseif args.spellId == 55815 then -- Spring + threat reset (core 10-24s repeat, was untracked)
		warnSpring:Show()
		timerSpringCD:Start()
	end
end