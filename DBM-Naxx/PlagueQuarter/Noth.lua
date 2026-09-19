local mod	= DBM:NewMod("Noth", "DBM-Naxx", 3)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("20260913231415")
mod:SetCreatureID(15954)

mod:RegisterCombat("combat_yell", L.Pull)

mod:RegisterEvents(
	"SPELL_CAST_SUCCESS 29213 54835 29212 54814 29208",
	"SPELL_AURA_APPLIED 29208",
	"CHAT_MSG_RAID_BOSS_EMOTE",
	"UNIT_SPELLCAST_SUCCEEDED boss1"
)

local warnTeleportNow	= mod:NewAnnounce("WarningTeleportNow", 3, 46573)
local warnTeleportSoon	= mod:NewAnnounce("WarningTeleportSoon", 1, 46573)
local warnCurse			= mod:NewSpellAnnounce(29213, 2)
local warnBlinkSoon		= mod:NewSoonAnnounce(29208, 1)
local warnBlink			= mod:NewSpellAnnounce(29208, 3)

local specWarnAdds		= mod:NewSpecialWarningAdds(29212, "-Healer", nil, nil, 1, 2)

local timerTeleport		= mod:NewTimer(110, "TimerTeleport", 46573, nil, nil, 6)--Core 110s ground phase
local timerTeleportBack	= mod:NewTimer(70, "TimerTeleportBack", 46573, nil, nil, 6)--Core 70s balcony
local timerCurseCD		= mod:NewCDTimer(25, 29213, nil, nil, nil, 5, nil, DBM_COMMON_L.CURSE_ICON)--Core 15s first, 25s repeat
local timerAddsCD		= mod:NewAddsTimer(30, 29212, nil, "-Healer")--Core announce 10s + summon 4s, 30s repeat
local timerBlink		= mod:NewNextTimer(30, 29208, nil, nil, nil, 3)--Core 25m-only, 26s first, 30s repeat

mod.vb.teleCount = 0
mod.vb.addsCount = 0
mod.vb.curseCount = 0

function mod:Balcony()
	self.vb.teleCount = self.vb.teleCount + 1
	self.vb.addsCount = 0
	timerCurseCD:Stop()
	timerAddsCD:Stop()
	timerBlink:Stop()
	-- Core: balcony announce 4s + summon 4s, 30s repeat; return after fixed 70s.
	timerAddsCD:Start(8)--Announce 4s + summon 4s
	timerTeleportBack:Start(70)
	warnTeleportSoon:Schedule(50)
	warnTeleportNow:Schedule(70)
end

-- function mod:BackInRoom(delay)
--	delay = delay or 0
--	self:SetStage(0)
--	local timer
--	if self.vb.phase == 1 then timer = 90 - delay
--	elseif self.vb.phase == 2 then timer = 110 - delay
--	elseif self.vb.phase == 3 then timer = 180 - delay
--	else return end
--	timerTeleport:Show(timer)
--	warnTeleportSoon:Schedule(timer - 20)
--	warnTeleportNow:Schedule(timer)
--	self:ScheduleMethod(timer, "Balcony")
-- end

function mod:OnCombatStart(delay)
	self.vb.phase = 0
	self.vb.teleCount = 0
	self.vb.addsCount = 0
	self.vb.curseCount = 0
	timerAddsCD:Start(14-delay)--Core announce 10s + summon 4s
	timerCurseCD:Start(15-delay)--Core 15s first
	timerTeleport:Start(110-delay)--Core 110s ground phase
	warnTeleportSoon:Schedule(90-delay)
	self:ScheduleMethod(110-delay, "Balcony")
end

function mod:OnCombatEnd()
	self:UnscheduleMethod("Balcony")
	timerTeleport:Cancel()
	timerTeleportBack:Cancel()
	timerCurseCD:Cancel()
	timerAddsCD:Cancel()
	timerBlink:Cancel()
	warnTeleportSoon:Cancel()
	warnTeleportNow:Cancel()
	warnBlinkSoon:Cancel()
end

function mod:SPELL_CAST_SUCCESS(args)
	if args:IsSpellID(29213, 54835) then	-- Curse of the Plaguebringer (core 25s repeat)
		self.vb.curseCount = self.vb.curseCount + 1
		warnCurse:Show()
		timerCurseCD:Start()
	end
end

function mod:SPELL_AURA_APPLIED(args)
	if args.spellId == 29208 and self:IsDifficulty("normal25", "heroic25") then -- Blink (core 25m-only, 30s repeat)
		warnBlink:Show()
		timerBlink:Start()
		warnBlinkSoon:Schedule(25)
	end
end

function mod:CHAT_MSG_RAID_BOSS_EMOTE(msg)
	if msg == L.Adds or msg:find(L.Adds) then
		self:SendSync("Adds")--Syncing to help unlocalized clients
	elseif msg == L.AddsTwo or msg:find(L.AddsTwo) then
		self:SendSync("AddsTwo")--Syncing to help unlocalized clients
	end
end

function mod:UNIT_SPELLCAST_SUCCEEDED(_, spellName)
	if spellName == GetSpellInfo(29231) then--Teleport Return (core fixed 70s balcony, 110s ground)
		self.vb.addsCount = 0
		self.vb.curseCount = 0
		timerAddsCD:Stop()
		timerAddsCD:Start(14)--Core announce 10s + summon 4s
		timerTeleport:Start(110)
		warnTeleportSoon:Schedule(90)
		warnTeleportNow:Show()
		timerCurseCD:Start(15)--Core 15s first
		self:ScheduleMethod(110, "Balcony")
	end
end

function mod:OnSync(msg)
	if not self:IsInCombat() then return end
	if msg == "Adds" then--Boss Grounded
		self.vb.addsCount = self.vb.addsCount + 1
		specWarnAdds:Show()
		specWarnAdds:Play("killmob")
		timerAddsCD:Start(30)--Core 30s repeat both phases
	elseif msg == "AddsTwo" then--Boss away
		self.vb.addsCount = self.vb.addsCount + 1
		specWarnAdds:Show()
		specWarnAdds:Play("killmob")
		timerAddsCD:Start(30)--Core 30s repeat both phases
	end
end