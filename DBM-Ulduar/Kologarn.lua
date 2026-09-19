local mod	= DBM:NewMod("Kologarn", "DBM-Ulduar")
local L		= mod:GetLocalizedStrings()

mod:SetRevision("20260914090752")
mod:SetCreatureID(32930)
mod:SetUsedIcons(5, 6, 7, 8)

mod:RegisterCombat("combat", 32930, 32933, 32934)

mod:RegisterEventsInCombat(
	"SPELL_CAST_SUCCESS 63356 64003 62166 63981",
	"SPELL_AURA_APPLIED 64290 64292",
	"SPELL_AURA_REMOVED 64290 64292",
	"SPELL_DAMAGE 63783 63982 63346 63976",
	"SPELL_MISSED 63783 63982 63346 63976",
	"CHAT_MSG_RAID_BOSS_WHISPER",
	"UNIT_DIED",
	"UNIT_SPELLCAST_SUCCEEDED boss1"
)

mod:SetBossHealthInfo(
	32930, L.Health_Body,
	32934, L.Health_Right_Arm,
	32933, L.Health_Left_Arm
)

-- General
local timerTimeForDisarmed		= mod:NewTimer(10, "achievementDisarmed")	-- 10 HC / 12 nonHC

--NOTE: Two crunch armors are setup to appear in gui twice on purpose, because they are very different mechanically. One is meant to be ignored and one is meant to be tank swap
-- Kologarn
mod:AddTimerLine(L.name)
local warnFocusedEyebeam		= mod:NewTargetNoFilterAnnounce(63346, 4)

local specWarnEyebeam			= mod:NewSpecialWarningRun(63346, nil, nil, nil, 4, 2)
local specWarnEyebeamNear		= mod:NewSpecialWarningClose(63346, nil, nil, nil, 1, 2)
local yellBeam					= mod:NewYell(63346)

local timerNextSmash			= mod:NewCDTimer(14, 63356, nil, "Tank", nil, 5, nil, DBM_COMMON_L.TANK_ICON) -- Core 8s first, 14s repeat
local timerNextEyebeam			= mod:NewCDTimer(20, 63346, nil, nil, nil, 3, nil, DBM_COMMON_L.IMPORTANT_ICON) -- Core 10s first, 20s repeat

mod:AddSetIconOption("SetIconOnEyebeamTarget", 63346, true, false, {8})

-- Right Arm
mod:AddTimerLine(L.Health_Right_Arm)
local warnGrip					= mod:NewTargetNoFilterAnnounce(64292, 2)

local timerNextGrip				= mod:NewCDTimer(25, 62166, nil, nil, nil, 3) -- Core 15s first, 25s repeat
local timerRespawnRightArm		= mod:NewTimer(50, "timerRightArm", nil, nil, nil, 1)--Core 50s

mod:AddSetIconOption("SetIconOnGripTarget", 64292, true, false, {7, 6, 5})

-- Left Arm
mod:AddTimerLine(L.Health_Left_Arm)
local timerNextShockwave		= mod:NewCDTimer(17, 63983, nil, nil, nil, 2) -- Core 17s first and repeat
local timerRespawnLeftArm		= mod:NewTimer(50, "timerLeftArm", nil, nil, nil, 1)--Core 50s

-- 5/23 00:33:48.648  SPELL_AURA_APPLIED,0x0000000000000000,nil,0x80000000,0x0480000001860FAC,"Hâzzad",0x4000512,63355,"Crunch Armor",0x1,DEBUFF
-- 6/3 21:41:56.140 UNIT_DIED,0x0000000000000000,nil,0x80000000,0xF1500080A60274A0,"Rechter Arm",0xa48

mod:GroupSpells(64292, 62166) -- Stone Grip aura and cast

mod.vb.disarmActive = false
local gripTargets = {}

local function armReset(self)
	self.vb.disarmActive = false
end

local function GripAnnounce(self)
	warnGrip:Show(table.concat(gripTargets, "<, >"))
	table.wipe(gripTargets)
end

