local mod	= DBM:NewMod("Erekem", "DBM-Party-WotLK", 12)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("20260919205410")
mod:SetCreatureID(29315)

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 54516 59463 54481 54511 53044",
	"SPELL_AURA_APPLIED 54479 59471"
)

local warningES	= mod:NewSpellAnnounce(54479, 3)
local warnBloodlust	= mod:NewSpellAnnounce(54516, 3)
local warnBonds		= mod:NewSpellAnnounce(59463, 3)
local warnChain		= mod:NewSpellAnnounce(54481, 2, nil, "Healer")

local timerShieldCD	= mod:NewCDTimer(20, 54479, nil, nil, nil, 3)--Core 20s repeat
local timerBloodlustCD	= mod:NewCDRangeTimer(35, 45, 54516, nil, nil, nil, 3)--Core 15s first, 35-45s repeat
local timerBondsCD	= mod:NewCDRangeTimer(16, 22, 59463, nil, nil, nil, 3)--Core 9-14s first, 16-22s repeat
local timerChainCD	= mod:NewCDRangeTimer(8, 11, 54481, nil, "Healer", nil, 3)--Core 0s first, 8-11s repeat
local timerShockCD	= mod:NewCDRangeTimer(8, 13, 54511, nil, nil, nil, 2)--Core 2-8s first, 8-13s repeat

function mod:OnCombatStart(delay)
	timerShieldCD:Start(20-delay)--Core 20s repeat
	timerBloodlustCD:Start(15-delay)--Core 15s first
	timerBondsCD:StartRange(9-delay, 14-delay)--Core 9-14s first
	timerChainCD:Start(5-delay)--Core 0s first (grace)
	timerShockCD:StartRange(2-delay, 8-delay)--Core 2-8s first
end

function mod:OnCombatEnd()
	timerShieldCD:Cancel()
	timerBloodlustCD:Cancel()
	timerBondsCD:Cancel()
	timerChainCD:Cancel()
	timerShockCD:Cancel()
end

function mod:SPELL_CAST_START(args)
	if args.spellId == 54516 then -- Bloodlust (core 35-45s repeat, was untracked)
		warnBloodlust:Show()
		timerBloodlustCD:StartRange(35, 45)
	elseif args.spellId == 59463 then -- Break Bonds (core 16-22s repeat, was untracked)
		warnBonds:Show()
		timerBondsCD:StartRange(16, 22)
	elseif args.spellId == 54481 then -- Chain Heal (core 8-11s repeat, was untracked)
		warnChain:Show()
		timerChainCD:StartRange(8, 11)
	elseif args.spellId == 54511 then -- Earth Shock (core 8-13s repeat, was untracked)
		timerShockCD:StartRange(8, 13)
	end
end

function mod:SPELL_AURA_APPLIED(args)
	if args:IsSpellID(54479, 59471)
	and mod:GetCIDFromGUID(args.sourceGUID) == 29315 then -- Earth Shield (core 20s repeat)
		warningES:Show()
		timerShieldCD:Start()
	end
end