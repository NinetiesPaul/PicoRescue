pico-8 cartridge // http://www.pico-8.com
version 34
__lua__
function _init()
	counter = 0
	world_x = 0
	starting_x = 0
	drop_off_x = 32
	player_strt_y = 32
	player_strt_x = drop_off_x + 16
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
		["water_cap"] = 4,
		["max_water_cap"] = 4,
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
		["finance"] = 1500,
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
	11 -- triage
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
	wounded_civs_pcs = {}
	wounded_civ = 0
	current_civ_detailed_wound = 0
	current_civ_wounds_number = 0

	stats = {
		["fire_put_out"] = 0,
		["civs_saved"] = 0,
		["missions_finished"] = 0,
		["missions_earnings"] = 0,
	}

	difficulty = "";
	difficulties = {
	"easy",
	-- "normal", -- debug
	-- "hard" -- debug
	}

	civ_spawn = {
		["easy"] = {
		120,
		140, -- debug
		-- 230,
		-- 320,
		-- 430
		},
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
	mission_civ_saved = 0
	mission_fire_put_out = 0
	mission_earnings = 0
	mission_has_wounded = false

	block_btns = false
	block_btns_counter = 0

	counter = 0
	mm_option = 1
	shop_option = 1
	prop_sound = false
	main_music = false

	triage_cursor_x = 64
	triage_cursor_y = 64
	tool_selected = "none"

	wounds_created = false
	all_wounds =
	{
		["arms"] =
		{
			{
				["x"] = 32,
				["y"] = 52,
				["cleaned"] = false,
				["bleeding"] = true,
				["dressed"] = false,
				["taped"] = false,
				["under_clothing"] = false,
				["spr"] = 132
			},
			{
				["x"] = 36,
				["y"] = 62,
				["cleaned"] = false,
				["bleeding"] = true,
				["dressed"] = false,
				["taped"] = false,
				["under_clothing"] = true,
				["spr"] = 133
			},
			{
				["x"] = 36,
				["y"] = 84,
				["cleaned"] = false,
				["bleeding"] = true,
				["dressed"] = false,
				["taped"] = false,
				["under_clothing"] = true,
				["spr"] = 134
			}
		}
	}
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
		print("finances",48,79,5)
		print("finances",48,78,mm_opt5_c)
	end

	if curr_screen == 7 then -- stats
		print("carrer stats",40,19,5)
		print("carrer stats",40,18,7)

		print("civilians rescued",10,48,7)
		print("fires put out",10,58,7)
		print("missions finished",10,68,7)
		print("missions earnings",10,78,7)

		print(stats.civs_saved,110,48,7)
		print(stats.fire_put_out,110,58,7)
		print(stats.missions_finished,110,68,7)
		print("$ " .. stats.missions_earnings,102,78,7)
	end

	if curr_screen == 8 then -- my heli
		print("my heli",50,19,5)
		print("my heli",50,18,7)

		print("health",10,48,7)
		print("fuel",10,56,7)
		print("max occupancy",10,64,7)
		print("water capacity",10,72,7)

		print(player.rotor_health,110,48,7)
		print(player.rotor_fuel,110,56,7)
		print(player.max_occup,110,64,7)
		print(player.water_cap,110,72,7)

		-- print("my upgrades",5,79,7)
	end

	if curr_screen == 10 then -- shop
		print("shop",56,19,5)
		print("shop",56,18,7)

		print("cash",44,29,5)
		print("cash",44,28,7)
		print("$" .. player.finance,64,29,3)
		print("$" .. player.finance,64,28,11)

		print("health $300",15,48,7)
		print("fuel $225",15,58,7)

		selector_pos = (shop_option == 1) and 47 or 57
		spr(018, 5, selector_pos, 1, 1, true)

		print(flr(player.rotor_health) .. "/" .. player.max_rotor_health, 100, 48, 7)
		print(flr(player.rotor_fuel) .. "/" .. player.max_rotor_fuel, 100, 58, 7)
	end
	
	if curr_screen == 9 then -- mission ended
		print("mission ended",40,21,11)

		print("civilians saved",10,60,7)
		print("fires put out",10,70,7)
		print("mission earnings",10,80,7)

		print(mission_civ_saved,110,60,7)
		print(mission_fire_put_out,110,70,7)
		print("$ " .. mission_earnings,102,80,7)
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

		for i = 0, 4 do
			spr(060,0 + i * 8, 0)
			spr(060,0 + i * 8, 8)
			palt(0, false) palt(7, true) spr(061,0 + i * 8, 16) palt()
		end

		for i = 0, 2 do
			spr(060,108 + i * 8, 0)
			spr(060,108 + i * 8, 8)
			palt(0, false) palt(7, true) spr(061,108 + i * 8, 16) palt()
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

		spr(016,0,1)
		rectfill(11,2,11 + rotor_health_bar_length,6, 14)
		palt(0, false) palt(2, true) spr(028, 10, 0, 4, 1) palt()

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

		spr(000,0,10)
		rectfill(11,11,11 + rotor_fuel_bar_length,15, 11)
		palt(0, false) palt(2, true) spr(028, 10, 9, 4, 1) palt()

		spr(048,108,1)
		water_drop_spr = (player.water_cap == 0) and 096 or
		(player.water_cap == 1) and 097 or
		(player.water_cap == 2) and 098 or
		(player.water_cap == 3) and 099 or
		(player.water_cap == 4) and 100 or 101
		pal(7,0) spr(water_drop_spr,116,0) pal()
		print(player.max_water_cap,124,3,0)

		spr(032,108,10)
		occup_spr = (player.occup == 0) and 096 or
		(player.occup == 1) and 097 or 098
		pal(7,0) spr(occup_spr,116,9) pal()
		print(player.max_occup,124,12,0)

		--[[ spr(006,0,32)
		arrow_flip = (drop_off_x > player.x) and true or false
		spr(037, 8 , 33, 1, 1, arrow_flip, false)
		print(abs(flr(drop_off_x - player.x)), 16, 35) 

		i=0
		for civ in all(civ_pcs) do
			if civ.closer_to_player and not civ.on_board then
				spr(032,100,0+i*8)
				arrow_flip = (civ.x > player.x) and true or false
				spr(037,107,0+i*8,1,1,arrow_flip,false)
				print(civ.distance, 116, 1 + i * 8, 5, 0)
				i+=1
			end
		end ]]--
		print(mission_has_wounded, 64, 0) -- debug
		print(#wounded_civs_pcs, 64, 8) -- debug

		print(count(civ_spawn[difficulty]) - mission_civ_saved .. " left to save!", drop_off_x - 8, 100, 0)

		foreach(civ_pcs,draw_civ)
		foreach(fire_pcs,draw_fire)
		foreach(smoke_pcs,draw_smoke)
		foreach(fire_pcs,on_smoke)
		foreach(water_drops,draw_water)
		foreach(ground_pcs,draw_ground)
	end

	if curr_screen == 11 then -- triage mode
		cls()

		rect(0,0,127,127, 7)

		sspr(16, 56, 14, 94, 24, 24, 28, 188)

		wearing_clothing = 0

		print("civ " .. wounded_civ, 10, 20, 7)
		print("wounds " .. current_civ_wounds_number, 10, 28, 7)

		-- leave this commented on the code

		for j=1, #wounded_civs_pcs do
			local wounded = wounded_civs_pcs[j]
			print(j, 70, 64 + j * 8, 7)
			for k=1, #wounded.wounds do
				local wound = wounded.wounds[k]
				print((wound.cleaned) and "y" or "n", 70 + k * 8, 64 + j * 8, 7)
			end
		end

		for i=1, #(wounded_civs_pcs)[wounded_civ].wounds do

			local wound = wounded_civs_pcs[wounded_civ].wounds[i]

			if (wound.cleaned) palt(4, true)
			if (not wound.bleeding) pal(8,14)
			spr(wound.spr, wound.x, wound.y)
			pal()
			palt()
			if (wound.dressed) spr(080, wound.x, wound.y)
			if (wound.taped) spr(081, wound.x, wound.y)
			if (wound.under_clothing) wearing_clothing += 1

			if current_civ_detailed_wound == 0 then
				spr(075, 110, 24, 2, 2)
				spr(077, 110, 37, 2, 2)
				spr(107, 109, 52, 2, 2)
				pal(7, 135) pal(6, 143) spr(109, 110, 64, 2, 2) pal()
				spr(105, 111, 80, 2, 2)
			end

			if i == current_civ_detailed_wound then
				rectfill(60, 26, 112, 108, 4)
				palt(0, false) palt(7, true) spr(074, 60, 26, 1, 1) palt()
				palt(0, false) palt(7, true) spr(074, 105, 26, 1, 1, true, false) palt()
				palt(0, false) palt(7, true) spr(074, 105, 101, 1, 1, true, true) palt()
				palt(0, false) palt(7, true) spr(074, 60, 101, 1, 1, false, true) palt()
				rectfill(63, 29, 109, 105, 7)
				sspr(72, 32, 8, 8, 78, 20, 16, 16)

				print("cleaned?", 64, 40, 0) -- (wound.cleaned) and 11 or 8
				-- palt(0, false) circ(94, 49, 3, 0) palt()
				-- palt(0, false) circ(104, 49, 3, 0) palt()
				-- cleaned_marker_x = (wound.cleaned) and 94 or 104
				spr((wound.cleaned) and 089 or 090, 100, 40)

				print("bleeding?", 64, 54, 0)
				-- palt(0, false) circ(94, 63, 3, 0) palt()
				-- palt(0, false) circ(104, 63, 3, 0) palt()
				-- bleeding_marker_x = (wound.bleeding) and 94 or 104
				spr((wound.bleeding) and 089 or 090, 100, 54)

				print("dressed?", 64, 68, 0)
				-- palt(0, false) circ(94, 77, 3, 0) palt()
				-- palt(0, false) circ(104, 77, 3, 0) palt()
				-- dressed_marker_x = (wound.dressed) and 94 or 104
				spr((wound.dressed) and 089 or 090, 100, 68)

				print("taped?", 64, 82, 0)
				-- palt(0, false) circ(94, 91, 3, 0) palt()
				-- palt(0, false) circ(104, 91, 3, 0) palt()
				-- taped_marker_x = (wound.taped) and 94 or 104
				spr((wound.taped) and 089 or 090, 100, 82)
			end
		end

		if (wearing_clothing > 0) sspr(0, 56, 14, 94, 24, 24, 28, 188)

		if tool_selected != "none" then
			if (tool_selected == "soap") tool_spr = 075
			if (tool_selected == "gauze") tool_spr = 077
			if (tool_selected == "scissor") tool_spr = 107
			if (tool_selected == "tape") tool_spr = 109
			if (tool_selected == "lens") tool_spr = 105
			spr(tool_spr, triage_cursor_x, triage_cursor_y, 2, 2)
		end

		spr(067, triage_cursor_x, triage_cursor_y)

		print(tool_selected, 2, 2, 5) -- debug
		print(triage_cursor_x .. " " .. triage_cursor_y, 2, 8, 7) -- debug
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
			if (mm_option == 1) curr_screen = 2 mission_civ_saved = 0 mission_fire_put_out = 0 mission_earnings = 0 difficulty = rnd(difficulties) 
			if (mm_option == 4) curr_screen = 7
			if (mm_option == 2) curr_screen = 8
			if (mm_option == 3) curr_screen = 10 block_btns = true
		end
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

		if btnp(4) and not block_btns then

			if shop_option == 1 and player.rotor_health < player.max_rotor_health then
				player.rotor_health = flr(player.rotor_health) + 1
				player.finance -= 300
				if (player.rotor_health > player.max_rotor_health) player.rotor_health = player.max_rotor_health
			end
			if shop_option == 2 and player.rotor_fuel < player.max_rotor_fuel then
				player.rotor_fuel = flr(player.rotor_fuel) + 1
				player.finance -= 225
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
		foreach(civ_pcs,pickup_civ)

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
			mission_earnings = mission_civ_saved * 75
			stats.missions_finished += 1
			stats.fire_put_out += mission_fire_put_out
			stats.civs_saved += mission_civ_saved
			stats.missions_earnings += mission_earnings
			civ_pcs_created = false
			fire_pcs_created = false
			fire_pcs = {}
			smoke_pcs = {}
			civ_pcs = {}
			player.water_cap = player.max_water_cap
			player.ladder = 0
			player.x = player_strt_x
			player.y = player_strt_y
			player.finance += mission_earnings

			music(-1)
			prop_sound = false
			block_btns = true
			if (mission_has_wounded) wounded_civ = #wounded_civs_pcs
			curr_screen = (mission_has_wounded) and 11 or 9
		end
	end

	if curr_screen == 11 then -- triage mode

		if (btn(0)) triage_cursor_x -= 2
		if (btn(1)) triage_cursor_x += 2
		if (btn(2)) triage_cursor_y -= 2
		if (btn(3)) triage_cursor_y += 2
		if (triage_cursor_x > 120) triage_cursor_x = 120
		if (triage_cursor_y > 120) triage_cursor_y = 120
		if (triage_cursor_x < 0) triage_cursor_x = 0
		if (triage_cursor_y < 0) triage_cursor_y = 0

		if (triage_cursor_x > 100 and triage_cursor_y >= 24 and triage_cursor_y <= 37 and btnp(4)) tool_selected = "soap"
		if (triage_cursor_x > 100 and triage_cursor_y >= 37 and triage_cursor_y <= 51 and btnp(4)) tool_selected = "gauze"
		if (triage_cursor_x > 100 and triage_cursor_y >= 52 and triage_cursor_y <= 67 and btnp(4)) tool_selected = "scissor"
		if (triage_cursor_x > 100 and triage_cursor_y >= 66 and triage_cursor_y <= 80 and btnp(4)) tool_selected = "tape"
		if (triage_cursor_x > 100 and triage_cursor_y >= 80 and triage_cursor_y <= 94 and btnp(4)) tool_selected = "lens"

		if (btnp(5)) tool_selected = "none" current_civ_detailed_wound = 0

		wounds_under_clothing = 0

		for k=1, #wounded_civs_pcs do

			if k == wounded_civ then 

				current_civ_wounds_number = #wounded_civs_pcs[k].wounds

				for i=1, current_civ_wounds_number do

					local wound = wounded_civs_pcs[k].wounds[i]

					if
						triage_cursor_x >= wound.x and
						triage_cursor_x <= wound.x + 8 and
						triage_cursor_y >= wound.y and
						triage_cursor_y <= wound.y + 8
						then
						if btnp(4) then
							if not wound.under_clothing then
								if (tool_selected == "soap" and not wound.cleaned) wound.cleaned = true
								if (tool_selected == "gauze" and not wound.bleeding and not wound.dressed) wound.dressed = true
								if (tool_selected == "gauze" and wound.bleeding) wound.bleeding = false
								if (tool_selected == "tape" and wound.dressed and not wound.taped) wound.taped = true
								if (tool_selected == "lens") current_civ_detailed_wound = i					
							else
								wounds_under_clothing += 1
							end
						end
					end

					if
						triage_cursor_x >= 30 and
						triage_cursor_x <= 50 and
						triage_cursor_y >= 68 and
						triage_cursor_y <= 101
						then
						if btnp(4) and tool_selected == "scissor" then
							if (wound.under_clothing) wound.under_clothing = false
						end
					end

					if (tool_selected != "lens") current_civ_detailed_wound = 0

					if (wound.cleaned and wound.dressed and wound.taped and not wound.bleeding) current_civ_wounds_number -= 1 
				end

				if (current_civ_wounds_number == 0) wounded_civ -= 1
			end
		end

		if (wounded_civ == 0) curr_screen = 9
	end

	if block_btns then
		block_btns_counter += 1
		unblock_after = (curr_screen == 5) and 150 or 5
		if (block_btns_counter % unblock_after == 0) block_btns = false
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
				civ.spr = 033
				civ.health = 10
				civ.rdy_to_climb_up = false
				civ.rdy_to_climb_down = false
				civ.on_board = false
				civ.distance = 0
				civ.closer_to_player = false
				civ.clock = 0
				local wounds = {}

				civ_is_wounded = flr(rnd(3) + 1) -- flr(rnd(4)) -- wip: use rng to flag civ as wounded
				if civ_is_wounded > 0 then
					wound_type = rnd({"arms"}) -- wip: add legs

					for i = 1, civ_is_wounded do 
						add(wounds, all_wounds[wound_type][i])
					end

					mission_has_wounded = true
					civ.wound_type = wound_type
				end

				civ.wounds = wounds

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
		print(#civ.wounds, civ.x+8, civ.y-8) -- debug
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

function pickup_civ(civ)
	if civ.on_board == false then
		if
			civ.x >= player.px1-2 and
			civ.x <= player.px2 and
			civ.y >= 112 and
			civ.y <= 120
		then
			civ.spr = 034

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
			if (not player.rescuing) civ.spr = 033
		end
	end


	if
		player.ladder == 3 and
		civ.rdy_to_climb_up and
		player.occup < player.max_occup
	then
		civ.clock += 1
		if (civ.clock % 5 == 0) civ.spr += 1
		if (civ.spr > 036) civ.spr = 035
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
			civ.clock += 1
			if (civ.clock % 5 == 0) civ.spr += 1
			if (civ.spr > 036) civ.spr = 035
			if (civ.y < 112) civ.y += 0.25

			if civ.y >= 112 then
				if #civ.wounds > 0 then
					add(wounded_civs_pcs, civ)
				end

				del(civ_pcs,civ)
				player.rescuing = false
				player.occup -= 1
				player.ladder_empty = true
				mission_civ_saved += 1
			end
		end
	end
end

function upd_ladder()
	if counter%15 == 0 then
		if player.dpl_ldd_pkup  or  player.dpl_ldd_doof then
			if (player.ladder<3) player.ladder += 1
		end
		if not player.dpl_ldd_pkup and not player.dpl_ldd_doof and counter%30 == 0 then
			if (player.ladder>0) player.ladder -= 1
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
		smoke.damage = 0.175
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
0b000bb000d00d000000300000b00000000d60000006600000000000000000000004f000ff44f4ff00b00000000d600000d00000000d60000000000000000000
00b0b00b00dddd000000b0000b3b00000bbbbb0000bbbb00000000000000000444440000054544500b3b00000bbbbb000d5d00000ddddd000000000000000000
000bbbbb00d00d00000030000b3b0000b331c7b00b7777b0006ee000000000004cc700000c1c11c00b3b0000b331c7b00d5d0000d55d1cd00000000000000000
00b7bbbb00dddd00000030000053bbbb3331ccb00bccccb00068ee700000000041cc0667776776770053bbbb3331ccb00015dddd555d11d00000000000000000
00bbbb7b00d00d000000b00000053333333311cbb311113b006888e076700006655576677666656700053333333311cb000155555555dd1d0000000000000000
00bbbb7b00dddd000000300000005555555533300333333000688000066766656767666007676660000055555555333000001111111155500000000000000000
00bb77bb00d00d000000b00000000000006006000060060000600000005655555555555005655650000000000060060000000000005005000000000000000000
000bbbb000dddd000000d00000000000055555600050050000600000000515515115150000511500000000000555556000000000011111500000000000000000
00ee0ee0bbbbbbbb0000000000000000000000000004200000b3b300777777770000000099aaaaa9000000000000000022222222222222222222222222222222
0e77eeee3b333b3b0000999000000000000000000004200003b33b30c7ccc7c70000000099aaaaa9000000000000000022222222222222222222222222222222
0e7eeeee333333330099aa900707007000000000000420003b3bb3331cc1c1cc0000000099aaaaa9000000000000000020000000000000000000000022222222
0eeeeeee3434344309aaa900077c77c00000000000042000b3bb33b3111c1c110002900099aaaaa9000000000000000002222222222222222222222202222222
0eeeee7e499949940099aa900cccccc000000000000420003b33b333c1c1c1cc0029990099aaaaa9000000000000000002222222222222222222222202222222
00eee7e099999999000099900cc1ccc000000000000440003b3b33b3111111110299a99099aaaaa9000000000000000002222202222202222202222202222222
000e7e0099999999000000000c11c1c0000000000042420033b3b33311111111299aaa9999aaaaa9000000000000000002202202202202202202202202222222
0000e0009999999900000000011111100000000004222220033333301111111199aaaaa999aaaaa9000000000000000020000000000000000000000022222222
0007770000ffff0000ffff0000ffff0000ffff0000000000006d5076766635500000000066777776000000001111111100000000000000000000000000000000
0007770000fcec00f0fcec0ff0fcec0000fcec0f00000000067cc5bbbbbbb3350000000066777776000000003133313100000000000000000000000000000000
0007770000feef0050feef0550feef0000feef05000000000dccc5bbbbbb33350000000066777776000000003333333300000000000000000000000000000000
00777770055dd550055dd550055dd550055dd5500000000066ddd6ddbbb333350005600066777776000000003434344300000000000000000000000000000000
07077707505555050055550000555505505555000000000066666653333333350056660066777776000000004444444400000000070700000000000000000000
07077707f0f55f0f00f55f0000f55ffffff55f0000000000d666d1533336d1310566766066777776000000004444444400000000007000000000000000000000
0007070000f00f0000f00f0000f000f00f000f0000000000055dd151155dd1505667776666777776000000004444444400000000070700000000000000000000
0007070000f00f0000f00f0000f0000000000f000000000000011100000111006677777666777776000000004444444400000000000000000000000000000000
0000c0000000000000000000000000000000000000000000006d50767666355000000000000000000000000000dddd00dddddddddddddddd0000000000000000
000c7c000000000000000000000000000000000000000000067cc5ccccccc11500000000000900000000000000d12100dddddddddddddddd0000000000000000
00c7ccc000000000000000000000000000000000000000000dccc5cccccc11150a0a00a000aa00000a00000000d22d00dddddddddddddddd0000000000000000
00ccccc0000000000000000000000000000000000000000066ddd6ddccc1111509aaa99000a9a09009aa0000055dd550dddddddd000000000000000000000000
0ccccc7c000000000000000000000000000000000000000066666651111111150aa9aaa00aaaaaa00aa9a0a050555505dddddddd000000000000000000000000
0cccc77c0000000000000000000000000000000000000000d666d1511116d115099899900989a8900a99aaa0d0d55d0ddddddddd777777770000000000000000
00cc77c00000000000000000000000000000000000000000055dd155555dd15009889890088a9890098999a000d00d00dddddddd777777770000000000000000
000ccc000000000000000000000000000000005555555555000111000001110008888880098898800888989000d00d00dddddddd777777770000000000000000
060060000600600006000000001000000000000000000000000000000000000000000000000dd000000777770000000000000000000000000000000000000000
00600060006000600060006001710000000000000000000000000000000000000000000000d00d00007777770000000000000000000777770000000000000000
06060606060000060000000601771000000000000000000000000000000000000000000000d00d0007777777000eeeeeeeeee000007666667000000000000000
606660606000006060000000017771000000000000000000000000000000000000000000000dd0007777777700ee22222222ee000766ddd66700000000000000
06060606000000060000000601777710000000000000000000000000000000000000000000dddd00777777770ee7eeeeeeee2ee0077666667777770000000000
600060006000600060006000017711000000000000000000000000000000000000000000dddddddd777777770ee7eeeeeeee2ee007d77777d7dddd7000000000
060606000606060000000000001171000000000000000000000000000000000000000000dddddddd777777770ee7eeeeeeee2ee007ddddddd7dddd7000000000
006060606060606060006060000000000000000000000000000000000000000000000000dddddddd777777770ee7eeeeeeee2ee007ddddddd7dddd7000000000
06666660000dfd00000000000000000000000000000000000000000000000000000000000000000b800080000ee7eeeeeeee2ee007ddddddd7dddd7000000000
677777660000dfd000000000000000000000000000000000000000000000000000000000000000b00808000002ee77777777ee2007ddddddd7dddd7000000000
6777767600000dfd0000000000000000000000000000000000000000000000000000000000000b0000800000022eeeeeeeeee22007dddd6d67dddd7000000000
67776766d00000df00000000000000000000000000000000000000000000000000000000b000b00008080000002222222222220007ddd6d6d7dddd7000000000
67767676fd00000d000000000000000000000000000000000000000000000000000000000b0b000080008000000222222222200007dd6d6d6777770000000000
67676766dfd000000000000000000000000000000000000000000000000000000000000000b000000000000000000000000000000076d6d67000000000000000
667676760dfd00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000777770000000000000000
0666666000dfd0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000006dddd000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000006ccccc500000000000000500000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000006cc777cc50000000000000500000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000006cc7cccccc5000000000000600000000000000000000000000000000
077700700770007007770070077700700707007007770070000000000000000000000000dc7ccccc7c5000000000000500000000000000000000000000000000
070700700070007000770070007700700777007007700070000000000000000000000000dc7ccccccc5000000000005560000000000011111000000000000000
0707070000700700070007000007070000070700000707000000000000000000000000005c7ccccc7c5000000000005660000000011111111111000000000000
0777070007770700077707000777070000070700077707000000000000000000000000005ccccccccc5000000000005560000000006611111770000000000000
00000000000000000000000000000000000000000000000000000000000000000000000005cccc7cc5000000000000506000000000666677777d000000000000
000000000000000000000000000000000000000000000000000000000000000000000000005ccccc55600000000000606000000000666667777dd00000000000
0000000000000000000000000000000000000000000000000000000000000000000000000005555505560000000005506600000000666677776ddd0000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000055d000000088506880000000666667767ddd0000000000
0000000070000000000000007000000000000000000000000000000000000000000000000000000000055d000008008080080000006666676760dd0000000000
000000070770000000000007f7700000000000000000000000000000000000000000000000000000000055d000080080800800000111667671110d0000000000
000000770707000000000077f7f70000000000000000000000000000000000000000000000000000000005000008008080080000000011111000000000000000
0000070707070000000007f7f7f70000000000000000000000000000000000000000000000000000000000000000880008800000000000000000000000000000
0000070707070000000007f7f7f70000480004000008000000800000000000000000000000000000000000000000000000000000000000000000000000000000
0000770707070000000077f7f7f70000848440000048000008048000000000000000000000000000000000000000000000000000000000000000000000000000
00070700000700000007f7fffff70000084800004488440084080000000000000000000000000000000000000000000000000000000000000000000000000000
00070700000770000007f7fffff77000084000000884000004404000000000000000000000000000000000000000000000000000000000000000000000000000
00070700000707000007f7fffff7f700048400000848000088800000000000000000000000000000000000000000000000000000000000000000000000000000
00070000000707000007fffffff7f700008040004404000004044000000000000000000000000000000000000000000000000000000000000000000000000000
00070000000007000007fffffffff700000800000800000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00070000000007000007fffffffff700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00070000000070000007ffffffff7000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00070000000070000007ffffffff7000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00070000000070000007ffffffff7000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000070000007000000007ffffff70000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000070000700000000007ffff700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000070000700000000007ffff700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000dddddddddd000000007ffff700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000dddddddddd000000007ffff700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000dddddddddd000000007ffff700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000dddddddddd000000007ffff700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000dddddddd0000000007ffff700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000dddddddd0000000007ffff700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000dddddddddd000000007ffff700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000dddddd6ddd000000007ffff700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000ddddd6dddd000000007fffff70000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000dddddddddd000000007fffff70000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000dddddddddd000000007fffff70000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000dd6ddddd6d000000007fffff70000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000d6ddddd6dd000000007fffff70000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000dddddddddd000000007fffff70000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000dddddddd6d000000007fffff70000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000dddd6dd6dd000000007fffff70000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000ddd6dd6ddd000000007fffff70000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__label__
55505550000055505050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
50505050000000505050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
55505550000000505550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
50505050000000500050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
55505550000000500050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000aaaaaaaaaa000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000aa77aaaa99aa00000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000aa7aaaaaaaa9aa0000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000aa7aaaaaaaa9aa0000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000aa7aaaaaaaa9aa0000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000aa7aaaaaaaa9aa0000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000aa7aaaaaaaa9aa0000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000009aa77aaaa99aa90000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000099aaaaaaaaaa990000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000099999999999900000000000000
00000000000000000000000000000000000000070000000000000000000000000000000000000000000000000000000000000009999999999000000000000000
000000000000000000000000000000000000007f7700000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000077f7f70000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000007f7f7f70000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000007f7f7f70000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000077f7f7f70000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000007f7fffff70000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000007f7fffff77000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000007f7fffff7f700000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000007fffffff7f700000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000007fffffffff700000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000748fffffff700000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000007848fffff7000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000074848ffff7000000000000000000000000000000000000000000000000000000000007777700000000000000000000
00000000000000000000000000000000007ff4fffff7000000000000000000000000000000000000000000000000000000000076666670000000000000000000
000000000000000000000000000000000007ff4fff70000000000000000000000000000000000000000000000000000000000766ddd667000000000000000000
0000000000000000000000000000000000007ffff700000000000000000000000000000000000000000000000000000000000776666677777700000000000000
0000000000000000000000000000000000007ffff7000000000000000000000000000000000000000000000000000000000007d77777d7dddd70000000000000
0000000000000000000000000000000000007ffff7000000000000000000000000000000000000000000000000000000000007ddddddd7dddd70000000000000
0000000000000000000000000000000000007fff47000000000000000000000000000000000000000000000000000000000007ddddddd7dddd70000000000000
0000000000000000000000000000000000007fff47000000000000000000000000000000000000000000000000000000000007ddddddd7dddd70000000000000
0000000000000000000000000000000000007f48f7000000000000000000000000000000000000000000000000000000000007ddddddd7dddd70000000000000
0000000000000000000000000000000000007fff87000000000000000000000000000000000000000000000000000000000007ddddddd7dddd70000000000000
0000000000000000000000000000000000007f4847000000000000000000000000000000000000000000000000000000000007ddddddd7dddd70000000000000
0000000000000000000000000000000000007f8ff7000000000000000000000000000000000000000000000000000000000007ddddddd7777700000000000000
00000000000000000000000000000000000074f4870000000000000000000000000000000000000000000000000000000000007ddddd70000000000000000000
0000000000000000000000000000000000007ff8ff70000000000000000000000000000000000000000000000000000000000007777700000000000000000000
0000000000000000000000000000000000007fffff70000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5500055055005550000000000000000000007fffff70000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5050505050505000000000000000000000007fffff70000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5050505050505500000000000000000000007fffff70000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5050505050505000000000000000000000007fffff70000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5050550050505550000000000000000000007f0f0f70000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000070000070000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000070000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000500000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000010000000000000000500000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000171000000000000000500000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000177100000000000000500000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000177710000000000005560000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000177771000000000005560000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000177110000000000005560000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000011710000000000005060000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000005060000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000055066000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000885068800000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000008008080080000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000008008080080000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000008008080080000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000880008800000000000000000
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
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000111110000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000111111111110000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000066111117700000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000666677777d0000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000666667777dd000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000666677777ddd00000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000666667777ddd00000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000006666677770dd00000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000111667771110d00000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000111110000000000000000000
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

__gff__
0000000000000000000000000000000000000000000000000000000000000000000101010100000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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

