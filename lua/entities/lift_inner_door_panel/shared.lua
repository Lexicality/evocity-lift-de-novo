--[[
	Lift door panel (Inner)
--]]
ENT.Type      = "anim"
ENT.Base      = "lift_door_panel"
ENT.PrintName = "Inner Lift Door Panel"
ENT.Author    = "Lexi"
ENT.Contact   = ""
ENT.Purpose   = "Getting out of the lift"
ENT.Spawnable = true
ENT.Category  = "Lift"

if (CLIENT) then
	local waittext =     Material("lift/doorcontrol_wait_new");
	local exittext =     Material("lift/doorcontrol_exit_new");
	local exitcolour  = Color(000, 153, 255, 200); -- Blue:   #0099FF
	local waitcolour  = Color(006, 179, 163, 200); -- Green:  #06B3A3
	local acolour, amat;
	local liftnum;
	function ENT:Draw()
		liftnum = LocalPlayer():GetNWInt("liftnumber");
		if (liftnum == 0) then return; end
		if (self:GetDTBool(liftnum - 1)) then
			acolour = exitcolour;
			amat = exittext;
		else
			acolour = waitcolour;
			amat = waittext;
		end
		self:DrawHologram(acolour, amat);
	end
end
