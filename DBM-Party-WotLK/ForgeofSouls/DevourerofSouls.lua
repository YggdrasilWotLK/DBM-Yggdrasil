local mod	= DBM:NewMod("DevourerofSouls", "DBM-Party-WotLK", 14)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("20260914104916")
mod:SetCreatureID(36502)

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 68982 68820 68939 68899",
	"SPELL_AURA_APPLIED 69051 68939",
	"SPELL_AURA_REMOVED 69051"
)

local warnUnleashedSouls		= mod:NewSpellAnnounce(68939, 3)
local warnWellofSouls			= mod:NewSpellAnnounce(68820, 3)
local warnMirroredSoul			= mod:NewTargetAnnounce(69051, 4)

local specwarnMirroredSoul		= mod:NewSpecialWarningReflect(69051, nil, nil, nil, 1, 2)
local specwarnWailingSouls		= mod:NewSpecialWarningSpell(68899, nil, nil, nil, 2, 2)
local specwarnPhantomBlast		= mod:NewSpecialWarningInterrupt(68982, "HasInterrupt", nil, nil, 1, 2)

local timerMirroredSoul			= mod:NewTargetTimer(8, 69051, nil, nil, nil, 3)
local timerUnleashedSouls		= mod:NewBuffActiveTimer(5, 68939, nil, nil, nil, 2)
local timerBlastCD				= mod:NewCDTimer(5, 68982, nil, nil, nil, 3)--Core 5s first and repeat (was untracked)
local timerMirroredCD				= mod:NewCDRangeTimer(20, 30, 69051, nil, nil, nil, 3)--Core 9s first, 20-30s repeat
local timerWellCD					= mod:NewCDRangeTimer(25, 30, 68820, nil, nil, nil, 3)--Core 6-8s first, 25-30s repeat
local timerUnleashedCD			= mod:NewCDRangeTimer(30, 40, 68939, nil, nil, nil, 2)--Core 18-20s first, 30-40s repeat
local timerWailingCD				= mod:NewCDTimer(80, 68899, nil, nil, nil, 2)--Core 65s first, 80s repeat

mod:AddSetIconOption("SetIconOnMirroredTarget", 69051, false, false, {8})

function mod:OnCombatStart(delay)
	timerBlastCD:Start(5-delay)--Core 5s first
	timerMirroredCD:Start(9-delay)--Core 9s first
	timerWellCD:StartRange(6-delay, 8-delay)--Core 6-8s first
	timerUnleashedCD:StartRange(18-delay, 20-delay)--Core 18-20s first
	timerWailingCD:Start(65-delay)--Core 65s first
end

function mod:OnCombatEnd()
	timerBlastCD:Cancel()
	timerMirroredCD:Cancel()
	timerWellCD:Cancel()
	timerUnleashedCD:Cancel()
	timerWailingCD:Cancel()
end

function mod:SPELL_CAST_START(args)
	if args.spellId == 68982 then	-- Phantom Blast (core single ID, 5s repeat)
		specwarnPhantomBlast:Show(args.sourceName)
		specwarnPhantomBlast:Play("kickcast")
		timerBlastCD:Start()
	elseif args.spellId == 68820 then					-- Well of Souls (core 25-30s repeat)
		warnWellofSouls:Show()
		timerWellCD:StartRange(25, 30)
	elseif args.spellId == 68939 then					-- Unleashed Souls (core 30-40s repeat)
		warnUnleashedSouls:Show()
		timerUnleashedCD:StartRange(30, 40)
	elseif args.spellId == 68899 then					-- Wailing Souls (core 80s repeat)
		specwarnWailingSouls:Show()
		specwarnWailingSouls:Play("aesoon")
		timerWailingCD:Start()
	end
end

function mod:SPELL_AURA_APPLIED(args)
	if args.spellId == 69051 and args:IsDestTypePlayer() then	-- Mirrored Soul (core 20-30s repeat)
		warnMirroredSoul:Show(args.destName)
		timerMirroredSoul:Start(args.destName)
		timerMirroredCD:StartRange(20, 30)
		specwarnMirroredSoul:Show(args.sourceName)--if sourcename isn't good use L.name
		specwarnMirroredSoul:Play("stopattack")
		if self.Options.SetIconOnMirroredTarget then
			self:SetIcon(args.destName, 8, 8)
		end
	elseif args.spellId == 68939 then							-- Unleashed Souls
		timerUnleashedSouls:Start()
	end
end

function mod:SPELL_AURA_REMOVED(args)
	if args.spellId == 69051 and args:IsDestTypePlayer() then	-- Mirrored Soul
		timerMirroredSoul:Cancel(args.destName)
		if self.Options.SetIconOnMirroredTarget then
			self:SetIcon(args.destName, 0)
		end
	end
end