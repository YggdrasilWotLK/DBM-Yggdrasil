local mod	= DBM:NewMod("Ionar", "DBM-Party-WotLK", 6)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("20260914104916")
mod:SetCreatureID(28546)
mod:SetUsedIcons(8)

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 52770 52780",
	"SPELL_AURA_APPLIED 52658",
	"SPELL_AURA_REMOVED 52658",
	"UNIT_HEALTH boss1"
)

local warningDisperseSoon	= mod:NewSoonAnnounce(52770, 2)
local warningDisperse		= mod:NewSpellAnnounce(52770, 3)
local warningOverload		= mod:NewTargetAnnounce(52658, 2)
local warnBall				= mod:NewSpellAnnounce(52780, 3)

local specWarnOverload		= mod:NewSpecialWarningMoveAway(52658, nil, nil, nil, 1, 2)

local timerOverload			= mod:NewTargetTimer(10, 52658, nil, nil, nil, 3)
local timerOverloadCD			= mod:NewCDRangeTimer(5, 6, 52658, nil, nil, nil, 3)--Core 5-6s repeat (was untracked)
local timerBallCD				= mod:NewCDRangeTimer(10, 11, 52780, nil, nil, nil, 3)--Core every 10-11s (was untracked)

mod:AddRangeFrameOption(10, 52658)
mod:AddSetIconOption("SetIconOnOverloadTarget", 52658, true, false, {8})

local warnedDisperse = false

function mod:OnCombatStart(delay)
	warnedDisperse = false
	timerOverloadCD:StartRange(5-delay, 6-delay)--Core 5-6s
	timerBallCD:StartRange(10-delay, 11-delay)--Core every 10-11s
end

function mod:OnCombatEnd()
	timerOverloadCD:Cancel()
	timerBallCD:Cancel()
	if self.Options.RangeFrame then
		DBM.RangeCheck:Hide()
	end
end

function mod:SPELL_AURA_APPLIED(args)
	if args.spellId == 52658 then -- Static Overload (core single ID both modes)
		if args:IsPlayer() then
			specWarnOverload:Show()
			specWarnOverload:Play("runout")
			if self.Options.RangeFrame then
				DBM.RangeCheck:Show(10)
			end
		else
			warningOverload:Show(args.destName)
		end
		timerOverload:Start(args.destName)
		timerOverloadCD:StartRange(5, 6)
		if self.Options.SetIconOnOverloadTarget then
			self:SetIcon(args.destName, 8, 10)
		end
	end
end

function mod:SPELL_AURA_REMOVED(args)
	if args.spellId == 52658 then
		if args:IsPlayer() and self.Options.RangeFrame then
			DBM.RangeCheck:Hide()
		end
		if self.Options.SetIconOnOverloadTarget then
			self:SetIcon(args.destName, 0)
		end
	end
end

function mod:SPELL_CAST_START(args)
	if args.spellId == 52770 then
		warningDisperse:Show()
	elseif args.spellId == 52780 then -- Ball Lightning (core every 10-11s, was untracked)
		warnBall:Show()
		timerBallCD:StartRange(10, 11)
	end
end

function mod:UNIT_HEALTH(uId)
	if not warnedDisperse and self:GetUnitCreatureId(uId) == 28546 and UnitHealth(uId) / UnitHealthMax(uId) <= 0.54 then
		warnedDisperse = true
		warningDisperseSoon:Show()
	end
end