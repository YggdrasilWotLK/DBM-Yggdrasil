local mod	= DBM:NewMod("Sindragosa", "DBM-Icecrown", 4)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("20260919194947")
mod:SetCreatureID(36853)
mod:SetUsedIcons(1, 2, 3, 4, 5, 6)
mod:SetMinSyncRevision(20220623000000)

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 69649 70123 71056 71057 71058 73061 73062 73063 73064 71077",
	"SPELL_CAST_SUCCESS 70117",
	"SPELL_AURA_APPLIED 11719 31589 70126 69762 70106 69766 70127 72528 72529 72530",
	"SPELL_AURA_REFRESH 11719 31589",
	"SPELL_AURA_APPLIED_DOSE 70106 69766 70127 72528 72529 72530",
	"SPELL_AURA_REMOVED 11719 31589 69762 70157 70106 69766 70127 72528 72529 72530",
	"UNIT_HEALTH boss1",
	"CHAT_MSG_MONSTER_YELL"
)

local strupper = strupper
local myRealm = select(3, DBM:GetMyPlayerInfo())

-- General
local berserkTimer				= mod:NewBerserkTimer((myRealm == "Lordaeron" or myRealm == "Frostmourne") and 420 or 600)

mod:AddBoolOption("RangeFrame", true) -- keep as BoolOption since the localization offers important information regarding boss ability and player debuff behaviour
mod:AddBoolOption("ClearIconsOnAirphase", true) -- don't group with any spellId, it applies to all raid icons

-- Stage One
mod:AddTimerLine(DBM_CORE_L.SCENARIO_STAGE:format(1))
local warnAirphase				= mod:NewAnnounce("WarnAirphase", 2, 43810)
local warnGroundphaseSoon		= mod:NewAnnounce("WarnGroundphaseSoon", 2, 43810)
local warnPhase2soon			= mod:NewPrePhaseAnnounce(2)
local warnInstability			= mod:NewCountAnnounce(69766, 2, nil, false)
local warnChilledtotheBone		= mod:NewCountAnnounce(70106, 2, nil, false)
local warnFrostBeacon			= mod:NewTargetNoFilterAnnounce(70126, 4)
local warnFrostBreath			= mod:NewSpellAnnounce(69649, 2, nil, "Tank|Healer")
local warnUnchainedMagic		= mod:NewTargetAnnounce(69762, 2, nil, "SpellCaster", 2)

local specWarnUnchainedMagic	= mod:NewSpecialWarningYou(69762, nil, nil, nil, 1, 2)
local specWarnFrostBeacon		= mod:NewSpecialWarningMoveAway(70126, nil, nil, nil, 3, 2)
local specWarnFrostBeaconSide	= mod:NewSpecialWarningMoveTo(70126, nil, nil, nil, 3, 2)
local specWarnInstability		= mod:NewSpecialWarningStack(69766, nil, mod:IsHeroic() and 4 or 8, nil, nil, 1, 6)
local specWarnChilledtotheBone	= mod:NewSpecialWarningStack(70106, nil, mod:IsHeroic() and 4 or 8, nil, nil, 1, 6)
local specWarnBlisteringCold	= mod:NewSpecialWarningRun(70123, nil, nil, nil, 4, 2)
local specWarnIcyGrip			= mod:NewSpecialWarningRun(70117, nil, nil, nil, 4, 2) --Nick bookmark

local timerNextAirphase			= mod:NewTimer(110, "TimerNextAirphase", 43810, nil, nil, 6)
local timerNextGroundphase		= mod:NewTimer(45, "TimerNextGroundphase", 43810, nil, nil, 6)
local timerNextFrostBreath		= mod:NewNextRangeTimer(20, 25, 69649, nil, "Tank|Healer", nil, 5, nil, DBM_COMMON_L.TANK_ICON)
local timerNextBlisteringCold	= mod:NewCDTimer(35, 70123, nil, nil, nil, 2, nil, DBM_COMMON_L.DEADLY_ICON, true, 2) -- Core: +1s after Icy Grip, no independent timer
local timerNextIcyGrip			= mod:NewCDRangeTimer(35, 40, 70117, nil, nil, nil, 2, nil, DBM_COMMON_L.DEADLY_ICON, true, 2) --Nick bookmark; core 33.5s P1 first, 35-40s P3
local timerNextBeacon			= mod:NewNextCountTimer(20, 70126, nil, nil, nil, 3, nil, DBM_COMMON_L.DEADLY_ICON) -- Core 7-10s first, 18-22s repeat
-- local timerBlisteringCold		= mod:NewCastTimer(6, 70123, nil, nil, nil, 2) -- Nick bookmark, not called later, disabled in v. 1.0.3 beta
local timerUnchainedMagic		= mod:NewCDRangeTimer(30, 35, 69762, nil, nil, nil, 3)
local timerInstability			= mod:NewBuffFadesTimer(5, 69766, nil, nil, nil, 5)
local timerChilledtotheBone		= mod:NewBuffFadesTimer(8, 70106, nil, nil, nil, 5)
local timerTailSmash			= mod:NewCDRangeTimer(22, 27, 71077, nil, nil, nil, 2) -- Core 22-27s P1, 19-23s P3

