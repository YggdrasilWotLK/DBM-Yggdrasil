local mod	= DBM:NewMod("MrSmite", "DBM-Party-Classic", 5)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("20220518110528")
mod:SetCreatureID(646)

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_SUCCESS 6432",
	"SPELL_AURA_APPLIED 6435"
)

local warningSmiteSlam		= mod:NewTargetNoFilterAnnounce(6435, 2)

local timerSmiteStomp		= mod:NewBuffActiveTimer(10, 6432, nil, nil, nil, 2)--DBC 10s duration; Stomp is HP-gated 67%/34%, not a loop

function mod:SPELL_CAST_SUCCESS(args)
	if args.spellId == 6432 then
		timerSmiteStomp:Start()
	end
end

function mod:SPELL_AURA_APPLIED(args)
	if args.spellId == 6435 then
		warningSmiteSlam:Show(args.destName)
	end
end