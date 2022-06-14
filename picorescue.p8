pico-8 cartridge // http://www.pico-8.com
version 34
__lua__
function _init()
	counter = 0
	world_x = 0
	starting_x = 0
	drop_off_x = 32
	player_strt_y = 32
	player_strt_x = drop_off_x
	max_world_x = 0

	player = {
		["x"] = player_strt_x,
		["px"] = player_strt_x,
		["y"] = player_strt_y,
		["py"] = player_strt_y,
		["mv_speed"] = 1,
		["on_mission"] = false,
		["speed_x"] = 0,
		["speed_y"] = 0,
		["mvn_dir"] = false,
		["facing"] = "left",
		["vhc_front"] = 04,
		["civ_range"] = false,
		["civ_pkup"] = false,
		["occup"] = 0,
		["max_occup"] = 2,
		["water_cap"] = 5,
		["max_water_cap"] = 5,
		["rotor_health"] = 10,
		["max_rotor_health"] = 10,
		["rotor_fuel"] = 10,
		["max_rotor_fuel"] = 10,
		["fuel_consumption"] = 0.03,
		["top_speed_x"] = 4,
		["top_speed_y"] = 2,
		["ladder"] = 0,
		["ladder_empty"] = true,
		["dpl_ldd_pkup"] = false,
		["dpl_ldd_doof"] = false,
		["rescuing"] = false,
		["droping_off"] = false,
		["rx1"] = 0,
		["ry1"] = 0,
		["rx2"] = 0,
		["ry2"] = 0,
		["budget"] = 15,
	}

	--[[
	1 -- start
	2 -- rotor mission
	3 -- human mission
	4 -- airplane mission
	5 -- game over
	6 -- main screen
	7 -- stats screen
	8 -- my heli screen
	9 -- mission ended
	10 -- shop
	]]--

	curr_screen = 1
	fire_pcs_created = false
	civ_pcs_created = false

	btn_pressed = false
	mvn_y = false
	mvn_x = false
	left_btn = false
	right_btn = false
	down_btn = false
	up_btn = false

	water_drops = {}
	fire_pcs = {}
	smoke_pcs = {}
	ground_pcs = {}
	tree_pcs = {}
	civ_pcs = {}

	stats = {
		["fire_put_out"] = 0,
		["civs_saved"] = 0,
		["missions_finished"] = 0,
	}

	difficulty = "";

	civ_spawn = {
		["easy"] = {230,320,430},
		["normal"] = {250,350,470,590},
		["hard"] = {290,390,540,650,740}
	}
	fire_spawn = {
		["easy"] = {200,220,330,360,410,420,440},
		["normal"] = {170,200,220,330,370,420,510,520,530,560},
		["hard"] = {200,220,330,370,410,460,510,530,560,610,630,660,700,730}
	}

	mission_type = rnd({"sea","fire"})
	mission_ground = 20
	mission_p_front = 4
	mission_p_back = 3
	mission_civ_saved = 0
	mission_fire_put_out = 0

	block_btns = false
	counter = 0
	mm_option = 1
	shop_option = 1
	prop_sound = false
	main_music = false
end

