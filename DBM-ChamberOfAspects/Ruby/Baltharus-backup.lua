local mod	= DBM:NewMod("Baltharus", "DBM-ChamberOfAspects", 2)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("20220518110528")
mod:SetCreatureID(39751, 39899) -- Baltharus, Clone(s)
mod:SetUsedIcons(1, 2, 3, 4, 5, 6, 7, 8)

mod:RegisterCombat("combat", 39751, 39899)

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 74509",
	"SPELL_AURA_APPLIED 75125 74505",
	"UNIT_HEALTH boss1"
)

local warningSplitSoon		= mod:NewAnnounce("WarningSplitSoon", 2)


local warnWhirlwind0		= mod:NewAnnounce("Original Tempest", 2, nil, nil, nil, nil, nil)
local warnWhirlwind1		= mod:NewAnnounce("Clone 1 Tempest", 2, nil, nil, nil, nil, nil)
local warnWhirlwind2		= mod:NewAnnounce("Clone 2 Tempest", 2, nil, nil, nil, nil, nil)

--local warnWhirlwind			= mod:NewSpellAnnounce(75125, 3, nil, "Tank|Healer")
local warningSplitSoon		= mod:NewAnnounce("WarningSplitSoon", 2)
local warningWarnBrand		= mod:NewTargetAnnounce(74505, 4)

local specWarnBrand			= mod:NewSpecialWarningYou(74505, nil, nil, nil, 3, 2)
local specWarnRepellingWave	= mod:NewSpecialWarningSpell(74509, nil, nil, nil, 2, 2)

--Nick bookmark, original tempest timer
local timerTempestOriginal	= mod:NewTimer(14, "Original Tempest", 75125, "Tank|Healer", nil, 5, nil, DBM_COMMON_L.TANK_ICON) --Nick bookmark
local timerTempestClone1	= mod:NewTimer(24, "Clone 1 Tempest", 75125, "Tank|Healer", nil, 5, nil, DBM_COMMON_L.TANK_ICON) --Nick bookmark
local timerTempestClone2	= mod:NewTimer(24, "Clone 2 Tempest", 75125, "Tank|Healer", nil, 5, nil, DBM_COMMON_L.TANK_ICON) --Nick bookmark

--local timerWhirlwind0		= mod:NewBuffActiveTimer(4, "Original Tempest ", nil, "Tank|Healer", nil, 3)
--local timerWhirlwind1		= mod:NewBuffActiveTimer(4, "Clone 1 Tempest ", nil, "Tank|Healer", nil, 3)
--local timerWhirlwind2		= mod:NewBuffActiveTimer(4, "Clone 2 Tempest ", nil, "Tank|Healer", nil, 3)
local timerWhirlwind0		= mod:NewTimer(4, "Original Tempest ends", 75125, "Tank|Healer", nil, 3)
local timerWhirlwind1		= mod:NewTimer(4, "Clone 1 Tempest ends", 75125, "Tank|Healer", nil, 3)
local timerWhirlwind2		= mod:NewTimer(4, "Clone 2 Tempest ends", 75125, "Tank|Healer", nil, 3)
local timerRepellingWave	= mod:NewCastTimer(4, 74509, nil, nil, nil, 2)--1 second cast + 3 second stun
local timerBrand			= mod:NewBuffActiveTimer(10, 74505, nil, nil, nil, 5)

tempestphase2	=	0
tempestcount	=	0 --Nick bookmark
repelcount		=	0 --Nick bookmark
CloneCount	=	0 --Nick bookmark

mod:AddRangeFrameOption(12, 74505)
mod:AddSetIconOption("SetIconOnBrand", 74505, false, false, {1, 2, 3, 4, 5, 6, 7, 8})

mod.vb.warnedSplit1	= false
mod.vb.warnedSplit2	= false
mod.vb.warnedSplit3	= false
local brandTargets = {}
mod.vb.brandIcon	= 8

local function showBrandWarning(self)
	warningWarnBrand:Show(table.concat(brandTargets, "<, >"))
	table.wipe(brandTargets)
	self.vb.brandIcon = 8
end

function mod:OnCombatStart()
	tempestphase2	=	0
	CloneCount		=	0
	tempestcount	=	0
	repelcount		=	0
	timerTempestOriginal:Start() --Nick bookmark
	self.vb.warnedSplit1 = false
	self.vb.warnedSplit2 = false
	self.vb.warnedSplit3 = false
	table.wipe(brandTargets)
	self.vb.brandIcon = 8
	if self.Options.RangeFrame then
		DBM.RangeCheck:Show(12)
	end
end


function mod:OnCombatEnd()
	if self.Options.RangeFrame then
		DBM.RangeCheck:Hide()
	end
end

function mod:SPELL_CAST_START(args)
	if args.spellId == 74509 and not self:IsDifficulty("normal25", "heroic25")  then
		specWarnRepellingWave:Show()
		specWarnRepellingWave:Play("carefly")
		timerRepellingWave:Start()
		timerTempestClone1:Start(22) --Nick bookmark
		CloneCount = 1
	elseif args.spellId == 74509 and self:IsDifficulty("normal25", "heroic25") and repelcount ==	0 then
		specWarnRepellingWave:Show()
		specWarnRepellingWave:Play("carefly")
		timerRepellingWave:Start()
		repelcount = 1 --Nick bookmark
		CloneCount = 1
		timerTempestClone1:Start(26) --Nick bookmark
	elseif args.spellId == 74509 and self:IsDifficulty("normal25", "heroic25") and repelcount ==	1 then
		specWarnRepellingWave:Show()
		specWarnRepellingWave:Play("carefly")
		timerRepellingWave:Start()
		repelcount = 2 --Nick bookmark
		CloneCount = 2
		timerTempestClone2:Start(24) --Nick bookmark
	end
