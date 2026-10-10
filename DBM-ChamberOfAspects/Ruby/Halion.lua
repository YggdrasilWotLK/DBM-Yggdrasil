local mod	= DBM:NewMod("Halion", "DBM-ChamberOfAspects", 2)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("20261010000141")
mod:SetCreatureID(39863)--40142 (twilight form)
mod:SetUsedIcons(7, 3)
mod:SetMinSyncRevision(4358)

mod:RegisterCombat("combat")
--mod:RegisterKill("yell", L.Kill)

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 74806 75954 75955 75956 74525 74526 74527 74528 74768",
	"SPELL_CAST_SUCCESS 74792 74562",
	"SPELL_AURA_APPLIED 74792 74562 74807",
	"SPELL_AURA_REMOVED 74792 74562 74807",
	"SPELL_DAMAGE",
	"SPELL_MISSED",
	"CHAT_MSG_MONSTER_YELL",
	"CHAT_MSG_RAID_BOSS_EMOTE",
	"UPDATE_WORLD_STATES",
	"UNIT_HEALTH boss1"
)

-- General
local berserkTimer					= mod:NewBerserkTimer(480)

-- Realm gating: core marks every player inside the twilight realm with aura 74807
-- (see boss_halion.cpp: fiery targets require -74807, soul targets require +74807).
-- Physical timers (meteor/fiery/flame breath) show only WITHOUT the aura,
-- twilight timers (cutter/soul/dark breath) only WITH it. Personal run-out
-- warnings on yourself always fire.
-- AnnounceAlternatePhase (default OFF) opts back into seeing both realms.
mod:AddBoolOption("AnnounceAlternatePhase", false, "announce")

-- Stage One - Physical Realm (100%)
mod:AddTimerLine(DBM_CORE_L.SCENARIO_STAGE:format(1)..": "..L.PhysicalRealm)
local warnPhase2Soon				= mod:NewPrePhaseAnnounce(2)
local warningFieryCombustion		= mod:NewTargetNoFilterAnnounce(74562, 4)
local warningMeteor					= mod:NewSpellAnnounce(74648, 3)
local warningFieryBreath			= mod:NewSpellAnnounce(74525, 2, nil, "Tank|Healer")

local specWarnFieryCombustion		= mod:NewSpecialWarningRun(74562, nil, nil, nil, 4, 2)
local yellFieryCombustion			= mod:NewYellMe(74562)
local specWarnMeteorStrike			= mod:NewSpecialWarningMove(74648, nil, nil, nil, 1, 2)

local timerFieryConsumptionCD		= mod:NewNextTimer(25, 74562, nil, nil, nil, 3)--Core 15-18s first, 25s repeat (no heroic split)
local timerMeteorCD					= mod:NewNextTimer(40, 74648, nil, nil, nil, 3)--Target or aoe? tough call. It's a targeted aoe!
local timerMeteorCast				= mod:NewCastTimer(6.5, 74648)--6.5 seconds from boss yell the meteor impacts (core marker 6500ms).
local timerFieryBreathCD			= mod:NewCDTimer(11, 74525, nil, "Tank|Healer", nil, 5, nil, DBM_COMMON_L.TANK_ICON)--Core 10-15s first, 10-12s repeat

mod:AddSetIconOption("SetIconOnFireConsumption", 74562, true, false, {7})--Red x for Fire

-- Stage Two - Twilight Realm (75%)
local twilightRealmName = DBM:GetSpellInfo(74807)
mod:AddTimerLine(DBM_CORE_L.SCENARIO_STAGE:format(2)..": "..twilightRealmName)
local warnPhase3Soon				= mod:NewPrePhaseAnnounce(3)
local warnPhase2					= mod:NewPhaseAnnounce(2, 2, nil, nil, nil, nil, nil, 2)
local warningShadowConsumption		= mod:NewTargetNoFilterAnnounce(74792, 4)
local warningShadowBreath			= mod:NewSpellAnnounce(74806, 2, nil, "Tank|Healer")
local warningTwilightCutter			= mod:NewAnnounce("TwilightCutterCast", 4, 74769, nil, nil, nil, 74769)

local specWarnShadowConsumption		= mod:NewSpecialWarningRun(74792, nil, nil, nil, 4, 2)
local yellShadowconsumption			= mod:NewYellMe(74792)
local specWarnTwilightCutter		= mod:NewSpecialWarningSpell(74769, nil, nil, nil, 3, 2)

