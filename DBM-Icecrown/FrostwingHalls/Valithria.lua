local mod	= DBM:NewMod("Valithria", "DBM-Icecrown", 4)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("20260919194947")
mod:SetCreatureID(36789)
mod:SetUsedIcons(8)
mod.onlyHighest = true--Instructs DBM health tracking to literally only store highest value seen during fight, even if it drops below that

mod:RegisterCombat("combat")

mod:RegisterEvents(
	"CHAT_MSG_MONSTER_YELL"
)

-- Her death is the fail condition, not a kill: only Dreamwalker's Rage (71189) counts as success.
mod.combatInfo.noBossDeathKill = true

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 70754 71748 72023 72024 71189",
	"SPELL_CAST_SUCCESS 71179 70588",
	"SPELL_AURA_APPLIED 70633 71283 72025 72026 70751 71738 72022 72023 69325 71730 70873 71941",
	"SPELL_AURA_APPLIED_DOSE 70751 71738 72022 72023 70873 71941",
	"SPELL_AURA_REMOVED 70633 71283 72025 72026 69325 71730 70873 71941",
	"SPELL_DAMAGE 71086 71743 71086 72030",
	"SPELL_MISSED 71086 71743 71086 72030"
)

local warnCorrosion			= mod:NewStackAnnounce(70751, 2, nil, false)
local warnGutSpray			= mod:NewTargetAnnounce(70633, 3, nil, "Tank|Healer")
local warnManaVoid			= mod:NewSpellAnnounce(71179, 2, nil, "ManaUser")
local warnSupression		= mod:NewSpellAnnounce(70588, 3)
local warnPortalSoon		= mod:NewSoonAnnounce(72483, 2, nil)
local warnPortal			= mod:NewSpellAnnounce(72483, 3, nil)
local warnPortalOpen		= mod:NewAnnounce("WarnPortalOpen", 4, 72483, nil, nil, nil, 72483)

local specWarnGutSpray		= mod:NewSpecialWarningDefensive(70633, nil, nil, nil, 1, 2)
local specWarnLayWaste		= mod:NewSpecialWarningSpell(69325, nil, nil, nil, 2, 2)
local specWarnGTFO			= mod:NewSpecialWarningGTFO(71179, nil, nil, nil, 1, 8)
local specWarnSuppressers	= mod:NewSpecialWarningSpell(70935)

local timerLayWaste			= mod:NewBuffActiveTimer(12, 69325, nil, nil, nil, 2)
local timerNextPortal		= mod:NewCDCountTimer(46.5, 72483, nil, nil, nil, 5, nil, DBM_COMMON_L.HEALER_ICON)
local timerPortalsOpen		= mod:NewTimer(6, "TimerPortalsOpen", 72483, nil, nil, 6, nil, nil, nil, nil, nil, nil, nil, 72483)
local timerPortalsClose		= mod:NewTimer(10, "TimerPortalsClose", 72483, nil, nil, 6, nil, nil, nil, nil, nil, nil, nil, 72483)
local timerHealerBuff		= mod:NewBuffFadesTimer(40, 70873, nil, nil, nil, 5, nil, DBM_COMMON_L.HEALER_ICON)
local timerGutSpray			= mod:NewTargetTimer(12, 70633, nil, "Tank|Healer", nil, 5)
local timerCorrosion		= mod:NewTargetTimer(6, 70751, nil, false, nil, 3)
local timerBlazingSkeleton	= mod:NewNextTimer(50, 70933, "TimerBlazingSkeleton", nil, nil, 1, 17204)
local timerAbom				= mod:NewNextCountTimer(50, 70922, "TimerAbom", nil, nil, 1)
local timerSuppressers		= mod:NewNextCountTimer(60, 70935, nil, nil, nil, 1)

local soundSpecWarnSuppressers	= mod:NewSound(70935)

local berserkTimer			= mod:NewBerserkTimer(420)

mod:AddSetIconOption("SetIconOnBlazingSkeleton", 70933, true, 5, {8})

mod.vb.AbomSpawn = 0
mod.vb.SuppressersWave = 0
mod.vb.portalCount = 0

local function Suppressers(self)
	self.vb.SuppressersWave = self.vb.SuppressersWave + 1
	-- Core: suppresser waves every 59s, always (60s aura period minus 1s decay per tick).
	timerSuppressers:Stop()
	timerSuppressers:Start(59, self.vb.SuppressersWave)
	specWarnSuppressers:Cancel()
	specWarnSuppressers:Schedule(59)
	soundSpecWarnSuppressers:Schedule(59, "Interface\\AddOns\\DBM-Core\\sounds\\RaidAbilities\\suppressersSpawned.mp3")
	self:Unschedule(Suppressers)
	self:Schedule(59, Suppressers, self)
end

local function StartBlazingSkeletonTimer(self)
	-- Core: blazing waves every 55s, always (60s aura period minus 5s decay per tick).
	timerBlazingSkeleton:Start(55)
	self:Schedule(55, StartBlazingSkeletonTimer, self)
end

local function StartAbomTimer(self)
	self.vb.AbomSpawn = self.vb.AbomSpawn + 1
	-- Core: abom waves every 59s, always (60s aura period minus 1s decay per tick).
	timerAbom:Start(59, self.vb.AbomSpawn + 1)
	self:Schedule(59, StartAbomTimer, self)
end

