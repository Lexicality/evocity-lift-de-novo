--[[
	Lift door panel (Inner)
--]]
include("shared.lua");
AddCSLuaFile("shared.lua");
AddCSLuaFile("cl_init.lua");

function ENT:SpawnFunction(ply, tr)
	scripted_ents.Get(self.Base)["SpawnFunction"](self, ply, tr);
end

function ENT:Use(activator)
	print(self, activator, self:GetDTBool(0));
	if (not activator:IsPlayer()) then
		return;
	end
	liftnum = activator:GetNWInt("liftnumber");
	if (liftnum == 0) then return; end
	if (self:GetDTBool(liftnum - 1)) then
		lift.GetOut(activator);
	end
end	
