local mod	= DBM:NewMod("Baltharus", "DBM-ChamberOfAspects", 2)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("20260913231151")
mod:SetCreatureID(39751, 39899) -- Baltharus, Clone(s)
mod:SetUsedIcons(1, 2, 3, 4, 5, 6, 7, 8)

mod:RegisterCombat("combat", 39751, 39899)

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 74509",
	"SPELL_AURA_APPLIED 75125 74502 74503 74504 74505",
	"SPELL_DAMAGE 40504",
	"SPELL_MISSED 40504",
	"UNIT_HEALTH boss1"
)

local warningSplitSoon		= mod:NewAnnounce("WarningSplitSoon", 2)


local warnWhirlwind0		= mod:NewAnnounce("Original Tempest", 2, nil, nil, nil, nil, nil)
local warnWhirlwind1		= mod:NewAnnounce("Clone 1 Tempest", 2, nil, nil, nil, nil, nil)
local warnWhirlwind2		= mod:NewAnnounce("Clone 2 Tempest", 2, nil, nil, nil, nil, nil)

--local warnWhirlwind			= mod:NewSpellAnnounce(75125, 3, nil, "Tank|Healer")
local warningSplitSoon		= mod:NewAnnounce("WarningSplitSoon", 2)
local warningWarnBrand		= mod:NewTargetAnnounce(74502, 4)
local warnCleave			= mod:NewSpellAnnounce(40504, 2, nil, "Tank|Healer")

local specWarnBrand			= mod:NewSpecialWarningYou(74502, nil, nil, nil, 3, 2)
local specWarnRepellingWave	= mod:NewSpecialWarningSpell(74509, nil, nil, nil, 2, 2)

--Nick bookmark, original tempest timer
local timerTempestOriginal	= mod:NewTimer(15, "Original Tempest", 75125, "Tank|Healer", nil, 5, nil, DBM_COMMON_L.TANK_ICON) --Core 15s first, 24s repeat
local timerTempestClone1	= mod:NewTimer(24, "Clone 1 Tempest", 75125, "Tank|Healer", nil, 5, nil, DBM_COMMON_L.TANK_ICON) --Nick bookmark
local timerTempestClone2	= mod:NewTimer(24, "Clone 2 Tempest", 75125, "Tank|Healer", nil, 5, nil, DBM_COMMON_L.TANK_ICON) --Nick bookmark

--local timerWhirlwind0		= mod:NewBuffActiveTimer(4, "Original Tempest ", nil, "Tank|Healer", nil, 3)
--local timerWhirlwind1		= mod:NewBuffActiveTimer(4, "Clone 1 Tempest ", nil, "Tank|Healer", nil, 3)
--local timerWhirlwind2		= mod:NewBuffActiveTimer(4, "Clone 2 Tempest ", nil, "Tank|Healer", nil, 3)
local timerWhirlwind0		= mod:NewTimer(4, "Original Tempest ends", 75125, "Tank|Healer", nil, 3)
local timerWhirlwind1		= mod:NewTimer(4, "Clone 1 Tempest ends", 75125, "Tank|Healer", nil, 3)
local timerWhirlwind2		= mod:NewTimer(4, "Clone 2 Tempest ends", 75125, "Tank|Healer", nil, 3)
local timerRepellingWave	= mod:NewCastTimer(4, 74509, nil, nil, nil, 2)--1 second cast + 3 second stun
local timerBrand			= mod:NewBuffActiveTimer(10, 74502, nil, nil, nil, 5)
local timerBrandCD		= mod:NewCDTimer(26, 74502, nil, nil, nil, 3)--Core 13s first, 26s repeat
local timerCleaveCD		= mod:NewCDTimer(24, 40504, nil, "Tank|Healer", nil, 5, nil, DBM_COMMON_L.TANK_ICON)--Core 11s first, 24s repeat

