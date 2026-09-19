local mod	= DBM:NewMod("FlameLeviathan", "DBM-Ulduar")
local L		= mod:GetLocalizedStrings()

mod:SetRevision("20260914090752")

mod:SetCreatureID(33113)

mod:RegisterCombat("yell", L.YellPull)

mod:RegisterEventsInCombat(
	"SPELL_AURA_APPLIED 62396 62475 62374 62533",
	"SPELL_AURA_REMOVED 62396 62374",
	"SPELL_SUMMON 62906 62907 62947"
)

local warnHodirsFury		= mod:NewTargetAnnounce(62533, 3)
local warnPursueTarget		= mod:NewAnnounce("PursueWarn", 2, 62374, nil, nil, nil, 62374)
local warnNextPursueSoon	= mod:NewAnnounce("warnNextPursueSoon", 3, 62374, nil, nil, nil, 62374)

local specWarnSystemOverload= mod:NewSpecialWarningSpell(62475, nil, nil, nil, 1, 12)
local specWarnPursue		= mod:NewSpecialWarning("SpecialPursueWarnYou", nil, nil, 2, 4, 2, nil, 62374, 62374)
local specWarnWardOfLife	= mod:NewSpecialWarning("warnWardofLife", nil, nil, nil, 1, 2, nil, 62906, 62906)

local timerSystemOverload	= mod:NewBuffActiveTimer(20, 62475, nil, nil, nil, 6)
local timerFlameVents		= mod:NewCastTimer(10, 62396, nil, nil, nil, 2, nil, DBM_COMMON_L.INTERRUPT_ICON)
local timerNextFlameVents	= mod:NewNextTimer(20, 62396, nil, nil, nil, 2)
local timerPursued			= mod:NewTargetTimer(31, 62374, nil, nil, nil, 3)--Core 31s repeat

local guids = {}
local function buildGuidTable(self)
	table.wipe(guids)
	for uId in DBM:GetGroupMembers() do
		local name, server = GetUnitName(uId, true)
		local fullName = name .. (server and server ~= "" and ("-" .. server) or "")
		guids[UnitGUID(uId.."pet") or "none"] = fullName
	end
end

function mod:OnCombatStart(delay)
	buildGuidTable(self)
	timerNextFlameVents:Start(20-delay)--Core 20s both modes
end

function mod:OnCombatEnd()
	timerNextFlameVents:Cancel()
	timerFlameVents:Cancel()
	timerSystemOverload:Cancel()
	timerPursued:Cancel()
	warnNextPursueSoon:Cancel()
end

function mod:OnTimerRecovery()
	buildGuidTable(self)
end

function mod:SPELL_AURA_APPLIED(args)
	local spellId = args.spellId
	if spellId == 62396 then		-- Flame Vents
		timerFlameVents:Start()
		timerNextFlameVents:Start()
	elseif spellId == 62475 then	-- Systems Shutdown / Overload
		timerSystemOverload:Start()
		timerNextFlameVents:Stop()
		-- Core only delays events ~0ms on shutdown; vents resume on normal 20s loop.
		timerNextFlameVents:Start(20)
		specWarnSystemOverload:Show()
		specWarnSystemOverload:Play("attacktank")
	elseif spellId == 62374 then	-- Pursued (core 31s repeat)
		local target = guids[args.destGUID]
		warnNextPursueSoon:Schedule(26)
		timerPursued:Start(31, target)
		if target then
			warnPursueTarget:Show(target)
			if target == UnitName("player") then
				specWarnPursue:Show()
				specWarnPursue:Play("justrun")
			end
		end
	elseif spellId == 62533 then	-- Hodir's Fury (core ID, was 62297)
		local target = guids[args.destGUID]
		if target then
			warnHodirsFury:Show(target)
		end
	end
end

function mod:SPELL_AURA_REMOVED(args)
	local spellId = args.spellId
	if spellId == 62396 then
		timerFlameVents:Stop()
	elseif spellId == 62374 then	-- Pursued
		local target = guids[args.destGUID]
		timerPursued:Stop(target)
	end
end

function mod:SPELL_SUMMON(args)
	if args:IsSpellID(62906, 62907, 62947) and self:AntiSpam(3, 1) then		-- Ward of Life spawned (core 62906/62947)
		specWarnWardOfLife:Show()
		specWarnWardOfLife:Show("bigmob")
	end
end