local mod	= DBM:NewMod("Moragg", "DBM-Party-WotLK", 12)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("20220518110528")
mod:SetCreatureID(29316)

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 54527",
	"SPELL_AURA_APPLIED 54396"
)

local warningLink	= mod:NewTargetNoFilterAnnounce(54396, 2)
local warnSaliva	= mod:NewSpellAnnounce(54527, 3, nil, "Tank")

local timerLink		= mod:NewTargetTimer(12, 54396, nil, nil, nil, 5, nil, DBM_COMMON_L.HEALER_ICON)
local timerLinkCD	= mod:NewCDTimer(20, 54396, nil, nil, nil, 3)--Core 10-11s first, 18-21s repeat
local timerSalivaCD	= mod:NewCDTimer(9, 54527, nil, "Tank", nil, 3)--Core 4-6s first, 8-10s repeat

function mod:OnCombatStart(delay)
	timerLinkCD:Start(10-delay)--Core 10-11s first
	timerSalivaCD:Start(5-delay)--Core 4-6s first
end

function mod:OnCombatEnd()
	timerLinkCD:Cancel()
	timerSalivaCD:Cancel()
end

function mod:SPELL_CAST_START(args)
	if args.spellId == 54527 then -- Corrosive Saliva (core 8-10s repeat, was untracked)
		warnSaliva:Show()
		timerSalivaCD:Start()
	end
end

function mod:SPELL_AURA_APPLIED(args)
	if args.spellId == 54396 then -- Optic Link (core 18-21s repeat)
		warningLink:Show(args.destName)
		timerLink:Start(args.destName)
		timerLinkCD:Cancel()
		timerLinkCD:Start()
	end
end