local timerShadowConsumptionCD		= mod:NewNextTimer(20, 74792, nil, nil, nil, 3)--Core 20s first and repeat (no heroic split)
local timerTwilightCutterCast		= mod:NewCastTimer(5, 74769, nil, nil, nil, 3, nil, DBM_COMMON_L.DEADLY_ICON)
local timerTwilightCutter			= mod:NewBuffActiveTimer(10, 74769, nil, nil, nil, 6)
local timerTwilightCutterCD			= mod:NewNextTimer(29, 74769, nil, nil, nil, 6)--Core 16s first, 29s repeat
local timerShadowBreathCD			= mod:NewCDTimer(11, 74806, nil, "Tank|Healer", nil, 5, nil, DBM_COMMON_L.TANK_ICON)--Core 10-15s first, 10-12s repeat

mod:AddSetIconOption("SetIconOnShadowConsumption", 74792, true, false, {3})--Purple diamond for shadow

-- Stage Three - Corporeality (50%)
local twilightDivisionName = DBM:GetSpellInfo(75063)
mod:AddTimerLine(DBM_CORE_L.SCENARIO_STAGE:format(3)..": "..twilightDivisionName)
local warnPhase3					= mod:NewPhaseAnnounce(3, 2, nil, nil, nil, nil, nil, 2)

local specWarnCorporeality			= mod:NewSpecialWarningCount(74826, nil, nil, nil, 1, 2)

mod.vb.warned_preP2 = false
mod.vb.warned_preP3 = false
local playerInShadowRealm = false
local previousCorporeality = 0

function mod:OnCombatStart(delay)--These may still need retuning too, log i had didn't have pull time though.
	self.vb.warned_preP2 = false
	self.vb.warned_preP3 = false
	self:SetStage(1)
	playerInShadowRealm = false
	previousCorporeality = 0
	berserkTimer:Start(-delay)
	timerMeteorCD:StartRange(20-delay, 25-delay)
	timerFieryConsumptionCD:Start(15-delay)
	timerFieryBreathCD:StartRange(10-delay, 15-delay)
end

function mod:OnCombatEnd()
	specWarnTwilightCutter:Cancel()
	specWarnTwilightCutter:CancelVoice()
	timerMeteorCD:Cancel()
	timerMeteorCast:Cancel()
	timerFieryConsumptionCD:Cancel()
	timerFieryBreathCD:Cancel()
	timerShadowConsumptionCD:Cancel()
	timerShadowBreathCD:Cancel()
	timerTwilightCutterCD:Cancel()
	timerTwilightCutterCast:Cancel()
	if self.Options.HealthFrame then
		DBM.BossHealth:Hide()
	end
end

function mod:SPELL_CAST_START(args)
	if args:IsSpellID(74806, 75954, 75955, 75956) and (playerInShadowRealm or self.Options.AnnounceAlternatePhase) then--Dark breath: twilight realm only
		warningShadowBreath:Show()
		timerShadowBreathCD:Start()
	elseif args:IsSpellID(74525, 74526, 74527, 74528) and (not playerInShadowRealm or self.Options.AnnounceAlternatePhase) then--Flame breath: physical realm only
		warningFieryBreath:Show()
		timerFieryBreathCD:Start()
	elseif args.spellId == 74768 and (playerInShadowRealm or self.Options.AnnounceAlternatePhase) and self:AntiSpam(7, "CutterCast") then -- Twilight Cutter orb cast (CLEU fallback for yell, twilight realm only)
		self:TwilightCutterWarn()
	end
end

function mod:TwilightCutterWarn()
	specWarnTwilightCutter:Schedule(5)
	specWarnTwilightCutter:ScheduleVoice(5, "farfromline")
	if playerInShadowRealm or self.Options.AnnounceAlternatePhase then--Twilight realm only, never outside (unless opted into both)
		timerTwilightCutterCD:Cancel()
		warningTwilightCutter:Show()
		timerTwilightCutterCast:Start()
		timerTwilightCutter:Schedule(5)--Delay it since it happens 5 seconds after the emote
		timerTwilightCutterCD:Schedule(29)
	end
	if self:LatencyCheck() then
		self:SendSync("TwilightCutter")
	end
end

function mod:SPELL_CAST_SUCCESS(args)--We use spell cast success for debuff timers in case it gets resisted by a player we still get CD timer for next one
	local spellId = args.spellId
	if spellId == 74792 and (playerInShadowRealm or self.Options.AnnounceAlternatePhase) then--Twilight realm only
		timerShadowConsumptionCD:Start()--Core 20s always
		if self:LatencyCheck() then
			self:SendSync("ShadowCD")
		end
	elseif spellId == 74562 and (not playerInShadowRealm or self.Options.AnnounceAlternatePhase) then--Physical realm only
		timerFieryConsumptionCD:Start()--Core 25s always
		if self:LatencyCheck() then
			self:SendSync("FieryCD")
		end
	end