local soundUnchainedMagic		= mod:NewSoundYou(69762, nil, "SpellCaster")

mod:AddSetIconOption("SetIconOnFrostBeacon", 70126, true, 7, {1, 2, 3, 4, 5, 6})
mod:AddSetIconOption("SetIconOnUnchainedMagic", 69762, true, 0, {1, 2, 3, 4, 5, 6})
mod:AddBoolOption("AnnounceFrostBeaconIcons", false, nil, nil, nil, nil, 70126)
mod:AddBoolOption("AssignWarnDirectionsCount", true, nil, nil, nil, nil, 70126)

-- Stage Two
mod:AddTimerLine(DBM_CORE_L.SCENARIO_STAGE:format(2))
local warnPhase2				= mod:NewPhaseAnnounce(2, 2, nil, nil, nil, nil, nil, 2)
local warnMysticBuffet			= mod:NewCountAnnounce(70128, 2, nil, false)

local specWarnMysticBuffet		= mod:NewSpecialWarningStack(70128, false, 5, nil, nil, 1, 6)

local timerMysticBuffet			= mod:NewBuffFadesTimer(8, 70128, nil, nil, nil, 5)
local timerNextMysticBuffet		= mod:NewNextTimer(6, 70128, nil, nil, nil, 2)
local timerMysticAchieve		= mod:NewAchievementTimer(30, 4620, "AchievementMystic")

mod:AddBoolOption("AchievementCheck", false, "announce", nil, nil, nil, 4620, "achievement")

gripped	=	0
tongued	=	0
slowed	=	0

local beaconTargets		= {}
local unchainedTargets	= {}
mod.vb.warned_P2 = false
mod.vb.warnedfailed = false
mod.vb.unchainedIcons = 1
mod.vb.beaconP2Count = 1
local playerUnchained = false
local playerBeaconed = false

local directionIndex
local DirectionAssignments = {DBM_COMMON_L.LEFT, DBM_COMMON_L.MIDDLE, DBM_COMMON_L.RIGHT}
local DirectionVoiceAssignments	= {"left", "center", "right"}

local beaconDebuffFilter, unchainedDebuffFilter
do
	local beaconDebuff, unchainedDebuff = DBM:GetSpellInfo(70126), DBM:GetSpellInfo(69762)
	beaconDebuffFilter = function(uId)
		return DBM:UnitDebuff(uId, beaconDebuff)
	end
	unchainedDebuffFilter = function(uId)
		return DBM:UnitDebuff(uId, unchainedDebuff)
	end
end

