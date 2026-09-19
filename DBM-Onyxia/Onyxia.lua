local mod	= DBM:NewMod("Onyxia", "DBM-Onyxia")
local L		= mod:GetLocalizedStrings()

mod:SetRevision("20260914094152")
mod:SetCreatureID(10184)

mod:RegisterCombat("combat")

mod:RegisterEvents(
	"CHAT_MSG_MONSTER_YELL"
)

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 68958 17086 18351 18564 18576 18584 18596 18609 18617 18435 68970 18431 18500 18392 68959",
	"SPELL_DAMAGE 68867 69286",
	"UNIT_DIED",
	"UNIT_HEALTH boss1"
)

local warnWhelpsSoon		= mod:NewAnnounce("WarnWhelpsSoon", 1, 69004)
local warnWingBuffet		= mod:NewSpellAnnounce(18500, 2, nil, "Tank")
local warnPhase2			= mod:NewPhaseAnnounce(2)
local warnFireball			= mod:NewTargetNoFilterAnnounce(18392, 2, nil, false)
local warnPhase3			= mod:NewPhaseAnnounce(3)
local warnPhase2Soon		= mod:NewPrePhaseAnnounce(2)
local warnPhase3Soon		= mod:NewPrePhaseAnnounce(3)
local warnGuardSummon		= mod:NewSpellAnnounce(68968, 3)--Core boss summons a guard every 30s in P2

--local preWarnDeepBreath	 = mod:NewSoonAnnounce(17086, 2)--Experimental, if it is off please let me know.
local specWarnBreath		= mod:NewSpecialWarningSpell(18584, nil, nil, nil, 2, 2)
local specWarnBellowingRoar	= mod:NewSpecialWarningSpell(18431, nil, nil, nil, 2, 2)
local yellFireball			= mod:NewYell(18392)
local specWarnBlastNova		= mod:NewSpecialWarningRun(68958, "Melee", nil, nil, 4, 2)
local specWarnAdds			= mod:NewSpecialWarningAdds(68968, "-Healer", nil, nil, 1, 2)

local timerNextFlameBreath	= mod:NewCDRangeTimer(10, 20, 18435, nil, "Tank", 2, 5)--Core 10-20s ground phases
local timerNextDeepBreath	= mod:NewCDTimer(35, 18584, nil, nil, nil, 3)--Movement-gated, no fixed core CD
local timerBreath			= mod:NewCastTimer(8, 18584, nil, nil, nil, 3)
local timerWhelps			= mod:NewTimer(90, "TimerWhelps", 10697, nil, nil, 1)--Core 90s repeat
local timerGuardSummonCD	= mod:NewAddsTimer(30, 68968, nil, "-Healer")--Core 30s P2 guard summons
local timerBellowingRoarCD	= mod:NewCDTimer(22, 18431, nil, nil, nil, 2)--Core 15s first, 22s repeat (P3)
local timerBlastNovaCD		= mod:NewCDTimer(15, 68958, nil, "Melee", nil, 3)--Core 15s first and repeat (guard)
local timerAchieve			= mod:NewAchievementTimer(300, 4405)
local timerAchieveWhelps	= mod:NewAchievementTimer(10, 4406)

mod:AddBoolOption("SoundWTF3", false, "sound")

mod.vb.warned_preP2 = false
mod.vb.warned_preP3 = false
mod.vb.whelpsCount = 0

function mod:OnCombatStart(delay)
	self:SetStage(1)
	self.vb.whelpsCount = 0
	self.vb.warned_preP2 = false
	self.vb.warned_preP3 = false
	timerAchieve:Start(-delay)
	timerNextFlameBreath:StartRange(10-delay, 20-delay)--Core 10-20s first
	if self.Options.SoundWTF3 then
		DBM:PlaySoundFile("Interface\\AddOns\\DBM-Onyxia\\sounds\\dps-very-very-slowly.ogg")
		self:Schedule(20, DBM.PlaySoundFile, DBM, "Interface\\AddOns\\DBM-Onyxia\\sounds\\hit-it-like-you-mean-it.ogg")
		self:Schedule(30, DBM.PlaySoundFile, DBM, "Interface\\AddOns\\DBM-Onyxia\\sounds\\now-hit-it-very-hard-and-fast.ogg")
	end
