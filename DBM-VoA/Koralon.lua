local mod	= DBM:NewMod("Koralon", "DBM-VoA")
local L		= mod:GetLocalizedStrings()

mod:SetRevision("20220518110528")
mod:SetCreatureID(35013)

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 67328 66665 66725 68161 66681",
	"SPELL_AURA_APPLIED 66684 67332",
	"SPELL_AURA_APPLIED_DOSE 66684 67332"
)

local warnBreath			= mod:NewSpellAnnounce(66665, 3)
local warnMeteor			= mod:NewSpellAnnounce(66725, 3)
local warnMeteorSoon		= mod:NewPreWarnAnnounce(66725, 5, 2)
local warnCinder			= mod:NewSpellAnnounce(66681, 2, nil, "Melee")

local specWarnCinder		= mod:NewSpecialWarningMove(66684, nil, nil, nil, 1, 2)

local timerNextMeteor		= mod:NewNextTimer(45, 66725, nil, nil, nil, 5, nil, DBM_COMMON_L.TANK_ICON)--Core 30s first, 45s repeat
local timerCinderCD		= mod:NewCDTimer(30, 66681, nil, "Melee", nil, 3)--Core 20s first, 30s repeat
local timerBreath			= mod:NewBuffActiveTimer(4.5, 66665, nil, nil, nil, 2)
local timerBreathCD			= mod:NewCDTimer(45, 66665, nil, nil, nil, 2)--Seems to variate, but 45sec cooldown looks like a good testing number to start.

-- NOTE: core has no berserk and casts BURNING_FURY 68168 (never 66721);
-- the old 300s enrage + Burning Fury timers were spurious and are removed.

function mod:OnCombatStart(delay)
	timerNextMeteor:Start(30-delay)--Core 30s first
	timerBreathCD:Start(10-delay)--Core 10s first
	timerCinderCD:Start(20-delay)--Core 20s first
	warnMeteorSoon:Schedule(25-delay)
end

function mod:OnCombatEnd()
	timerNextMeteor:Cancel()
	timerBreathCD:Cancel()
	timerBreath:Cancel()
	timerCinderCD:Cancel()
	warnMeteorSoon:Cancel()
end

function mod:SPELL_CAST_START(args)
	if args:IsSpellID(67328, 66665) then
		warnBreath:Show()
		timerBreath:Start()
		timerBreathCD:Start()
	elseif args:IsSpellID(66725, 68161) then
		warnMeteor:Show()
		timerNextMeteor:Start()
		warnMeteorSoon:Schedule(40)
	elseif args.spellId == 66681 then -- Flaming Cinder (core 30s repeat)
		warnCinder:Show()
		timerCinderCD:Start()
	end
end

function mod:SPELL_AURA_APPLIED(args)
	if args:IsPlayer() and args:IsSpellID(66684, 67332) then
		specWarnCinder:Show()
		specWarnCinder:Play("runaway")
	end
end
mod.SPELL_AURA_APPLIED_DOSE = mod.SPELL_AURA_APPLIED