local function warnBeaconTargets(self)
	if self.Options.RangeFrame then
		if not playerBeaconed then
			DBM.RangeCheck:Show(10, beaconDebuffFilter, nil, nil, nil, 9)
		else
			DBM.RangeCheck:Show(10, nil, nil, nil, nil, 9)
		end
	end
	if self.Options.AssignWarnDirectionsCount then
		if self.vb.phase == 1 then
			if self:IsDifficulty("normal25") then
				-- 5 beacons
				warnFrostBeacon:Show("\n<   >"..
				strupper(DBM_COMMON_L.LEFT)		..": <".."   >"..(beaconTargets[1] or DBM_COMMON_L.UNKNOWN).."<, >"..(beaconTargets[2] or DBM_COMMON_L.UNKNOWN).."<   >\n".."<   >"..
				strupper(DBM_COMMON_L.MIDDLE)	..": <".."   >"..(beaconTargets[3] or DBM_COMMON_L.UNKNOWN).."<   >\n".."<   >"..
				strupper(DBM_COMMON_L.RIGHT)	..": <".."   >"..(beaconTargets[4] or DBM_COMMON_L.UNKNOWN).."<, >"..(beaconTargets[5] or DBM_COMMON_L.UNKNOWN))
			elseif self:IsDifficulty("heroic25") then
				-- 6 beacons
				warnFrostBeacon:Show("\n<   >"..
				strupper(DBM_COMMON_L.LEFT)		..": <".."   >"..(beaconTargets[1] or DBM_COMMON_L.UNKNOWN).."<, >"..(beaconTargets[2] or DBM_COMMON_L.UNKNOWN).."<   >\n".."<   >"..
				strupper(DBM_COMMON_L.MIDDLE)	..": <".."   >"..(beaconTargets[3] or DBM_COMMON_L.UNKNOWN).."<, >"..(beaconTargets[4] or DBM_COMMON_L.UNKNOWN).."<   >\n".."<   >"..
				strupper(DBM_COMMON_L.RIGHT)	..": <".."   >"..(beaconTargets[5] or DBM_COMMON_L.UNKNOWN).."<, >"..(beaconTargets[6] or DBM_COMMON_L.UNKNOWN))
			elseif self:IsDifficulty("normal10", "heroic10") then
				-- 2 beacons
				warnFrostBeacon:Show("\n<   >"..
				strupper(DBM_COMMON_L.LEFT)		..": <".."   >"..(beaconTargets[1] or DBM_COMMON_L.UNKNOWN).."<   >\n".."<   >"..
				strupper(DBM_COMMON_L.RIGHT)	..": <".."   >"..(beaconTargets[2] or DBM_COMMON_L.UNKNOWN))
			end
		elseif self.vb.phase == 2 then
			warnFrostBeacon:Show(beaconTargets[1].."< = >"..self.vb.beaconP2Count - 1)
		end
	else
		warnFrostBeacon:Show(table.concat(beaconTargets, "<, >"))
	end
	table.wipe(beaconTargets)
	playerBeaconed = false
end

local function warnUnchainedTargets(self)
	if self.Options.RangeFrame then
		if not playerUnchained then
			DBM.RangeCheck:Show(21, unchainedDebuffFilter) -- 21.5 yd with new radar calculations. 21 here since radar code adds 0.5 to activeRange
		else
			DBM.RangeCheck:Show(21) -- 21.5 yd with new radar calculations. 21 here since radar code adds 0.5 to activeRange
		end
	end
	warnUnchainedMagic:Show(table.concat(unchainedTargets, "<, >"))
	if self.vb.phase == 1 then--Core 30-35s P1, 12-17s P3
		timerUnchainedMagic:StartRange(30, 35)
	else
		timerUnchainedMagic:StartRange(12, 17)
	end
	table.wipe(unchainedTargets)
	self.vb.unchainedIcons = 1
	playerUnchained = false
end

local function directionBeaconTargets(self, index)
	if index then
		if self:IsDifficulty("normal25") then
			if (index == 1 or index == 2) then directionIndex = 1		--LEFT
			elseif (index == 3) then directionIndex = 2					--CENTER
			else directionIndex = 3 end									--RIGHT
		elseif self:IsDifficulty("heroic25") then
			if (index == 1 or index == 2) then directionIndex = 1		--LEFT
			elseif (index == 3 or index == 4) then directionIndex = 2	--CENTER
			else directionIndex = 3 end									--RIGHT
		elseif self:IsDifficulty("normal10", "heroic10") then
			if index == 1 then directionIndex = 1						--LEFT
			else directionIndex = 3 end									--RIGHT
		end
		specWarnFrostBeaconSide:Show(DirectionAssignments[directionIndex])
		specWarnFrostBeaconSide:Play(DirectionVoiceAssignments[directionIndex] or "scatter")
	end
end

local function ResetRange(self)
	if self.Options.RangeFrame then
		DBM.RangeCheck:DisableBossMode()
	end
end

function mod:AnnounceBeaconIcons(uId, icon)
	if self.Options.AnnounceFrostBeaconIcons and IsInGroup() and DBM:GetRaidRank() > 1 then
		SendChatMessage(L.BeaconIconSet:format(icon, DBM:GetUnitFullName(uId)), IsInRaid() and "RAID" or "PARTY")
	end
