local mod	= DBM:NewMod("Anubarak", "DBM-Party-WotLK", 2)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("20260914104916")
mod:SetCreatureID(29120)

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 53472 59433"
)

local warningPound		= mod:NewSpellAnnounce(53472, 3)

local timerPoundCD		= mod:NewCDTimer(18, 53472, nil, nil, nil, 3)--Core 15s first, 18s repeat

local timerAchieve		= mod:NewAchievementTimer(240, 1860)

function mod:OnCombatStart(delay)
	if not self:IsDifficulty("normal5") then
		timerAchieve:Start(-delay)
	end
	timerPoundCD:Start(15-delay)--Core 15s first
end

function mod:OnCombatEnd()
	timerPoundCD:Cancel()
end

function mod:SPELL_CAST_START(args)
	if args:IsSpellID(53472, 59433) then -- Pound (59433 kept as fallback per tactic)
		warningPound:Show()
		timerPoundCD:Start()
	end
end