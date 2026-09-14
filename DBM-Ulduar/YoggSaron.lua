local mod	= DBM:NewMod("YoggSaron", "DBM-Ulduar")
local L		= mod:GetLocalizedStrings()

mod:SetRevision("20220701215737")
mod:SetCreatureID(33288)
mod:RegisterCombat("combat_yell", L.YellPull)
mod:SetUsedIcons(8, 7, 6, 2, 1)

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 64059 64189",
	"SPELL_CAST_SUCCESS 64144 64465 64167 64163",
	"SPELL_SUMMON 63031",
	"SPELL_AURA_APPLIED 63802 63830 63881 64126 64125 63138 63894 64167 64163 64465",
	"SPELL_AURA_REMOVED 63802 63894 64167 64163 63830 63138 63881 64465",
	"SPELL_AURA_REMOVED_DOSE 63050",
	"UNIT_HEALTH"
)

--General
local enrageTimer					= mod:NewBerserkTimer(900)
local timerAchieve					= mod:NewAchievementTimer(420, 3012)

-- I have hidden most NPC TimerLines and only kept stage and brain TimerLines to prevent GUI clutter.
-- Stage One: The Lucid Dream
mod:AddTimerLine(L.S1TheLucidDream)
-- Sara
-- mod:AddTimerLine(L.Sara)
local warnFervor					= mod:NewTargetAnnounce(63138, 4)

local specWarnFervor				= mod:NewSpecialWarningYou(63138, nil, nil, nil, 1, 2)

local timerFervor					= mod:NewTargetTimer(15, 63138, nil, false, 2)

mod:AddSetIconOption("SetIconOnFervorTarget", 63138, false, false, {7})
mod:AddBoolOption("ShowSaraHealth", false)

-- Guardian of Yogg-Saron
-- mod:AddTimerLine(L.GuardianofYoggSaron)
local warnGuardianSpawned			= mod:NewAnnounce("WarningGuardianSpawned", 3, 63031, nil, nil, nil, 63031)

local specWarnGuardianLow			= mod:NewSpecialWarning("SpecWarnGuardianLow", false, nil, nil, nil, nil, nil, 63031, 63031)

-- Stage Two: Descent Into Madness
mod:AddTimerLine(L.S2DescentIntoMadness)
local warnP2						= mod:NewPhaseAnnounce(2, 2, nil, nil, nil, nil, nil, 2)
local warnSanity					= mod:NewAnnounce("WarningSanity", 3, 63050, nil, nil, nil, 63050)

local specWarnSanity				= mod:NewSpecialWarning("SpecWarnSanity", nil, nil, nil, nil, nil, nil, 63050, 63050)--Warning, no voice pack support

mod:AddInfoFrameOption(63050)

-- Sara
-- mod:AddTimerLine(L.Sara)
local warnBrainLink				= mod:NewTargetAnnounce(63802, 3)

local specWarnBrainLink			= mod:NewSpecialWarningYou(63802, nil, nil, nil, 1, 2)
local specWarnMalady				= mod:NewSpecialWarningYou(63830, nil, nil, nil, 1, 2)
local specWarnMaladyNear			= mod:NewSpecialWarningClose(63830, nil, nil, nil, 1, 2)

local timerBrainLinkCD				= mod:NewCDTimer(30, 63802, nil, nil, nil, 3)--Core 0ms first, 30s repeat
local timerMaladyCD					= mod:NewCDTimer(20, 63830, nil, nil, nil, 3)--Core 7s first, 20s repeat

mod:AddSetIconOption("SetIconOnBrainLinkTarget", 63802, true, false, {1, 2})
mod:AddSetIconOption("SetIconOnFearTarget", 63830, true, false, {6})
mod:AddArrowOption("MaladyArrow", 63830, true)

-- Crusher Tentacle
-- mod:AddTimerLine(L.CrusherTentacle)
local warnCrusherTentacleSpawned	= mod:NewAnnounce("WarningCrusherTentacleSpawned", 2, "Interface\\Icons\\achievement_boss_yoggsaron_01", nil, nil, nil, 64139)

-- Corruptor Tentacle
-- mod:AddTimerLine(L.CorruptorTentacle)

-- Constrictor Tentacle
-- mod:AddTimerLine(L.ConstrictorTentacle)
local warnSqueeze					= mod:NewTargetNoFilterAnnounce(64125, 3)

local yellSqueeze					= mod:NewYell(64125)  -- Constrictor Tentacle

