local mod	= DBM:NewMod("TheBeast", "DBM-Party-Classic", 4)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("20220518110528")
mod:SetCreatureID(10430)

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 16785 15570 14100 16636 16788 16144"
)

local warnBreak			= mod:NewSpellAnnounce(16785, 3, nil, "Tank")
local warnImmolate		= mod:NewSpellAnnounce(15570, 3)
local warnRoar			= mod:NewSpellAnnounce(14100, 3)
local warnCharge		= mod:NewSpellAnnounce(16636, 3)
local warnFireball		= mod:NewSpellAnnounce(16788, 2, nil, "Healer")
local warnBlast			= mod:NewSpellAnnounce(16144, 2, nil, "Healer")

local timerBreakCD		= mod:NewCDTimer(10, 16785, nil, "Tank", nil, 3)--Core 12s first, 10s repeat
local timerImmolateCD		= mod:NewCDTimer(8, 15570, nil, nil, nil, 3)--Core 3s first, 8s repeat
local timerRoarCD			= mod:NewCDTimer(20, 14100, nil, nil, nil, 3)--Core 23s first, 20s repeat
local timerChargeCD		= mod:NewCDTimer(19, 16636, nil, nil, nil, 3)--Core 2s first, 15-23s repeat
local timerFireballCD		= mod:NewCDTimer(14, 16788, nil, "Healer", nil, 2)--Core 8-21s first and repeat
local timerBlastCD		= mod:NewCDTimer(6, 16144, nil, "Healer", nil, 2)--Core 5-8s first and repeat

function mod:OnCombatStart(delay)
	timerBreakCD:Start(12-delay)--Core 12s first
	timerImmolateCD:Start(3-delay)--Core 3s first
	timerRoarCD:Start(23-delay)--Core 23s first
	timerChargeCD:Start(2-delay)--Core 2s first
	timerFireballCD:Start(14-delay)--Core 8-21s first (mid)
	timerBlastCD:Start(6-delay)--Core 5-8s first (mid)
end

function mod:OnCombatEnd()
	timerBreakCD:Cancel()
	timerImmolateCD:Cancel()
	timerRoarCD:Cancel()
	timerChargeCD:Cancel()
	timerFireballCD:Cancel()
	timerBlastCD:Cancel()
end

function mod:SPELL_CAST_START(args)
	if args.spellId == 16785 then -- Flamebreak (core 10s repeat)
		warnBreak:Show()
		timerBreakCD:Start()
	elseif args.spellId == 15570 then -- Immolate (core 8s repeat)
		warnImmolate:Show()
		timerImmolateCD:Start()
	elseif args.spellId == 14100 then -- Terrifying Roar (core 20s repeat)
		warnRoar:Show()
		timerRoarCD:Start()
	elseif args.spellId == 16636 then -- Berserker Charge (core 15-23s repeat)
		warnCharge:Show()
		timerChargeCD:Start()
	elseif args.spellId == 16788 then -- Fireball (core 8-21s repeat)
		warnFireball:Show()
		timerFireballCD:Start()
	elseif args.spellId == 16144 then -- Fireblast (core 5-8s repeat)
		warnBlast:Show()
		timerBlastCD:Start()
	end
end