function _draw()
	cls()

	rect(0,0,127,127, 7)

	if curr_screen == 1 then
		rectfill(0,0,127,127,8)

		for i=0, 15 do
			spr(025,0+i*8,0)
			spr(025,0+i*8,8)
			spr(024,0+i*8,16,1,1,false,true)
		end

		print("pico rescue",42,50,0)
		print("pico rescue",41,49,7)

		print("press any key",37,80,7)

		for i=0, 15 do
			spr(024,0+i*8,104)
			spr(025,0+i*8,112)
			spr(025,0+i*8,120)
		end
	end

	if curr_screen == 6 then -- main
		mm_opt1_c = (mm_option == 1) and 7 or 9
		mm_opt2_c = (mm_option == 2) and 7 or 9
		mm_opt3_c = (mm_option == 3) and 7 or 9
		mm_opt4_c = (mm_option == 4) and 7 or 9
		mm_opt5_c = (mm_option == 5) and 7 or 9

		print("play mission",40,39,5)
		print("play mission",40,38,mm_opt1_c)
		print("my heli",50,49,5)
		print("my heli",50,48,mm_opt2_c)
		print("shop",56,59,5)
		print("shop",56,58,mm_opt3_c)
		print("carrer stats",39,69,5)
		print("carrer stats",39,68,mm_opt4_c)
		print("budget",52,79,5)
		print("budget",52,78,mm_opt5_c)
	end

	if curr_screen == 7 then -- stats
		print("carrer stats",6,29,5)
		print("carrer stats",5,28,7)

		print("civilians rescued",5,48,7)
		print("fires put out",5,58,7)
		print("missions",5,68,7)

		print(stats.civs_saved,100,48,7)
		print(stats.fire_put_out,100,58,7)
		print(stats.missions_finished,100,68,7)
	end

	if curr_screen == 8 then -- my heli
		print("my heli",6,29,5)
		print("my heli",5,28,7)

		print("health",5,48,7)
		print("fuel",5,56,7)
		print("max occupancy",5,64,7)
		print("water capacity",5,72,7)

		print(player.rotor_health,100,48,7)
		print(player.rotor_fuel,100,56,7)
		print(player.max_occup,100,64,7)
		print(player.water_cap,100,72,7)

		-- print("my upgrades",5,79,7)
	end
	
	if curr_screen == 9 then -- mission ended
		print("mission ended!",32,21,11)

		print("civilians saved",5,60,7)
		print(mission_civ_saved,95,60,7)
		print("fires put out",5,70,7)
		print(mission_fire_put_out,95,70,7)
	end

	if curr_screen == 5 then -- game over
		rectfill(0,0,127,127,0)

		for i=0, 15 do
			spr(041,0+i*8,0)
			spr(041,0+i*8,8)
			spr(040,0+i*8,16,1,1,false,true)
		end		

		print("game over",42,50,7)

		if (not block_btns) print("press any key",37,80,7)

		for i=0, 15 do
			spr(040,0+i*8,104)
			spr(041,0+i*8,112)
			spr(041,0+i*8,120)
		end
	end

	if curr_screen == 2 then -- rotor mission
		rectfill(0,0,128,119,12)
		spr(006,drop_off_x,112)

		flip_spr = (player.facing == "right") and true or false
		tail_pos = (player.facing == "right") and player.x+8 or player.x-8

		if (counter % 3 == 0) spr(052, player.x - 8, player.y - 8)
		if (counter % 3 == 0) spr(052, player.x + 8, player.y - 8, 1, 1, true)
		spr(053, player.x, player.y - 8)
		spr(player.vhc_front,player.x,player.y,1,1,flip_spr)
		if (player.facing != false) spr(003,tail_pos,player.y,1,1,flip_spr)

		for i = 1, player.ladder do
			spr(001,player.x,player.y+i*8)
		end

		health = player.rotor_health/player.max_rotor_health

		rotor_health_bar_length = (health == 1) and 22 or
		(health > 0.87 and health < 1) and 19 or
		(health > 0.75 and health < 0.87) and 16 or
		(health > 0.62 and health < 0.75) and 13 or
		(health > 0.5 and health < 0.62) and 10 or
		(health > 0.37 and health < 0.5) and 7 or
		(health > 0.25 and health < 0.37) and 4 or
		(health > 0.12 and health < 0.25) and 1
		or 0

		spr(16,1,1)
		rectfill(11,2,11 + rotor_health_bar_length,6, 14)
		spr(028, 10, 0, 4, 1)


		fuel_usage = player.rotor_fuel/player.max_rotor_fuel

		rotor_fuel_bar_length = (fuel_usage == 1) and 22 or
		(fuel_usage > 0.87 and fuel_usage < 1) and 19 or
		(fuel_usage > 0.75 and fuel_usage < 0.87) and 16 or
		(fuel_usage > 0.62 and fuel_usage < 0.75) and 13 or
		(fuel_usage > 0.5 and fuel_usage < 0.62) and 10 or
		(fuel_usage > 0.37 and fuel_usage < 0.5) and 7 or
		(fuel_usage > 0.25 and fuel_usage < 0.37) and 4 or
		(fuel_usage > 0.12 and fuel_usage < 0.25) and 1
		or 0

		spr(0,1,10)
		pal(8,3)
		pal(14,11)
		rectfill(11,11,11 + rotor_fuel_bar_length,15, 14)
		spr(028, 10, 9, 4, 1)
		pal()

		spr(048,1,19)
		pal(7,0)
		spr(045,9,19)
		pal()
		print(player.water_cap, 14, 21, 0)

		spr(032,1,27)
		pal(7,0)
		occup_spr = (player.occup == 0) and 060 or
		(player.occup == 1) and 061 or 062
		spr(occup_spr,7,25)
		pal()
		print(player.max_occup,15,28,0)


		--[[ spr(006,0,32)
		arrow_flip = (drop_off_x > player.x) and true or false
		spr(037, 8 , 33, 1, 1, arrow_flip, false)
		print(abs(flr(drop_off_x - player.x)), 16, 35) ]]--

		i=0
		for civ in all(civ_pcs) do
			if civ.closer_to_player and not civ.on_board then
				spr(032,100,0+i*8)
				arrow_flip = (civ.x > player.x) and true or false
				spr(037,107,0+i*8,1,1,arrow_flip,false)
				print(civ.distance, 116, 1 + i * 8, 5, 0)
				i+=1
			end
		end

		print(count(civ_spawn[difficulty]) - mission_civ_saved .. " left to save!", drop_off_x - 8, 100, 0)

		foreach(civ_pcs,draw_civ)
		foreach(fire_pcs,draw_fire)
		foreach(smoke_pcs,draw_smoke)
		foreach(fire_pcs,on_smoke)
		foreach(water_drops,draw_water)
		foreach(ground_pcs,draw_ground)
	end

	if curr_screen == 10 then -- shop
		print("shop",6,29,5)
		print("shop",5,28,7)

		print("health",15,48,7)
		print("fuel",15,58,7)

		selector_pos = (shop_option == 1) and 47 or 57
		spr(018, 5, selector_pos, 1, 1, true)

		print(flr(player.rotor_health) .. "/" .. player.max_rotor_health, 100, 48, 7)
		print(flr(player.rotor_fuel) .. "/" .. player.max_rotor_fuel, 100, 58, 7)
	end

	if curr_screen == 6 or curr_screen == 7 or curr_screen == 8 then
		print("z/🅾️ [select]", 2, 120, 7)
		print("x/❎ [back]", 82, 120, 7)
	end
