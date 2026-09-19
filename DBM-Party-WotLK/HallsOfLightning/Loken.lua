local mod	= DBM:NewMod("Loken", "DBM-Party-WotLK", 6)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("20260914104916")
mod:SetCreatureID(28923)

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 52960 59835 52921"
)

local warningNova	= mod:NewSpellAnnounce(52960, 3)
local warnArc			= mod:NewSpellAnnounce(52921, 2, nil, "Healer")

local timerNovaCD	= mod:NewCDTimer(15, 52960, nil, nil, nil, 2)--Core 15s repeat
local timerArcCD		= mod:NewCDTimer(12, 52921, nil, "Healer", nil, 3)--Core every 12s (was untracked)
local timerAchieve	= mod:NewAchievementTimer(120, 1867)

function mod:OnCombatStart(delay)
	if not self:IsDifficulty("normal5") then
		timerAchieve:Start(-delay)
	end
	timerNovaCD:Start(15-delay)--Core 15s
	timerArcCD:Start(12-delay)--Core every 12s
end

function mod:OnCombatEnd()
	timerNovaCD:Cancel()
	timerArcCD:Cancel()
end

function mod:SPELL_CAST_START(args)
	if args:IsSpellID(52960, 59835) then -- Lightning Nova (core 15s repeat)
		warningNova:Show()
		timerNovaCD:Start()
	elseif args.spellId == 52921 then -- Arc Lightning (was untracked)
		warnArc:Show()
		timerArcCD:Start()
	end
end