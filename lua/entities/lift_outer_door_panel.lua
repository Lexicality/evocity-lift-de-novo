--[[
	Lift door panel (Outer)
--]]
AddCSLuaFile()

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
else
	function ENT:SpawnFunction(ply, tr)
		scripted_ents.Get(self.Base)["SpawnFunction"](self, ply, tr);
	end

	function ENT:Use(activator)
		print(self, activator);
		if (not activator:IsPlayer()) then
			return;
		elseif (self:GetDTBool(0)) then -- Tryin to get in
			lift.GetIn(activator, self.liftnum);
		elseif (not self:GetDTBool(1)) then -- Request
			lift.RequestStop(self.liftnum, self.floornum);
		end
	end

	ENT.liftnum  = 0;
	ENT.floornum = 0;
	function ENT:Setup(liftnum, floornum)
		print("setup", self, liftnum, floornum);
		self.liftnum  = liftnum;
		self.floornum = floornum;
	end

end
