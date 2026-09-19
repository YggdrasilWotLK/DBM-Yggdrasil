local mod	= DBM:NewMod(392, "DBM-Party-Classic", 3, 229)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("20260919205410")
mod:SetCreatureID(10584)

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 16509 15580 16508"
)

local warnRend			= mod:NewSpellAnnounce(16509, 3, nil, "Tank|Healer")
local warnStrike		= mod:NewSpellAnnounce(15580, 3, nil, "Tank")
local warnRoar			= mod:NewSpellAnnounce(16508, 3)

local timerRendCD			= mod:NewCDRangeTimer(8, 10, 16509, nil, "Tank|Healer", nil, 3)--Core 17-20s first, 8-10s repeat
local timerStrikeCD		= mod:NewCDRangeTimer(8, 10, 15580, nil, "Tank", nil, 3)--Core 10-12s first, 8-10s repeat
local timerRoarCD			= mod:NewCDRangeTimer(40, 45, 16508, nil, nil, nil, 3)--Core 25-30s first, 40-45s repeat

function mod:OnCombatStart(delay)
	timerRendCD:StartRange(17-delay, 20-delay)--Core 17-20s first
	timerStrikeCD:StartRange(10-delay, 12-delay)--Core 10-12s first
	timerRoarCD:StartRange(25-delay, 30-delay)--Core 25-30s first
end

function mod:OnCombatEnd()
	timerRendCD:Cancel()
	timerStrikeCD:Cancel()
	timerRoarCD:Cancel()
end

function mod:SPELL_CAST_START(args)
	if args.spellId == 16509 then -- Rend (core 8-10s repeat)
		warnRend:Show()
		timerRendCD:StartRange(8, 10)
	elseif args.spellId == 15580 then -- Strike (core 8-10s repeat)
		warnStrike:Show()
		timerStrikeCD:StartRange(8, 10)
	elseif args.spellId == 16508 then -- Intimidating Roar (core 40-45s repeat)
		warnRoar:Show()
		timerRoarCD:StartRange(40, 45)
	end
end