local function Portals(self)
	self.vb.portalCount = self.vb.portalCount + 1
	warnPortal:Show()
	warnPortalOpen:Cancel()
	timerPortalsOpen:Cancel()
	warnPortalSoon:Cancel()
	warnPortalOpen:Schedule(15)
	timerPortalsOpen:Start()
	timerPortalsClose:Schedule(15)
	warnPortalSoon:Schedule(41)
	timerNextPortal:StartRange(45, 48, self.vb.portalCount)--Core 45-48s
	self:Unschedule(Portals)
	self:Schedule(46.5, Portals, self)--Mid-window driver; yell resyncs. Core 45-48s
end

function mod:OnCombatStart(delay)
	if self:IsHeroic() then
		berserkTimer:Start(-delay)
	end
	self.vb.portalCount = 0
	timerNextPortal:StartRange(45, 48, self.vb.portalCount + 1)--Core 45-48s
	warnPortalSoon:Schedule(41)
	self:Schedule(46.5, Portals, self)--Mid-window driver; yell resyncs. Core 45-48s
	self.vb.AbomSpawn = 0
	self:Schedule(30-delay, StartBlazingSkeletonTimer, self)
	self:Schedule(5-delay, StartAbomTimer, self)
	timerBlazingSkeleton:Start(30-delay)
	timerAbom:Start(5-delay, self.vb.AbomSpawn + 1)
	self.vb.SuppressersWave = 1
	timerSuppressers:Start(70-delay, self.vb.SuppressersWave)--First real wave: aura cast at 10s + 60s period (the cast itself summons nothing)
	specWarnSuppressers:Schedule(70-delay)
	soundSpecWarnSuppressers:Schedule(70-delay, "Interface\\AddOns\\DBM-Core\\sounds\\RaidAbilities\\suppressersSpawned.mp3")
	self:Schedule(70-delay, Suppressers, self)
end

function mod:OnCombatEnd()
	self:Unschedule(Portals)
	self:Unschedule(StartBlazingSkeletonTimer)
	self:Unschedule(StartAbomTimer)
	self:Unschedule(Suppressers)
	warnPortalSoon:Cancel()
	warnPortalOpen:Cancel()
	timerNextPortal:Cancel()
	timerPortalsOpen:Cancel()
	timerPortalsClose:Cancel()
	timerBlazingSkeleton:Cancel()
	timerAbom:Cancel()
	timerSuppressers:Cancel()
	specWarnSuppressers:Cancel()
	soundSpecWarnSuppressers:Cancel()
end

function mod:SPELL_CAST_START(args)
	local spellId = args.spellId
	if args:IsSpellID(70754, 71748, 72023, 72024) then--Fireball (its the first spell Blazing SKeleton's cast upon spawning)
		if self.Options.SetIconOnBlazingSkeleton then
			self:ScanForMobs(args.sourceGUID, 2, 8, 1, nil, 12, "SetIconOnBlazingSkeleton")
		end
	elseif spellId == 71189 then
		DBM:EndCombat(self)
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	local spellId = args.spellId
	if spellId == 71179 then--Mana Void
		warnManaVoid:Show()
	elseif spellId == 70588 and self:AntiSpam(5, 1) then--Supression
		warnSupression:Show(args.destName)
	end
end

function mod:SPELL_AURA_APPLIED(args)
	if args:IsSpellID(70633, 71283, 72025, 72026) and args:IsDestTypePlayer() then--Gut Spray
		timerGutSpray:Start(args.destName)
		warnGutSpray:CombinedShow(0.3, args.destName)
		if self:IsTank() then
			specWarnGutSpray:Show()
			specWarnGutSpray:Play("defensive")
		end
	elseif args:IsSpellID(70751, 71738, 72022, 72023) and args:IsDestTypePlayer() then--Corrosion
		warnCorrosion:Show(args.destName, args.amount or 1)
		timerCorrosion:Start(args.destName)
	elseif args:IsSpellID(69325, 71730) then--Lay Waste
		specWarnLayWaste:Show()
		specWarnLayWaste:Play("aesoon")
		timerLayWaste:Start()
	elseif args:IsSpellID(70873, 71941) and args:IsPlayer() then	--Emerald Vigor/Twisted Nightmares (portal healers)
		timerHealerBuff:Stop()
		timerHealerBuff:Start()
	end
end
mod.SPELL_AURA_APPLIED_DOSE = mod.SPELL_AURA_APPLIED

function mod:SPELL_AURA_REMOVED(args)
	if args:IsSpellID(70633, 71283, 72025, 72026) then--Gut Spray
		timerGutSpray:Cancel(args.destName)
	elseif args:IsSpellID(69325, 71730) then--Lay Waste
		timerLayWaste:Cancel()
	elseif args:IsSpellID(70873, 71941) and args:IsPlayer() then	--Emerald Vigor/Twisted Nightmares (portal healers)
		timerHealerBuff:Stop()
	end
end

function mod:SPELL_DAMAGE(_, _, _, destGUID, _, _, spellId, spellName)
	if (spellId == 71086 or spellId == 71743 or spellId == 71086 or spellId == 72030) and destGUID == UnitGUID("player") and self:AntiSpam(2, 2) then		-- Mana Void
		specWarnGTFO:Show(spellName)
		specWarnGTFO:Play("watchfeet")
	end
end
mod.SPELL_MISSED = mod.SPELL_DAMAGE

function mod:CHAT_MSG_MONSTER_YELL(msg)
	if (msg == L.YellPull or msg:find(L.YellPull)) and not self:IsInCombat() then
		DBM:StartCombat(self, 0)
	elseif (msg == L.YellPortals or msg:find(L.YellPortals)) and self:LatencyCheck() then
		self:SendSync("NightmarePortal")
	end
end

function mod:OnSync(msg)
	if msg == "NightmarePortal" and self:IsInCombat() then
		self:Unschedule(Portals)
		Portals(self)
	end
end