local mod	= DBM:NewMod("Galdarah", "DBM-Party-WotLK", 5)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("20220518110528")
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

local timerStomp		= mod:NewCDTimer(11, 55292)--Core 7-10s first, 10-12s repeat
local timerSlash		= mod:NewCDTimer(18, 55250)--Core 11-19s first, 17-19s repeat
local timerCharge		= mod:NewCDTimer(16, 54956)--Core 8-11s first, 16-17s repeat
local timerPunctureCD		= mod:NewCDTimer(16, 55276, nil, "Healer", nil, 3)--Core 10-16s first, 15-18s repeat (was untracked)
local timerStampedeCD		= mod:NewCDTimer(15, 55218, nil, nil, nil, 3)--Core 10s first, 15s repeat (was untracked)
local timerEnrageCD		= mod:NewCDTimer(16, 55285, nil, "Tank", nil, 3)--Core 6-8s first, 16-17s repeat (was untracked)
local timerPhase1		= mod:NewTimer(32, "TimerPhase1", 72262)--Core 32s phases, not 52s
local timerPhase2		= mod:NewTimer(32, "TimerPhase2", 72262)

function mod:OnCombatStart(delay)
	self:SetStage(1)
	timerSlash:Start(15-delay)--Core 11-19s first
	timerPunctureCD:Start(13-delay)--Core 10-16s first
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
		timerSlash:Start()
		specWarnSlash:Show()
	elseif args:IsSpellID(55292, 59829) then -- Stomp (core N/H IDs)
		timerStomp:Start()
	elseif args:IsSpellID(54956, 59827) then -- Impaling Charge (core N/H IDs)
		timerCharge:Start()
	elseif args.spellId == 55276 then -- Puncture (was untracked)
		warnPuncture:Show()
		timerPunctureCD:Start()
	elseif args.spellId == 55218 then -- Stampede (was untracked)
		warnStampede:Show()
		timerStampedeCD:Start()
	elseif args.spellId == 55285 then -- Enrage rhino (was untracked)
		warnEnrageRhino:Show()
		timerEnrageCD:Start()
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	if args:IsSpellID(55250, 59824) then
		timerSlash:Start()
	elseif args:IsSpellID(55292, 59829) then
		timerStomp:Start()
	elseif args:IsSpellID(54956, 59827) then
		timerCharge:Start()
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
			timerStomp:Start(8)--Core 7-10s first
			timerCharge:Start(10)--Core 8-11s first
			timerEnrageCD:Start(7)--Core 6-8s first
		elseif self.vb.phase == 2 then
			self:SetStage(1)
			timerPhase1:Cancel()
			warnPhase1:Show()
			timerPhase2:Start(32)--Core 32s troll phase
			timerSlash:Cancel()
			timerStomp:Cancel()
			timerCharge:Cancel()
			timerSlash:Start(15)--Core 11-19s first
			timerPunctureCD:Start(13)
			timerStampedeCD:Start(10)
		end
	end
end