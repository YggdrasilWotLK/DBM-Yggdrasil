local mod	= DBM:NewMod("Ichoron", "DBM-Party-WotLK", 12)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("20220518110528")
mod:SetCreatureID(29313)

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 54241 54312",
	"SPELL_CAST_SUCCESS 54241"
)

local warnVolley		= mod:NewSpellAnnounce(54241, 3)
local warnFrenzy		= mod:NewSpellAnnounce(54312, 4)

local timerVolleyCD		= mod:NewCDTimer(12, 54241, nil, nil, nil, 3)--Core 7-12s first, 10-15s repeat

function mod:OnCombatStart(delay)
	timerVolleyCD:Start(10-delay)--Core 7-12s first
end

function mod:OnCombatEnd()
	timerVolleyCD:Cancel()
end

function mod:SPELL_CAST_START(args)
	if args.spellId == 54241 then -- Water Bolt Volley (core 10-15s repeat; suppressed while exploded)
		warnVolley:Show()
		timerVolleyCD:Start()
	elseif args.spellId == 54312 then -- Frenzy below 25%
		warnFrenzy:Show()
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	if args.spellId == 54241 then
		timerVolleyCD:Start()
	end
end