end

function _update()
	counter += 1

	if curr_screen != 2 then
		if main_music == false then
			main_music = true
			music(1)
		else
			if (stat(56) >= 430) main_music = false
		end
	else
		main_music = false
	end

	if curr_screen == 1 then
		if btnp(1) or btnp(2) or btnp(0) or btnp(3) or btnp(4) or btnp(5) then
			block_btns = true
			curr_screen = 6
		end
	end

	if curr_screen == 5 then -- game over
		if counter % 150 == 0 then
			block_btns = false
		end

		if not block_btns then
			if
				btnp(1) or btnp(2) or
				btnp(0) or btnp(3) or
				btnp(4) or btnp(5)
			then
				_init()
			end
		end
	end

	if curr_screen == 6 then -- main
		if (btnp(2)) mm_option -= 1 sfx(2)
		if (btnp(3)) mm_option += 1 sfx(2)

		if (mm_option > 5) mm_option = 1
		if (mm_option < 1) mm_option = 5

		if btnp(4) and not block_btns then
			sfx(1)
			if (mm_option == 1) curr_screen = 2 mission_civ_saved = 0 mission_fire_put_out = 0 difficulty = rnd({"easy","normal","hard"})
			if (mm_option == 4) curr_screen = 7
			if (mm_option == 2) curr_screen = 8
			if (mm_option == 3) curr_screen = 10
		end

		block_btns = false
	end
	
	if curr_screen == 7 then -- stats
		if btnp(5) then
			sfx(0)
			block_btns = true
			curr_screen = 6
			mm_option = 4
		end
	end
	
	if curr_screen == 8 then -- my heli
		if btnp(5) then
			sfx(0)
			block_btns = true
			curr_screen = 6
			mm_option = 2
		end
	end
	
	if curr_screen == 10 then -- shop
		if (btnp(2)) shop_option -= 1 sfx(2)
		if (btnp(3)) shop_option += 1 sfx(2)

		if (shop_option > 2) shop_option = 1
		if (shop_option < 1) shop_option = 2

		if btnp(4) then
			if shop_option == 1 then
				player.rotor_health += 1
				player.budget -= 1
				if (player.rotor_health > player.max_rotor_health) player.rotor_health = player.max_rotor_health
			end
			if shop_option == 2 then
				player.rotor_fuel = flr(player.rotor_fuel)
				player.rotor_fuel += 1
				player.budget -= 1
				if (player.rotor_fuel > player.max_rotor_fuel) player.rotor_fuel = player.max_rotor_fuel
			end
		end

		if btnp(5) then
			sfx(0)
			block_btns = true
			curr_screen = 6
			mm_option = 3
		end
	end
	
	if curr_screen == 9 then -- mission ended
		if btnp(5) or btnp(4) then
			sfx(0)
			block_btns = true
			curr_screen = 6
			mm_option = 1
		end
	end

	if curr_screen == 2 then -- rotor mission

		if prop_sound == false then
			prop_sound = true
			music(00)
		end

		if (counter % 15 == 0) player.rotor_fuel -= player.fuel_consumption

		btn_pressed = (btn(1)) or (btn(2)) or (btn(0)) or (btn(3))
		mvn_y = btn(2) or btn(3)
		mvn_x = btn(0) or btn(1)
		right_btn = btn(0)
		left_btn = btn(1)
		up_btn = btn(2)
		down_btn = btn(3)

		create_ground()
		-- create_trees()
		if (not fire_pcs_created) create_fire()
		if (not civ_pcs_created) create_civ()
		if (not player.rescuing) move_rotor()

		upd_rotor_mvmt()
		upd_pkup_area()
		upd_ladder()
		move_dropoff()
		droping_off()

		foreach(fire_pcs,update_fire)
		foreach(smoke_pcs,move_smoke)
		foreach(fire_pcs,move_fire)
		foreach(ground_pcs,move_ground)
		foreach(water_drops,move_water)
		foreach(civ_pcs,move_civ)
		foreach(civ_pcs,civ_on_range)
		foreach(civ_pcs,move_civ_on_range)
		foreach(civ_pcs,civ_climb_ladder)

		if
			player.rotor_fuel <= 0 or
			player.rotor_health <= 0
		then
			curr_screen = 5
			music(-1)
			prop_sound = false
			block_btns = true
		end

		if count(civ_pcs) == 0 then
			stats.missions_finished += 1
			stats.fire_put_out += mission_fire_put_out
			stats.civs_saved += mission_civ_saved
			civ_pcs_created = false
			fire_pcs_created = false
			fire_pcs = {}
			smoke_pcs = {}
			civ_pcs = {}
			player.water_cap = player.max_water_cap

			music(-1)
			curr_screen = 9
			prop_sound = false
			block_btns = true
		end
	end
