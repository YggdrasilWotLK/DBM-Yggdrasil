local mod	= DBM:NewMod("Ignis", "DBM-Ulduar")
local L		= mod:GetLocalizedStrings()

mod:SetRevision("20220518110528")
mod:SetCreatureID(33118)
mod:SetUsedIcons(8)

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 62680 63472 62488",
	"SPELL_CAST_SUCCESS 62546 63474",
	"SPELL_AURA_APPLIED 62717 63477 62382 67114",
	"SPELL_AURA_REMOVED 62717 63477"
)

local warnSlagPot				= mod:NewTargetNoFilterAnnounce(63477, 3)
local warnConstruct				= mod:NewCountAnnounce(62488, 2)
local warnBerserk				= mod:NewSpellAnnounce(64238, 3)

local specWarnFlameJetsCast		= mod:NewSpecialWarningCast(63472, "SpellCaster", nil, nil, 2, 2)
local specWarnFlameBrittle		= mod:NewSpecialWarningSwitch(62382, "Dps", nil, nil, 1, 2)

local timerFlameJetsCast		= mod:NewCastTimer(2.7, 63472, nil, nil, nil, 5, nil, DBM_COMMON_L.IMPORTANT_ICON)
local timerActivateConstruct	= mod:NewCDCountTimer(30, 62488, nil, nil, nil, 1)
local timerFlameJetsCooldown	= mod:NewCDTimer(25, 63472, nil, nil, nil, 2, nil, DBM_COMMON_L.IMPORTANT_ICON)--Core 32s first, 25s repeat
local timerScorchCooldown		= mod:NewCDTimer(20, 62546, nil, nil, nil, 5)--Core 10s first, 20s repeat
local timerScorchCast			= mod:NewCastTimer(3, 62546)
local timerSlagPot				= mod:NewTargetTimer(10, 63477, nil, nil, nil, 3, nil, DBM_COMMON_L.DEADLY_ICON)
local timerGrabCD				= mod:NewCDTimer(24, 62707, nil, "Tank", nil, 5, nil, DBM_COMMON_L.TANK_ICON)--Core 25s first, ~24s repeat
local timerAchieve				= mod:NewAchievementTimer(240, 2930)

mod.vb.ConstructCount = 0

mod:AddSetIconOption("SlagPotIcon", 63477, false, false, {8})

function mod:OnCombatStart(delay)
	self.vb.ConstructCount = 0
	timerAchieve:Start()
	if self:IsDifficulty("normal10") then
		timerActivateConstruct:Start(40-delay, self.vb.ConstructCount)
	else
		timerActivateConstruct:Start(30-delay, self.vb.ConstructCount)--Core 30s on 25m
	end
	timerScorchCooldown:Start(10-delay)--Core 10s first
	timerFlameJetsCooldown:Start(32-delay)--Core 32s first
	timerGrabCD:Start(25-delay)--Core 25s first
end

function mod:OnCombatEnd()
	timerActivateConstruct:Cancel()
	timerFlameJetsCooldown:Cancel()
	timerFlameJetsCast:Cancel()
	timerScorchCooldown:Cancel()
	timerScorchCast:Cancel()
	timerGrabCD:Cancel()
end

function mod:SPELL_CAST_START(args)
	if args:IsSpellID(62680, 63472) then		-- Flame Jets
		timerFlameJetsCast:Start()
		specWarnFlameJetsCast:Show()
		specWarnFlameJetsCast:Play("stopcast")
		timerFlameJetsCooldown:Start()
	elseif args.spellId == 62488 then		-- Activate Construct
		self.vb.ConstructCount = self.vb.ConstructCount + 1
		warnConstruct:Show(self.vb.ConstructCount)
		if self.vb.ConstructCount < 20 then
			timerActivateConstruct:Start(self:IsDifficulty("normal10") and 40 or 30, self.vb.ConstructCount)
		else
			warnBerserk:Show()--Core berserks at 20 stacks (64238)
		end
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	if args:IsSpellID(62546, 63474) then	-- Scorch cast (core 20s repeat)
		timerScorchCast:Start()
		timerScorchCooldown:Start()
	end
end

function mod:SPELL_AURA_APPLIED(args)
	if args:IsSpellID(62717, 63477) then		-- Slag Pot (core grab 25s/~24s + 6s delay)
		warnSlagPot:Show(args.destName)
		timerSlagPot:Start(args.destName)
		timerGrabCD:Start()
		if self.Options.SlagPotIcon then
			self:SetIcon(args.destName, 8, 10)
		end
	elseif args:IsSpellID(62382, 67114) and self:AntiSpam(5, 1) then -- Brittle (67114 on 25m)
		specWarnFlameBrittle:Show()
		specWarnFlameBrittle:Play("killmob")
	end
end

function mod:SPELL_AURA_REMOVED(args)
	if args:IsSpellID(62717, 63477) then		-- Slag Pot
		if self.Options.SlagPotIcon then
			self:SetIcon(args.destName, 0)
		end
	end
end