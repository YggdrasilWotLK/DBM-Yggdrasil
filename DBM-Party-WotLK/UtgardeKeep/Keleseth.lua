local mod	= DBM:NewMod("Keleseth", "DBM-Party-WotLK", 10)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("20220518110528")
mod:SetCreatureID(23953)

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 42672",
	"SPELL_AURA_APPLIED 48400",
	"SPELL_AURA_REMOVED 48400"
)

local warningTomb	= mod:NewTargetNoFilterAnnounce(48400, 4)

local timerTomb		= mod:NewTargetTimer(10, 48400)
local timerTombCD	= mod:NewCDTimer(15, 48400)--Core 28s first, 15s repeat

function mod:OnCombatStart()
	timerTombCD:Start(28)--Core 28s first
end

function mod:OnCombatEnd()
	timerTombCD:Cancel()
end

function mod:SPELL_CAST_START(args)
	if args.spellId == 42672 then -- Frost Tomb cast (aura 48400 lands later via tomb NPC)
		timerTombCD:Start()
	end
end

function mod:SPELL_AURA_APPLIED(args)
	if args.spellId == 48400 then
		warningTomb:Show(args.destName)
		timerTomb:Start(args.destName)
	end
end

function mod:SPELL_AURA_REMOVED(args)
	if args.spellId == 48400 then
		timerTomb:Cancel()
	end
end