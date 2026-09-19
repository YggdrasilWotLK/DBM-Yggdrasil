local mod	= DBM:NewMod(393, "DBM-Party-Classic", 3, 229)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("20260914135658")
mod:SetCreatureID(9736)

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 16497 15609 16496",
	"UNIT_HEALTH boss1"
)

local warnBomb			= mod:NewSpellAnnounce(16497, 3)
local warnNet			= mod:NewSpellAnnounce(15609, 2)
local warnPotion		= mod:NewSpellAnnounce(15504, 3)

local timerBombCD			= mod:NewCDTimer(14, 16497, nil, nil, nil, 3)--Core 16s first, 14s repeat
local timerNetCD			= mod:NewCDTimer(15, 15609, nil, nil, nil, 3)--Core 14s first, 16s/3s repeat

mod.vb.warnedPotion = false

function mod:OnCombatStart(delay)
	self.vb.warnedPotion = false
	timerBombCD:Start(16-delay)--Core 16s first
	timerNetCD:Start(14-delay)--Core 14s first
end

function mod:OnCombatEnd()
	timerBombCD:Cancel()
	timerNetCD:Cancel()
end

function mod:SPELL_CAST_START(args)
	if args.spellId == 16497 then -- Stun Bomb (core 14s repeat)
		warnBomb:Show()
		timerBombCD:Start()
	elseif args.spellId == 15609 then -- Hooked Net (core 16s/3s repeat)
		warnNet:Show()
		timerNetCD:Start()
	end
end

function mod:UNIT_HEALTH(uId)
	if not self.vb.warnedPotion and self:GetUnitCreatureId(uId) == 9736 and UnitHealth(uId) / UnitHealthMax(uId) <= 0.50 then
		self.vb.warnedPotion = true
		warnPotion:Show()--Healing Potion below 50%, once
	end
end
