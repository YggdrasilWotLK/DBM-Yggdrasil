local mod	= DBM:NewMod("DrakosTheInterrogator", "DBM-Party-WotLK", 9)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("20260914104916")
mod:SetCreatureID(27654)

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 51336 50774",
	"UNIT_DIED"
)

mod:AddBoolOption("MakeitCountTimer", true, "timer")

local warnPull			= mod:NewSpellAnnounce(51336, 3)
local warnStomp			= mod:NewSpellAnnounce(50774, 3)

local timerPullCD			= mod:NewCDRangeTimer(15, 25, 51336, nil, nil, nil, 3)--Core 10-15s first, 15-25s repeat
local timerStompCD		= mod:NewCDRangeTimer(10, 20, 50774, nil, nil, nil, 2)--Core 3-6s first, 10-20s repeat

function mod:OnCombatStart(delay)
	timerPullCD:StartRange(10-delay, 15-delay)--Core 10-15s first
	timerStompCD:StartRange(3-delay, 6-delay)--Core 3-6s first
end

function mod:OnCombatEnd()
	timerPullCD:Cancel()
	timerStompCD:Cancel()
end

function mod:SPELL_CAST_START(args)
	if args.spellId == 51336 then -- Magic Pull (core 15-25s repeat, was untracked)
		warnPull:Show()
		timerPullCD:StartRange(15, 25)
	elseif args.spellId == 50774 then -- Thundering Stomp (core 10-20s repeat, was untracked)
		warnStomp:Show()
		timerStompCD:StartRange(10, 20)
	end
end

function mod:UNIT_DIED(args)
	if not self:IsDifficulty("normal5") then
		if self.Options.MakeitCountTimer and not DBT:GetBar(L.MakeitCountTimer) then
			local cid = self:GetCIDFromGUID(args.destGUID)
			if cid == 27654 then		-- Drakos The Interrogator
				DBT:CreateBar(1200, L.MakeitCountTimer)
			end
		end
	end
end