local mod	= DBM:NewMod("Emalon", "DBM-VoA")
local L		= mod:GetLocalizedStrings()

mod:SetRevision("20220705003611")
mod:SetCreatureID(33993)
mod:SetUsedIcons(8)

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 64216 65279",
	"SPELL_CAST_SUCCESS 64213 64215",
	"SPELL_HEAL 64218",
	"SPELL_AURA_APPLIED 64217",
	"SPELL_AURA_REMOVED 64217"
)

local warnOverCharge		= mod:NewSpellAnnounce(64218, 4)
local warnChainLightning	= mod:NewSpellAnnounce(64213, 3)

local specWarnNova			= mod:NewSpecialWarningRun(65279, nil, nil, nil, 4, 2)

local timerNova				= mod:NewCastTimer(65279, nil, nil, nil, 2)
local timerNovaCD			= mod:NewCDTimer(40, 65279, nil, nil, nil, 2)--Core 40s first and repeat
local timerOvercharge		= mod:NewNextTimer(40, 64218, nil, nil, nil, 5, nil, DBM_COMMON_L.DAMAGE_ICON)--Core 47s first, 40s repeat
local timerChainCD			= mod:NewCDTimer(25, 64213, nil, nil, nil, 3)--Core 5s first, 25s repeat
local timerMobOvercharge	= mod:NewTimer(20, "timerMobOvercharge", 64217, nil, nil, 5, DBM_COMMON_L.DAMAGE_ICON, nil, nil, nil, nil, nil, nil, 64218)

local timerEmalonEnrage		= mod:NewBerserkTimer(360, nil, "EmalonEnrage")

mod:AddRangeFrameOption(10, 64213)
mod:AddSetIconOption("SetIconOnOvercharge", 64218, true, 5, {8})

local function ResetRange(self)
	if self.Options.RangeFrame then
		DBM.RangeCheck:DisableBossMode()
	end
end

function mod:OnCombatStart(delay)
	timerOvercharge:Start(47-delay)--Core 47s first
	timerNovaCD:Start(40-delay)--Core 40s first
	timerChainCD:Start(5-delay)--Core 5s first
	timerEmalonEnrage:Start(-delay)
	if self.Options.RangeFrame then
		DBM.RangeCheck:Show(10)
	end
end

function mod:OnCombatEnd()
	timerOvercharge:Cancel()
	timerNovaCD:Cancel()
	timerNova:Cancel()
	timerChainCD:Cancel()
	timerMobOvercharge:Cancel()
	if self.Options.RangeFrame then
		DBM.RangeCheck:Hide()
	end
end

function mod:SPELL_CAST_START(args)
	if args.spellId == 64216 or args.spellId == 65279 then
		timerNova:Start()
		timerNovaCD:Start()
		specWarnNova:Show()
		if self.Options.RangeFrame then
			-- On 10m you receive no damage outside 20 yards,
			-- on 25m you receive damage either way but 25 yards should be safe
			DBM.RangeCheck:SetBossRange(
				self:IsDifficulty("normal10", "heroic10") and 20 or 25,
				self:GetBossUnitByCreatureId(33993)
			)
			-- 5s cast
			self:Schedule(5.5, ResetRange, self)
		end
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	if args:IsSpellID(64213, 64215) then -- Chain Lightning (core 25s repeat, was untracked)
		warnChainLightning:Show()
		timerChainCD:Start()
	end
end

function mod:SPELL_HEAL(_, _, _, destGUID, _, _, spellId)
	if spellId == 64218 then
		warnOverCharge:Show()
		timerOvercharge:Start()
		if self.Options.SetIconOnOvercharge then
			self:ScanForMobs(destGUID, 2, 8, 1, 0.2, 10, "SetIconOnOvercharge")
		end
	end
end

function mod:SPELL_AURA_APPLIED(args)
	if args.spellId == 64217 then	-- 1 of 10 stacks (+1 each 2 seconds)
		timerMobOvercharge:Start()
	end
end

function mod:SPELL_AURA_REMOVED(args)
	if args.spellId == 64217 then
		timerMobOvercharge:Stop()
	end
end