end
-->8
-- movement logic

function move_rotor()
	if right_btn then
		if player.px > world_x then
			if player.speed_x > 0 then
				player.speed_x -= 0.035
				player.facing = false
				player.vhc_front = 05
				world_x -= player.speed_x
			end
		else
			player.vhc_front = 04
			player.facing = "right"
			if (player.speed_x <= player.top_speed_x) player.speed_x += 0.025
			player.px = world_x
			world_x += player.speed_x
		end
	end

	if left_btn then
		if player.px < world_x then
			if player.speed_x > 0 then
				player.speed_x -= 0.035
				player.facing = false
				player.vhc_front = 05
				world_x += player.speed_x
			end
		else
			player.vhc_front = 04
			player.facing = "left"
			if (player.speed_x <= player.top_speed_x) player.speed_x += 0.025
			player.px = world_x
			world_x -= player.speed_x
		end
	end

	if up_btn then
		if player.py < player.y then
			if player.speed_y > 0 then
				player.speed_y -= 0.035
				player.y += player.speed_y
			end
		else
			player.mvn_dir = "up"
			if (player.speed_y <= player.top_speed_y) player.speed_y += 0.025
			player.py = player.y
			player.y -= player.speed_y
		end
	end

	if down_btn	and player.y < 120 then
		if player.py > player.y then
			if player.speed_y > 0 then
				player.speed_y -= 0.035
				player.y -= player.speed_y
			end
		else	
			player.mvn_dir = "down"
			if (player.speed_y <= player.top_speed_y) player.speed_y += 0.025
			player.py = player.y
			player.y += player.speed_y
		end
	end

	if btnp(5) and player.water_cap > 0 then
		drop_water()
	end
end

function upd_rotor_mvmt()
	if player.px < world_x and mvn_x == false then
		player.px = world_x
		player.speed_x -= 0.025
		world_x += player.speed_x
	end

	if player.px > world_x and mvn_x == false then
		player.px = world_x
		player.speed_x -= 0.025
		world_x -= player.speed_x
	end

	if player.py < player.y and mvn_y == false then
		player.py = player.y
		player.speed_y -= 0.025
		player.y += player.speed_y
	end

	if player.py > player.y and mvn_y == false then
		player.py = player.y
		player.speed_y -= 0.025
		player.y -= player.speed_y
	end

	if (player.px > world_x) player.mvn_dir = "right"
	if (player.px < world_x) player.mvn_dir = "left"
	if (player.px == world_x) player.mvn_dir = false

	if player.speed_x < 0 then
		player.speed_x = 0
		player.px = world_x
	end

	if player.speed_y < 0 then
		player.speed_y = 0
		player.py = player.y
	end

	if player.y < 0 then
		player.y = 0
		player.speed_y = 0
	end

	if player.y > 88 then
		player.y = 88
		player.speed_y = 0
	end

	if world_x > 84 then
		world_x = 84 
		player.speed_x = 0
	end

	if world_x < max_world_x then
		world_x = max_world_x
		player.speed_x = 0
	end
