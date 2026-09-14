local mod	= DBM:NewMod("Ahune", "DBM-WorldEvents")
local L		= mod:GetLocalizedStrings()

mod:SetRevision("20220630185628")
mod:SetCreatureID(25740)--25740 Ahune, 25755, 25756 the two types of adds

mod:SetReCombatTime(10)
mod:RegisterCombat("combat")
mod:SetMinCombatTime(15)

mod:RegisterEvents(
	"CHAT_MSG_MONSTER_YELL"--Luma Skymother pull line is MONSTER_YELL (type 14), not SAY
)

mod:RegisterEventsInCombat(
	"SPELL_AURA_APPLIED 45954",
	"SPELL_AURA_REMOVED 45954"
)

local warnSubmerged				= mod:NewAnnounce("Submerged", 2, "Interface\\AddOns\\DBM-Core\\textures\\CryptFiendBurrow.blp")
local warnEmerged				= mod:NewAnnounce("Emerged", 2, "Interface\\AddOns\\DBM-Core\\textures\\CryptFiendUnBurrow.blp")

local specWarnAttack			= mod:NewSpecialWarning("specWarnAttack", nil, nil, nil, 1, 2)

local timerCombatStart			= mod:NewCombatTimer(10)--rollplay for first pull
local timerEmerge				= mod:NewTimer(35, "EmergeTimer", "Interface\\AddOns\\DBM-Core\\textures\\CryptFiendUnBurrow.blp", nil, nil, 6)--Core 35s submerge (was 33.5)
local timerSubmerge				= mod:NewTimer(100, "SubmergeTimer", "Interface\\AddOns\\DBM-Core\\textures\\CryptFiendBurrow.blp", nil, nil, 6)--Core 100s emerged (was 92)

function mod:OnCombatStart(delay)
	if self:AntiSpam(4, 1) then
		timerSubmerge:Start(98-delay)--first ~98s attackable, rest 100s
	end
end

function mod:SPELL_AURA_APPLIED(args)
	if args.spellId == 45954 and self:AntiSpam(4, 1) then -- Ahunes Shield
		warnEmerged:Show()
		timerSubmerge:Start()
	end
end

function mod:SPELL_AURA_REMOVED(args)
	if args.spellId == 45954 then -- Ahunes Shield
		warnSubmerged:Show()
		timerEmerge:Start()
		specWarnAttack:Show()
		specWarnAttack:Play("changetarget")
	end
end

function mod:CHAT_MSG_MONSTER_YELL(msg)
	if msg == L.Pull then
		timerCombatStart:Start()
		self:Schedule(10, DBM.StartCombat, DBM, self, 0)
	end
end