mod.vb.self.vb.tempestphase2 = 0
mod.vb.self.vb.tempestcount = 0 --Nick bookmark
mod.vb.self.vb.repelcount = 0 --Nick bookmark
mod.vb.self.vb.CloneCount = 0 --Nick bookmark

mod:AddRangeFrameOption(12, 74502)
mod:AddSetIconOption("SetIconOnBrand", 74502, false, false, {1, 2, 3, 4, 5, 6, 7, 8})

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
	self.vb.tempestphase2 = 0
	self.vb.CloneCount = 0
	self.vb.tempestcount = 0
	self.vb.repelcount = 0
	timerTempestOriginal:Start(15) --Core 15s first
	timerBrandCD:Start(13) --Core 13s first
	timerCleaveCD:Start(11) --Core 11s first
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
	self:Unschedule(showBrandWarning)
	timerTempestOriginal:Cancel()
	timerTempestClone1:Cancel()
	timerTempestClone2:Cancel()
	timerBrandCD:Cancel()
	timerCleaveCD:Cancel()
	timerRepellingWave:Cancel()
	if self.Options.RangeFrame then
		DBM.RangeCheck:Hide()
	end
end

function mod:SPELL_CAST_START(args)
	if args.spellId == 74509 and not self:IsDifficulty("normal25", "heroic25")  then
		specWarnRepellingWave:Show()
		specWarnRepellingWave:Play("carefly")
		timerRepellingWave:Start()
		timerTempestClone1:Start(21) --Core clone first tempest 18-25s, mean ~21s
		self.vb.CloneCount = 1
	elseif args.spellId == 74509 and self:IsDifficulty("normal25", "heroic25") and self.vb.repelcount ==	0 then
		specWarnRepellingWave:Show()
		specWarnRepellingWave:Play("carefly")
		timerRepellingWave:Start()
		self.vb.repelcount = 1 --Nick bookmark
		self.vb.CloneCount = 1
		timerTempestClone1:Start(21) --Nick bookmark, core 18-25s
	elseif args.spellId == 74509 and self:IsDifficulty("normal25", "heroic25") and self.vb.repelcount >= 1 then
		specWarnRepellingWave:Show()
		specWarnRepellingWave:Play("carefly")
		timerRepellingWave:Start()
		self.vb.repelcount = self.vb.repelcount + 1 --Nick bookmark
		self.vb.CloneCount = 2
		timerTempestClone2:Start(21) --Nick bookmark, core 18-25s
	end
end

