local mod	= DBM:NewMod(537, "DBM-Party-BC", 8, 250)

mod:SetRevision("20260914132425")
mod:SetCreatureID(18344)

mod:SetModelID(19780)
mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_SUCCESS 32371"
)

local specWarnAdds	= mod:NewSpecialWarningAdds(32371, "-Healer", nil, nil, 1, 2)

function mod:SPELL_CAST_SUCCESS(args)
	if args.spellId == 32371 then -- Ethereal Beacon (ID check instead of locale name-match)
		self:SendSync("Adds")
	end
end

function mod:OnSync(msg)
	if msg == "Adds" and self:AntiSpam(5, 1) then
		specWarnAdds:Show()
		specWarnAdds:Play("killmob")
	end
end