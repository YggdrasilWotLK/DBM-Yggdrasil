local mod = DBM:NewMod(545, "DBM-Party-BC", 10, 253)
local L = mod:GetLocalizedStrings()

mod:SetRevision("20220518110528")
mod:SetCreatureID(18667)

mod:SetModelID(18058)
mod:SetModelScale(0.95)
mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_SUCCESS 33676"
)

local warnChaos			= mod:NewSpellAnnounce(33676, 4)

local timerChaos		= mod:NewBuffActiveTimer(15, 33676, nil, nil, nil, 3)
local timerChaosMin		= mod:NewNextTimer(50, 33676, nil, nil, nil, 6)--Core repeat min 50s: earliest recast
local timerNextChaos	= mod:NewNextTimer(70, 33676, nil, nil, nil, 6)--Core 24s first, 50-70s repeat RNG; max bar

function mod:OnCombatStart(delay)
	timerChaosMin:Start(24-delay)--Core 24s first
	timerNextChaos:Start(24-delay)--Core 24s first
end

function mod:SPELL_CAST_SUCCESS(args)
	if args.spellId == 33676 then
		warnChaos:Show()
		timerChaos:Start()
		timerChaosMin:Cancel()
		timerNextChaos:Cancel()
		timerChaosMin:Start(50)
		timerNextChaos:Start(70)
	end
end