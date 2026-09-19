local mod	= DBM:NewMod("ScourgelordTyrannus", "DBM-Party-WotLK", 15)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("20260919205410")
mod:SetCreatureID(36658, 36661)
mod:SetUsedIcons(8)

-- mod:RegisterCombat("yell", L.CombatStart)
-- mod:RegisterKill("yell", L.YellCombatEnd)
mod:RegisterCombat("combat")
-- mod:SetMinCombatTime(40)

mod:RegisterEvents(
	"CHAT_MSG_MONSTER_YELL"
)

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 69167 69246",
	"SPELL_CAST_SUCCESS 69155",
	"SPELL_AURA_APPLIED 69172",
	"SPELL_AURA_REMOVED 69172",
	"SPELL_PERIODIC_DAMAGE 69238 69628",
	"SPELL_PERIODIC_MISSED 69238 69628",
	"CHAT_MSG_RAID_BOSS_EMOTE",
	"UNIT_DIED"
)

local warnForcefulSmash			= mod:NewSpellAnnounce(69155, 2, nil, "Tank")
local warnOverlordsBrand		= mod:NewTargetAnnounce(69172, 4)
local warnHoarfrost				= mod:NewTargetAnnounce(69246, 2)

local specWarnHoarfrost			= mod:NewSpecialWarningMoveAway(69246, nil, nil, nil, 1, 2)
local yellHoarfrost				= mod:NewYell(69246)
local specWarnHoarfrostNear		= mod:NewSpecialWarningClose(69246, nil, nil, nil, 1, 2)
local specWarnIcyBlast			= mod:NewSpecialWarningMove(69238, nil, nil, nil, 1, 2)
local specWarnOverlordsBrand	= mod:NewSpecialWarningReflect(69172, nil, nil, nil, 3, 2)
local specWarnUnholyPower		= mod:NewSpecialWarningSpell(69167, "Tank", nil, nil, 1, 2) --Spell for now. may change to run away if damage is too high for defensive

local timerCombatStart			= mod:NewCombatTimer(34)
local timerOverlordsBrandCD		= mod:NewCDRangeTimer(11, 12, 69172, nil, nil, nil, 3, nil, DBM_COMMON_L.DEADLY_ICON)--Core 4-6s first, 11-12s repeat
local timerOverlordsBrand		= mod:NewTargetTimer(8, 69172, nil, nil, nil, 5)
local timerUnholyPower			= mod:NewBuffActiveTimer(10, 69167, nil, "Tank|Healer", 2, 5)
local timerUnholyPowerCD		= mod:NewCDRangeTimer(40, 48, 69167, nil, "Tank|Healer", 2, 5)--Core ~40-48s chain (was untracked)
local timerHoarfrostCD			= mod:NewCDTimer(25, 69246, nil, nil, nil, 3)--Core 25s first and repeat
local timerForcefulSmash		= mod:NewCDRangeTimer(40, 48, 69155, nil, "Tank", 2, 5, nil, DBM_COMMON_L.TANK_ICON)--Core 14-16s first, 40-48s chain

mod:AddSetIconOption("SetIconOnHoarfrostTarget", 69246, true, false, {8})
mod:AddRangeFrameOption(8, 69246)

function mod:OnCombatStart(delay)
	timerForcefulSmash:StartRange(14-delay, 16-delay)--Core 14-16s first
	timerOverlordsBrandCD:StartRange(4-delay, 6-delay)--Core 4-6s first
	timerHoarfrostCD:Start(25-delay)--Core 25s first
end

function mod:OnCombatEnd()
	timerForcefulSmash:Cancel()
	timerOverlordsBrandCD:Cancel()
	timerUnholyPowerCD:Cancel()
	timerHoarfrostCD:Cancel()
	if self.Options.RangeFrame then
		DBM.RangeCheck:Hide()
	end
end

function mod:SPELL_CAST_START(args)
	if args.spellId == 69167 then					-- Unholy Power (core single ID, 1s after Smash)
		specWarnUnholyPower:Show()
		specWarnUnholyPower:Play("justrun")
		timerUnholyPower:Start()
		timerUnholyPowerCD:StartRange(40, 48)
	elseif args.spellId == 69246 then -- Mark of Rimefang (cast fallback for emote path)
		timerHoarfrostCD:Start()
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	if args.spellId == 69155 then					-- Forceful Smash (core single ID)
		warnForcefulSmash:Show()
		timerForcefulSmash:StartRange(40, 48)
	end
end

function mod:SPELL_AURA_APPLIED(args)
	if args.spellId == 69172 then							-- Overlord's Brand
		timerOverlordsBrandCD:StartRange(11, 12)
		timerOverlordsBrand:Start(args.destName)
		if args:IsPlayer() then
			specWarnOverlordsBrand:Show(args.sourceName)
			specWarnOverlordsBrand:Play("stopattack")
		else
			warnOverlordsBrand:Show(args.destName)
		end
	end
end

function mod:SPELL_AURA_REMOVED(args)
	if args.spellId == 69172 then							-- Overlord's Brand
		timerOverlordsBrand:Stop(args.destName)
	end
end

function mod:SPELL_PERIODIC_DAMAGE(_, _, _, destGUID, _, _, spellId)
	if (spellId == 69238 or spellId == 69628) and destGUID == UnitGUID("player") and self:AntiSpam() then		-- Icy Blast, MOVE!
		specWarnIcyBlast:Show()
		specWarnIcyBlast:Play("runaway")
	end
end
mod.SPELL_PERIODIC_MISSED = mod.SPELL_PERIODIC_DAMAGE

function mod:UNIT_DIED(args)
	if self:GetCIDFromGUID(args.destGUID) == 36658 then
		DBM:EndCombat(self)
	end
end

function mod:CHAT_MSG_RAID_BOSS_EMOTE(msg, _, _, _, target)
	if msg == L.HoarfrostTarget or msg:find(L.HoarfrostTarget) then--Probably don't need this, verify
		target = target or msg and msg:match(L.HoarfrostTarget)
		if not target then return end
		timerHoarfrostCD:Start()
		target = DBM:GetUnitFullName(target)
		if target == UnitName("player") then
			specWarnHoarfrost:Show()
			specWarnHoarfrost:Play("targetyou")
			yellHoarfrost:Yell()
			if self.Options.RangeFrame then
				DBM.RangeCheck:Show(8, nil, nil, nil, nil, 5)
			end
		elseif self:CheckNearby(8, target) then
			specWarnHoarfrostNear:Show(target)
			specWarnHoarfrostNear:Play("watchstep")
		else
			warnHoarfrost:Show(target)
		end
		if self.Options.SetIconOnHoarfrostTarget then
			self:SetIcon(target, 8, 5)
		end
	end
end

function mod:CHAT_MSG_MONSTER_YELL(msg)
	if (msg == L.CombatStart or msg == L.CombatStart) then
		timerCombatStart:Start()
	end
end