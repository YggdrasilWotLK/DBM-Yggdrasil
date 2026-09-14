local mod	= DBM:NewMod(386, "DBM-Party-Classic", 2, 228)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("20220518110528")
mod:SetCreatureID(9938)

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 24375 13900"
)

local warnStomp			= mod:NewSpellAnnounce(24375, 3)
local warnBurst			= mod:NewSpellAnnounce(13900, 3, nil, "Tank")

local timerStompCD		= mod:NewCDTimer(10, 24375, nil, nil, nil, 3)--Core 8-12s first and repeat
local timerBurstCD		= mod:NewCDTimer(6, 13900, nil, "Tank", nil, 3)--Core 4-8s first and repeat

function mod:OnCombatStart(delay)
	timerStompCD:Start(10-delay)--Core 8-12s first (mid)
	timerBurstCD:Start(6-delay)--Core 4-8s first (mid)
end

function mod:OnCombatEnd()
	timerStompCD:Cancel()
	timerBurstCD:Cancel()
end

function mod:SPELL_CAST_START(args)
	if args.spellId == 24375 then -- War Stomp (core 8-12s repeat)
		warnStomp:Show()
		timerStompCD:Start()
	elseif args.spellId == 13900 then -- Fiery Burst (core 4-8s repeat)
		warnBurst:Show()
		timerBurstCD:Start()
	end
end
