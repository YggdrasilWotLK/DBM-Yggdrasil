local mod = DBM:NewMod(562, "DBM-Party-BC", 14, 257)
local L = mod:GetLocalizedStrings()

mod:SetRevision("20260914132425")
mod:SetCreatureID(17977)

mod:SetModelID(19438)
mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_SUCCESS 34716",
	"SPELL_SUMMON 34727 34730"
)

local warnTreants	= mod:NewSpellAnnounce(34727, 3)
local warnStomp		= mod:NewSpellAnnounce(34716, 4)

local timerTreants	= mod:NewNextTimer(40, 34727, nil, nil, nil, 1)--Core 20s first, 40s repeat
local timerStomp	= mod:NewBuffActiveTimer(5, 34716, nil, nil, nil, 3)

function mod:OnCombatStart(delay)
	timerTreants:Start(20-delay)--Core 20s first
end

function mod:SPELL_CAST_SUCCESS(args)
	if args.spellId == 34716 then
		warnStomp:Show()
		timerStomp:Start()
	end
end

function mod:SPELL_SUMMON(args)
	if args:IsSpellID(34727, 34730) then--34730 is the core summon ID, 34727 kept as fallback
		warnTreants:Show()
		timerTreants:Start()
	end
end