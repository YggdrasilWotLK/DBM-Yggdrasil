local mod	= DBM:NewMod("NovosTheSummoner", "DBM-Party-WotLK", 4)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("20260914104916")
mod:SetCreatureID(26631)

mod:RegisterCombat("yell", L.YellPull)
mod:RegisterKill("yell", L.YellKill)
mod:SetWipeTime(25)

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 49034 49037",
	"SPELL_CAST_SUCCESS 49179",
	"SPELL_AURA_APPLIED 50090",
	"CHAT_MSG_MONSTER_YELL"
)

local WarnCrystalHandler		= mod:NewAnnounce("WarnCrystalHandler", 2, 59910)
local warnPhase2				= mod:NewPhaseAnnounce(2)
local warnBlizzard			= mod:NewSpellAnnounce(49034, 3)
local warnFrostbolt			= mod:NewSpellAnnounce(49037, 2)

local timerCrystalHandler		= mod:NewTimer(20, "timerCrystalHandler", 59910, nil, nil, 1, DBM_COMMON_L.DAMAGE_ICON)--Core 20s x4
local timerBlizzardCD			= mod:NewCDTimer(15, 49034, nil, nil, nil, 3)--Core Blizzard (was phantom 59856)
local timerFrostboltCD		= mod:NewCDTimer(10, 49037, nil, nil, nil, 2)--Core Frostbolt (was phantom 59854)

mod.vb.CrystalHandlers = 4

function mod:OnCombatStart(delay)
	self:SetStage(1)
	timerCrystalHandler:Start(20-delay)--Core 20s first
	self.vb.CrystalHandlers = 4
end

function mod:OnCombatEnd()
	timerCrystalHandler:Cancel()
	timerBlizzardCD:Cancel()
	timerFrostboltCD:Cancel()
end

function mod:CHAT_MSG_MONSTER_YELL(msg)
	if msg == L.HandlerYell then
		self.vb.CrystalHandlers = self.vb.CrystalHandlers - 1
		WarnCrystalHandler:Show(self.vb.CrystalHandlers)
		if self.vb.CrystalHandlers > 0 then
			timerCrystalHandler:Start()
		end
	elseif msg == L.Phase2 then
		self:SetStage(2)
		warnPhase2:Show()
	end
end

-- Core casts Blizzard 49034 / Frostbolt 49037 (old 59856/59854 IDs were phantom)
function mod:SPELL_CAST_START(args)
	if args.spellId == 49034 then
		warnBlizzard:Show()
		timerBlizzardCD:Start()
	elseif args.spellId == 49037 then
		warnFrostbolt:Show()
		timerFrostboltCD:Start()
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	if args.spellId == 49179 then -- Summon Crystal Handler (core 20s x4)
		timerCrystalHandler:Start()
	end
end

function mod:SPELL_AURA_APPLIED(args)
	if args.spellId == 50090 then -- Touch of Misery (core ID)
		warnFrostbolt:Show(args.destName)
	end
end