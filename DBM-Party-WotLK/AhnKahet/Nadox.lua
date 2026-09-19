local mod	= DBM:NewMod("Nadox", "DBM-Party-WotLK", 1)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("20260919205410")
mod:SetCreatureID(29309)

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_AURA_APPLIED 56130 59467",
	"SPELL_AURA_REMOVED 56130 59467",
	"SPELL_CAST_START 56119"
)

local warningPlague	= mod:NewTargetAnnounce(56130, 2, nil, "Healer")
local warnSwarmer		= mod:NewSpellAnnounce(56119, 2)

local timerPlague	= mod:NewTargetTimer(30, 56130, nil, "Healer", nil, 3)
local timerPlagueCD	= mod:NewCDRangeTimer(12, 17, 56130, nil, "Healer", nil, 3)--Core 5-8s first, 12-17s repeat
local timerSwarmerCD	= mod:NewCDTimer(10, 56119, nil, nil, nil, 1)--Core swarmers every 10s (was untracked)

function mod:OnCombatStart(delay)
	timerPlagueCD:StartRange(5-delay, 8-delay)--Core 5-8s first
	timerSwarmerCD:Start(10-delay)--Core every 10s
end

function mod:OnCombatEnd()
	timerPlagueCD:Cancel()
	timerSwarmerCD:Cancel()
end

function mod:SPELL_CAST_START(args)
	if args.spellId == 56119 then -- Ahn'kahar Swarmer (core every 10s, was untracked)
		warnSwarmer:Show()
		timerSwarmerCD:Start()
	end
end

function mod:SPELL_AURA_APPLIED(args)
	if args:IsSpellID(56130, 59467) then -- Brood Plague (core casts 56130 both modes; 59467 heroic twin fallback)
		warningPlague:Show(args.destName)
		timerPlague:Start(args.destName)
		timerPlagueCD:StartRange(12, 17)
	end
end

function mod:SPELL_AURA_REMOVED(args)
	if args:IsSpellID(56130, 59467) then
		timerPlague:Cancel(args.destName)
	end
end