end

function upd_pkup_area()
	player.px1 = player.x-8
	player.py1 = 112
	player.px2 = player.x+16
	player.py2 = 120
end
-->8
-- civilian logic

function create_civ()
	for k,v in pairs(civ_spawn) do
		if k == difficulty then
			for value in all(v) do
				local civ = {}
				civ.x = value
				civ.y = 112
				civ.spr = 33
				civ.health = 10
				civ.on_range = false
				civ.rdy_to_climb_up = false
				civ.rdy_to_climb_down = false
				civ.on_board = false
				civ.distance = 0
				civ.closer_to_player = false
				add(civ_pcs, civ)
				max_world_x = 0 - (value + 40)
			end
		end
	end

	civ_pcs_created = true
end

function draw_civ(civ)
	if civ.on_board == false then
		spr(civ.spr,civ.x,civ.y)
	end
end

function move_civ(civ)
	if civ.on_board == false then
		if (player.mvn_dir == "left") civ.x += player.speed_x
		if (player.mvn_dir == "right") civ.x -= player.speed_x

		civ.distance = abs(flr(civ.x - player.x))
		civ.closer_to_player = false
		if player.x - 32 >= civ.distance - 48 and
		player.x - 32 <= civ.distance + 48 then
			civ.closer_to_player = true
		end
	end
end

function civ_on_range(civ)
	if civ.on_board == false then
		if
			civ.x >= player.px1-2 and
			civ.x <= player.px2 and
			civ.y >= 112 and
			civ.y <= 120
		then
			civ.on_range = true
		else
			civ.on_range = false
		end
	end
end

function move_civ_on_range(civ)
	if civ.on_board == false then
		if civ.on_range then
			civ.spr = 34
			--if (player.x < civ.x) civ.x -= 0.15
			--if (player.x > civ.x) civ.x += 0.15
			
			if
				civ.x+4 >= player.x and
				civ.x+4 <= player.x+8 and
				player.y >= 88
			then
				civ.rdy_to_climb_up = true
				player.dpl_ldd_pkup = true
			else
				civ.rdy_to_climb_up = false
				player.dpl_ldd_pkup = false
			end
		else
			civ.spr = 033
		end
	end
end

function upd_ladder()
	if counter%30 == 0 then
		if player.dpl_ldd_pkup  or  player.dpl_ldd_doof then
			if (player.ladder<3) player.ladder += 1
		end
		if not player.dpl_ldd_pkup and not player.dpl_ldd_doof and counter%30 == 0 then
			if (player.ladder>0) player.ladder -= 1
		end
	end
end

function civ_climb_ladder(civ)
	if civ.on_board == false then
		if
			player.ladder == 3 and
			civ.rdy_to_climb_up and
			player.occup < player.max_occup
		then
			if (civ.y > player.y) civ.y -= 0.25
			player.rescuing = true

			if civ.y == player.y then
				civ.on_board = true
				civ.rdy_to_climb_up = false
				player.dpl_ldd_pkup = false
				player.rescuing = false
				player.occup += 1
			end
		end
	end
end

function droping_off()
	if
		player.x >= drop_off_x and
		player.x < drop_off_x+8 and
		player.y >= 88
	then
		player.dpl_ldd_doof = true
	else
		player.dpl_ldd_doof = false
	end

	for civ in all(civ_pcs) do
		if civ.on_board  then
			if
				player.ladder == 3 and
				civ.on_board and
				player.dpl_ldd_doof and
				player.ladder_empty == true
			then
				civ.rdy_to_climb_down = true
				civ.on_board = false
				player.rescuing = true
				player.ladder_empty = false
			end
		end
		if
			civ.rdy_to_climb_down and
			not civ.on_board 			
		then
			if (civ.y < 112) civ.y += 0.25

			if civ.y >= 112 then
				del(civ_pcs,civ)
				player.rescuing = false
				player.occup -= 1
				player.ladder_empty = true
				mission_civ_saved += 1
			end
		end
	end
end


-->8
-- scenery logic

function create_trees()
	if player.speed_x > 1 then
		if counter%30==0 and flr(rnd(2)) == 1 then
			if (player.facing == "right") x = -8
			if (player.facing == "left") x = 128
			
			local tree = {}
			tree.x = x
			tree.y = 112
			add(tree_pcs, tree)
		end
	end
end

