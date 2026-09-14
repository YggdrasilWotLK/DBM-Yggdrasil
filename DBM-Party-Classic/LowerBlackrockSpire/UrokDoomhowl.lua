local mod	= DBM:NewMod(392, "DBM-Party-Classic", 3, 229)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("20220518110528")
mod:SetCreatureID(10584)

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 16509 15580 16508"
)

local warnRend			= mod:NewSpellAnnounce(16509, 3, nil, "Tank|Healer")
local warnStrike		= mod:NewSpellAnnounce(15580, 3, nil, "Tank")
local warnRoar			= mod:NewSpellAnnounce(16508, 3)

local timerRendCD			= mod:NewCDTimer(9, 16509, nil, "Tank|Healer", nil, 3)--Core 17-20s first, 8-10s repeat
local timerStrikeCD		= mod:NewCDTimer(9, 15580, nil, "Tank", nil, 3)--Core 10-12s first, 8-10s repeat
local timerRoarCD			= mod:NewCDTimer(42, 16508, nil, nil, nil, 3)--Core 25-30s first, 40-45s repeat

function mod:OnCombatStart(delay)
	timerRendCD:Start(18-delay)--Core 17-20s first (mid)
	timerStrikeCD:Start(11-delay)--Core 10-12s first (mid)
	timerRoarCD:Start(27-delay)--Core 25-30s first (mid)
end

function mod:OnCombatEnd()
	timerRendCD:Cancel()
	timerStrikeCD:Cancel()
	timerRoarCD:Cancel()
end

function mod:SPELL_CAST_START(args)
	if args.spellId == 16509 then -- Rend (core 8-10s repeat)
		warnRend:Show()
		timerRendCD:Start()
	elseif args.spellId == 15580 then -- Strike (core 8-10s repeat)
		warnStrike:Show()
		timerStrikeCD:Start()
	elseif args.spellId == 16508 then -- Intimidating Roar (core 40-45s repeat)
		warnRoar:Show()
		timerRoarCD:Start()
	end
end
