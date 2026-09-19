local mod	= DBM:NewMod(386, "DBM-Party-Classic", 2, 228)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("20260919205410")
mod:SetCreatureID(9938)

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 24375 13900"
)

local warnStomp			= mod:NewSpellAnnounce(24375, 3)
local warnBurst			= mod:NewSpellAnnounce(13900, 3, nil, "Tank")

local timerStompCD		= mod:NewCDRangeTimer(8, 12, 24375, nil, nil, nil, 3)--Core 8-12s first and repeat
local timerBurstCD		= mod:NewCDRangeTimer(4, 8, 13900, nil, "Tank", nil, 3)--Core 4-8s first and repeat

function mod:OnCombatStart(delay)
	timerStompCD:StartRange(8-delay, 12-delay)--Core 8-12s first
	timerBurstCD:StartRange(4-delay, 8-delay)--Core 4-8s first
end

function mod:OnCombatEnd()
	timerStompCD:Cancel()
	timerBurstCD:Cancel()
end

function mod:SPELL_CAST_START(args)
	if args.spellId == 24375 then -- War Stomp (core 8-12s repeat)
		warnStomp:Show()
		timerStompCD:StartRange(8, 12)
	elseif args.spellId == 13900 then -- Fiery Burst (core 4-8s repeat)
		warnBurst:Show()
		timerBurstCD:StartRange(4, 8)
	end
end
