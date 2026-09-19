local mod	= DBM:NewMod(575, "DBM-Party-BC", 6, 261)
local L		= mod:GetLocalizedStrings()

mod.statTypes = "normal,heroic,mythic"

mod:SetRevision("20260914132425")
mod:SetCreatureID(17798)

mod:SetModelID(20235)
mod:SetModelScale(0.95)
mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_SUCCESS 31543",
	"SPELL_AURA_APPLIED 31534",
	"SPELL_AURA_REMOVED 31534"
)

local WarnChannel		= mod:NewSpellAnnounce(31543, 2)

local specWarnReflect	= mod:NewSpecialWarningReflect(31534, "-Melee", nil, nil, 1, 2)--CasterDps after new core

local timerReflect		= mod:NewBuffActiveTimer(8, 31534, nil, nil, nil, 5)

function mod:SPELL_CAST_SUCCESS(args)
	if args.spellId == 31543 then
		WarnChannel:Show()
	end
end

function mod:SPELL_AURA_APPLIED(args)
	if args.spellId == 31534 then
		timerReflect:Start(args.destName)
		specWarnReflect:Show(args.destName)
		specWarnReflect:Play("stopattack")
	end
end

function mod:SPELL_AURA_REMOVED(args)
	if args.spellId == 31534 then
		timerReflect:Stop()
	end
end