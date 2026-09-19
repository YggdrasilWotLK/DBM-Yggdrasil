local mod = DBM:NewMod("Falric", "DBM-Party-WotLK", 16)
local L = mod:GetLocalizedStrings()

mod:SetRevision("20260914104916")
mod:SetCreatureID(38112)

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_AURA_APPLIED 72422 72453 72426 72452 72435",
	"SPELL_AURA_REMOVED 72422 72453 72426"
)

local warnFear					= mod:NewSpellAnnounce(72435, 3)
local warnImpendingDespair		= mod:NewTargetNoFilterAnnounce(72426, 3)
local warnQuiveringStrike		= mod:NewTargetNoFilterAnnounce(72422, 3)
local warnHopeless				= mod:NewSpellAnnounce(72395, 2)

local timerFear					= mod:NewBuffActiveTimer(4, 72435)
local timerFearCD					= mod:NewCDTimer(20, 72435, nil, nil, nil, 3)--Core 20s first and repeat
local timerImpendingDespair		= mod:NewTargetTimer(6, 72426, nil, "Healer", 2, 5, nil, DBM_COMMON_L.HEALER_ICON..DBM_COMMON_L.MAGIC_ICON)
local timerDespairCD				= mod:NewCDTimer(12, 72426, nil, "Healer", 2, 5)--Core 11s first, 12s repeat
local timerQuiveringStrike		= mod:NewTargetTimer(5, 72422, nil, "Tank", 2, 5, nil, DBM_COMMON_L.TANK_ICON)
local timerQuiveringCD			= mod:NewCDTimer(5, 72422, nil, "Tank", 2, 5)--Core every 5s

function mod:OnCombatStart(delay)
	timerQuiveringCD:Start(5-delay)--Core every 5s
	timerDespairCD:Start(11-delay)--Core 11s first
	timerFearCD:Start(20-delay)--Core 20s first
end

function mod:OnCombatEnd()
	timerQuiveringCD:Cancel()
	timerDespairCD:Cancel()
	timerFearCD:Cancel()
end

function mod:SPELL_AURA_APPLIED(args)
	if args:IsSpellID(72422, 72453) then -- Quivering Strike (aura-driven, no CAST_START tracking per tactic)
		timerQuiveringStrike:Start(args.destName)
		warnQuiveringStrike:Show(args.destName)
		timerQuiveringCD:Start()
	elseif args.spellId == 72426 then -- Impending Despair (aura-driven)
		timerImpendingDespair:Start(args.destName)
		warnImpendingDespair:Show(args.destName)
		timerDespairCD:Start()
	elseif args:IsSpellID(72452, 72435) and self:AntiSpam() then -- Fear (aura-driven)
		warnFear:Show()
		timerFear:Start()
		timerFearCD:Start()
	elseif args.spellId == 72395 then -- Hopelessness at 67/34/11% (was untracked)
		warnHopeless:Show()
	end
end

function mod:SPELL_AURA_REMOVED(args)
	if args:IsSpellID(72422, 72453) then
		timerQuiveringStrike:Cancel(args.destName)
	elseif args.spellId == 72426 then
		timerImpendingDespair:Cancel(args.destName)
	elseif args:IsSpellID(72452, 72435) then
		timerFear:Cancel()
	end
end