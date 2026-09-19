local mod	= DBM:NewMod("KingDred", "DBM-Party-WotLK", 4)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("20260919205410")
mod:SetCreatureID(27483)

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 22686 48873 48878 48849",
	"SPELL_CAST_SUCCESS 22686",
	"SPELL_AURA_APPLIED 48920 48873 48878"
)

local warningSlash	= mod:NewSpellAnnounce(48873, 3)
local warningPiercing	= mod:NewSpellAnnounce(48878, 3, nil, "Tank")
local warningBite	= mod:NewTargetNoFilterAnnounce(48920, 2, nil, "Healer")
local warningFear	= mod:NewSpellAnnounce(22686, 1)
local warnRoar		= mod:NewSpellAnnounce(48849, 3)

local timerFearCD	= mod:NewCDTimer(40, 22686, nil, nil, nil, 2)--Core 33s first, 40s repeat
local timerSlash	= mod:NewTargetTimer(10, 48873)
local timerSlashCD	= mod:NewCDTimer(20, 48873, nil, "Tank|Healer", nil, 5)--Core 18.5s first, 20s repeat
local timerPiercingCD	= mod:NewCDTimer(20, 48878, nil, "Tank", nil, 5)--Core 17s first, 20s repeat (separate mechanic)
local timerRoarCD		= mod:NewCDTimer(17, 48849, nil, nil, nil, 3)--Core 10-20s first, 17s repeat

function mod:OnCombatStart(delay)
	timerFearCD:Start(33-delay)--Core 33s first
	timerSlashCD:Start(18.5-delay)--Core 18.5s first
	timerPiercingCD:Start(17-delay)--Core 17s first
	timerRoarCD:StartRange(10-delay, 20-delay)--Core 10-20s first
end

function mod:OnCombatEnd()
	timerFearCD:Cancel()
	timerSlashCD:Cancel()
	timerPiercingCD:Cancel()
	timerRoarCD:Cancel()
end

function mod:SPELL_CAST_START(args)
	if args.spellId == 22686 then -- Bellowing Roar (core 40s repeat; GUID compare was dead code)
		warningFear:Show()
		timerFearCD:Start()
	elseif args.spellId == 48849 then -- Fearsome Roar (core 17s repeat, was untracked)
		warnRoar:Show()
		timerRoarCD:Start()
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	if args.spellId == 22686 then
		timerFearCD:Start()
	end
end

function mod:SPELL_AURA_APPLIED(args)
	if args.spellId == 48920 then
		warningBite:Show(args.destName)
	elseif args.spellId == 48873 then -- Mangling Slash (core 20s repeat)
		warningSlash:Show()
		timerSlash:Start(10, args.destName)
		timerSlashCD:Start()
	elseif args.spellId == 48878 then -- Piercing Slash (separate core mechanic, 20s repeat)
		warningPiercing:Show()
		timerPiercingCD:Start()
	end
end