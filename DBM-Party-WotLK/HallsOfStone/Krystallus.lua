local mod	= DBM:NewMod("Krystallus", "DBM-Party-WotLK", 7)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("20220518110528")
mod:SetCreatureID(27977)

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 50827 50843 59742 50868 59744",
	"SPELL_CAST_SUCCESS 50827"
)

local warningShatter	= mod:NewSpellAnnounce(50810, 3)
local warnBoulder		= mod:NewSpellAnnounce(50843, 2)--Core random target, no role filter
local warnStomp		= mod:NewSpellAnnounce(50868, 3)

local timerShatterCD	= mod:NewCDTimer(12, 50810, nil, nil, nil, 2)--Core slam 10-13s, shatter +8s
local timerBoulderCD	= mod:NewCDTimer(6, 50843, nil, nil, nil, 3)--Core 5-7s first (was untracked)
local timerStompCD	= mod:NewCDTimer(15, 50868, nil, nil, nil, 2)--Core 13-18s first (was untracked)

function mod:OnCombatStart(delay)
	timerShatterCD:Start(18-delay)--Core slam 10-13s + 8s shatter
	timerBoulderCD:Start(6-delay)--Core 5-7s first
	timerStompCD:Start(15-delay)--Core 13-18s first
end

function mod:OnCombatEnd()
	timerShatterCD:Cancel()
	timerBoulderCD:Cancel()
	timerStompCD:Cancel()
end

function mod:SPELL_CAST_START(args)
	if args.spellId == 50827 then -- Ground Slam -> Shatter in 8s (core chain; old 50833 trigger was dead)
		warningShatter:Show()	-- Shatter warning when Ground Slam is cast
		timerShatterCD:Start()
	elseif args:IsSpellID(50843, 59742) then -- Boulder Toss (was untracked)
		warnBoulder:Show()
		timerBoulderCD:Start()
	elseif args:IsSpellID(50868, 59744) then -- Stomp (was untracked)
		warnStomp:Show()
		timerStompCD:Start()
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	if args.spellId == 50827 then
		timerShatterCD:Start(8)--Shatter lands 8s after slam
	end
end