local mod	= DBM:NewMod("Ick", "DBM-Party-WotLK", 15)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("20260919205410")
mod:SetCreatureID(36476)
mod:SetUsedIcons(8)

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 68987 68989 69012 69021 69028",
	"SPELL_CAST_SUCCESS 68989",
	"SPELL_AURA_APPLIED 69029 70850",
	"SPELL_AURA_REMOVED 69029 70850",
	"SPELL_PERIODIC_DAMAGE 69024 70436",
	"SPELL_PERIODIC_MISSED 69024 70436",
	"UNIT_AURA_UNFILTERED"
)

local warnPursuitCast			= mod:NewCastAnnounce(68987, 3)
local warnPursuit				= mod:NewTargetNoFilterAnnounce(68987, 4)
local warnKick				= mod:NewSpellAnnounce(69021, 3, nil, "Tank")
local warnBolt				= mod:NewSpellAnnounce(69028, 2, nil, "Healer")

local specWarnToxic				= mod:NewSpecialWarningMove(69024, nil, nil, nil, 1, 2)
local specWarnMines				= mod:NewSpecialWarningSpell(69015, nil, nil, nil, 2, 2)
local specWarnPursuit			= mod:NewSpecialWarningRun(68987, nil, nil, 2, 4, 2)
local specWarnPoisonNova		= mod:NewSpecialWarningRun(68989, "Melee", nil, 2, 4, 2)

local timerSpecialCD			= mod:NewCDSpecialTimer(27)--Core 25-30s rotation (+20s after Barrage)
local timerPursuitCast			= mod:NewCastTimer(5, 68987)
local timerPursuitConfusion		= mod:NewBuffActiveTimer(12, 69029)
local timerPoisonNova			= mod:NewCastTimer(5, 68989, nil, "Melee", 2, 2)
local timerKickCD				= mod:NewCDRangeTimer(20, 25, 69021, nil, "Tank", nil, 3)--Core 20-25s (was untracked)
local timerBoltCD				= mod:NewCDTimer(14, 69028, nil, "Healer", nil, 2)--Core 14s via Krick (was untracked)

mod:AddSetIconOption("SetIconOnPursuitTarget", 68987, true, false, {8})

local pursuit = DBM:GetSpellInfo(68987)
local pursuitTable = {}

function mod:OnCombatStart(delay)
	table.wipe(pursuitTable)
	timerSpecialCD:Start(25-delay)--Core first special 25s
	timerKickCD:StartRange(20-delay, 25-delay)--Core 20-25s first
	timerBoltCD:Start(14-delay)--Core 14s first
end

function mod:OnCombatEnd()
	timerSpecialCD:Cancel()
	timerKickCD:Cancel()
	timerBoltCD:Cancel()
end

function mod:SPELL_CAST_START(args)
	if args.spellId == 68987 then							-- Pursuit
		warnPursuitCast:Show()
		timerPursuitCast:Start()
		timerSpecialCD:Start()
	elseif args.spellId == 68989 then				-- Poison Nova (core single ID; SUCCESS fallback shares AntiSpam key below)
		if self:AntiSpam(5, "Nova") then
			specWarnPoisonNova:Show()
			specWarnPoisonNova:Play("runout")
		end
		timerPoisonNova:Start()
		timerSpecialCD:Start()
	elseif args.spellId == 69012 then				--Explosive Barrage (core +20s lockout after)
		specWarnMines:Show()
		specWarnMines:Play("watchstep")
		timerSpecialCD:Start(40) --Barrage + 20s lockout
	elseif args.spellId == 69021 then -- Mighty Kick (was untracked)
		warnKick:Show()
		timerKickCD:StartRange(20, 25)
	elseif args.spellId == 69028 then -- Shadow Bolt via Krick (was untracked)
		warnBolt:Show()
		timerBoltCD:Start()
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	if args.spellId == 68989 then -- Poison Nova fallback (may be instant; shares AntiSpam with START)
		if self:AntiSpam(5, "Nova") then
			specWarnPoisonNova:Show()
			specWarnPoisonNova:Play("runout")
		end
		timerPoisonNova:Start()
		timerSpecialCD:Start()
	end
end

function mod:SPELL_AURA_APPLIED(args)
	if args:IsSpellID(69029, 70850) then							-- Pursuit Confusion
		timerPursuitConfusion:Start(args.destName)
	end
end

function mod:SPELL_AURA_REMOVED(args)
	if args:IsSpellID(69029, 70850) then					-- Pursuit Confusion
		timerPursuitConfusion:Cancel()
	end
end

function mod:SPELL_PERIODIC_DAMAGE(_, _, _, destGUID, _, _, spellId)
	if (spellId == 69024 or spellId == 70436) and destGUID == UnitGUID("player") and self:AntiSpam() then
		specWarnToxic:Show()
		specWarnToxic:Play("runaway")
	end
end
mod.SPELL_PERIODIC_MISSED = mod.SPELL_PERIODIC_DAMAGE

function mod:UNIT_AURA_UNFILTERED(uId)
	local isPursuitDebuff = DBM:UnitDebuff(uId, pursuit)
	local name = DBM:GetUnitFullName(uId)
	if not isPursuitDebuff and pursuitTable[name] then
		pursuitTable[name] = nil
		if self.Options.SetIconOnPursuitTarget then
			self:SetIcon(name, 0)
		end
	elseif isPursuitDebuff and not pursuitTable[name] then
		pursuitTable[name] = true
		if UnitIsUnit(uId, "player") then
			specWarnPursuit:Show()
			specWarnPursuit:Play("justrun")
		else
			warnPursuit:Show(name)
		end
		if self.Options.SetIconOnPursuitTarget then
			self:SetIcon(name, 8)
		end
	end
end