end

function mod:SPELL_AURA_APPLIED(args)
	local spellId = args.spellId
		if args.spellId == 75125 and not self:IsDifficulty("normal25", "heroic25") then  --Nick bookmark, 10-man timers specifying original VS copy
			if CloneCount == 0 then
				timerTempestOriginal:Cancel()
				timerTempestOriginal:Start(24)
				warnWhirlwind0:Show()
				timerWhirlwind0:Show()
			elseif CloneCount == 1 and tempestcount == 0 then
				tempestcount = tempestcount+1
				timerTempestOriginal:Cancel()
				timerTempestOriginal:Start(24)
				warnWhirlwind0:Show()
				timerWhirlwind0:Show()
			elseif CloneCount == 1 and tempestcount == 1 then
				tempestcount = 0
				timerTempestClone1:Cancel()
				timerTempestClone1:Start(24)
				warnWhirlwind1:Show()
				timerWhirlwind1:Show()
			end
		elseif args.spellId == 75125 and self:IsDifficulty("normal25", "heroic25") then  --Nick bookmark, 25-man timers specifying original VS copies 1 and 2
			if CloneCount == 0 then
				timerTempestOriginal:Cancel()
				timerTempestOriginal:Start(24)
				warnWhirlwind0:Show()
				timerWhirlwind0:Show()
			elseif CloneCount == 1 and tempestcount == 0 then
				tempestcount = tempestcount+1
				timerTempestOriginal:Cancel()
				timerTempestOriginal:Start(24)
				warnWhirlwind0:Show()
				timerWhirlwind0:Show()
			elseif CloneCount == 1 and tempestcount == 1 then
				tempestcount = 0
				timerTempestClone1:Cancel()
				timerTempestClone1:Start(24)
				warnWhirlwind1:Show()
				timerWhirlwind1:Show()
			elseif CloneCount == 2 and tempestcount == 0 and tempestphase2 == 0 then
				tempestphase2 = tempestphase2+1
				tempestcount = 1
				timerTempestOriginal:Cancel()
				timerTempestOriginal:Start(24)
				warnWhirlwind0:Show()
				timerWhirlwind0:Show()
			elseif CloneCount == 2 and tempestcount == 0 and tempestphase2 == 1 then
				tempestphase2 = tempestphase2+1
				tempestcount = 1
				timerTempestOriginal:Cancel()
				timerTempestOriginal:Start(24)
				warnWhirlwind0:Show()
				timerWhirlwind0:Show()
			elseif CloneCount == 2 and tempestcount == 1 and tempestphase2 == 0 then
				tempestphase2 = tempestphase2+1
				tempestcount = 0
				timerTempestClone1:Cancel()
				timerTempestClone1:Start(24)
				warnWhirlwind1:Show()
				timerWhirlwind1:Show()
			elseif CloneCount == 2 and tempestcount == 1 and tempestphase2 == 1 then
				tempestphase2 = tempestphase2+1
				tempestcount = 0
				timerTempestClone1:Cancel()
				timerTempestClone1:Start(24)
				warnWhirlwind1:Show()
				timerWhirlwind1:Show()
			elseif CloneCount == 2 and tempestphase2 == 2 then
				tempestphase2 = 0
				timerTempestClone2:Cancel()
				timerTempestClone2:Start(24)
				warnWhirlwind2:Show()
				timerWhirlwind2:Show()
			end
		elseif spellId == 74505 and self:IsInCombat() then--Only do this when boss is actually engaged, otherwise it doesn't really matter and just spams.
		brandTargets[#brandTargets + 1] = args.destName
			if args:IsPlayer() then
			specWarnBrand:Show()
			specWarnBrand:Play("targetyou")
			timerBrand:Show()
			end
			if self.vb.brandIcon > 0 then
				if self.Options.SetIconOnBrand then
				self:SetIcon(args.destName, self.vb.brandIcon, 10)
			end
				self.vb.brandIcon = self.vb.brandIcon - 1
		end
		self:Unschedule(showBrandWarning)
		self:Schedule(0.5, showBrandWarning, self)
	end
end

function mod:UNIT_HEALTH(uId)
	if self:IsDifficulty("normal25", "heroic25") then
		if not self.vb.warnedSplit1 and self:GetUnitCreatureId(uId) == 39751 and UnitHealth(uId) / UnitHealthMax(uId) <= 0.70 then
			self.vb.warnedSplit1 = true
			warningSplitSoon:Show()
		elseif not self.vb.warnedSplit3 and self:GetUnitCreatureId(uId) == 39751 and UnitHealth(uId) / UnitHealthMax(uId) <= 0.37 then
			self.vb.warnedSplit3 = true
			warningSplitSoon:Show() 
		end
	else
		if not self.vb.warnedSplit2 and self:GetUnitCreatureId(uId) == 39751 and UnitHealth(uId) / UnitHealthMax(uId) <= 0.54 then
			self.vb.warnedSplit2 = true
			warningSplitSoon:Show()
		end
	end
end