end

function mod:SPELL_AURA_APPLIED(args)--We don't use spell cast success for actual debuff on >player< warnings since it has a chance to be resisted.
	local spellId = args.spellId
	if spellId == 74807 and args:IsPlayer() then--Twilight realm phasing on self (core applies 74807 on portal entry, removes on exit)
		playerInShadowRealm = true
		return
	elseif spellId == 74792 and (playerInShadowRealm or self.Options.AnnounceAlternatePhase) then--Twilight realm only
		if self:LatencyCheck() then
			self:SendSync("ShadowTarget", args.destName)
		end
		if args:IsPlayer() then
			specWarnShadowConsumption:Show()
			specWarnShadowConsumption:Play("runout")
			yellShadowconsumption:Yell()
		end
		if playerInShadowRealm or self.Options.AnnounceAlternatePhase then--Twilight realm only
			warningShadowConsumption:Show(args.destName)
		end
		if self.Options.SetIconOnShadowConsumption then
			self:SetIcon(args.destName, 3)
		end
	elseif spellId == 74562 and (not playerInShadowRealm or self.Options.AnnounceAlternatePhase) then--Physical realm only
		if self:LatencyCheck() then
			self:SendSync("FieryTarget", args.destName)
		end
		if args:IsPlayer() then
			specWarnFieryCombustion:Show()
			specWarnFieryCombustion:Play("runout")
			yellFieryCombustion:Yell()
		end
		if not playerInShadowRealm or self.Options.AnnounceAlternatePhase then--Physical realm only
			warningFieryCombustion:Show(args.destName)
		end
		if self.Options.SetIconOnFireConsumption then
			self:SetIcon(args.destName, 7)
		end
	end
end

function mod:SPELL_AURA_REMOVED(args)
	local spellId = args.spellId
	if spellId == 74807 and args:IsPlayer() then--Left twilight realm (portal exit / wipe)
		playerInShadowRealm = false
		return
	elseif spellId == 74792 then
		if self.Options.SetIconOnShadowConsumption then
			self:SetIcon(args.destName, 0)
		end
	elseif spellId == 74562 then
		if self.Options.SetIconOnFireConsumption then
			self:SetIcon(args.destName, 0)
		end
	end
end

function mod:SPELL_DAMAGE(_, _, _, destGUID, _, _, spellId)
	if (spellId == 74713 or spellId == 74718) and destGUID == UnitGUID("player") and self:AntiSpam() then -- Meteor fire (core IDs, physical realm only by design)
		specWarnMeteorStrike:Show()
		specWarnMeteorStrike:Play("runaway")
	-- NOTE: realm tracking is aura-based (74807 on player), see SPELL_AURA_APPLIED/REMOVED.
	elseif self:GetCIDFromGUID(destGUID) == 39863 and self.Options.HealthFrame and playerInShadowRealm then -- check if Physical Realm boss exists and playerInShadowRealm is still cached as true
		DBM.BossHealth:Clear()
		DBM.BossHealth:AddBoss(39863, L.NormalHalion)
	elseif self:GetCIDFromGUID(destGUID) == 40142 and self.Options.HealthFrame and not playerInShadowRealm then -- check if Shadow Realm boss exists
		DBM.BossHealth:Clear()
		DBM.BossHealth:AddBoss(40142, L.TwilightHalion)
	end
end
mod.SPELL_MISSED = mod.SPELL_DAMAGE

function mod:UNIT_HEALTH(uId)
	if not self.vb.warned_preP2 and self:GetUnitCreatureId(uId) == 39863 and UnitHealth(uId) / UnitHealthMax(uId) <= 0.79 then
		self.vb.warned_preP2 = true
		warnPhase2Soon:Show()
	elseif not self.vb.warned_preP3 and self:GetUnitCreatureId(uId) == 40142 and UnitHealth(uId) / UnitHealthMax(uId) <= 0.54 then
		self:SendSync("Phase3soon")
	end
end