end

function mod:OnCombatStart(delay)
	self:SetStage(1)
	berserkTimer:Start(-delay)
	timerNextAirphase:Start(50-delay)
	timerNextBlisteringCold:Start(34.5-delay) -- Icy Grip 33.5s + 1s
	timerNextIcyGrip:Start(33.5-delay) --Nick bookmark; core 33.5s
	timerNextFrostBreath:StartRange(8-delay, 12-delay) -- Core 8-12s first
	timerUnchainedMagic:StartRange(9-delay, 14-delay) -- Core 9-14s first
	timerTailSmash:Start(20-delay)
	self.vb.warned_P2 = false
	self.vb.warnedfailed = false
	table.wipe(beaconTargets)
	table.wipe(unchainedTargets)
	self.vb.unchainedIcons = 1
	self.vb.beaconP2Count = 1
	playerUnchained = false
	playerBeaconed = false
	gripped = 0
	tongued = 0 -- Curse of Tongues tracker
	slowed	= 0 -- arcane mage slow tracker	
end

function mod:OnCombatEnd()
	if self.Options.RangeFrame then
		DBM.RangeCheck:Hide()
	end
end

function mod:SPELL_CAST_START(args)
	if args:IsSpellID(69649, 71056, 71057, 71058) or args:IsSpellID(73061, 73062, 73063, 73064) then--Frost Breath
		warnFrostBreath:Show()
		if self.vb.phase == 1 then--Core 20-25s P1, 7-10s P3
			timerNextFrostBreath:StartRange(20, 25)
		else
			timerNextFrostBreath:StartRange(7, 10)
		end
	elseif args.spellId == 71077 then--Tail Smash, core 22-27s P1, 19-23s P3
		if self.vb.phase == 1 then
			timerTailSmash:StartRange(22, 27)
		else
			timerTailSmash:StartRange(19, 23)
		end
	elseif args.spellId == 70123 then
		if tongued == 1 or slowed == 1 then
			timerNextBlisteringCold:Cancel()
			timerNextBlisteringCold:Start(6.5)
			tongued = 0
			slowed	= 0
		end
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	local spellId = args.spellId
	if spellId == 70117 then--Icy Grip Cast, not blistering cold, but adds an extra 1sec to the warning
		specWarnBlisteringCold:Show()
		specWarnBlisteringCold:Play("runout")
		gripped = 1
		-- Core: Blistering Cold follows Grip by ~1s (+5s yell)
		timerNextBlisteringCold:Start(1)
		timerNextIcyGrip:Start(37)
		if self.Options.RangeFrame then
			DBM.RangeCheck:SetBossRange(25, self:GetBossUnitByCreatureId(36853))
			self:Schedule(5.5, ResetRange, self)
		end
	end
end

function mod:SPELL_AURA_REFRESH(args)
	local spellId = args.spellId
	if spellId == 11719 then --Curse of Tongues refresh tracker, Nick bookmark
	tongued = 1
	elseif spellId == 31589 then --Arcane mage slow refresh tracker, Nick bookmark
	slowed = 1
	end
end