function create_ground()
	for i = count(ground_pcs), 16 do
		local ground = {}
		ground.x = starting_x*1
		ground.y = 120
		add(ground_pcs, ground)
		starting_x+=8
	end
end

function draw_ground(ground)
	spr(017,ground.x,ground.y)
end

function move_ground(ground)
	if (player.mvn_dir == "left") ground.x += player.speed_x
	if (player.mvn_dir == "right") ground.x -= player.speed_x

	if (ground.x < -8) ground.x += 136
	if (ground.x > 128) ground.x -= 136
end

function move_dropoff()
	if (player.mvn_dir == "left") drop_off_x += player.speed_x
	if (player.mvn_dir == "right") drop_off_x -= player.speed_x
end
-->8
-- fire and smoke logic

function create_fire()
	for k,v in pairs(fire_spawn) do
		if k == difficulty then
			for value in all(v) do
				local fire = {}
				fire.x = value
				fire.y = 112
				fire.smk_mh = rnd({1,2,3})
				fire.smk_h = 0
				fire.smk_cd_time = rnd({45, 60})
				fire.smk_cd = false
				fire.counter = 0
				fire.spr = 056
				fire.cadence = rnd({15, 30, 45})
				add(fire_pcs, fire)
			end
		end
	end

	fire_pcs_created = true
end

function draw_fire(fire)
	spr(fire.spr,fire.x,fire.y)
end

function update_fire(fire)
	fire.counter += 1
	if (counter % 2 == 0) fire.spr += 1
	if (fire.spr > 058) fire.spr = 56

	if fire.counter % fire.cadence == 0 and fire.smk_h < fire.smk_mh then
		fire.smk_h += 1
		local smoke = {}
		smoke.x = fire.x
		smoke.y = fire.y - fire.smk_h * 8
		smoke.spr = 064
		smoke.damage = 0.075
		add(smoke_pcs, smoke)
	end

	if fire.smk_h == fire.smk_mh and fire.smk_cd == false then
		fire.smk_cd = true
	end

	if fire.smk_cd and fire.counter % fire.smk_cd_time == 0 then
		fire.smk_h = 0
		fire.smk_mh = rnd({1,2,3})
		fire.smk_cd = false
	end
end

function draw_smoke(smoke)
	spr(smoke.spr,smoke.x,smoke.y)
end

function move_smoke(smoke)
	smoke.y -= 0.95
	if (smoke.y < 68) smoke.spr = 065 smoke.damage = 0.050
	if (smoke.y < 56) smoke.spr = 066 smoke.damage = 0.025

	if (player.mvn_dir == "left") smoke.x += player.speed_x
	if (player.mvn_dir == "right") smoke.x -= player.speed_x
	if
		player.x >= smoke.x - 2 and
		player.x <= smoke.x + 6 and
		player.y >= smoke.y and
		player.y <= smoke.y + 8 then
		player.rotor_health -= smoke.damage
	end

	if (smoke.y < 40) del(smoke_pcs, smoke)
end

function on_smoke(fire)
	-- player.rotor_health -= 0.015
end

function move_fire(fire)
	if (player.mvn_dir == "left") fire.x += player.speed_x
	if (player.mvn_dir == "right") fire.x -= player.speed_x
end
-->8
-- water logic

function drop_water()
	local water = {}
	water.x = player.x
	water.y = player.y + 8
	water.speed = 0
	add(water_drops,water)
	player.water_cap -= 1
end

function draw_water(water)
	spr(019,water.x,water.y,1,1,false,true)
end

function move_water(water)
 if (water.speed < 2) water.speed += 0.15
 water.y += water.speed
	if (player.mvn_dir == "left") water.x += player.speed_x
	if (player.mvn_dir == "right") water.x -= player.speed_x

 for fire in all(fire_pcs) do
	 if
	 	water.x >= fire.x-2 and
	 	water.x <= fire.x+10 and
	 	water.y >= fire.y and
	 	water.y <= fire.y+8
		then
			mission_fire_put_out += 1
			del(fire_pcs,fire)
		end
 end

 if (water .y >= 116) del(water_drops,water)
