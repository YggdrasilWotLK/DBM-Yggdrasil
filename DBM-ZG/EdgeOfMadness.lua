local mod	= DBM:NewMod("EdgeOfMadness", "DBM-ZG", 1)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("20220518110528")
mod:SetCreatureID(15083)

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_SUCCESS 24684 24699 24683 24664 8269"--24664 Sleep + 8269 Frenzy are the core IDs; old IDs kept as fallback where DBC-real,
	"SPELL_AURA_APPLIED 24664 8269",
	"SPELL_SUMMON 24728 24683"
)

--TODO, this mod was a huge mess, wrong spellIds, duplicate events. So It needs heavy review with logs
local warnIllusions	= mod:NewSpellAnnounce(24728)
local warnSleep		= mod:NewSpellAnnounce(24664)
local warnChainBurn	= mod:NewSpellAnnounce(24684)
local warnFrenzy	= mod:NewSpellAnnounce(8269)
local warnVanish	= mod:NewSpellAnnounce(24699)
local warnCloud		= mod:NewSpellAnnounce(24683)

local timerSleep	= mod:NewBuffActiveTimer(6, 24664, nil, nil, nil, 3)
local timerCloud	= mod:NewBuffActiveTimer(15, 24683, nil, nil, nil, 3)

function mod:SPELL_CAST_SUCCESS(args)
	if args.spellId == 24684 then
		warnChainBurn:Show()
	elseif args.spellId == 24699 and args:IsSrcTypeHostile() then
		warnVanish:Show()
	elseif args.spellId == 24683 then
		warnCloud:Show()
		timerCloud:Start()
	end
end

function mod:SPELL_AURA_APPLIED(args)
	if args:IsSpellID(24684, 24664) and args:IsDestTypePlayer() and  self:AntiSpam(3, 1) then--24664 is the core Sleep ID
		warnSleep:Show()
		timerSleep:Start()
	elseif args:IsSpellID(24699, 8269) and args:IsDestTypeHostile() then--8269 is the core Frenzy ID
		warnFrenzy:Show()
	end
end

function mod:SPELL_SUMMON(args)
	if args.spellId == 24728 then
		warnIllusions:Show()
	--elseif args:IsSpellID(24683) then
	--	warnCloud:Show()
	--	timerCloud:Start()
	end
end