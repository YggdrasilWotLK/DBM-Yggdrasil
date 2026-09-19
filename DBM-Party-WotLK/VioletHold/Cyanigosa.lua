local mod	= DBM:NewMod("Cyanigosa", "DBM-Party-WotLK", 12)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("20260919205410")
mod:SetCreatureID(31134)

mod:RegisterCombat("combat")

mod:RegisterEvents(
	"CHAT_MSG_MONSTER_YELL"
)

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 58693 58690 58688",
	"SPELL_CAST_SUCCESS 58694 58693",
	"SPELL_AURA_APPLIED 59374",
	"SPELL_AURA_REMOVED 59374"
)

local warningVacuum		= mod:NewSpellAnnounce(58694, 1)
local warningBlizzard	= mod:NewSpellAnnounce(58693, 3)
local warnTail			= mod:NewSpellAnnounce(58690, 2, nil, "Melee")
local warnEnergy		= mod:NewSpellAnnounce(58688, 3)

local specwarnMana		= mod:NewSpecialWarningDispel(59374, "Healer", nil, nil, 1, 2)

local timerVacuumCD		= mod:NewCDTimer(30, 58694, nil, nil, nil, 2)--Core 30s first and repeat
local timerBlizzardCD		= mod:NewCDTimer(15, 58693, nil, nil, nil, 3)--Core 5-10s first, 15s repeat
local timerMana			= mod:NewTargetTimer(8, 59374, nil, "Healer", nil, 5, nil, DBM_COMMON_L.MAGIC_ICON)
local timerManaCD			= mod:NewCDTimer(20, 59374, nil, "Healer", nil, 5, nil, DBM_COMMON_L.MAGIC_ICON)--Core 20s first and repeat (heroic)
local timerTailCD			= mod:NewCDRangeTimer(15, 20, 58690, nil, "Melee", nil, 2)--Core 15-20s repeat
local timerEnergyCD		= mod:NewCDRangeTimer(20, 25, 58688, nil, nil, nil, 3)--Core 5-8s first, 20-25s repeat
local timerCombat		= mod:NewCombatTimer(14)

function mod:OnCombatStart(delay)
	timerVacuumCD:Start(30 - delay)--Core 30s first
	timerBlizzardCD:Start(7 - delay)--Core 5-10s first
	timerTailCD:Start(17 - delay)--Core 15-20s first
	timerEnergyCD:StartRange(5 - delay, 8 - delay)--Core 5-8s first
	if self:IsDifficulty("heroic5") then
		timerManaCD:Start(20 - delay)--Core 20s first (heroic)
	end
end

function mod:OnCombatEnd()
	timerVacuumCD:Cancel()
	timerBlizzardCD:Cancel()
	timerTailCD:Cancel()
	timerEnergyCD:Cancel()
	timerManaCD:Cancel()
end

function mod:SPELL_CAST_START(args)
	if args.spellId == 58693 then -- Blizzard (core single ID, 15s repeat)
		warningBlizzard:Show()
		timerBlizzardCD:Start()
	elseif args.spellId == 58690 then -- Tail Sweep (core 15-20s repeat, was untracked)
		timerTailCD:StartRange(15, 20)
	elseif args.spellId == 58688 then -- Uncontrollable Energy (core 20-25s repeat, was untracked)
		warnEnergy:Show()
		timerEnergyCD:StartRange(20, 25)
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	if args.spellId == 58694 then -- Vacuum (core 30s repeat)
		warningVacuum:Show()
		timerVacuumCD:Cancel()
		timerVacuumCD:Start()
	end
end

function mod:SPELL_AURA_APPLIED(args)
	if args.spellId == 59374 then -- Mana Destruction (heroic, core 20s repeat)
		if self:CheckDispelFilter() then
			specwarnMana:Show(args.destName)
			specwarnMana:Play("helpdispel")
		end
		timerMana:Start(args.destName)
		timerManaCD:Start()
	end
end

function mod:SPELL_AURA_REMOVED(args)
	if args.spellId == 59374 then
		timerMana:Cancel(args.destName)
	end
end

function mod:CHAT_MSG_MONSTER_YELL(msg)
	if msg == L.CyanArrived then
		self:SendSync("CyanArrived")
	end
end

function mod:OnSync(msg)
	if msg == "CyanArrived" then
		timerCombat:Start()
	end
end