-- Descent into Madness
mod:AddTimerLine(L.DescentIntoMadness)
local warnBrainPortalSoon			= mod:NewAnnounce("WarnBrainPortalSoon", 2, 57687, nil, nil, nil, 64027)

local specWarnBrainPortalSoon		= mod:NewSpecialWarning("SpecWarnBrainPortalSoon", false, nil, nil, nil, nil, nil, 57687, 64027)

local timerBrainPortal				= mod:NewTimer(20, "NextPortal", 57687, nil, nil, 5, nil, nil, nil, nil, nil, nil, nil, 64027)

-- Influence Tentacle
-- mod:AddTimerLine(L.InfluenceTentacle)

-- Laughing Skull
-- mod:AddTimerLine(L.LaughingSkull)
local timerLunaticGaze				= mod:NewCastTimer(4, 64163, nil, nil, nil, 2, nil, DBM_COMMON_L.IMPORTANT_ICON) -- Laughing Skull
local timerNextLunaticGaze			= mod:NewCDTimer(12, 64163, nil, nil, nil, 2, nil, DBM_COMMON_L.IMPORTANT_ICON) -- Core 7s first, 12s repeat (P3)

-- Brain of Yogg-Saron
-- mod:AddTimerLine(L.BrainofYoggSaron)
local warnMadness					= mod:NewCastAnnounce(64059, 2)

local specWarnMadnessOutNow			= mod:NewSpecialWarning("SpecWarnMadnessOutNow", nil, nil, nil, nil, nil, nil, 64059, 64059)  -- Brain of Yogg-Saron. Warning, no voice pack support

local timerMadness					= mod:NewCastTimer(60, 64059, nil, nil, nil, 5, nil, DBM_COMMON_L.DEADLY_ICON, nil, 3)  -- Brain of Yogg-Saron

-- Stage Three: True Face of Death
mod:AddTimerLine(L.S3TrueFaceofDeath)
local warnP3						= mod:NewPhaseAnnounce(3, 2, nil, nil, nil, nil, nil, 2)

-- Yogg-Saron
-- mod:AddTimerLine(L.YoggSaron)
mod:AddSetIconOption("SetIconOnBeacon", 64465, true, true, {1, 2, 3, 4, 5, 6, 7, 8})

-- Immortal Guardian
-- mod:AddTimerLine(L.ImmortalGuardian)
local warnEmpowerSoon				= mod:NewSoonAnnounce(64465, 4)

local timerEmpower					= mod:NewCDTimer(40, 64465, nil, nil, nil, 3)--Core reschedules 40s after each beacon empowerment
local timerEmpowerDuration			= mod:NewBuffActiveTimer(10, 64486, nil, nil, nil, 3)

-- Hard Mode
mod:AddTimerLine(DBM_COMMON_L.HEROIC_ICON..DBM_CORE_L.HARD_MODE)
-- Stage Three: True Face of Death
mod:AddTimerLine(L.S3TrueFaceofDeath)
local warnDeafeningRoarSoon			= mod:NewPreWarnAnnounce(64189, 5, 3)

local specWarnDeafeningRoar			= mod:NewSpecialWarningSpell(64189, nil, nil, nil, 1, 2)

local timerCastDeafeningRoar		= mod:NewCastTimer(2.3, 64189, nil, nil, nil, 2)
local timerNextDeafeningRoar		= mod:NewNextTimer(50, 64189, nil, nil, nil, 2)--Core 50s first and repeat (hard mode only)

local targetWarningsShown = {}
local brainLinkTargets = {}
local SanityBuff = DBM:GetSpellInfoNew(63050)
mod.vb.brainLinkIcon = 2
mod.vb.beaconIcon = 8
mod.vb.Guardians = 0

function mod:OnCombatStart()
	self:SetStage(1)
	self.vb.brainLinkIcon = 2
	self.vb.beaconIcon = 8
	self.vb.Guardians = 0
	enrageTimer:Start()
	timerAchieve:Start()
	table.wipe(targetWarningsShown)
	table.wipe(brainLinkTargets)
	if self.Options.InfoFrame then
		DBM.InfoFrame:SetHeader(SanityBuff)
		DBM.InfoFrame:Show(30, "playerdebuffstacks", SanityBuff, 2)--Sorted lowest first (highest first is default of arg not given)
	end
	if self.Options.ShowSaraHealth then
		if not self.Options.HealthFrame then
			DBM.BossHealth:Show(L.name)
		else
			DBM.BossHealth:AddBoss(33134, L.Sara)
		end
	end
end

