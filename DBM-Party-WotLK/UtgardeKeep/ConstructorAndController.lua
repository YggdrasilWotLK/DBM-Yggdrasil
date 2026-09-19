local mod	= DBM:NewMod("ConstructorAndController", "DBM-Party-WotLK", 10)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("20260919205410")
mod:SetCreatureID(24200, 24201)

mod:RegisterCombat("combat", 24200, 24201)

mod:RegisterEventsInCombat(
	"SPELL_AURA_APPLIED 43650",
	"SPELL_AURA_REMOVED 43650",
	"SPELL_CAST_START 43651",
	"SPELL_CAST_SUCCESS 48583",
	"SPELL_SUMMON 52611"
)

local warningEnfeeble	= mod:NewTargetNoFilterAnnounce(43650, 2)
local warningSummon		= mod:NewSpellAnnounce(52611, 3)
local warnCharge		= mod:NewSpellAnnounce(43651, 3, nil, "Tank")
local warnStoneStrike		= mod:NewSpellAnnounce(48583, 2, nil, "Tank")

local timerEnfeeble		= mod:NewTargetTimer(6, 43650)
local timerEnfeebleCD		= mod:NewCDRangeTimer(5, 10, 43650, nil, nil, nil, 3)--Core 5s first, 5-10s repeat
local timerChargeCD		= mod:NewCDRangeTimer(5, 10, 43651, nil, "Tank", nil, 3)--Core 5s first, 5-10s repeat
local timerStoneStrikeCD	= mod:NewCDTimer(10, 48583, nil, "Tank", nil, 3)--Core 10s first

function mod:OnCombatStart(delay)
	timerEnfeebleCD:Start(5-delay)--Core 5s first
	timerChargeCD:Start(5-delay)--Core 5s first
	timerStoneStrikeCD:Start(10-delay)--Core 10s first
end

function mod:OnCombatEnd()
	timerEnfeebleCD:Cancel()
	timerChargeCD:Cancel()
	timerStoneStrikeCD:Cancel()
end

function mod:SPELL_AURA_APPLIED(args)
	if args.spellId == 43650 then
		warningEnfeeble:Show(args.destName)
		timerEnfeeble:Start(args.destName)
		timerEnfeebleCD:StartRange(5, 10)
	end
end

function mod:SPELL_AURA_REMOVED(args)
	if args.spellId == 43650 then
		timerEnfeeble:Cancel(args.destName)
	end
end

function mod:SPELL_SUMMON(args)
	if args.spellId == 52611 and self:AntiSpam() then
		warningSummon:Show()
	end
end

function mod:SPELL_CAST_START(args)
	if args.spellId == 43651 then -- Skarvald Charge (core 5-10s repeat)
		warnCharge:Show()
		timerChargeCD:StartRange(5, 10)
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	if args.spellId == 48583 then -- Stone Strike (core 10s first)
		warnStoneStrike:Show()
		timerStoneStrikeCD:Start()
	end
end