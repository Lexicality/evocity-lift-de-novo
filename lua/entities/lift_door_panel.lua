ENT.Type      = "anim"
ENT.Base      = "base_anim"
ENT.PrintName = "Base Lift Door Panel"
ENT.Author    = "Lexi"
ENT.Contact   = ""
ENT.Purpose   = "HOLE-O-GRAMZ"
ENT.Spawnable = false

AddCSLuaFile();

if (SERVER) then
	function ENT:Initialize()
		self:SetModel("models/props_junk/sawblade001a.mdl")
		self:SetSolid(SOLID_VPHYSICS)
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_NONE)
		self:SetCollisionGroup(COLLISION_GROUP_WORLD);
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
	function ENT:SpawnFunction(ply, tr, classname)
		if (not tr.Hit) then return end
		local pos = tr.HitPos + tr.HitNormal * 30;
		local ent = ents.Create(classname);
		ent:SetPos(pos);
		ent:Spawn();
		ent:Activate();
		return ent;
	end
else
	local render = render
	local backmaterial = Material("lift/doorcontrol_whitecircle");
	local backouter  =   Material("lift/doorcontrol_background_1st_outer_circle");
	local backouter2 =   Material("lift/doorcontrol_background_2nd_outer_circle");
	local backouter3 =   Material("lift/doorcontrol_background_3rd_outer_circle");
	local innerring =    Material("lift/doorcontrol_background_inner_ring");
	local innerteeth1 =  Material("lift/doorcontrol_background_inner_teeth_inner");
	local innerteeth2 =  Material("lift/doorcontrol_background_inner_teeth_outer");
	local liftsymbol =   Material("lift/doorcontrol_lift");
	local whitecolour =  Color(255, 255, 255, 200); -- White
	local dir, pos, ft;
	local size = 24;
	local rotation, outerrotation, outercounterrotation, innerrotation1, innerrotation2 = 180, 0, 0, 0, 0;
	function ENT:DrawHologram(colour, text)
		dir = self:GetUp();
		pos = self:GetPos();
		ft = FrameTime()*2;
		outerrotation = outerrotation + ft*5;
		outercounterrotation = outercounterrotation - ft*10;
		innerrotation1 = innerrotation1 + ft*3
		innerrotation2 = innerrotation2 - ft*7 -- :D
		-- Backplate
		render.SetMaterial(backmaterial);
		render.DrawQuadEasy(pos, dir, size, size, colour, rotation);

		pos = pos + dir/4;
		-- First outer cog
		render.SetMaterial(backouter);
		render.DrawQuadEasy(pos, dir, size, size, colour, outerrotation);

		pos = pos + dir/4;
		-- Inner Inner Teeth
		render.SetMaterial(innerteeth1);
		render.DrawQuadEasy(pos, dir, size, size, colour, innerrotation1);
		-- Outer Inner Teeth
		render.SetMaterial(innerteeth2);
		render.DrawQuadEasy(pos, dir, size, size, colour, innerrotation2);

		pos = pos + dir/4;
		-- Third outer cog - counterspin
		render.SetMaterial(backouter3);
		render.DrawQuadEasy(pos, dir, size, size, colour, outercounterrotation);
		-- Second outer cog
		render.SetMaterial(backouter2);
		render.DrawQuadEasy(pos, dir, size, size, colour, outerrotation);
		-- Inner Ring (No spin)
		render.SetMaterial(innerring);
		render.DrawQuadEasy(pos, dir, size, size, colour, rotation);

		-- 3/4 from the end
		pos = pos + dir/2;
		render.SetMaterial(liftsymbol);
		render.DrawQuadEasy(pos, dir, size, size, whitecolour, rotation);
		if (self:IsBeingLookedAt()) then
			-- 1+3/4 from the end
			pos = pos + dir/2;
			render.SetMaterial(text);
			render.DrawQuadEasy(pos, dir, size, size, whitecolour, rotation);
		end
	end

	function ENT:IsBeingLookedAt()
		local tr = LocalPlayer():GetEyeTrace();
		return tr.Entity == self and tr.HitPos:Distance(LocalPlayer():GetPos()) < 90;
	end
end