function mod:OnCombatEnd()
	timerBrainPortal:Cancel()
	timerMadness:Cancel()
	timerLunaticGaze:Cancel()
	timerNextLunaticGaze:Cancel()
	timerBrainLinkCD:Cancel()
	timerMaladyCD:Cancel()
	timerEmpower:Cancel()
	timerEmpowerDuration:Cancel()
	timerNextDeafeningRoar:Cancel()
	warnBrainPortalSoon:Cancel()
	specWarnBrainPortalSoon:Cancel()
	specWarnMadnessOutNow:Cancel()
	warnEmpowerSoon:Cancel()
	warnDeafeningRoarSoon:Cancel()
	if self.Options.InfoFrame then
		DBM.InfoFrame:Hide()
	end
end

function mod:FervorTarget(targetname)
	if not targetname then return end
	if targetname == UnitName("player") and self:AntiSpam(4, 1) then
		specWarnFervor:Show()
		specWarnFervor:Play("targetyou")
	end
end

local function warnBrainLinkWarning(self)
	warnBrainLink:Show(table.concat(brainLinkTargets, "<, >"))
	timerBrainLinkCD:Start()--VERIFY ME
	table.wipe(brainLinkTargets)
	self.vb.brainLinkIcon = 2
end

function mod:SPELL_CAST_START(args)
	local spellId = args.spellId
	if spellId == 64059 then	-- Induce Madness (core 60s channel, portals on 80s loop)
		timerMadness:Start()
		warnMadness:Show()
		timerBrainPortal:Schedule(80)
		warnBrainPortalSoon:Schedule(75)
		specWarnBrainPortalSoon:Schedule(75)
		specWarnMadnessOutNow:Schedule(55)
	elseif spellId == 64189 then		--Deafening Roar (core 50s)
		timerNextDeafeningRoar:Start()
		warnDeafeningRoarSoon:Schedule(45)
		timerCastDeafeningRoar:Start()
		specWarnDeafeningRoar:Show()
		specWarnDeafeningRoar:Play("silencesoon")
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	local spellId = args.spellId
	if spellId == 64144 and self:GetUnitCreatureId(args.sourceGUID) == 33966 then
		warnCrusherTentacleSpawned:Show()
	elseif spellId == 64465 then -- Shadow Beacon (AURA handler owns the CD)
		warnEmpowerSoon:Schedule(35)
	elseif args:IsSpellID(64167, 64163) and self:AntiSpam(3, 3) then	-- Lunatic Gaze (core 12s repeat)
		timerLunaticGaze:Start()
		timerNextLunaticGaze:Start()
	end
end

function mod:SPELL_SUMMON(args)
	if args.spellId == 63031 then -- Guardian of Yogg-Saron (core ID, was 62979)
		self.vb.Guardians = self.vb.Guardians + 1
		warnGuardianSpawned:Show(self.vb.Guardians)
	end
end

