--
-- Lift control panel - Shared
--
AddCSLuaFile();

ENT.Type      = "anim"
ENT.Base      = "base_anim"
ENT.PrintName = "Lift Control Panel"
ENT.Author    = "Lexi"
ENT.Contact   = ""
ENT.Purpose   = "Controlling the lift"
ENT.Spawnable = true
ENT.Category  = "Lift"

local ratio = 32;
local buttonh = 128/ratio/1.5;
local buttonw = 512/ratio/1.5;
local buttonposes = {
	Vector(0,0,-buttonh*1.6);
	Vector(0,0,-buttonh*0.8);
	Vector(0,0, 0          );
	Vector(0,0, buttonh*0.8);
	Vector(0,0, buttonh*1.6);
}
do
	-- note:
	-- Forward() == x == Left
	-- Right() == -y (YES, FUCKING NEGATIVE) == down?
	-- Up() == z == Outwards
	local bw, bh = buttonw / 2, buttonh / 2;
	local function box(pos)
		pos = pos.z
		return {
			Vector( bw,  bh + pos,  0);
			Vector(-bw, -bh + pos, 10);
		};
	end
	local bvecs = {}
	for num, pos in pairs(buttonposes) do
		bvecs[num] = box(pos);
	end
	function ENT:LookingAtButton(ply)
		local tr = ply:GetEyeTrace();
		if (not (tr.Entity == self and tr.HitPos:Distance(tr.StartPos) < 90)) then
			return false;
		end
		local pos = self:WorldToLocal(tr.HitPos);
		for b, vecs in pairs(bvecs) do
			if (util.IsWithinBox(vecs[1], vecs[2], pos)) then
				return b;
			end
		end
		return false;
	end
end
if (CLIENT) then
	local render = render
	local arrow   = Material("lift/holo_controls_arrow");
	local rails   = Material("lift/holo_controls_arrow_rails");
	local bground = Material("lift/holo_controls_background");
	local top     = Material("lift/holo_controls_top");
	local topb    = Material("lift/holo_controls_top_blank");
	local bottom  = Material("lift/holo_controls_bottom");
	local huge    = Material("lift/holo_controls_huge");
	local selcol  = Color(150, 150, 150);
	local rotation = 180;
	local buttons = {
		Material("lift/holo_controls_button_carpark");
		Material("lift/holo_controls_button_lobby");
		Material("lift/holo_controls_button_systems");
		Material("lift/holo_controls_button_offices");
		Material("lift/holo_controls_button_executive");
	}
	local selectedbuttons = {
		Material("lift/holo_controls_button_selected_carpark");
		Material("lift/holo_controls_button_selected_lobby");
		Material("lift/holo_controls_button_selected_systems");
		Material("lift/holo_controls_button_selected_offices");
		Material("lift/holo_controls_button_selected_executive");
	}
	local boollookup = {};
	for i = 1, 4 do
		boollookup[i] = {};
		for j = 1, 5 do
			boollookup[i][j] = i .. j;
		end
	end
	local posmply, posvec, posvecbtm = 0.8, Vector(0,0,buttonh), buttonposes[1];
	local toppos = Vector(0,0,buttonh* 2.8);
	local topw, toph = 512/ratio, 128/ratio;
	local btmpos = Vector(0,0,buttonh*-2.8);
	local btmw, btmh = 512/ratio, 128/ratio;
	local railsw, railsh = 128/ratio/1.7, buttonh*4.525;
	local arrw, arrh = 64/ratio/1.4, 64/ratio/1.4;
	local bw, bh = 512/ratio/1.3, buttonh*4.6;
	local hw, hh = 1024/ratio/1.8, 1024/ratio/1.8
	local dir, pos, off, bcol;
	local liftnum;
	function ENT:Draw()
		liftnum = LocalPlayer():GetNWInt("liftnumber");
		if (liftnum == 0) then return; end
		dir = self:GetUp();
		pos = self:GetPos();
		off = self:GetForward();
		pos = pos + dir / 4;
		render.SetMaterial(arrow);
		render.DrawQuadEasy(pos - (off * 6.2) + posvecbtm + (posvec * posmply * (self:GetDTFloat(liftnum - 1) - 1)), dir, arrw, arrh, nil, rotation);
		local btn = self:LookingAtButton(LocalPlayer());
		for i = 1, 5 do
			if (self:GetNWBool(boollookup[liftnum][i])) then
				render.SetMaterial(selectedbuttons[i]);
			else
				render.SetMaterial(buttons[i]);
			end
			bcol = (btn and btn == i) and selcol or nil;
			render.DrawQuadEasy(pos+buttonposes[i]+off, dir, buttonw, buttonh, bcol, rotation);
		end
		pos = pos + dir / 4;
		render.SetMaterial(huge);
		render.DrawQuadEasy(pos, dir, hw, hh, nil, rotation);
	end
else
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

end
