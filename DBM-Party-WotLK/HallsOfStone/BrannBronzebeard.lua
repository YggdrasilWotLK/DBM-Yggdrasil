local mod	= DBM:NewMod("BrannBronzebeard", "DBM-Party-WotLK", 7)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("20260914104916")
mod:SetCreatureID(28070)
mod:SetMinSyncRevision(2861)

mod:RegisterCombat("yell", L.Pull)
mod:RegisterKill("yell", L.Kill)
mod:SetMinCombatTime(50)
mod:SetWipeTime(25)

mod:RegisterEventsInCombat(
	"CHAT_MSG_MONSTER_YELL"
)

local warningPhase	= mod:NewAnnounce("WarningPhase", 2, "Interface\\Icons\\Spell_Nature_WispSplode")

local timerEvent	= mod:NewTimer(310, "timerEvent", "Interface\\Icons\\Spell_Holy_BorrowedTime", nil, nil, 6)--Core 310s tribunal

function mod:OnCombatStart(delay)
	timerEvent:Start(310-delay)--Core 310s
end

function mod:OnCombatEnd()
	timerEvent:Cancel()
end

function mod:CHAT_MSG_MONSTER_YELL(msg)
	if L.Phase1 == msg then
		warningPhase:Show(1)
	elseif msg == L.Phase2 or (msg:find("Celestial") and msg:find("planetary")) then -- locale Phase2 has double-space typo
		warningPhase:Show(2)
	elseif msg == L.Phase3 then
		warningPhase:Show(3)
	end
end