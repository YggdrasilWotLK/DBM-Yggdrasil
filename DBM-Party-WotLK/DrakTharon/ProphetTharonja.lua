local mod	= DBM:NewMod("ProphetTharonja", "DBM-Party-WotLK", 4)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("20260914104916")
mod:SetCreatureID(26632)

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 49548 49527 49518 49528 49537",
	"SPELL_AURA_APPLIED 49356",
	"UNIT_HEALTH boss1"
)

local warningDecayFleshSoon		= mod:NewSoonAnnounce(49356, 2)
local warningCloud				= mod:NewSpellAnnounce(49548, 3)
local warningFleshSoon			= mod:NewSoonAnnounce(49356, 3)
local warningFlesh				= mod:NewSpellAnnounce(49356, 3)
local warnCurse					= mod:NewSpellAnnounce(49527, 3)
local warnRain					= mod:NewSpellAnnounce(49518, 3)
local warnBreath				= mod:NewSpellAnnounce(49537, 3)

local timerCloudCD				= mod:NewCDTimer(10, 49548, nil, nil, nil, 3)--Core 6s first, 10s repeat
local timerCurseCD				= mod:NewCDTimer(13, 49527, nil, nil, nil, 3)--Core 5s first, 13s repeat (was untracked)
local timerRainCD					= mod:NewCDTimer(12, 49518, nil, nil, nil, 3)--Core skeleton Rain of Fire (was untracked)
local timerBreathCD				= mod:NewCDTimer(8, 49537, nil, nil, nil, 3)--Core 3s first, 8s repeat (was untracked)

mod.vb.warnedDecay = false

function mod:OnCombatStart(delay)
	self.vb.warnedDecay = false
	timerCloudCD:Start(6-delay)--Core 6s first
	timerCurseCD:Start(5-delay)--Core 5s first
	timerBreathCD:Start(3-delay)--Core 3s first
end

function mod:OnCombatEnd()
	timerCloudCD:Cancel()
	timerCurseCD:Cancel()
	timerRainCD:Cancel()
	timerBreathCD:Cancel()
end

function mod:SPELL_CAST_START(args)
	if args.spellId == 49548 then -- Poison Cloud (core single ID, 10s repeat)
		warningCloud:Show()
		timerCloudCD:Start()
	elseif args.spellId == 49527 then -- Curse of Life (was untracked)
		warnCurse:Show()
		timerCurseCD:Start()
	elseif args.spellId == 49518 then -- Rain of Fire (was untracked)
		warnRain:Show()
		timerRainCD:Start()
	elseif args.spellId == 49537 then -- Lightning Breath (was untracked)
		warnBreath:Show()
		timerBreathCD:Start()
	end
end

function mod:SPELL_AURA_APPLIED(args)
	if args.spellId == 49356 and self:AntiSpam(1) then
		warningFleshSoon:Show()
		warningFlesh:Schedule(5)
	end
end

function mod:UNIT_HEALTH(uId)
	if not self.vb.warnedDecay and self:GetUnitCreatureId(uId) == 26632 and UnitHealth(uId) / UnitHealthMax(uId) <= 0.50 then--Core flesh shift below 50%
		self.vb.warnedDecay = true
		warningDecayFleshSoon:Show()
	end
end