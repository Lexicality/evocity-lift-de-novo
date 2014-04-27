--[[
	Lift door panel (Outer)
--]]
ENT.Type      = "anim"
ENT.Base      = "lift_door_panel"
ENT.PrintName = "Outer Lift Door Panel"
ENT.Author    = "Lexi"
ENT.Contact   = ""
ENT.Purpose   = "Getting into / calling the lift"
ENT.Spawnable = true
ENT.Category  = "Lift"

if (CLIENT) then
	local waittext =    Material("lift/doorcontrol_wait_new");
	local entertext =   Material("lift/doorcontrol_enter_new");
	local calltext =    Material("lift/doorcontrol_call_new");
	local entercolour = Color(000, 153, 255, 200); -- Blue:  #0099FF
	local waitcolour  = Color(006, 179, 163, 200); -- Green: #06B3A3
	local noentcolour = Color(238, 012, 012, 200); -- Red:   #EE0C0C
	local acolour, amat;
	function ENT:Draw()
		if (self:GetDTBool(0)) then -- Enterable overrides requested.
			acolour = entercolour;
			amat = entertext;
		elseif (self:GetDTBool(1)) then -- Requested
			acolour = waitcolour;
			amat = waittext;
		else
			acolour = noentcolour;
			amat = calltext;
		end
		self:DrawHologram(acolour, amat);
	end
end
