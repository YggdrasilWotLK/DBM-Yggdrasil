local mod	= DBM:NewMod("Grobbulus", "DBM-Naxx", 2)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("20260913231415")
mod:SetCreatureID(15931)
mod:SetUsedIcons(1, 2, 3, 4)

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_AURA_APPLIED 28169",
	"SPELL_AURA_REMOVED 28169",
	"SPELL_CAST_SUCCESS 28240 28157 54364"
)

local warnInjection			= mod:NewTargetNoFilterAnnounce(28169, 2)
local warnCloud				= mod:NewSpellAnnounce(28240, 2)
local warnSlimeSprayNow		= mod:NewSpellAnnounce(54364, 2)
local warnSlimeSpraySoon	= mod:NewSoonAnnounce(54364, 1)

local specWarnInjection		= mod:NewSpecialWarningYou(28169, nil, nil, nil, 1, 2)
local yellInjection			= mod:NewYellMe(28169, nil, false)

local timerInjection		= mod:NewTargetTimer(10, 28169, nil, nil, nil, 3)
local timerInjectionCD	= mod:NewCDTimer(12, 28169, nil, nil, nil, 3)--Core 20s first, 6s+1.2s/hp% repeat (~12s avg)
local timerCloud			= mod:NewNextTimer(15, 28240, nil, nil, nil, 5, nil, DBM_COMMON_L.TANK_ICON)
local timerSlimeSpray		= mod:NewNextTimer(20, 54364, nil, nil, nil, 2)--Core 10s first, 20s repeat
local enrageTimer			= mod:NewBerserkTimer(720)

mod:AddSetIconOption("SetIconOnInjectionTarget", 28169, false, false, {1, 2, 3, 4})

mod.vb.slimeSprays = 1
local mutateIcons = {}

local function addIcon(self)
	for i,j in ipairs(mutateIcons) do
		local icon = 0 + i
		self:SetIcon(j, icon)
	end
end

local function removeIcon(self, target)
	for i,j in ipairs(mutateIcons) do
		if j == target then
			table.remove(mutateIcons, i)
			self:SetIcon(target, 0)
		end
	end
	addIcon(self)
end

function mod:OnCombatStart(delay)
	self.vb.slimeSprays = 1
	table.wipe(mutateIcons)
	if self:IsDifficulty("normal25", "heroic25") then
		enrageTimer:Start(540 - delay)--Core 9min on 25m
	else
		enrageTimer:Start(720 - delay)--Core 12min on 10m
	end
	warnSlimeSpraySoon:Schedule(5 - delay)
	timerSlimeSpray:Start(10 - delay)--Core 10s first, 20s repeat
	timerCloud:Start(15 - delay)--Core 15s first
	timerInjectionCD:Start(20 - delay)--Core 20s first
end

function mod:OnCombatEnd()
	for _, j in ipairs(mutateIcons) do
		self:SetIcon(j, 0)
	end
end

function mod:SPELL_AURA_APPLIED(args)
	if args.spellId == 28169 then
		warnInjection:Show(args.destName)
		timerInjection:Start(args.destName)
		timerInjectionCD:Start()--Core accelerates as boss HP drops; fixed restart, resyncs each cast
		if args:IsPlayer() then
			specWarnInjection:Show()
			specWarnInjection:Play("runout")
			yellInjection:Yell()
		end
		if self.Options.SetIconOnInjectionTarget then
			table.insert(mutateIcons, args.destName)
			addIcon(self)
		end
	end
end

function mod:SPELL_AURA_REMOVED(args)
	if args.spellId == 28169 then
		timerInjection:Cancel(args.destName)--Cancel timer if someone is dumb and dispels it.
		if self.Options.SetIconOnInjectionTarget then
			removeIcon(self, args.destName)
		end
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	if args.spellId == 28240 then
		warnCloud:Show()
		timerCloud:Start()
	elseif args:IsSpellID(28157, 54364) then -- Slime Spray (core flat 20s)
		warnSlimeSprayNow:Show()
		warnSlimeSpraySoon:Schedule(15)
		timerSlimeSpray:Start(20)
	end
end