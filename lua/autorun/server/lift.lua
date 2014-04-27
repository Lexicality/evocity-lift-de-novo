if (game.GetMap():lower() ~= "rp_evocity_v17x") then return; end
AddCSLuaFile("autorun/lift_sh.lua");
do
	local path = "addons/lift/materials/lift/*"
	local mat = "materials/lift/";
	for _, filename in pairs(file.Find(path, "MOD")) do
		resource.AddSingleFile(mat..filename);
	end
end
local speed = 10;   -- It takes 30 seconds to get from floor to floor
local waittime = 3; -- Wait for 3s at each requested foor.
local update = 0.1; -- The lift's position will be updated every 0.1 seconds
local basement = Vector(-7271.4023, -8695.0830, -175.9688);
local exits = {
	{ -- Lift one
		basement;
		Vector(-7507.2744, -9595.8877,   82.0313);
		Vector(-7507.4766, -9595.1787,  474.0313);
		Vector(-7507.4766, -9595.1787, 1754.0313);
		Vector(-7507.4766, -9595.1787, 3801.4827);
	};
	{ -- Lift two
		basement;
		Vector(-7507.2744, -9397,   82.0313);
		Vector(-7507.4766, -9397,  474.0313);
		Vector(-7507.4766, -9397, 1754.0313);
		Vector(-7507.4766, -9397, 3801.4827);
	};
	{ -- Lift three
		basement;
		Vector(-7000, -9397,   82.0313);
		Vector(-7000, -9397,  474.0313);
		Vector(-7000, -9397, 1754.0313);
		Vector(-7000, -9397, 3801.4827);
	};
	{ -- Lift four
		basement;
		Vector(-7000, -9595.8877,   82.0313);
		Vector(-7000, -9595.1787,  474.0313);
		Vector(-7000, -9595.1787, 1754.0313);
		Vector(-7000, -9595.1787, 3801.4827);
	};
};
local insidepos = Vector(-7353.4619, -9584.0156, 74.0313);
local buttons = {
	inner = null;
	-- Lift 1
	{
		Vector(-7432.8345, -9589.2061,  125.1422); -- Floor 1
		Vector(-7432.6445, -9589.2598,  517.1422); -- Floor 2
		Vector(-7432.4878, -9589.0938, 1797.2568); -- Floor 3
		Vector(-7432.4878, -9589.2334, 3844.2747); -- Floor 4
		angle = Angle(-90, 0, 0);
	};
	-- Lift 2
	{
		Vector(-7432.8345, -9397,  125.1422); -- Floor 1
		Vector(-7432.6445, -9397,  517.1422); -- Floor 2
		Vector(-7432.4878, -9397, 1797.2568); -- Floor 3
		Vector(-7432.4878, -9397, 3844.2747); -- Floor 4
		angle = Angle(-90, 0, 0);
	};
	-- Lift 3
	{
		Vector(-7059, -9397,  125.1422); -- Floor 1
		Vector(-7059, -9397,  517.1422); -- Floor 2
		Vector(-7059, -9397, 1797.2568); -- Floor 3
		Vector(-7059, -9397, 3844.2747); -- Floor 4
		angle = Angle(90, 0, 0);
	};
	-- Lift 4
	{
		Vector(-7059, -9589.2061,  125.1422); -- Floor 1
		Vector(-7059, -9589.2598,  517.1422); -- Floor 2
		Vector(-7059, -9589.0938, 1797.2568); -- Floor 3
		Vector(-7059, -9589.2334, 3844.2747); -- Floor 4
		angle = Angle(90, 0, 0);
	};
};
local cpanel;
local requests = {
	-- Lift 1
	{
		false,
		false,
		false,
		false,
		false
	};
	-- Lift 2
	{
		false,
		false,
		false,
		false,
		false
	};
	-- Lift 3
	{
		false,
		false,
		false,
		false,
		false
	};
	-- Lift 4
	{
		false,
		false,
		false,
		false,
		false
	};
};
local liftpos = {
	2,
	2,
	2,
	2
};
local dirs = {
	0,
	0,
	0,
	0
};
local liftadds = {
	0,
	0,
	0,
	0
};
local liftreps = {
	0,
	0,
	0,
	0
};
local waiting = {
	false,
	false,
	false,
	false
};
local moving = {
	false,
	false,
	false,
	false
};
local noises = {
	false,
	false,
	false,
	false
}
local function moveNoise(liftnum, mode)
	if (noises[liftnum] == mode) then
		return;
	end
	noises[liftnum] = mode;
	local rcp = RecipientFilter();
	for _, ply in pairs(player.GetAll()) do
		if (ply:GetNWInt("liftnumber") == liftnum) then
			rcp:AddPlayer(ply);
		end
	end
	SendUserMessage("Lift Move", rcp, mode);
end

