local mod	= DBM:NewMod("Volkhan", "DBM-Party-WotLK", 6)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("20220518110528")
mod:SetCreatureID(28587)

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 52387"
)

local warningStomp	= mod:NewSpellAnnounce(52237, 3)
local warnHeat		= mod:NewSpellAnnounce(52387, 2)

local timerStompCD	= mod:NewCDTimer(30, 52237, nil, nil, nil, 2)--NOTE: core never casts Stomp; timer retained for other cores
local timerHeatCD		= mod:NewCDTimer(8, 52387, nil, nil, nil, 3)--Core Heat every 8s (was untracked)

function mod:OnCombatStart(delay)
	timerHeatCD:Start(8-delay)--Core every 8s
end

function mod:OnCombatEnd()
	timerStompCD:Cancel()
	timerHeatCD:Cancel()
end

function mod:SPELL_CAST_START(args)
	if args:IsSpellID(59529, 52237) then
		warningStomp:Show()
		timerStompCD:Start()
	elseif args.spellId == 52387 then -- Heat (core every 8s, the real rotation)
		warnHeat:Show()
		timerHeatCD:Start()
	end
end