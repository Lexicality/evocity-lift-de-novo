--
-- Lift Control Panel - Server
--
include("shared.lua");
AddCSLuaFile("shared.lua");
AddCSLuaFile("cl_init.lua");

function ENT:Initialize()
	self:SetModel("models/props_junk/sawblade001a.mdl")
	self:SetSolid(SOLID_VPHYSICS)
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_NONE)
	self:SetCollisionGroup(COLLISION_GROUP_WORLD);
	self:SetColor(255,255,255,1);
	self:DrawShadow(false);
	self:SetUseType(SIMPLE_USE);
	self.PhysgunDisabled = true;
	self.m_tblToolsAllowed = {};
	self._POwner = "World" -- Damn prop protection ¬_¬'
	local phys = self:GetPhysicsObject();
	if (IsValid(phys)) then
		phys:EnableMotion(false);
	end
end

function ENT:SpawnFunction(ply, tr)
	if (not tr.Hit) then return end
	local pos = tr.HitPos + tr.HitNormal * 30;
	local ent = ents.Create("lift_control_panel");
	ent:SetPos(pos);
	ent:SetAngles(Angle(0, 90, 90));
	ent:Spawn();
	ent:Activate();
	return ent;
end

function ENT:Use(ply)
	print(self, ply)
	if (not (IsValid(ply) and ply:IsPlayer() and ply:GetNWInt("liftnumber") > 0)) then
		return;
	end
	local btn = self:LookingAtButton(ply)
	print(btn);
	if (btn) then
		lift.RequestStop(ply:GetNWInt("liftnumber"), btn);
	end
end
