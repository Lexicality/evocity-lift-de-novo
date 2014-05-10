print "Hello world!"
AddCSLuaFile()

DEFINE_BASECLASS( "base_anim" )

ENT.PrintName   = "Lift"
ENT.Author      = "Lex Robinson"
ENT.Information = "Will this work? I doubt it"
ENT.Category    = "Lift"

ENT.Editable    = false
ENT.Spawnable   = true
ENT.AdminOnly   = false
ENT.RenderGroup = RENDERGROUP_TRANSALPHA

function ENT:SpawnFunction( ply, tr, ClassName )

	if ( not tr.Hit ) then return end

	local SpawnPos = tr.HitPos + tr.HitNormal * 10;

	local ent = ents.Create( ClassName )
	ent:SetPos( SpawnPos )
	ent:Spawn()
	ent:Activate()

	return ent
end

function ENT:Initialize()

	if ( SERVER ) then

		self:SetModel( "models/hunter/plates/plate1x1.mdl" )
		self:PhysicsInit( SOLID_VPHYSICS )
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)

		-- Wake the physics object up. It's time to have fun!
		local phys = self:GetPhysicsObject()
		phys:Wake()

		-- Set collision bounds exactly
		-- self:SetCollisionBounds( Vector( -size, -size, -size ), Vector( size, size, size ) )

	else

		self.ents = {
			-- self
		};

		-- woo debug
		g_Liftus = self;

	end

end

if (SERVER) then return; end

function ENT:AddEnt(ent)
	table.insert(self.ents, ent);
end

concommand.Add("liftify", function(ply)
	local ent = ply:GetEyeTrace().Entity;
	if (IsValid(ent) and IsValid(g_Liftus)) then
		g_Liftus:AddEnt(ent);
	end
end)

-- TY Jinto! http://facepunch.com/showthread.php?t=1205832&p=37280318&viewfull=1#post37280318

function ENT:DrawMask( size )

	local pos = self:GetPos();
	local up = self:GetUp();
	local forward = self:GetForward();
	local right = self:GetRight();

	local segments = 4;


	render.SetColorMaterial();

	mesh.Begin( MATERIAL_POLYGON, segments );

	local function point(x, y)
		mesh.Position( pos + (forward * y + right * x) * size + up * 0.5 );
		mesh.AdvanceVertex()
	end

	point(-1, -1)
	point( 1, -1)
	point( 1,  1)
	point(-1,  1)


	-- for i = 0, segments - 1 do

	-- 	local rot = math.pi * 2 * ( i / segments );
	-- 	local sin = math.sin( rot ) * size;
	-- 	local cos = math.cos( rot ) * size;

	-- 	mesh.Position( pos + ( forward * sin ) + ( right * cos ) );
	-- 	mesh.AdvanceVertex();

	-- end

	mesh.End();

end


function ENT:DrawInterior()

	for i, ent in ipairs(self.ents) do
		if (IsValid(ent)) then
			ent:DrawModel();
		else
			table.remove(self.ents, i);
		end
	end
end


function ENT:DrawOverlay()

	-- self:DrawModel()d
end


function ENT:Draw()

	render.SetBlend(0.9);

	self:DrawModel();

	render.SetBlend(1);

	render.ClearStencil();
	render.SetStencilEnable( true );
	render.SetStencilCompareFunction( STENCIL_ALWAYS );
	render.SetStencilPassOperation( STENCIL_REPLACE );
	render.SetStencilFailOperation( STENCIL_KEEP );
	render.SetStencilZFailOperation( STENCIL_KEEP );
	render.SetStencilWriteMask( 1 );
	render.SetStencilTestMask( 1 );
	render.SetStencilReferenceValue( 1 );

	self:DrawMask( 40 );

	render.SetStencilCompareFunction( STENCIL_EQUAL );

	-- clear the inside of our mask so we have a nice clean slate to draw in.
	render.ClearBuffersObeyStencil( 0, 0, 0, 0, true );

	self:DrawInterior();

	render.SetStencilEnable( false );

	self:DrawOverlay();

end
