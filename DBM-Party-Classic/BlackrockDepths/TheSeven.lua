local mod	= DBM:NewMod(385, "DBM-Party-Classic", 2, 228)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("20220518110528")
mod:SetCreatureID(9035, 9039, 9040, 9037, 9034, 9038, 9036)--9035 Anger'rel, 9039/doomrel, 9040/doperel, 9037/gloomrel, 9034/haterel, 9038/seethrel, 9036/vilerel


mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 15245 12742 12493 13787 15092",
	"UNIT_HEALTH boss1 boss2 boss3 boss4 boss5 boss6 boss7"
)

local warnVolley		= mod:NewSpellAnnounce(15245, 3, nil, "Healer")
local warnImmolate		= mod:NewSpellAnnounce(12742, 3)
local warnWeakness		= mod:NewSpellAnnounce(12493, 2)
local warnVoids			= mod:NewSpellAnnounce(15092, 4)

local timerVolleyCD		= mod:NewCDTimer(12, 15245, nil, "Healer", nil, 3)--Core Doom'rel 10s first, 12s repeat
local timerImmolateCD		= mod:NewCDTimer(25, 12742, nil, nil, nil, 3)--Core 18s first, 25s repeat
local timerWeaknessCD		= mod:NewCDTimer(45, 12493, nil, nil, nil, 2)--Core 5s first, 45s repeat
local timerArmorCD		= mod:NewCDTimer(300, 13787, nil, nil, nil, 2)--Core 16s first, 300s repeat

mod.vb.warnedVoids = false

function mod:OnCombatStart(delay)
	self.vb.warnedVoids = false
	timerVolleyCD:Start(10-delay)--Core 10s first (Doom'rel)
	timerImmolateCD:Start(18-delay)--Core 18s first
	timerWeaknessCD:Start(5-delay)--Core 5s first
	timerArmorCD:Start(16-delay)--Core 16s first
end

function mod:OnCombatEnd()
	timerVolleyCD:Cancel()
	timerImmolateCD:Cancel()
	timerWeaknessCD:Cancel()
	timerArmorCD:Cancel()
end

function mod:SPELL_CAST_START(args)
	if args.spellId == 15245 then -- Shadowbolt Volley (Doom'rel 9039, core 12s repeat)
		warnVolley:Show()
		timerVolleyCD:Start()
	elseif args.spellId == 12742 then -- Immolate (core 25s repeat)
		warnImmolate:Show()
		timerImmolateCD:Start()
	elseif args.spellId == 12493 then -- Curse of Weakness (core 45s repeat)
		warnWeakness:Show()
		timerWeaknessCD:Start()
	elseif args.spellId == 15092 then -- Summon Voidwalkers below 51% (once)
		warnVoids:Show()
	end
end

function mod:UNIT_HEALTH(uId)
	if not self.vb.warnedVoids and self:GetUnitCreatureId(uId) == 9039 and UnitHealth(uId) / UnitHealthMax(uId) <= 0.51 then
		self.vb.warnedVoids = true
		warnVoids:Show()--Voidwalkers below 51%, once
	end
end