end

function mod:OnCombatEnd()
	self:UnscheduleMethod("Whelps")
	timerWhelps:Cancel()
	timerNextFlameBreath:Cancel()
	timerNextDeepBreath:Cancel()
	timerBreath:Cancel()
	timerGuardSummonCD:Cancel()
	timerBellowingRoarCD:Cancel()
	timerBlastNovaCD:Cancel()
	warnWhelpsSoon:Cancel()
end

function mod:Whelps()
	if self:IsInCombat() then
		self.vb.whelpsCount = self.vb.whelpsCount + 1
		timerWhelps:Start()
		warnWhelpsSoon:Schedule(80)
		self:ScheduleMethod(90, "Whelps")--Core 90s repeat
	end
end

function mod:FireballTarget(targetname)
	if not targetname then return end
	warnFireball:Show(targetname)
	if targetname == UnitName("player") then
		yellFireball:Yell()
	end
end

function mod:CHAT_MSG_MONSTER_YELL(msg)
	if msg == L.YellPull and not self:IsInCombat() then
		DBM:StartCombat(self, 0)
	elseif msg == L.YellP2 or msg:find(L.YellP2) then
		self:SendSync("Phase2")
	elseif msg == L.YellP3 or msg:find(L.YellP3) then
		self:SendSync("Phase3")
	end
end

function mod:SPELL_CAST_START(args)
	local spellId = args.spellId
	if spellId == 68958 then -- Blast Nova (guard, core 15s repeat)
		specWarnBlastNova:Show()
		timerBlastNovaCD:Start()
	elseif spellId == 68959 then -- Ignite Weapon (guard self-buff, core 18-21s; signals guard activity, no fixed CD)
		specWarnAdds:Show()
		specWarnAdds:Play("bigmob")
	elseif args:IsSpellID(17086, 18351, 18564, 18576) or args:IsSpellID(18584, 18596, 18609, 18617) then	-- 1 ID for each direction
		specWarnBreath:Show()
		timerBreath:Start()
		timerNextDeepBreath:Start()
--		preWarnDeepBreath:Schedule(35)			  -- Pre-Warn Deep Breath
	elseif args:IsSpellID(18435, 68970) then		-- Flame Breath (Ground phases, core 10-20s)
		timerNextFlameBreath:StartRange(10, 20)
	elseif spellId == 18431 then -- Bellowing Roar (core 22s repeat in P3)
		specWarnBellowingRoar:Show()
		specWarnBellowingRoar:Play("fearsoon")
		if self.vb.phase == 3 then
			timerBellowingRoarCD:Start()
		end
	elseif spellId == 18500 then
		warnWingBuffet:Show()
	elseif spellId == 18392 then
		self:BossTargetScanner(args.sourceGUID, "FireballTarget", 0.15, 12)
	end
end

function mod:SPELL_DAMAGE(_, _, _, destGUID, _, _, spellId)
	if (spellId == 68867 or spellId == 69286) and destGUID == UnitGUID("player") and self.Options.SoundWTF3 then		-- Tail Sweep
		DBM:PlaySoundFile("Interface\\AddOns\\DBM-Onyxia\\sounds\\watch-the-tail.ogg")
	end
end

function mod:UNIT_DIED(args)
	if self:IsInCombat() and args:IsPlayer() and self.Options.SoundWTF3 then
		DBM:PlaySoundFile("Interface\\AddOns\\DBM-Onyxia\\sounds\\thats-a-fucking-fifty-dkp-minus.ogg")
	end
end

