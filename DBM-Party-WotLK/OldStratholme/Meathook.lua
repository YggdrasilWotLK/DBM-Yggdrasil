local mod	= DBM:NewMod("Meathook", "DBM-Party-WotLK", 3)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("20220518110528")
mod:SetCreatureID(26529)

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 52666 58824 58841",
	"SPELL_CAST_SUCCESS 52696 58823"
)

local warningChains		= mod:NewTargetNoFilterAnnounce(52696, 4)
local warnDisease			= mod:NewSpellAnnounce(52666, 3, nil, "Healer")
local warnFrenzy			= mod:NewSpellAnnounce(58841, 3, nil, "Tank")

local timerChains		= mod:NewTargetTimer(5, 52696, nil, nil, nil, 3)
local timerChainsCD		= mod:NewCDTimer(14, 52696, nil, nil, nil, 3)--Core 15s first, 14s repeat
local timerDiseaseCD		= mod:NewCDTimer(6, 52666, nil, nil, nil, 2)--Core every 6s (was untracked)
local timerFrenzyCD		= mod:NewCDTimer(20, 58841, nil, nil, nil, 3)--Core every 20s (was untracked)

function mod:OnCombatStart(delay)
	timerChainsCD:Start(15-delay)--Core 15s first
	timerDiseaseCD:Start(6-delay)--Core every 6s
	timerFrenzyCD:Start(20-delay)--Core every 20s
end

function mod:OnCombatEnd()
	timerChainsCD:Cancel()
	timerDiseaseCD:Cancel()
	timerFrenzyCD:Cancel()
end

function mod:SPELL_CAST_START(args)
	if args:IsSpellID(52666, 58824) then -- Disease Expulsion (was untracked)
		warnDisease:Show()
		timerDiseaseCD:Start()
	elseif args.spellId == 58841 then -- Frenzy (was untracked)
		warnFrenzy:Show()
		timerFrenzyCD:Start()
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	if args:IsSpellID(52696, 58823) then
		warningChains:Show(args.destName)
		timerChains:Start(args.destName)
		timerChainsCD:Start()
	end
end