local mod	= DBM:NewMod("Sladran", "DBM-Party-WotLK", 5)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("20260919205410")
mod:SetCreatureID(29304)

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 55081 59842 48287 54970"
)

local warningNova	= mod:NewSpellAnnounce(55081, 3)
local warnBite		= mod:NewSpellAnnounce(48287, 3, nil, "Tank")
local warnVenom		= mod:NewSpellAnnounce(54970, 2)

local timerNovaCD	= mod:NewCDRangeTimer(16, 53, 55081, nil, nil, nil, 2)--Core randomized 16-53s
local timerBiteCD		= mod:NewCDTimer(10, 48287, nil, "Tank", nil, 3)--Core 3s first, 10s repeat (was untracked)
local timerVenomCD	= mod:NewCDTimer(10, 54970, nil, nil, nil, 2)--Core 15s first, 10s repeat (was untracked)

function mod:OnCombatStart(delay)
	timerNovaCD:StartRange(16-delay, 53-delay)--Core 16-53s first
	timerBiteCD:Start(5-delay)--Core 3s first (grace)
	timerVenomCD:Start(15-delay)--Core 15s first
end

function mod:OnCombatEnd()
	timerNovaCD:Cancel()
	timerBiteCD:Cancel()
	timerVenomCD:Cancel()
end

function mod:SPELL_CAST_START(args)
	if args:IsSpellID(55081, 59842) then -- Poison Nova (core 16-53s window)
		warningNova:Show()
		timerNovaCD:StartRange(16, 53)
	elseif args.spellId == 48287 then -- Powerful Bite (was untracked)
		warnBite:Show()
		timerBiteCD:Start()
	elseif args.spellId == 54970 then -- Venom Bolt (was untracked)
		warnVenom:Show()
		timerVenomCD:Start()
	end
end