function mod:SPELL_AURA_APPLIED(args)
	local spellId = args.spellId
	if spellId == 63802 then		-- Brain Link
		self:Unschedule(warnBrainLinkWarning)
		brainLinkTargets[#brainLinkTargets + 1] = args.destName
		if self.Options.SetIconOnBrainLinkTarget then
			self:SetIcon(args.destName, self.vb.brainLinkIcon)
		end
		self.vb.brainLinkIcon = self.vb.brainLinkIcon - 1
		if args:IsPlayer() then
			specWarnBrainLink:Show()
			specWarnBrainLink:Play("linegather")
		end
		if #brainLinkTargets == 2 then
			warnBrainLinkWarning(self)
		else
			self:Schedule(0.5, warnBrainLinkWarning, self)
		end
	elseif args:IsSpellID(63830, 63881) then   -- Malady of the Mind (core 20s repeat)
		timerMaladyCD:Start()
		if self.Options.SetIconOnFearTarget then
			self:SetIcon(args.destName, 6, 30)
		end
		if args:IsPlayer() then
			specWarnMalady:Show()
			specWarnMalady:Play("targetyou")
		else
			local uId = DBM:GetRaidUnitId(args.destName)
			if uId then
				local inRange = CheckInteractDistance(uId, 2)
				if inRange then
					specWarnMaladyNear:Show(args.destName)
					specWarnMaladyNear:Play("runaway")
					if self.Options.MaladyArrow then
						local x, y = GetPlayerMapPosition(uId)
						if x == 0 and y == 0 then
							SetMapToCurrentZone()
							x, y = GetPlayerMapPosition(uId)
						end
						DBM.Arrow:ShowRunAway(x, y, 12, 5)
					end
				end
			end
		end
	elseif args:IsSpellID(64126, 64125) then	-- Squeeze
		warnSqueeze:Show(args.destName)
		if args:IsPlayer() then
			yellSqueeze:Yell()
		end
	elseif spellId == 63138 then	-- Sara's Fervor
		warnFervor:Show(args.destName)
		timerFervor:Start(args.destName)
		if self.Options.SetIconOnFervorTarget then
			self:SetIcon(args.destName, 7, 15)
		end
		if args:IsPlayer() and self:AntiSpam(4, 1) then
			specWarnFervor:Show()
			specWarnFervor:Play("targetyou")
		end
	elseif spellId == 63894 and self.vb.phase < 2 then	-- Shadowy Barrier of Yogg-Saron (this is happens when p2 starts)
		self:SetStage(2)
		timerMaladyCD:Start(7)--Core 7s first
		timerBrainLinkCD:Start(5)--Core 0ms first; 5s grace for transition
		timerBrainPortal:Start(60)--Core 60s first
		warnBrainPortalSoon:Schedule(55)
		specWarnBrainPortalSoon:Schedule(55)
		warnP2:Show()
		warnP2:Play("ptwo")
		if self.Options.ShowSaraHealth then
			DBM.BossHealth:RemoveBoss(33134)
			if not self.Options.HealthFrame then
				DBM.BossHealth:Hide()
			end
		end
	elseif args:IsSpellID(64167, 64163) then	-- Lunatic Gaze (reduces sanity)
		timerLunaticGaze:Start()
	elseif spellId == 64465 then -- Shadow Beacon (core reschedules 40s per empowerment)
		if self.Options.SetIconOnBeacon then
			self:ScanForMobs(args.destGUID, 2, self.vb.beaconIcon, 1, 0.2, 10, "SetIconOnBeacon")
		end
		self.vb.beaconIcon = self.vb.beaconIcon - 1
		if self.vb.beaconIcon == 0 then
			self.vb.beaconIcon = 8
		end
		timerEmpower:Start()
		timerEmpowerDuration:Start()
		warnEmpowerSoon:Schedule(35)
	end
end

function mod:SPELL_AURA_REMOVED(args)
	local spellId = args.spellId
	if spellId == 63802 and self.Options.SetIconOnBrainLinkTarget then		-- Brain Link
		self:SetIcon(args.destName, 0)
	elseif spellId == 63138 and self.Options.SetIconOnFervorTarget then	-- Sara's Fervor
		self:SetIcon(args.destName, 0)
	elseif spellId == 63894 then		-- Shadowy Barrier removed from Yogg-Saron (start p3)
		self:SendSync("Phase3")			-- Sync this because you don't get it in your combat log if you are in brain room.
	elseif args:IsSpellID(64167, 64163) and self:AntiSpam(3, 2) then	-- Lunatic Gaze
		timerNextLunaticGaze:Start()
	elseif args:IsSpellID(63830, 63881) and self.Options.SetIconOnFearTarget then   -- Malady of the Mind (Death Coil)
		self:SetIcon(args.destName, 0)
	elseif spellId == 64465 then -- Shadow Beacon
		if self.Options.SetIconOnBeacon then
			self:ScanForMobs(args.destGUID, 2, 0, 1, 0.2, 12, "SetIconOnBeacon")
		end
	end
end

function mod:SPELL_AURA_REMOVED_DOSE(args)
	if args.spellId == 63050 and args.destGUID == UnitGUID("player") then
		local amount = args.amount or 1
		if amount == 50 then
			warnSanity:Show(args.amount)
		elseif amount == 35 or amount == 25 or amount == 15 then
			specWarnSanity:Show(amount)
		end
	end
end

function mod:UNIT_HEALTH(uId)
	if self.vb.phase == 1 and uId == "target" and self:GetUnitCreatureId(uId) == 33136 and UnitHealth(uId) / UnitHealthMax(uId) <= 0.3 and not targetWarningsShown[UnitGUID(uId)] then
		targetWarningsShown[UnitGUID(uId)] = true
		specWarnGuardianLow:Show()
	end
end

function mod:OnSync(msg)
	if msg == "Phase3" then
		self:SetStage(3)
		timerBrainPortal:Cancel()
		warnBrainPortalSoon:Cancel()
		timerMaladyCD:Cancel()
		timerBrainLinkCD:Cancel()
		timerEmpower:Start()
		warnP3:Show()
		warnP3:Play("pthree")
		warnEmpowerSoon:Schedule(35)
		timerNextDeafeningRoar:Start(50)--Core 50s (hard mode only)
		warnDeafeningRoarSoon:Schedule(45)
	end
end