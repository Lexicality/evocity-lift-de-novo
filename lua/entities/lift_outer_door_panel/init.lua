--[[
	Lift door panel (Outer)
--]]
include("shared.lua");
AddCSLuaFile("shared.lua");
AddCSLuaFile("cl_init.lua");

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
