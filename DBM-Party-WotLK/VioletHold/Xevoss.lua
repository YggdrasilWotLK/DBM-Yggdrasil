local mod	= DBM:NewMod("Xevoss", "DBM-Party-WotLK", 12)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("20260914104916")
mod:SetCreatureID(29266)

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 54202 54226"
)

local warnBarrage	= mod:NewSpellAnnounce(54202, 3)
local warnBuffet	= mod:NewSpellAnnounce(54226, 2)

local timerBarrageCD	= mod:NewCDTimer(20, 54202, nil, nil, nil, 3)--Core 16-20s first, 20s repeat
local timerBuffetCD		= mod:NewCDTimer(10, 54226, nil, nil, nil, 3)--Core 5s after summon (was untracked)

function mod:OnCombatStart(delay)
	timerBarrageCD:Start(18-delay)--Core 16-20s first
end

function mod:OnCombatEnd()
	timerBarrageCD:Cancel()
	timerBuffetCD:Cancel()
end

function mod:SPELL_CAST_START(args)
	if args.spellId == 54202 then -- Arcane Barrage Volley (core 20s repeat)
		warnBarrage:Show()
		timerBarrageCD:Start()
	elseif args.spellId == 54226 then -- Arcane Buffet (5s after summon, was untracked)
		warnBuffet:Show()
		timerBuffetCD:Start()
	end
end