function mod:UPDATE_WORLD_STATES()
	for i = 1, GetNumWorldStateUI() do
		local _, state, text = GetWorldStateUIInfo(i)
		if state == 1 and strfind(text, "%%") then
			local corporeality = tonumber(strmatch(text, "%d+"))
			if corporeality > 0 and previousCorporeality ~= corporeality then
				specWarnCorporeality:Show(corporeality)
				previousCorporeality = corporeality
				if corporeality > 50 then
					if self:IsTank() then
						specWarnCorporeality:Play("defensive")
					end
				end
				if corporeality < 40 then
					if self:IsDps() then
						specWarnCorporeality:Play("dpsstop")
					end
				elseif corporeality == 40 then
					if self:IsDps() then
						specWarnCorporeality:Play("dpsslow")
					end
				elseif corporeality == 60 then
					if self:IsDps() then
						specWarnCorporeality:Play("dpsmore")
					end
				elseif corporeality > 60 then
					if self:IsDps() then
						specWarnCorporeality:Play("dpshard")
					end
				end
			end
		end
	end
end

function mod:CHAT_MSG_MONSTER_YELL(msg)
	if msg == L.Phase2 or msg:find(L.Phase2) then
		self:SendSync("Phase2")
	elseif msg == L.Phase3 or msg:find(L.Phase3) then
		self:SendSync("Phase3")
	elseif msg == L.MeteorCast or msg:find(L.MeteorCast) then--There is no CLEU cast trigger for meteor, only yell
		warningMeteor:Play("meteorrun")
		if not playerInShadowRealm or self.Options.AnnounceAlternatePhase then--Physical realm only (boss P1/P3), never for shadow players
			warningMeteor:Show()
			timerMeteorCast:Start()--7 seconds from boss yell the meteor impacts.
			timerMeteorCD:Start()
		end
		if self:LatencyCheck() then
			self:SendSync("Meteor")
		end
	elseif msg == L.twilightcutter or msg:find(L.twilightcutter) then -- Cutter warning (yell path; cast 74768 path calls TwilightCutterWarn directly)
		if self:AntiSpam(7, "CutterYell") then
			self:TwilightCutterWarn()
		end
	end
end

function mod:OnSync(msg, target)
	if msg == "TwilightCutter" then
		if (playerInShadowRealm or self.Options.AnnounceAlternatePhase) and self:AntiSpam(7, msg) then
			timerTwilightCutterCD:Cancel()
			warningTwilightCutter:Show()
			timerTwilightCutterCast:Start()
			timerTwilightCutter:Schedule(5)--Delay it since it happens 5 seconds after the emote
			timerTwilightCutterCD:Schedule(29)
		end
	elseif msg == "Meteor" then
		if not playerInShadowRealm or self.Options.AnnounceAlternatePhase then
			warningMeteor:Show()
			timerMeteorCast:Start()
			timerMeteorCD:Start()
		end
	elseif msg == "ShadowTarget" then
		if playerInShadowRealm or self.Options.AnnounceAlternatePhase then
			warningShadowConsumption:Show(target)
		end
	elseif msg == "FieryTarget" then
		if not playerInShadowRealm or self.Options.AnnounceAlternatePhase then
			warningFieryCombustion:Show(target)
		end
	elseif msg == "ShadowCD" then
		if playerInShadowRealm or self.Options.AnnounceAlternatePhase then
			timerShadowConsumptionCD:Start()--Core 20s always
		end
	elseif msg == "FieryCD" then
		if not playerInShadowRealm or self.Options.AnnounceAlternatePhase then
			timerFieryConsumptionCD:Start()--Core 25s always
		end
	elseif msg == "Phase2" and self.vb.phase < 2 then
		self:SetStage(2)
		timerFieryBreathCD:Cancel()
		timerMeteorCD:Cancel()
		timerFieryConsumptionCD:Cancel()
		warnPhase2:Show()
		warnPhase2:Play("ptwo")
		if playerInShadowRealm or self.Options.AnnounceAlternatePhase then--Seed shadow timers only for players inside (rest pick them up on first casts after portal entry)
			timerShadowBreathCD:Start(13) -- Core 10-15s
			timerShadowConsumptionCD:Start(20)--Core 20s
			timerTwilightCutterCD:Start(16)--Core 16s first
		end
	elseif msg == "Phase3" and self.vb.phase < 3 then
		self:SetStage(3)
		warnPhase3:Show()
		warnPhase3:Play("pthree")
		if not playerInShadowRealm or self.Options.AnnounceAlternatePhase then--Boss under 51% (P3) and player outside: physical fight resumes, show meteor/fire. Shadow players never see these.
			timerMeteorCD:Start(30) --Estimate, core never re-seeds meteor in P3.
			timerFieryConsumptionCD:Start(25)--Core 25s repeat (estimate from P3 start)
		end
	elseif msg == "Phase3soon" and not self.vb.warned_preP3 then
		self.vb.warned_preP3 = true
		warnPhase3Soon:Show()
	end
end