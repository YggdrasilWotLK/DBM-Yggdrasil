local mod	= DBM:NewMod("Taldaram", "DBM-Party-WotLK", 1)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("20260914104916")
mod:SetCreatureID(29308)

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 55931 55968",
	"SPELL_AURA_APPLIED 55959 59513",
	"SPELL_AURA_REMOVED 55959 59513"
)

local warningEmbrace	= mod:NewTargetAnnounce(55959, 2)
local warningFlame		= mod:NewSpellAnnounce(55931, 3)
local warnThirst		= mod:NewSpellAnnounce(55968, 3, nil, "Tank|Healer")

local timerEmbrace		= mod:NewTargetTimer(20, 55959, nil, nil, nil, 3, nil, DBM_COMMON_L.DAMAGE_ICON)
local timerFlameCD		= mod:NewCDTimer(15, 55931, nil, nil, nil, 3)
local timerThirstCD		= mod:NewCDTimer(15, 55968, nil, "Tank|Healer", nil, 3)--Core 10s first, 15s repeat (was untracked)


function mod:OnCombatStart(delay)
	timerFlameCD:Start(10-delay)--Core 10s first
	timerThirstCD:Start(10-delay)--Core 10s first
end

function mod:OnCombatEnd()
	timerFlameCD:Cancel()
	timerThirstCD:Cancel()
end

function mod:SPELL_CAST_START(args)
	if args.spellId == 55931 then
		warningFlame:Show()
		timerFlameCD:Start()
	elseif args.spellId == 55968 then -- Bloodthirst (core 15s repeat, was untracked)
		warnThirst:Show()
		timerThirstCD:Start()
	end
end

function mod:SPELL_AURA_APPLIED(args)
	if args:IsSpellID(55959, 59513) then
		warningEmbrace:Show(args.destName)
		timerEmbrace:Start(args.destName)
	end
end

function mod:SPELL_AURA_REMOVED(args)
	if args:IsSpellID(55959, 59513) then
		timerEmbrace:Cancel(args.destName)
	end
end