function mod:SPELL_AURA_APPLIED(args)
	local spellId = args.spellId
		if args.spellId == 75125 and not self:IsDifficulty("normal25", "heroic25") then  --Nick bookmark, 10-man timers specifying original VS copy
			if self.vb.CloneCount == 0 then
				timerTempestOriginal:Cancel()
				timerTempestOriginal:Start(24)
				warnWhirlwind0:Show()
				timerWhirlwind0:Show()
			elseif self.vb.CloneCount == 1 and self.vb.tempestcount == 0 then
				self.vb.tempestcount = self.vb.tempestcount+1
				timerTempestOriginal:Cancel()
				timerTempestOriginal:Start(24)
				warnWhirlwind0:Show()
				timerWhirlwind0:Show()
			elseif self.vb.CloneCount == 1 and self.vb.tempestcount == 1 then
				self.vb.tempestcount = 0
				timerTempestClone1:Cancel()
				timerTempestClone1:Start(24)
				warnWhirlwind1:Show()
				timerWhirlwind1:Show()
			end
		elseif args.spellId == 75125 and self:IsDifficulty("normal25", "heroic25") then  --Nick bookmark, 25-man timers specifying original VS copies 1 and 2
			if self.vb.CloneCount == 0 then
				timerTempestOriginal:Cancel()
				timerTempestOriginal:Start(24)
				warnWhirlwind0:Show()
				timerWhirlwind0:Show()
			elseif self.vb.CloneCount == 1 and self.vb.tempestcount == 0 then
				self.vb.tempestcount = self.vb.tempestcount+1
				timerTempestOriginal:Cancel()
				timerTempestOriginal:Start(24)
				warnWhirlwind0:Show()
				timerWhirlwind0:Show()
			elseif self.vb.CloneCount == 1 and self.vb.tempestcount == 1 then
				self.vb.tempestcount = 0
				timerTempestClone1:Cancel()
				timerTempestClone1:Start(24)
				warnWhirlwind1:Show()
				timerWhirlwind1:Show()
			elseif self.vb.CloneCount == 2 and self.vb.tempestcount == 0 and self.vb.tempestphase2 == 0 then
				self.vb.tempestphase2 = self.vb.tempestphase2+1
				self.vb.tempestcount = 1
				timerTempestOriginal:Cancel()
				timerTempestOriginal:Start(24)
				warnWhirlwind0:Show()
				timerWhirlwind0:Show()
			elseif self.vb.CloneCount == 2 and self.vb.tempestcount == 0 and self.vb.tempestphase2 == 1 then
				self.vb.tempestphase2 = self.vb.tempestphase2+1
				self.vb.tempestcount = 1
				timerTempestOriginal:Cancel()
				timerTempestOriginal:Start(24)
				warnWhirlwind0:Show()
				timerWhirlwind0:Show()
			elseif self.vb.CloneCount == 2 and self.vb.tempestcount == 1 and self.vb.tempestphase2 == 0 then
				self.vb.tempestphase2 = self.vb.tempestphase2+1
				self.vb.tempestcount = 0
				timerTempestClone1:Cancel()
				timerTempestClone1:Start(24)
				warnWhirlwind1:Show()
				timerWhirlwind1:Show()
			elseif self.vb.CloneCount == 2 and self.vb.tempestcount == 1 and self.vb.tempestphase2 == 1 then
				self.vb.tempestphase2 = self.vb.tempestphase2+1
				self.vb.tempestcount = 0
				timerTempestClone1:Cancel()
				timerTempestClone1:Start(24)
				warnWhirlwind1:Show()
				timerWhirlwind1:Show()
			elseif self.vb.CloneCount == 2 and self.vb.tempestphase2 == 2 then
				self.vb.tempestphase2 = 0
				timerTempestClone2:Cancel()
				timerTempestClone2:Start(24)
				warnWhirlwind2:Show()
				timerWhirlwind2:Show()
			end
		elseif args:IsSpellID(74502, 74503, 74504, 74505) and self:IsInCombat() then--Only do this when boss is actually engaged, otherwise it doesn't really matter and just spams.
		brandTargets[#brandTargets + 1] = args.destName
		timerBrandCD:Start()
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

function mod:SPELL_DAMAGE(_, _, _, destGUID, _, _, spellId)
	if spellId == 40504 then -- Cleave (core 11s first, 24s repeat, no cast event)
		warnCleave:Show()
		timerCleaveCD:Start()
	end
end
mod.SPELL_MISSED = mod.SPELL_DAMAGE

function mod:UNIT_HEALTH(uId)
	if self:IsDifficulty("normal25", "heroic25") then
		if not self.vb.warnedSplit1 and self:GetUnitCreatureId(uId) == 39751 and UnitHealth(uId) / UnitHealthMax(uId) <= 0.66 then
			self.vb.warnedSplit1 = true
			warningSplitSoon:Show()
		elseif not self.vb.warnedSplit3 and self:GetUnitCreatureId(uId) == 39751 and UnitHealth(uId) / UnitHealthMax(uId) <= 0.33 then
			self.vb.warnedSplit3 = true
			warningSplitSoon:Show() 
		end
	else
		if not self.vb.warnedSplit2 and self:GetUnitCreatureId(uId) == 39751 and UnitHealth(uId) / UnitHealthMax(uId) <= 0.50 then
			self.vb.warnedSplit2 = true
			warningSplitSoon:Show()
		end
	end
end