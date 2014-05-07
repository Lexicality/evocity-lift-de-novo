--[[
	Shared lift shit
--]]
if (game.GetMap():lower() ~= "rp_evocity_v17x") then return; end
local collides = {
	func_door = true;
	func_tracktrain = true;
	-- REALLY DIRTY HACK
	lift_inner_door_panel = true;
	lift_outer_door_panel = true;
	lift_control_panel = true;
};
function util.IsWithinBox(topleft,bottomright,pos)
	if not (pos.z < math.min(topleft.z, bottomright.z) or pos.z > math.max(topleft.z, bottomright.z) or
			pos.x < math.min(topleft.x, bottomright.x) or pos.x > math.max(topleft.x, bottomright.x) or
			pos.y < math.min(topleft.y, bottomright.y) or pos.y > math.max(topleft.y, bottomright.y)) then
		return true
	end
end
local ghqup, ghqdown = Vector(-6870.458, -9682.7305, 3921.0347), Vector(-7571.376, -9296.7158, 67.8573);
do
	local carparkup, carparkdown = Vector(-7413.2056,-8639.085,4.565), Vector(-7132.1904,-8848.5469,-188.023);
	local world = NULL;
	hook.Add("InitPostEntity", "getworld - lift", function()
		if (SERVER) then
			world = game.GetWorld();
		else
			world = Entity(0);
		end
	end);
	local function inbox(e)
		local pos = e:GetPos();
		return util.IsWithinBox(ghqup, ghqdown, pos) or util.IsWithinBox(carparkup, carparkdown, pos);
	end
	local function plybox(e)
		return e:IsPlayer() and inbox(e);
	end
	hook.Add("ShouldCollide", "Lift Nollide Field", function(a, b)
		if (a == world or b == world or a == NULL or b == NULL or a == nil or b == nil) then
			-- DO NOT FUCK WITH WOLRDSPAWN
			return;
		end
		if (IsValid(a) and IsValid(b) and ((inbox(a) and inbox(b)) or (plybox(a) or plybox(b))) and not (collides[a:GetClass()] or collides[b:GetClass()])) then
			return false;
		end
	end);
end
if (SERVER) then
	umsg.PoolString("Lift Bell");
	umsg.PoolString("Lift Move");
	return;
end
local lpl;
local lift = NULL;
local dosounds;
hook.Add("InitPostEntity", "Liftcatcher", function()
	lpl = LocalPlayer();
	lift = Entity(758+game.MaxPlayers());
	print("Got Lift:", lift);
	-- game.CleanupMap() catch ¬_¬'
	if (not IsValid(lift) or lift:GetClass() ~= "func_tracktrain") then
		print("Not lift.")
		lift = NULL;
		--for _, ent in pairs(ents.FindInBox(Vector(-7350, -9600, 40), Vector(-7300, -9500, 80))) do
		for _, ent in pairs(ents.FindInBox(ghqup, ghqdown)) do
			print("Is lift? ", ent);
			if (ent:GetClass() == "func_tracktrain") then
				print("Yup, lift.");
				lift = ent;
				break;
			end
		end
	end
	if (not IsValid(lift)) then
		local m = Msg;
		Msg = ErrorNoHalt;
		PrintTable(ents.FindInBox(ghqup, ghqdown));
		Msg = m;
		error("WHAT THE FUCK WHY IS THE LIFT NOT THERE");
	end
	dosounds();
end);
-- Hides anyone with a differing lift number
hook.Add("PrePlayerDraw", "Lift Player H1d3r", function(ply)
	if (lpl:GetNWInt("liftnumber") ~= ply:GetNWInt("liftnumber")) then
		return true;
	end
end);
local bell = Sound("plats/elevbell1.wav");
usermessage.Hook("Lift Bell", function(um)
	local button = um:ReadEntity();
	if (lpl:GetNWInt("liftnumber") == 0 and IsValid(button)) then
		button:EmitSound(bell);
	end
end);
local start = Sound("plats/elevator_start1.wav");
local drone = Sound("plats/elevator_move_loop1.wav");
local stop2 = Sound("plats/elevator_stop2.wav");
local startl = SoundDuration(start);
local stop2l = SoundDuration(stop2);
local dronep;
function dosounds()
	dronep = CreateSound(lift, drone);
end
local function startend()
	dronep:Play();
end
usermessage.Hook("Lift Move", function(um)
	if (not IsValid(lift)) then
		error("WHAT THE FUCK WHY IS THE LIFT NOT THERE");
	end
	if (um:ReadBool()) then
		lift:EmitSound(start);
		timer.Simple(startl, startend);
	else
		dronep:Stop();
		lift:EmitSound(stop2);
		lift:EmitSound(bell);
	end
end);
