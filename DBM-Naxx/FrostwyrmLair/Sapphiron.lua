local mod	= DBM:NewMod("Sapphiron", "DBM-Naxx", 5)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("20260913231415")
mod:SetCreatureID(15989)

mod:RegisterCombat("combat")
mod:SetModelScale(0.1)

mod:RegisterEventsInCombat(
--	"SPELL_CAST_START 28524",
	"SPELL_CAST_SUCCESS 28542 55665 28560",
	"SPELL_AURA_APPLIED 28522 55699 28547",
	"CHAT_MSG_MONSTER_EMOTE",
	"CHAT_MSG_RAID_BOSS_EMOTE",
	"UNIT_HEALTH boss1"
)

--TODO, verify SPELL_CAST_START on retail to switch to it over emote, same as classicc era was done
local warnDrainLifeNow	= mod:NewSpellAnnounce(28542, 2)
local warnDrainLifeSoon	= mod:NewSoonAnnounce(28542, 1)
local warnIceBlock		= mod:NewTargetAnnounce(28522, 2)
local warnAirPhaseSoon	= mod:NewAnnounce("WarningAirPhaseSoon", 3, "Interface\\AddOns\\DBM-Core\\textures\\CryptFiendUnBurrow.blp")
local warnAirPhaseNow	= mod:NewAnnounce("WarningAirPhaseNow", 4, "Interface\\AddOns\\DBM-Core\\textures\\CryptFiendUnBurrow.blp")
local warnLanded		= mod:NewAnnounce("WarningLanded", 4, "Interface\\AddOns\\DBM-Core\\textures\\CryptFiendBurrow.blp")

local specWarnLowHP		= mod:NewSpecialWarning("SpecWarnSapphLow")
local specWarnBlizzard	= mod:NewSpecialWarningGTFO(28547, nil, nil, nil, 1, 8)
local specWarnDeepBreath= mod:NewSpecialWarningSpell(28524, nil, nil, nil, 1, 2)
local yellIceBlock		= mod:NewYell(28522)

local timerDrainLife	= mod:NewCDTimer(24, 28542, nil, nil, nil, 3, nil, DBM_COMMON_L.CURSE_ICON)
local timerAirPhase		= mod:NewTimer(45, "TimerAir", "Interface\\AddOns\\DBM-Core\\textures\\CryptFiendUnBurrow.blp", nil, nil, 6)--Core 45s initial, 45s + 35s delay repeat
local timerLanding		= mod:NewTimer(28.5, "TimerLanding", "Interface\\AddOns\\DBM-Core\\textures\\CryptFiendBurrow.blp", nil, nil, 6)
local timerIceBlast		= mod:NewCastTimer(8.5, 28524, nil, nil, nil, 2, DBM_COMMON_L.DEADLY_ICON)--Core 8.5s explosion delay
local timerBlizzardCD		= mod:NewCDTimer(8, 28560, nil, nil, nil, 3)--Core 17s first, 8s/6.5s repeat

local berserkTimer		= mod:NewBerserkTimer(900)

local UnitAffectingCombat = UnitAffectingCombat
local noTargetTime = 0
local warned_lowhp = false
mod.vb.isFlying = false

mod:AddRangeFrameOption("12")

local function resetIsFlying(self)
	self.vb.isFlying = false
end

local function Landing(self)
	warnLanded:Show()
	warnDrainLifeSoon:Schedule(5)
	timerDrainLife:Start(10.5)
	timerBlizzardCD:Start(8)
	warnAirPhaseSoon:Schedule(35)
	timerAirPhase:Start(45)--Core 45s ground between flights
	if self.Options.RangeFrame then
		DBM.RangeCheck:Hide()
		self:Schedule(44, DBM.RangeCheck.Show, DBM.RangeCheck, 12)
	end
end

