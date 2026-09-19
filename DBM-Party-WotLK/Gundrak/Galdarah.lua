local mod	= DBM:NewMod("Galdarah", "DBM-Party-WotLK", 5)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("20260919205410")
mod:SetCreatureID(29306)

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 55250 59824 55292 59829 54956 59827 55276 55218 55285",
	"SPELL_CAST_SUCCESS 55250 59824 55292 59829 54956 59827",
	"CHAT_MSG_MONSTER_YELL"
)

local warnPhase1		= mod:NewAnnounce("TimerPhase1", 4, "Interface\\Icons\\Spell_Shadow_ShadesOfDarkness")
local warnPhase2		= mod:NewAnnounce("TimerPhase2", 4, "Interface\\Icons\\Spell_Shadow_ShadesOfDarkness")

local specWarnSlash		= mod:NewSpecialWarningMove(55250)
local warnPuncture		= mod:NewSpellAnnounce(55276, 3, nil, "Healer")
local warnStampede		= mod:NewSpellAnnounce(55218, 3)
local warnEnrageRhino		= mod:NewSpellAnnounce(55285, 3, nil, "Tank")

local timerStomp		= mod:NewCDRangeTimer(10, 12, 55292)--Core 7-10s first, 10-12s repeat
local timerSlash		= mod:NewCDRangeTimer(17, 19, 55250)--Core 11-19s first, 17-19s repeat
local timerCharge		= mod:NewCDRangeTimer(16, 17, 54956)--Core 8-11s first, 16-17s repeat
local timerPunctureCD		= mod:NewCDRangeTimer(15, 18, 55276, nil, "Healer", nil, 3)--Core 10-16s first, 15-18s repeat (was untracked)
local timerStampedeCD		= mod:NewCDTimer(15, 55218, nil, nil, nil, 3)--Core 10s first, 15s repeat (was untracked)
local timerEnrageCD		= mod:NewCDRangeTimer(16, 17, 55285, nil, "Tank", nil, 3)--Core 6-8s first, 16-17s repeat (was untracked)
local timerPhase1		= mod:NewTimer(32, "TimerPhase1", 72262)--Core 32s phases, not 52s
local timerPhase2		= mod:NewTimer(32, "TimerPhase2", 72262)

function mod:OnCombatStart(delay)
	self:SetStage(1)
	timerSlash:StartRange(11-delay, 19-delay)--Core 11-19s first
	timerPunctureCD:StartRange(10-delay, 16-delay)--Core 10-16s first
	timerStampedeCD:Start(10-delay)--Core 10s first
	timerPhase2:Start(32-delay)--Core 32s troll phase
end

function mod:OnCombatEnd()
	timerStomp:Cancel()
	timerSlash:Cancel()
	timerCharge:Cancel()
	timerPunctureCD:Cancel()
	timerStampedeCD:Cancel()
	timerEnrageCD:Cancel()
	timerPhase1:Cancel()
	timerPhase2:Cancel()
end

function mod:SPELL_CAST_START(args)
	if args:IsSpellID(55250, 59824) then -- Whirling Slash (core N/H IDs)
		timerSlash:StartRange(17, 19)
		specWarnSlash:Show()
	elseif args:IsSpellID(55292, 59829) then -- Stomp (core N/H IDs)
		timerStomp:StartRange(10, 12)
	elseif args:IsSpellID(54956, 59827) then -- Impaling Charge (core N/H IDs)
		timerCharge:StartRange(16, 17)
	elseif args.spellId == 55276 then -- Puncture (was untracked)
		warnPuncture:Show()
		timerPunctureCD:StartRange(15, 18)
	elseif args.spellId == 55218 then -- Stampede (was untracked)
		warnStampede:Show()
		timerStampedeCD:Start()
	elseif args.spellId == 55285 then -- Enrage rhino (was untracked)
		warnEnrageRhino:Show()
		timerEnrageCD:StartRange(16, 17)
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	if args:IsSpellID(55250, 59824) then
		timerSlash:StartRange(17, 19)
	elseif args:IsSpellID(55292, 59829) then
		timerStomp:StartRange(10, 12)
	elseif args:IsSpellID(54956, 59827) then
		timerCharge:StartRange(16, 17)
	end
end

function mod:CHAT_MSG_MONSTER_YELL(msg)
	if msg == L.YellPhase2_1 or msg:find(L.YellPhase2_1) or msg == L.YellPhase2_2 or msg:find(L.YellPhase2_2) then
		if self.vb.phase == 1 then
			self:SetStage(2)
			timerPhase2:Cancel()
			warnPhase2:Show()
			timerPhase1:Start(32)--Core 32s rhino phase
			timerSlash:Cancel()
			timerStomp:Cancel()
			timerCharge:Cancel()
			timerStomp:StartRange(7, 10)--Core 7-10s first
			timerCharge:StartRange(8, 11)--Core 8-11s first
			timerEnrageCD:StartRange(6, 8)--Core 6-8s first
		elseif self.vb.phase == 2 then
			self:SetStage(1)
			timerPhase1:Cancel()
			warnPhase1:Show()
			timerPhase2:Start(32)--Core 32s troll phase
			timerSlash:Cancel()
			timerStomp:Cancel()
			timerCharge:Cancel()
			timerSlash:StartRange(11, 19)--Core 11-19s first
			timerPunctureCD:StartRange(10, 16)
			timerStampedeCD:Start(10)
		end
	end
end