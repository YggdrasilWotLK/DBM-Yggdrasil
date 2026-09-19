local mod	= DBM:NewMod("Trollgore", "DBM-Party-WotLK", 4)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("20260914104916")
mod:SetCreatureID(26630)

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 49555 49380",
	"SPELL_CAST_SUCCESS 49380",
	"CHAT_MSG_RAID_BOSS_EMOTE"
)

local warnConsume		= mod:NewSpellAnnounce(49380,1)--Core ID 49380 (was phantom 59803)

local timerExplosionCD	= mod:NewCDTimer(17, 49555)--Core 15-19s repeat
local timerNextConsume	= mod:NewNextTimer(15, 49380)--Core 15s repeat

function mod:OnCombatStart(delay)
	timerExplosionCD:Start(35-delay)--Core 35s first
	timerNextConsume:Start(15-delay)--Core 15s first
end

function mod:OnCombatEnd()
	timerExplosionCD:Cancel()
	timerNextConsume:Cancel()
end

function mod:SPELL_CAST_START(args)
	if args.spellId == 49555 then
		timerExplosionCD:Start()
	elseif args.spellId == 49380 then -- Consume (core ID; SUCCESS fallback shares AntiSpam key below)
		if self:AntiSpam(5, "Consume") then
			warnConsume:Show()
		end
		timerNextConsume:Start()
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	if args.spellId == 49380 then
		if self:AntiSpam(5, "Consume") then
			warnConsume:Show()
		end
		timerNextConsume:Start()
	end
end

function mod:CHAT_MSG_RAID_BOSS_EMOTE(msg)
	if msg == L.YellExplosion or msg:find(L.YellExplosion) then
		timerExplosionCD:Start()
	end
end