function mod:OnCombatStart(delay)
	noTargetTime = 0
	warned_lowhp = false
	self.vb.isFlying = false
	warnDrainLifeSoon:Schedule(12 - delay)
	timerDrainLife:Start(17 - delay)--Core 17s first
	timerBlizzardCD:Start(17 - delay)--Core 17s first
	warnAirPhaseSoon:Schedule(35 - delay)
	timerAirPhase:Start(45 - delay)--Core 45s first
	berserkTimer:Start(-delay)
	if self.Options.RangeFrame then
		self:Schedule(46 - delay, DBM.RangeCheck.Show, DBM.RangeCheck, 12)
	end
	self:RegisterOnUpdateHandler(function(self, elapsed)
		if not self:IsInCombat() then return end
		local foundBoss, target
		for uId in DBM:GetGroupMembers() do
			local unitID = uId.."target"
			if self:GetUnitCreatureId(unitID) == 15989 and UnitAffectingCombat(unitID) then
				target = DBM:GetUnitFullName(unitID.."target")
				foundBoss = true
				break
			end
		end
		if foundBoss and not target then
			noTargetTime = noTargetTime + elapsed
		elseif foundBoss then
			noTargetTime = 0
		end
		if noTargetTime > 0.5 and not self.vb.isFlying then
			noTargetTime = 0
			self.vb.isFlying = true
			self:Schedule(60, resetIsFlying, self)
			timerDrainLife:Cancel()
			timerAirPhase:Cancel()
			warnAirPhaseNow:Show()
			timerLanding:Start()
		end
	end, 0.2)
end

function mod:OnCombatEnd()
	self:UnregisterOnUpdateHandler()
	self:Unschedule(Landing)
	timerDrainLife:Cancel()
	timerAirPhase:Cancel()
	timerLanding:Cancel()
	timerIceBlast:Cancel()
	timerBlizzardCD:Cancel()
	if self.Options.RangeFrame then
		DBM.RangeCheck:Hide()
	end
end

function mod:SPELL_AURA_APPLIED(args)
	if args.spellId == 28522 then
		warnIceBlock:CombinedShow(0.5, args.destName)
		if args:IsPlayer() then
			yellIceBlock:Yell()
		end
	elseif args:IsSpellID(55699, 28547) and args:IsPlayer() and self:AntiSpam(1) then
		specWarnBlizzard:Show(args.spellName)
		specWarnBlizzard:Play("watchfeet")
		timerBlizzardCD:Start()
	end
end

--[[
function mod:SPELL_CAST_START(args)
	--if args:IsSpellID(28524, 29318) then--NEEDS verification before deployed
		timerIceBlast:Start()
		timerLanding:Update(16.3, 28.5)--Probably not even needed, if base timer is more accurate
		self:Schedule(12.2, Landing, self)
		warnDeepBreath:Show()
		warnDeepBreath:Play("findshelter")
	end
end
--]]

function mod:SPELL_CAST_SUCCESS(args)
	if args:IsSpellID(28542, 55665) then -- Life Drain
		warnDrainLifeNow:Show()
		warnDrainLifeSoon:Schedule(18.5)
		timerDrainLife:Start()
	elseif args.spellId == 28560 then -- Blizzard summon (core 8s/6.5s repeat)
		if self:IsDifficulty("normal25", "heroic25") then
			timerBlizzardCD:Start(6.5)
		else
			timerBlizzardCD:Start(8)
		end
	end
end

function mod:CHAT_MSG_MONSTER_EMOTE(msg)
	if msg == L.EmoteBreath or msg:find(L.EmoteBreath) then
		self:SendSync("DeepBreath")
	end
end
mod.CHAT_MSG_RAID_BOSS_EMOTE = mod.CHAT_MSG_MONSTER_EMOTE -- used to be a normal emote

function mod:UNIT_HEALTH(uId)
	if not warned_lowhp and self:GetUnitCreatureId(uId) == 15989 and UnitHealth(uId) / UnitHealthMax(uId) < 0.11 then--Core skips flight below 11%
		warned_lowhp = true
		specWarnLowHP:Show()
		timerAirPhase:Cancel()
	end
end

function mod:OnSync(event)
	if event == "DeepBreath" then--Core breath->ground 14s (8.5 + 3 + 1 + 1.5)
		timerIceBlast:Start()
		timerLanding:Update(14)
		self:Schedule(14, Landing, self)
		specWarnDeepBreath:Show()
		specWarnDeepBreath:Play("findshelter")
	end
end