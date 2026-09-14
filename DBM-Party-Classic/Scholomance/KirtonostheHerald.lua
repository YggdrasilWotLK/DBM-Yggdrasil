local mod	= DBM:NewMod("KirtonostheHerald", "DBM-Party-Classic", 13)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("20220518110528")
mod:SetCreatureID(10506)

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 17228 12889 18144 12882 6016 8379 14515"
)

local warnVolley		= mod:NewSpellAnnounce(17228, 3, nil, "Healer")
local warnTongues		= mod:NewSpellAnnounce(12889, 2, nil, "Healer")
local warnSwoop			= mod:NewSpellAnnounce(18144, 3)
local warnFlap			= mod:NewSpellAnnounce(12882, 2)
local warnPierce		= mod:NewSpellAnnounce(6016, 3, nil, "Tank")
local warnDisarm		= mod:NewSpellAnnounce(8379, 2, nil, "Tank")
local warnDominate		= mod:NewTargetNoFilterAnnounce(14515, 4)

local timerVolleyCD		= mod:NewCDTimer(10, 17228, nil, "Healer", nil, 3)--Core 2s first, 10s repeat (caster phase)
local timerTonguesCD	= mod:NewCDTimer(20, 12889, nil, "Healer", nil, 3)--Core 6s first, 20s repeat (caster phase)
local timerSwoopCD		= mod:NewCDTimer(15, 18144, nil, nil, nil, 3)--Core 4s first, 15s repeat (gargoyle phase)
local timerFlapCD			= mod:NewCDTimer(13, 12882, nil, nil, nil, 2)--Core 7s/13s first, 13s repeat
local timerPierceCD		= mod:NewCDTimer(12, 6016, nil, "Tank", nil, 3)--Core 11s first, 12s repeat (gargoyle phase)
local timerDisarmCD		= mod:NewCDTimer(11, 8379, nil, "Tank", nil, 3)--Core 15s first, 11s repeat (gargoyle phase)

function mod:OnCombatStart(delay)
	timerVolleyCD:Start(2-delay)--Core 2s first
	timerTonguesCD:Start(6-delay)--Core 6s first
	timerFlapCD:Start(13-delay)--Core 13s first (caster)
	timerPierceCD:Start(11-delay)--Core 11s first (gargoyle)
	timerDisarmCD:Start(15-delay)--Core 15s first (gargoyle)
	timerSwoopCD:Start(4-delay)--Core 4s first (gargoyle)
end

function mod:OnCombatEnd()
	timerVolleyCD:Cancel()
	timerTonguesCD:Cancel()
	timerSwoopCD:Cancel()
	timerFlapCD:Cancel()
	timerPierceCD:Cancel()
	timerDisarmCD:Cancel()
end

function mod:SPELL_CAST_START(args)
	if args.spellId == 17228 then -- Shadow Bolt Volley (caster phase, core 10s repeat)
		warnVolley:Show()
		timerVolleyCD:Start()
	elseif args.spellId == 12889 then -- Curse of Tongues (caster phase, core 20s repeat)
		warnTongues:Show()
		timerTonguesCD:Start()
	elseif args.spellId == 18144 then -- Swoop (gargoyle phase, core 15s repeat)
		warnSwoop:Show()
		timerSwoopCD:Start()
	elseif args.spellId == 12882 then -- Wing Flap (core 13s repeat)
		warnFlap:Show()
		timerFlapCD:Start()
	elseif args.spellId == 6016 then -- Pierce Armor (gargoyle phase, core 12s repeat)
		warnPierce:Show()
		timerPierceCD:Start()
	elseif args.spellId == 8379 then -- Disarm (gargoyle phase, core 11s repeat)
		warnDisarm:Show()
		timerDisarmCD:Start()
	elseif args.spellId == 14515 then -- Dominate Mind, every 2nd caster phase
		warnDominate:Show(args.destName)
	end
end