function mod:OnCombatStart(delay)
	timerNextSmash:Start(8-delay) -- Core 8s first
	timerNextEyebeam:Start(10-delay) -- Core 10s first
	timerNextShockwave:Start(17-delay) -- Core 17s first
	timerNextGrip:Start(15-delay) -- Core 15s first
end

function mod:OnCombatEnd()
	timerNextSmash:Cancel()
	timerNextEyebeam:Cancel()
	timerNextShockwave:Cancel()
	timerNextGrip:Cancel()
	timerRespawnRightArm:Cancel()
	timerRespawnLeftArm:Cancel()
	self:Unschedule(GripAnnounce)
end

function mod:SPELL_CAST_SUCCESS(args)
	if args:IsSpellID(63356, 64003) then -- Overhead Smash (both 10/25 IDs)
		timerNextSmash:Start()
	elseif args.IsSpellID(62166, 63981) then -- Stone Grip
		timerNextGrip:Start()
	end
end

function mod:SPELL_AURA_APPLIED(args)
	if args:IsSpellID(64290, 64292) then
		if self.Options.SetIconOnGripTarget then
			self:SetIcon(args.destName, 8 - #gripTargets, 10)
		end
		table.insert(gripTargets, args.destName)
		self:Unschedule(GripAnnounce)
		if #gripTargets >= 3 then
			GripAnnounce(self)
		else
			self:Schedule(0.3, GripAnnounce, self)
		end
	end
end

function mod:SPELL_AURA_REMOVED(args)
	if args:IsSpellID(64290, 64292) then
		self:SetIcon(args.destName, 0)
	end
end

function mod:UNIT_DIED(args)
	if self:GetCIDFromGUID(args.destGUID) == 32934 then		-- right arm
		timerRespawnRightArm:Start()
		timerNextGrip:Cancel()
		if not self.vb.disarmActive then
			self.vb.disarmActive = true
			if self:IsDifficulty("normal10") then
				timerTimeForDisarmed:Start(12)
				self:Schedule(12, armReset, self)
			else
				timerTimeForDisarmed:Start()
				self:Schedule(10, armReset, self)
			end
		end
	elseif self:GetCIDFromGUID(args.destGUID) == 32933 then		-- left arm
		timerRespawnLeftArm:Start()
		if not self.vb.disarmActive then
			self.vb.disarmActive = true
			if self:IsDifficulty("normal10") then
				timerTimeForDisarmed:Start(12)
				self:Schedule(12, armReset, self)
			else
				timerTimeForDisarmed:Start()
				self:Schedule(10, armReset, self)
			end
		end
	end
end

function mod:SPELL_DAMAGE(_, _, _, destGUID, destName, _, spellId)
	if (spellId == 63346 or spellId == 63976) and self:AntiSpam(2, 2) then
		if destGUID == UnitGUID("player") then
			specWarnEyebeam:Show()
		else
			local uId = self:GetUnitIdFromGUID(destGUID)
			if uId then
				local inRange = CheckInteractDistance(uId, 5)
				if inRange then
					specWarnEyebeamNear:Show(destName)
				end
			end
		end

	end
end
mod.SPELL_MISSED = mod.SPELL_DAMAGE

function mod:CHAT_MSG_RAID_BOSS_WHISPER(msg)
	if msg:find(L.FocusedEyebeam) then
		self:SendSync("EyeBeamOn", UnitName("player"))
	end
end

function mod:OnSync(msg, target)
	if msg == "EyeBeamOn" then
		warnFocusedEyebeam:Show(target)
		if target == UnitName("player") then
			specWarnEyebeam:Show()
			specWarnEyebeam:Play("justrun")
			specWarnEyebeam:ScheduleVoice(1, "keepmove")
			yellBeam:Yell()
		end
		warnFocusedEyebeam:Show(target)
		if self.Options.SetIconOnEyebeamTarget then
			self:SetIcon(target, 5, 8)
		end
	end
end

function mod:UNIT_SPELLCAST_SUCCEEDED(_, spellName)
	if spellName == GetSpellInfo(63983) then--Arm Sweep
		timerNextShockwave:Start()
	elseif spellName == GetSpellInfo(63342) then--Focused Eyebeam Summon Trigger
		timerNextEyebeam:Start()
	end
end