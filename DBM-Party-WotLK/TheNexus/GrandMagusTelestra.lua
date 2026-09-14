local mod	= DBM:NewMod("GrandMagusTelestra", "DBM-Party-WotLK", 8)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("20220518110528")
mod:SetCreatureID(26731)

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 47772 47773 47756",
	"UNIT_HEALTH boss1",
	"CHAT_MSG_MONSTER_YELL"
)

local warningSplitSoon	= mod:NewAnnounce("WarningSplitSoon", 2)
local warningSplitNow	= mod:NewAnnounce("WarningSplitNow", 3)
local warningMerge		= mod:NewAnnounce("WarningMerge", 2)
local warnNova			= mod:NewSpellAnnounce(47772, 3)
local warnFirebomb		= mod:NewSpellAnnounce(47773, 3)
local warnGravityWell		= mod:NewSpellAnnounce(47756, 3)

local timerNovaCD			= mod:NewCDTimer(15, 47772, nil, nil, nil, 3)--Core 10s first, 15s repeat
local timerFirebombCD		= mod:NewCDTimer(3, 47773, nil, nil, nil, 3)--Core 0s first, 3s repeat
local timerGravityWellCD	= mod:NewCDTimer(15, 47756, nil, nil, nil, 3)--Core 20s first, 15s repeat

mod.vb.warnedSplit1		= false
mod.vb.warnedSplit2		= false

function mod:OnCombatStart(delay)
	self.vb.warnedSplit1 = false
	self.vb.warnedSplit2 = false
	timerNovaCD:Start(10-delay)--Core 10s first
	timerFirebombCD:Start(3-delay)--Core 0s first
	timerGravityWellCD:Start(20-delay)--Core 20s first
end

function mod:OnCombatEnd()
	timerNovaCD:Cancel()
	timerFirebombCD:Cancel()
	timerGravityWellCD:Cancel()
end

function mod:SPELL_CAST_START(args)
	if args.spellId == 47772 then -- Ice Nova (core 15s repeat, was untracked)
		warnNova:Show()
		timerNovaCD:Start()
	elseif args.spellId == 47773 then -- Firebomb (core 3s repeat, was untracked)
		warnFirebomb:Show()
		timerFirebombCD:Start()
	elseif args.spellId == 47756 then -- Gravity Well (core 15s repeat, was untracked)
		warnGravityWell:Show()
		timerGravityWellCD:Start()
	end
end

function mod:UNIT_HEALTH(uId)
	if not self.vb.warnedSplit1 and self:GetUnitCreatureId(uId) == 26731 and UnitHealth(uId) / UnitHealthMax(uId) <= 0.51 then--Core split at 51%
		self.vb.warnedSplit1 = true
		warningSplitSoon:Show()
	elseif not self.vb.warnedSplit2 and not self:IsDifficulty("normal5") and self:GetUnitCreatureId(uId) == 26731 and UnitHealth(uId) / UnitHealthMax(uId) <= 0.11 then--Core heroic second at 11%
		self.vb.warnedSplit2 = true
		warningSplitSoon:Show()
	end
end

function mod:CHAT_MSG_MONSTER_YELL(msg)
	if msg == L.SplitTrigger1 or msg == L.SplitTrigger2 then
		warningSplitNow:Show()
	elseif msg == L.MergeTrigger then
		warningMerge:Show()
	end
end