function mod:P2GuardLoop()
	if self:IsInCombat() and self.vb.phase == 2 then
		specWarnAdds:Show()
		specWarnAdds:Play("bigmob")
		warnGuardSummon:Show()
		timerGuardSummonCD:Start()
		self:ScheduleMethod(30, "P2GuardLoop")
	end
end

function mod:UNIT_HEALTH(uId)
	if self.vb.phase == 1 and not self.vb.warned_preP2 and self:GetUnitCreatureId(uId) == 10184 and UnitHealth(uId) / UnitHealthMax(uId) <= 0.70 then
		self.vb.warned_preP2 = true
		warnPhase2Soon:Show()
	elseif self.vb.phase == 2 and not self.vb.warned_preP3 and self:GetUnitCreatureId(uId) == 10184 and UnitHealth(uId) / UnitHealthMax(uId) <= 0.45 then
		self.vb.warned_preP3 = true
		warnPhase3Soon:Show()
		if self.Options.SoundWTF3 then
			self:Unschedule(DBM.PlaySoundFile, DBM)
		end
	end
end

function mod:OnSync(msg)
	if not self:IsInCombat() then return end
	if msg == "Phase2" then
		self:SetStage(2)
		self.vb.whelpsCount = 0
		warnPhase2:Show()
		--timerBigAddCD:Start(65)
--		preWarnDeepBreath:Schedule(72)	-- Pre-Warn Deep Breath
		timerNextDeepBreath:Start(77) -- 67
		timerAchieveWhelps:Start()
		timerNextFlameBreath:Cancel()
		timerGuardSummonCD:Start(30)--Core 30s guard summons in P2
		warnGuardSummon:Schedule(30)
		self:UnscheduleMethod("P2GuardLoop")
		self:ScheduleMethod(30, "P2GuardLoop")
		self:ScheduleMethod(5, "Whelps")
		if self.Options.SoundWTF3 then
			self:Unschedule(DBM.PlaySoundFile, DBM)
			DBM:PlaySoundFile("Interface\\AddOns\\DBM-Onyxia\\sounds\\i-dont-see-enough-dots.ogg")
			self:Schedule(10, DBM.PlaySoundFile, DBM, "Interface\\AddOns\\DBM-Onyxia\\sounds\\throw-more-dots.ogg")
			self:Schedule(17, DBM.PlaySoundFile, DBM, "Interface\\AddOns\\DBM-Onyxia\\sounds\\whelps-left-side-even-side-handle-it.ogg") -- 18
		end
		if self.Options.RangeFrame then
			DBM.RangeCheck:Show(8)
		end
	elseif msg == "Phase3" then
		self:SetStage(3)
		warnPhase3:Show()
		self:UnscheduleMethod("Whelps")
		self:UnscheduleMethod("P2GuardLoop")
		timerWhelps:Stop()
		timerNextDeepBreath:Stop()
		timerGuardSummonCD:Stop()
		warnWhelpsSoon:Cancel()
		timerNextFlameBreath:StartRange(10, 20)--Core re-arms ground timers on landing
		timerBellowingRoarCD:Start(15)--Core 15s first in P3
--		preWarnDeepBreath:Cancel()
		if self.Options.SoundWTF3 then
			self:Unschedule(DBM.PlaySoundFile, DBM)
			self:Schedule(15, DBM.PlaySoundFile, DBM, "Interface\\AddOns\\DBM-Onyxia\\sounds\\dps-very-very-slowly.ogg")
			self:Schedule(35, DBM.PlaySoundFile, DBM, "Interface\\AddOns\\DBM-Onyxia\\sounds\\hit-it-like-you-mean-it.ogg")
			self:Schedule(45, DBM.PlaySoundFile, DBM, "Interface\\AddOns\\DBM-Onyxia\\sounds\\now-hit-it-very-hard-and-fast.ogg")
		end
		if self.Options.RangeFrame then
			DBM.RangeCheck:Hide()
		end
	end
end