local function initLift()
	local lift = Entity(757+game.MaxPlayers());
	print(lift, lift:GetClass());
	-- game.CleanupMap() catch ¬_¬'
	if (lift:GetClass() ~= "func_tracktrain") then
		for _, ent in pairs(ents.FindInBox(Vector(-7337, -9590, 50), Vector(-7335, -9588, 62))) do
			if (ent:GetClass() == "func_tracktrain") then
				lift = ent;
				break;
			end
		end
	end
	lift:SetPos(lift:GetPos()+Vector(0,0,15));
	local noremoves = {
		func_door = true;
		func_tracktrain = true;
		player = true;
		lift_control_panel = true;
		lift_inner_door_panel = true;
	}
	local class;
	for _,ent in pairs(ents.FindInBox(Vector(-7248.3320, -9495.4482, 63.3047), Vector(-7424.3315, -9679.2529, 195.5849))) do
		print(ent, ent:GetClass());
		if (not noremoves[ent:GetClass():lower()]) then
			ent:Remove()
		end
	end
	for _, ent in pairs(ents.FindInBox(Vector(-7439.646,-9466.5098,3918.9688), Vector(-7457.5972,-9532.5469,76.8043))) do
		if (ent:GetClass():lower() == "func_button") then
			ent:Remove();
		end
	end
end
local function spawnButtons()
	local ent;
	-- Lift inner button
	ent = ents.Create("lift_inner_door_panel");
	ent:SetPos(Vector(-7422.6787, -9588.8857,  127.1422));
	ent:SetAngles(Angle(90, 0, 0));
	ent:Spawn();
	ent:Activate();
	buttons.inner = ent;
	-- Lift inner cpannel
	ent = ents.Create("lift_control_panel");
	--ent:SetPos(Vector(-7419.1270, -9523.0732,  120.9154));
	ent:SetPos(Vector(-7419.1270, -9523.0732,  130.9154));
	ent:SetAngles(Angle(0, 90, 90));
	ent:Spawn();
	ent:Activate();
	-- Start all the lifts off in the lobby.
	for i = 0, 3 do
		ent:SetDTFloat(i, 2);
	end
	cpanel = ent;
	-- Basement button
	ent = ents.Create("lift_outer_door_panel");
	ent:SetPos(Vector(-7269.8267, -8649.8682, -115.3198));
	ent:SetAngles(Angle(0, 0, 90));
	ent:Spawn();
	ent:Activate();
	ent:Setup(0, 1);
	buttons.basement = ent;
	for lift, liftbuttons in ipairs(buttons) do
		buttons.inner:SetDTBool(lift - 1, true);
		for id, pos in ipairs(liftbuttons) do
			ent = ents.Create("lift_outer_door_panel");
			ent:SetPos(pos);
			ent:SetAngles(liftbuttons.angle);
			ent:Spawn();
			ent:Activate();
			ent:Setup(lift, id + 1);
			liftbuttons[id] = ent;
			if (id == 1) then -- Lobby.
				ent:SetDTBool(0, true);
			end
		end
		table.insert(liftbuttons, 1, buttons.basement); -- All lifts share a common basement.
	end
end
local function setRequest(liftnum, floornum, status)
	print("LIFT: Setting the request status of floor "..floornum.." on lift "..liftnum.." to "..tostring(status)..".");
	if (liftpos[liftnum] == floornum) then
		return;
	end
	requests[liftnum][floornum] = status
	cpanel:SetNWBool(liftnum .. floornum, status);
	if (floornum == 1 and not status) then -- Basement is a special case.
		for i = 1, 4 do
			if (requests[i][1]) then
				status = true;
				break;
			end
		end
	end
	buttons[liftnum][floornum]:SetDTBool(1, status);
end
local function setEnterable(liftnum, floornum, status)
	buttons.inner:SetDTBool(liftnum - 1, status);
	print("LIFT: Setting the enterable status of floor "..floornum.." on lift "..liftnum.." to "..tostring(status)..".");
	if (floornum == 1) then -- Basement is a special case.
		print("-> Basement.");
		if (status) then
			print("--> Status on.");
			buttons.basement.liftnum = liftnum;
		else
			print("--> Status off.");
			buttons.basement.liftnum = 0;
			for i = 1, 4 do
				if (i ~= liftnum and liftpos[i] == 1) then
					print("---> Another lift is at floor 1.");
					status = true;
					buttons.basement.liftnum = i;
					break;
				end
			end
		end
	end
	buttons[liftnum][floornum]:SetDTBool(0, status);
end
local function isMoving(liftnum)
	return moving[liftnum];
end
local function isWaiting(liftnum)
	return waiting[liftnum];
