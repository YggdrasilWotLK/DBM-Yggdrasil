local mod	= DBM:NewMod("Keristrasza", "DBM-Party-WotLK", 8)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("20220518110528")
mod:SetCreatureID(26723)

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 48096 50155",
	"SPELL_CAST_SUCCESS 48179 8599 50997",--50997 SUCCESS carries no destName, handled via AURA_APPLIED instead
	"SPELL_AURA_APPLIED 50997",
	"SPELL_AURA_REMOVED 50997"
)

local warningChains		= mod:NewTargetAnnounce(50997, 4)
local warningNova		= mod:NewSpellAnnounce(48179, 3)
local warningEnrage		= mod:NewSpellAnnounce(8599, 3, nil, "Tank|Healer", 2)
local warnBreath		= mod:NewSpellAnnounce(48096, 3, nil, "Tank")
local warnTailSweep		= mod:NewSpellAnnounce(50155, 2, nil, "Melee")

local timerChains		= mod:NewTargetTimer(10, 50997, nil, "Healer", 2, 5, nil, DBM_COMMON_L.HEALER_ICON..DBM_COMMON_L.MAGIC_ICON)
local timerChainsCD		= mod:NewCDTimer(20, 50997, nil, nil, nil, 3)--Core 20s first and repeat (normal only)
local timerNova			= mod:NewBuffActiveTimer(10, 48179)
local timerNovaCD		= mod:NewCDTimer(11, 48179, nil, nil, nil, 2)--Core 11s repeat (heroic Crystalize)
local timerBreathCD		= mod:NewCDTimer(14, 48096, nil, "Tank", nil, 3)--Core 14s (Crystalfire Breath, was untracked)
local timerTailCD			= mod:NewCDTimer(5, 50155, nil, "Melee", nil, 2)--Core 5s (Tail Sweep, was untracked)

function mod:OnCombatStart(delay)
	timerChainsCD:Start(20-delay)--Core 20s first (normal)
	timerNovaCD:Start(11-delay)--Core 11s (heroic)
	timerBreathCD:Start(14-delay)--Core 14s
	timerTailCD:Start(5-delay)--Core 5s
end

function mod:OnCombatEnd()
	timerChainsCD:Cancel()
	timerNovaCD:Cancel()
	timerBreathCD:Cancel()
	timerTailCD:Cancel()
end

function mod:SPELL_CAST_START(args)
	if args.spellId == 48096 then -- Crystalfire Breath (was untracked)
		warnBreath:Show()
		timerBreathCD:Start()
	elseif args.spellId == 50155 then -- Tail Sweep (was untracked)
		warnTailSweep:Show()
		timerTailCD:Start()
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	if args.spellId == 48179 then -- Crystalize (heroic, core 11s repeat)
		warningNova:Show()
		timerNova:Start()
		timerNovaCD:Start()
	elseif args.spellId == 8599 and args.sourceGUID and self:GetCIDFromGUID(args.sourceGUID) == 26723 then -- Enrage (fixed souceGUID typo)
		warningEnrage:Show()
	end
end

function mod:SPELL_AURA_APPLIED(args)
	if args.spellId == 50997 then -- Crystal Chains (normal; heroic uses Crystalize, no destName on SUCCESS)
		warningChains:Show(args.destName)
		timerChains:Start(args.destName)
		timerChainsCD:Start()
	end
end

function mod:SPELL_AURA_REMOVED(args)
	if args.spellId == 50997 then
		timerChains:Cancel(args.destName)
	end
end