function mod:SPELL_AURA_APPLIED(args)
	local spellId = args.spellId
	if spellId == 11719 then --Curse of Tongues application tracker, Nick bookmark
	tongued = 1
	elseif spellId == 31589 then --Arcane mage slow application tracker, Nick bookmark
	slowed = 1
	elseif spellId == 70126 then
		beaconTargets[#beaconTargets + 1] = args.destName
		if args:IsPlayer() then
			playerBeaconed = true
			-- Beacon Direction snippet
			if self.vb.phase == 1 and self.Options.SpecWarn70126moveto then
				for i = 1, #beaconTargets do
					local targetName = beaconTargets[i]
					if targetName == DBM:GetMyPlayerInfo() then
						directionBeaconTargets(self, i)
					end
				end
			else
				specWarnFrostBeacon:Show()
				specWarnFrostBeacon:Play("scatter")
			end
		end
		if self.vb.phase == 2 then--Phase 2 there is only one icon/beacon, don't use sorting method if we don't have to.
			if self.vb.beaconP2Count == 4 or self.vb.beaconP2Count == 8 or self.vb.beaconP2Count == 12 or self.vb.beaconP2Count == 16 then
				timerNextIcyGrip:StartRange(35, 40)--Core P3 Icy 35-40s
				timerNextBeacon:StartRange(18, 22, self.vb.beaconP2Count)
			elseif self.vb.beaconP2Count == 1 or self.vb.beaconP2Count == 2 or self.vb.beaconP2Count == 3 or self.vb.beaconP2Count == 5 or self.vb.beaconP2Count == 6 or self.vb.beaconP2Count == 7 or self.vb.beaconP2Count == 9 or self.vb.beaconP2Count == 10 or self.vb.beaconP2Count == 11 or self.vb.beaconP2Count == 13 or self.vb.beaconP2Count == 14 or self.vb.beaconP2Count == 15 or self.vb.beaconP2Count == 17 or self.vb.beaconP2Count == 18 or self.vb.beaconP2Count == 19 then
			timerNextBeacon:StartRange(18, 22, self.vb.beaconP2Count)
			elseif self.vb.beaconP2Count == 20 then
				timerNextIcyGrip:StartRange(35, 40)--Core P3 Icy 35-40s
				timerNextBeacon:StartRange(18, 22, self.vb.beaconP2Count)
				self.vb.beaconP2Count = 0 -- Nick bookmark, loops beacon count back to 0 to repeat timers without longer code
			end
			self.vb.beaconP2Count = self.vb.beaconP2Count + 1
			if self.Options.SetIconOnFrostBeacon then
				self:SetIcon(args.destName, 8)
				if self.Options.AnnounceFrostBeaconIcons and IsInGroup() and DBM:GetRaidRank() > 1 then
					SendChatMessage(L.BeaconIconSet:format(8, args.destName), IsInRaid() and "RAID" or "PARTY")
				end
			end
			warnBeaconTargets(self)
		else--Phase 1 air phase, multiple beacons
			local maxBeacon = self:IsDifficulty("heroic25") and 6 or self:IsDifficulty("normal25") and 5 or 2--Heroic 10 and normal 2 are both 2
			if self.Options.SetIconOnFrostBeacon then
				self:SetSortedIcon("roster", 0.3, args.destName, 1, maxBeacon, false, "AnnounceBeaconIcons")
			end
			self:Unschedule(warnBeaconTargets)
			if #beaconTargets >= maxBeacon then
				warnBeaconTargets(self)
			else
				self:Schedule(0.3, warnBeaconTargets, self)
			end
		end
	elseif spellId == 69762 then
		unchainedTargets[#unchainedTargets + 1] = args.destName
		if args:IsPlayer() then
			playerUnchained = true
			specWarnUnchainedMagic:Show()
			specWarnUnchainedMagic:Play("targetyou")
			soundUnchainedMagic:Play("Interface\\AddOns\\DBM-Core\\sounds\\RaidAbilities\\unchained.mp3")
		end
		if self.Options.SetIconOnUnchainedMagic then
			self:SetIcon(args.destName, self.vb.unchainedIcons)
		end
		self.vb.unchainedIcons = self.vb.unchainedIcons + 1
		self:Unschedule(warnUnchainedTargets)
		local maxUnchained = self:IsDifficulty("normal25", "heroic25") and 6 or 2
		if #unchainedTargets >= maxUnchained then
			warnUnchainedTargets(self)
		else
			self:Schedule(0.3, warnUnchainedTargets, self)
		end
	elseif spellId == 70106 then	--Chilled to the bone (melee)
		if args:IsPlayer() then
			timerChilledtotheBone:Start()
			if (self:IsHeroic() and (args.amount or 1) >= 4) or (args.amount or 1) >= 8 then
				specWarnChilledtotheBone:Show(args.amount)
				specWarnChilledtotheBone:Play("stackhigh")
			else
				warnChilledtotheBone:Show(args.amount or 1)
			end
		end
	elseif spellId == 69766 then	--Instability (casters)
		if args:IsPlayer() then
			timerInstability:Start()
			if (self:IsHeroic() and (args.amount or 1) >= 4) or (args.amount or 1) >= 8 then
				specWarnInstability:Show(args.amount)
				specWarnInstability:Play("stackhigh")
			else
				warnInstability:Show(args.amount or 1)
			end
		end
	elseif args:IsSpellID(70127, 72528, 72529, 72530) then	--Mystic Buffet (phase 2 - everyone)
		if args:IsPlayer() then
			timerMysticBuffet:Start()
			timerNextMysticBuffet:Start()
			if (args.amount or 1) >= 5 then
				specWarnMysticBuffet:Show(args.amount)
				specWarnMysticBuffet:Play("stackhigh")
			else
				warnMysticBuffet:Show(args.amount or 1)
			end
			if self.Options.AchievementCheck and not self.vb.warnedfailed and (args.amount or 1) < 2 then
				timerMysticAchieve:Start()
			end
		end
		if args:IsDestTypePlayer() then
			if self.Options.AchievementCheck and DBM:GetRaidRank() > 0 and not self.vb.warnedfailed and self:AntiSpam(3) then
				if (args.amount or 1) == 5 then
					SendChatMessage(L.AchievementWarning:format(args.destName), "RAID")
				elseif (args.amount or 1) > 5 then
					self.vb.warnedfailed = true
					SendChatMessage(L.AchievementFailed:format(args.destName, (args.amount or 1)), "RAID_WARNING")
				end
			end
		end
	end
end
mod.SPELL_AURA_APPLIED_DOSE = mod.SPELL_AURA_APPLIED

function mod:SPELL_AURA_REMOVED(args)
	local spellId = args.spellId
	if spellId == 11719 then --Curse of Tongues falling off tracker, Nick bookmark
		tongued = 0
	elseif spellId == 31589 then --Slow falling off tracker, Nick bookmark
		slowed = 0
	elseif spellId == 69762 then
		if self.Options.SetIconOnUnchainedMagic then
			self:SetIcon(args.destName, 0)
		end
	elseif spellId == 70157 then
		if self.Options.SetIconOnFrostBeacon then
			self:SetIcon(args.destName, 0)
		end
	elseif spellId == 70106 then	--Chilled to the bone (melee)
		if args:IsPlayer() then
			timerChilledtotheBone:Cancel()
		end
	elseif spellId == 69766 then	--Instability (casters)
		if args:IsPlayer() then
			timerInstability:Cancel()
		end
	elseif args:IsSpellID(70127, 72528, 72529, 72530) then
		if args:IsPlayer() then
			timerMysticAchieve:Cancel()
			timerMysticBuffet:Cancel()
		end
	end
end

function mod:UNIT_HEALTH(uId)
	if not self.vb.warned_P2 and self:GetUnitCreatureId(uId) == 36853 and UnitHealth(uId) / UnitHealthMax(uId) <= 0.38 then
		self.vb.warned_P2 = true
		warnPhase2soon:Show()
	end
end

function mod:CHAT_MSG_MONSTER_YELL(msg)
	if (msg == L.YellAirphase or msg:find(L.YellAirphase)) or (msg == L.YellAirphaseDem or msg:find(L.YellAirphaseDem)) then
		if self.Options.ClearIconsOnAirphase then
			self:ClearIcons()
		end
		warnAirphase:Show()
		timerNextFrostBreath:Cancel()
		timerUnchainedMagic:Start(55)
		timerNextBlisteringCold:Start(80)--Air (~45s) + Icy 35-40s; Blistering follows Grip +1s
		timerNextIcyGrip:Start(78)--Nick bookmark; ~45s air + 33.5-40s
		timerNextAirphase:Start()
		timerNextGroundphase:Start()
		timerTailSmash:Start(68) -- 2 logs from late 2021 with 68 seconds after airphase begin. Need more logs to validate
		warnGroundphaseSoon:Schedule(37.5)
	elseif (msg == L.YellPhase2 or msg:find(L.YellPhase2)) or (msg == L.YellPhase2Dem or msg:find(L.YellPhase2Dem)) then
		self:SetStage(2)
		warnPhase2:Show()
		warnPhase2:Play("ptwo")
		timerNextBeacon:StartRange(7, 10, 1) -- no need to use self.vb.beaconP2Count here since it will always be one on this timer
		timerNextAirphase:Cancel()
		timerNextGroundphase:Cancel()
		warnGroundphaseSoon:Cancel()
		timerNextBlisteringCold:Start(36)--Core P3 Icy 35-40s + 1s
		timerNextIcyGrip:StartRange(35, 40)--Nick bookmark; core 35-40s
	end
end