end
local setMoving;
do
	local add = (1 / speed) * update; -- How much needs to be added to the position every 0.1 seconds to take 30 seconds to go from 1 to 2.
	local reps = speed * (1 / update); -- How many 0.1 ticks are in 30 seconds.
	function setMoving(liftnum, direction)
		liftreps[liftnum] = reps;
		dirs[liftnum] = direction;
		liftadds[liftnum] = add * direction;
		moving[liftnum] = true;
		buttons.inner:SetDTBool(liftnum - 1, false); -- Disable getting out
		setEnterable(liftnum, liftpos[liftnum], false); -- Disable getting in.
		moveNoise(liftnum, true);
	end
end
local calculateNextStop;
do
	local function calcUp(liftnum)
		print("LIFT: Calculating upwards for lift ",liftnum);
		for i = liftpos[liftnum] + 1, 5 do
			print("->Checking floor #",i,", it is: ",requests[liftnum][i]);
			if (requests[liftnum][i]) then
				print("-->Found a request. Moving.");
				setMoving(liftnum, 1);
				return true;
			end
		end
		print("LIFT: Could not find a request above the current position.");
	end
	local function calcDown(liftnum)
		print("LIFT: Calculating downwards for lift ",liftnum);
		for i = liftpos[liftnum] - 1, 1, -1 do
			print("->Checking floor #",i,", it is: ",", it is: ",requests[liftnum][i]);
			if (requests[liftnum][i]) then
				print("-->Found a request. Moving.");
				setMoving(liftnum, -1);
				return true;
			end
		end
		print("LIFT: Could not find a request below the current position.");

	end
	function calculateNextStop(liftnum)
		print("LIFT: Calculating next stop for lift ",liftnum);
		waiting[liftnum] = false;
		if (dirs[liftnum] < 0) then
			return calcDown(liftnum) or calcUp(liftnum);
		else
			return calcUp(liftnum) or calcDown(liftnum);
		end
	end
end

local function arrivedAtFloor(liftnum)
	local pos = math.Round(liftpos[liftnum]);
	liftpos[liftnum] = pos;
	print("LIFT: Lift #"..liftnum.." just arrived at floor "..pos..".");
	moving[liftnum] = false;
	if (requests[liftnum][pos]) then
		print("->This floor has been requested. Waiting for "..waittime.." seconds.");
		waiting[liftnum] = true;
		timer.Simple(waittime, calculateNextStop, liftnum);
		setRequest(liftnum, pos, false);
		setEnterable(liftnum, pos, true);
		moveNoise(liftnum, false);
		local rcp = RecipientFilter();
		local button = buttons[liftnum][pos];
		rcp:AddPVS(button:GetPos());
		SendUserMessage("Lift Bell", rcp);
	else
		print("->This floor has not been requested. Moving on.");
		calculateNextStop(liftnum);
	end
end

local function moveThink()
	for i = 1, 4 do
		if (isMoving(i)) then
			liftpos[i] = liftpos[i] + liftadds[i];
			cpanel:SetDTFloat(i - 1, liftpos[i]);
			print("LIFT: Lift",i,"is at",liftpos[i]);
			liftreps[i] = liftreps[i] - 1;
			if (liftreps[i] == 0) then
				arrivedAtFloor(i);
			end
		end
	end
end
timer.Create("Lift Think", update, 0, moveThink);

-- public functions
lift = {}
function lift.RequestStop(liftnum, floornum)
	if (floornum == 1 and liftnum == 0) then -- Special case
		-- TODO: Find out which lift is closest to the basement and select it.
		liftnum = 1;
	elseif (liftnum > 4 or liftnum < 1) then
		error("Liftnum out of bounds!", 2);
	elseif (floornum < 1 or floornum > 5) then
		error("Floornum out of bounds!", 2);
	end
	print("LIFT: Got request for lift",liftnum,"to go to floor",floornum);
	setRequest(liftnum, floornum, true);
	if (not (isMoving(liftnum) or isWaiting(liftnum))) then
		calculateNextStop(liftnum);
	end
end
function lift.GetIn(ply, liftnum)
	print("LIFT:",ply,"just tried to get into lift",liftnum);
	if (liftnum > 4 or liftnum < 1) then
		error("Liftnum out of bounds!", 2);
	elseif (isMoving(liftnum)) then
		return false;
	end
	ply:SetPos(insidepos);
	ply:SetNWInt("liftnumber",liftnum);
end
function lift.GetOut(ply)
	local liftnum = ply:GetNWInt("liftnumber");
	print("LIFT:",ply,"just tried to get out of lift",liftnum);
	if (liftnum > 4 or liftnum < 1) then
		error("Liftnum out of bounds!", 2);
	elseif (isMoving(liftnum)) then
		return false;
	end
	ply:SetPos(exits[liftnum][liftpos[liftnum]]);
	ply:SetNWInt("liftnumber", 0);
end


hook.Add("InitPostEntity", "Lift correctional facility", function()
	timer.Simple(1, initLift);
	timer.Simple(1.5, spawnButtons);
	-- DEBUG DEBUG DEBUG
	for _, ent in pairs(ents.FindByClass("trigger_teleport")) do
		ent:Remove();
	end
end);
