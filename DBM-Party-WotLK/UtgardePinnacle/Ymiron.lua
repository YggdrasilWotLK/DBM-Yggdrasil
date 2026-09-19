local mod	= DBM:NewMod("Ymiron", "DBM-Party-WotLK", 11)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("20260914104916")
mod:SetCreatureID(26861)

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 51750 48291 48292",
	"SPELL_CAST_SUCCESS 51750",
	"SPELL_AURA_APPLIED 48294 59301",
	"SPELL_AURA_REMOVED 48294 59301"
)

local warningBane		= mod:NewSpellAnnounce(48294, 3)
local warningScreams	= mod:NewSpellAnnounce(51750, 2)
local warnFetid			= mod:NewSpellAnnounce(48291, 3, nil, "Tank|Healer")
local warnSlash			= mod:NewSpellAnnounce(48292, 3, nil, "Tank")

local timerBane			= mod:NewBuffActiveTimer(5, 48294, nil, nil, nil, 5, nil, DBM_COMMON_L.MAGIC_ICON)
local timerBaneCD			= mod:NewCDRangeTimer(20, 25, 48294, nil, nil, nil, 3)--Core 18s first, 20-25s repeat
local timerScreams		= mod:NewBuffActiveTimer(8, 51750, nil, nil, nil, 2)
local timerFetidCD		= mod:NewCDRangeTimer(10, 13, 48291, nil, "Tank|Healer", nil, 3)--Core 8s first, 10-13s repeat
local timerSlashCD		= mod:NewCDRangeTimer(30, 35, 48292, nil, "Tank", nil, 3)--Core 28s first, 30-35s repeat

function mod:OnCombatStart(delay)
	timerBaneCD:Start(18-delay)--Core 18s first
	timerFetidCD:Start(8-delay)--Core 8s first
	timerSlashCD:Start(28-delay)--Core 28s first
end

function mod:OnCombatEnd()
	timerBaneCD:Cancel()
	timerFetidCD:Cancel()
	timerSlashCD:Cancel()
end

function mod:SPELL_CAST_START(args)
	if args.spellId == 51750 then -- Screams of the Dead (triggered; SUCCESS may not log; shares AntiSpam key below)
		if self:AntiSpam(5, "Screams") then
			warningScreams:Show()
		end
		timerScreams:Start()
	elseif args.spellId == 48291 then -- Fetid Rot (core 10-13s repeat, was untracked)
		warnFetid:Show()
		timerFetidCD:StartRange(10, 13)
	elseif args.spellId == 48292 then -- Dark Slash (core 30-35s repeat, was untracked)
		warnSlash:Show()
		timerSlashCD:StartRange(30, 35)
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	if args.spellId == 51750 then -- Fallback; shares AntiSpam with START
		if self:AntiSpam(5, "Screams") then
			warningScreams:Show()
		end
		timerScreams:Start()
	end
end

function mod:SPELL_AURA_APPLIED(args)
	if args:IsSpellID(48294, 59301) then
		warningBane:Show()
		timerBane:Start()
		timerBaneCD:StartRange(20, 25)
	end
end

function mod:SPELL_AURA_REMOVED(args)
	if args:IsSpellID(48294, 59301) then
		timerBane:Stop()
	end
end