end
__gfx__
b00033b000d00d000000300000b00000000d60000006600000000000000000000004f000ff44f4ff00b00000000d600000d00000000d60000000000000000000
0b03000b00dddd000000b0000b3b00000bbbbb0000bbbb00000000000000000444440000054544500b3b00000bbbbb000d5d00000ddddd000000000000000000
0033333300d00d00000030000b3b0000b331c7b00b7777b0006ee000000000004cc700000c1c11c00b3b0000b331c7b00d5d0000d55d1cd00000000000000000
03b7bbb300dddd00000030000053bbbb3331ccb00bccccb00068ee700000000041cc0667776776770053bbbb3331ccb00015dddd555d11d00000000000000000
037bbbb300d00d000000b00000053333333311cbb311113b006888e076700006655576677666656700053333333311cb000155555555dd1d0000000000000000
03bbbbb300dddd000000300000005555555533300333333000688000066766656767666007676660000055555555333000001111111155500000000000000000
03bbbbb300d00d000000b00000000000006006000060060000600000005655555555555005655650000000000060060000000000005005000000000000000000
0033333000dddd000000d00000000000055555600050050000600000000515515115150000511500000000000555556000000000011111500000000000000000
088008e0bbbbbbbb0000000000000000000000000004200000b3b300777777770000000099aaaaa900b00000000d600000000000000000000000000000000000
8ee8877e3b333b3b0000999000000000000000000004200003b33b30c7ccc7c70000000099aaaaa90b3b0000bbbbbb0000000000000000000000000000000000
8eeeee78333333330099aa900707007000000000000420003b3bb3331cc1c1cc0000000099aaaaa90b3b000b3331c7b008888888888888888888888800000000
8eeeeee83434344309aaa900077c77c00000000000042000b3bb33b3111c1c110002900099aaaaa90053bbb33331ccb080000000000000000000000080000000
8eeeeee8499949940099aa900cccccc000000000000420003b33b333c1c1c1cc0029990099aaaaa900053333333311cb80000000000000000000000080000000
08eeee8099999999000099900cc1ccc000000000000440003b3b33b3111111110299a99099aaaaa9000055555555333080000080000080000080000080000000
008ee80099999999000000000c11c1c0000000000042420033b3b33311111111299aaa9999aaaaa9000000000060060080080080080080080080080080000000
000880009999999900000000011111100000000004222220033333301111111199aaaaa999aaaaa9000000000555556008888888888888888888888800000000
0000000000ffff0000ffff0000ffff0000ffff0000000000006d5076766635500000000066777776000000001111111100000000000000000000000000000000
0000000000fcec00f0fcec0ff0fcec0000fcec0f00009990067cc5bbbbbbb3350000000066777776000000003133313100000000000000000000000000000000
00ffff0000feef0050feef0550feef0000feef050099aa900dccc5bbbbbb33350000000066777776000000003333333300000000000000000000000000000000
00fcec00055dd550055dd550055dd550055dd55009aaa90066ddd6ddbbb333350005600066777776000000003434344300000000000000000000000000000000
00feef005055550500555500005555055055550009aaa90066666653333333350056660066777776000000004444444400000000070700000000000000000000
00ffff00f0f55f0f00f55f0000f55ffffff55f000099aa90d666d1533336d1310566766066777776000000004444444400000000007000000000000000000000
0000000000f00f0000f00f0000f000f00f000f0000009990055dd151155dd1505667776666777776000000004444444400000000070700000000000000000000
0000000000f00f0000f00f0000f0000000000f000000000000011100000111006677777666777776000000004444444400000000000000000000000000000000
000010000000000000000000000000000000000000000000006d50767666355000000000000000000000000000dddd0000000000000000000000000000000000
0001c1000008880000033300000111000000000000000000067cc5ccccccc11500000000000900000000000000d1210000000000000000000000000000000000
001ccc1000077780000777300007771000000000000000000dccc5cccccc11150a0a00a000aa00000a00000000d22d0000000000000000000000000000000000
001ccc10000eee80000bbb30000ccc10000000000000000066ddd6ddccc1111509aaa99000a9a09009aa0000055dd55000000000000000000000000000000000
01c7ccc100eee80000bbb30000ccc100000000000000000066666651111111150aa9aaa00aaaaaa00aa9a0a05055550507770070077000700777007000000000
01c7ccc10088800000333000001110000000000000000000d666d1511116d115099899900989a8900a99aaa0d0d55d0d07070070007000700077007000000000
001c7c100000000000000000000000000000000000000000055dd155555dd15009889890088a9890098999a000d00d0007070700007007000700070000000000
000111000000000000000000000000000000005555555555000111000001110008888880098898800888989000d00d0007770700077707000777070000000000
06006000060060000600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00600060006000600060006000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
06060606060000060000000600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
60666060600000606000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
06060606000000060000000600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
60006000600060006000600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
06060600060606000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00606060606060606000606000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
77707700777077007770777077707070070077707000707077007770777077707770777077707070707070700000000000000000000000000000000000000000
70707070707070707000700070007070000007007000777077707070707070707070700007007070707070700000000000000000000000000000000000000000
77707700700070707700777070707770070007007000777070707070777077707770777007007070707007000000000000000000000000000000000000000000
70707070707070707000700070707070070007007000707070707070700077007700007007007070707070700000000000000000000000000000000000000000
70707700777077007770700077707070070077007770707070707770700007707070777007007770070070700000000000000000000000000000000000000000
__label__
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cc88cc8ecccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c8ee8877ecc88888888888888888888888cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c8eeeee78c8eeeeeeeeeeeeeeeeeeeeccc8ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c8eeeeee8c8eeeeeeeeeeeeeeeeeeeeccc8ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c8eeeeee8c8eeeee8eeeee8eeeee8eeccc8ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cc8eeee8cc8ee8ee8ee8ee8ee8ee8ee8cc8ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
ccc8ee8cccc88888888888888888888888cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccc88cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cbccc33bcccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
ccbc3cccbcc33333333333333333333333cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
ccc333333c3bbbbbbbbbbbcccccccccccc3ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cc3b7bbb3c3bbbbbbbbbbbcccccccccccc3ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cc37bbbb3c3bbbbb3bbbbb3ccccc3ccccc3ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cc3bbbbb3c3bb3bb3bb3bb3cc3cc3cc3cc3ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cc3bbbbb3cc33333333333333333333333cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
ccc33333cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
ccccc1cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccc1c1ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
ccc1ccc1cccccc000ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
ccc1ccc1cccccc0ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cc1c7ccc1c0c0c000ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cc1c7ccc1cc0cccc0ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
ccc1c7c1cc0c0c000ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccc111ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccccccccc000cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccffffc000cc0ccc0cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccfcecc0c0cc0c000cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccfeefc0c0c0cc0cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccffffc000c0cc000cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc6cccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc6ccc6ccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc6cccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc6ccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc6cccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc6ccc6ccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc6ccc6c6ccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc6cc6ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc6ccc6ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc6c6c6c6cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccc6c666c6ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc6c6c6c6cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccc6ccc6ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc6c6c6cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccc55555555cccccccccccccccccccc6c6c6ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccbccccccccd6ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccb3bcccccbbbbbcccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccb3bccccb331c7bccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccc53bbbb3331ccbccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccc53333333311cbcccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccc55555555333cccccccccccccccccccccccccccccccccccccccccccccccccc6cc6ccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccc6cc6cccccccccccccccccccccccccccccccccccccccccccccccccccc6ccc6ccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccc555556cccccccccccccccccccccccccccccccccccccccccccccccccc6c6c6c6cccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc6c666c6ccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc6c6c6c6cccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc6ccc6ccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc6c6c6cccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc6c6c6ccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccacccccccccccccccccccccccccccccacccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc9aaccccccccccccccccccccccccccc9aacccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccaa9acaccccccccccccccccccccccccaa9acaccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccca99aaacccccccccccccccccccccccca99aaaccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc98999acccccccccccccccccccccccc98999accccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc888989cccccccccccccccccccccccc888989ccccccccccccccccccccccccccccccccc
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
3b333b3b3b333b3b3b333b3b3b333b3b3b333b3b3b333b3b3b333b3b3b333b3b3b333b3b3b333b3b3b333b3b3b333b3b3b333b3b3b333b3b3b333b3b3b333b3b
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
34343443343434433434344334343443343434433434344334343443343434433434344334343443343434433434344334343443343434433434344334343443
49994994499949944999499449994994499949944999499449994994499949944999499449994994499949944999499449994994499949944999499449994994
99999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999
99999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999
99999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999

__gff__
0000000000000000000000000000000000000000000000000000000000000000010101010100000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
01010000235502255021550205501f5501d5501c5501b5501a5501955018550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01010000195501a5501b5501c5501d5501e5501f55020550215502255023550005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500
000100003e2203e2203e2203e22000000000000000000000000003e2003e2003e2003e2003e200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
070a00000c1230e1230c1230e1230c1230e1230c1230e1230c1230e1230c1230e1230c1230e1230c1230e1230c1230e1230c1230e1230c1230e1230c1230e1230c1230e1230c1230e1230c1230e1230c1230e123
2d120000090500905009055090550905509055090500905009055090550b0550c0550e0500e0500e0500e0500e0500e0500c0500c0550b0500b0550c0500c0550000000000000000000000000000000000000000
011400000905509055090550905009055090550b0520b0550c050110500905509055090550905009055090550c0520c0550b0500b050070550705507055070500705507055090520905507052070550505205055
1d0500002b0552d0552f0550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__music__
03 03424344
03 04424344
00 05424344

