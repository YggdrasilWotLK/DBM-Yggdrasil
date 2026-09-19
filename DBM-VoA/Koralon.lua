local mod	= DBM:NewMod("Koralon", "DBM-VoA")
local L		= mod:GetLocalizedStrings()

mod:SetRevision("20260914092922")
mod:SetCreatureID(35013)

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 67328 66665 66725 68161 66681",
	"SPELL_AURA_APPLIED 66684 67332 68168 66721",
	"SPELL_AURA_APPLIED_DOSE 66684 67332"
)

local warnBreath			= mod:NewSpellAnnounce(66665, 3)
local warnMeteor			= mod:NewSpellAnnounce(66725, 3)
local warnMeteorSoon		= mod:NewPreWarnAnnounce(66725, 5, 2)
local warnCinder			= mod:NewSpellAnnounce(66681, 2, nil, "Melee")
local warnBurningFury		= mod:NewStackAnnounce(68168, 2, nil, "Tank|Healer")--Core 68168 ticks every 20s (old 66721 kept as fallback)

local specWarnCinder		= mod:NewSpecialWarningMove(66684, nil, nil, nil, 1, 2)

local timerNextMeteor		= mod:NewNextTimer(45, 66725, nil, nil, nil, 5, nil, DBM_COMMON_L.TANK_ICON)--Core 30s first, 45s repeat
local timerCinderCD		= mod:NewCDTimer(30, 66681, nil, "Melee", nil, 3)--Core 20s first, 30s repeat
local timerBreath			= mod:NewBuffActiveTimer(4.5, 66665, nil, nil, nil, 2)
local timerBreathCD			= mod:NewCDTimer(45, 66665, nil, nil, nil, 2)--Seems to variate, but 45sec cooldown looks like a good testing number to start.
local timerBurningFuryCD	= mod:NewNextTimer(20, 68168, nil, nil, nil, 5, nil, DBM_COMMON_L.TANK_ICON..DBM_COMMON_L.HEALER_ICON)--Core 68168 periodic trigger every 20s

-- NOTE: core has no berserk and casts BURNING_FURY 68168 (never 66721);
-- the old 300s enrage + Burning Fury timers were spurious and are removed.

function mod:OnCombatStart(delay)
	timerNextMeteor:Start(30-delay)--Core 30s first
	timerBreathCD:Start(10-delay)--Core 10s first
	timerCinderCD:Start(20-delay)--Core 20s first
	timerBurningFuryCD:Start(20-delay)--Core 68168 first tick 20s after engage
	warnMeteorSoon:Schedule(25-delay)
end

function mod:OnCombatEnd()
	timerNextMeteor:Cancel()
	timerBreathCD:Cancel()
	timerBreath:Cancel()
	timerCinderCD:Cancel()
	timerBurningFuryCD:Cancel()
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
	elseif args:IsSpellID(68168, 66721) then -- Burning Fury (core 68168 ticks every 20s; 66721 fallback)
		warnBurningFury:Show(args.destName, args.amount or 1)
		timerBurningFuryCD:Start()
	end
end
mod.SPELL_AURA_APPLIED_DOSE = mod.SPELL_AURA_APPLIED