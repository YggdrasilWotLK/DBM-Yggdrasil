local mod	= DBM:NewMod("Tenebron", "DBM-ChamberOfAspects", 1)
local L		= mod:GetLocalizedStrings()

mod.statTypes = "normal,normal25"

mod:SetRevision("20260914090611")
mod:SetCreatureID(30452)

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 57570",
	"SPELL_CAST_SUCCESS 57579 59127"
)

local warnShadowFissure		= mod:NewSpellAnnounce(59127, nil, nil, nil, nil, nil, 2)
local warnShadowBreath		= mod:NewSpellAnnounce(57570, 2)
local timerShadowFissure	= mod:NewCastTimer(5, 59128, nil, nil, nil, 3)--Cast timer until Void Blast. it's what happens when shadow fissure explodes.
local timerShadowFissureCD	= mod:NewCDTimer(22.5, 59127, nil, nil, nil, 3)--Core 20s first, 22.5s repeat
local timerShadowBreathCD	= mod:NewCDTimer(17.5, 57570, nil, nil, nil, 3)--Core 10s first, 17.5s repeat

mod:GroupSpells(59127, 59128)--Shadow fissure with void blast

function mod:OnCombatStart(delay)
	timerShadowFissureCD:Start(20-delay)--Core 20s first
	timerShadowBreathCD:Start(10-delay)--Core 10s first
end

function mod:OnCombatEnd()
	timerShadowFissureCD:Cancel()
	timerShadowBreathCD:Cancel()
end

function mod:SPELL_CAST_START(args)
	if args.spellId == 57570 then -- Shadow Breath (core 17.5s repeat)
		warnShadowBreath:Show()
		timerShadowBreathCD:Start()
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	if args:IsSpellID(57579, 59127) then
		warnShadowFissure:Show()
		warnShadowFissure:Play("watchstep")
		timerShadowFissure:Start()
		timerShadowFissureCD:Start()
	end
end