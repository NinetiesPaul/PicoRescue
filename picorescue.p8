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
		x = player_strt_x,
		px = player_strt_x,
		y = player_strt_y,
		py = player_strt_y,
		speed_x = 0,
		speed_y = 0,
		acc_x = 0.015, -- 0.015, 0.025. 0.05
		mvn_dir = false,
		facing = "left",
		vhc_front = 04,
		occup = 0,
		max_occup = 2, -- 3 4
		water_cap = 4,
		max_water_cap = 4,
		rotor_health = 10,
		max_rotor_health = 10,
		rotor_fuel = 10,
		max_rotor_fuel = 10,
		fuel_consumption = 0.07, -- 0.05 0.03
		top_speed_x = 2, -- 3 4
		top_speed_y = 2,
		ladder = 0,
		ladder_empty = true,
		dpl_ldd_pkup = false,
		dpl_ldd_doof = false,
		rescuing = false,
		droping_off = false,
		rx1 = 0,
		ry1 = 0,
		rx2 = 0,
		ry2 = 0,
		finance = 1500,
		ladder_climb_spd = 5, -- 0.20, -- 0.3 -- 0.5
		spotlight_px1 = player_strt_x + 3,
		spotlight_py1 = player_strt_y + 10,
		spotlight_px2 = player_strt_x + 7,
		spotlight_py2 = player_strt_y + 33,
		spotlight_height = 0 -- 1
	}

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
	current_civ_detailed_wound = 0
	current_wounds_treated = 0
	current_wounds =
	{
		wounds = {},
		wound_type = "",
		side = "front",
		rescuee_name = "",
		wearing_clothing = "true",
		blood_level = 10
	}

	triage_cursor_x = 64
	triage_cursor_y = 64
	tool_selected = "none"

	stats =
	{
		fire_put_out = 0,
		civs_saved = 0,
		missions_finished = 0,
		missions_earnings = 0,
	}
	difficulties = { "easy" } -- ,  "normal", "hard"
	civ_spawn =
	{
		easy = { 70 }, -- 150, 250, 345, 460
		normal = { 250, 350, 395, 470, 590 },
		hard = { 290, 390, 580, 620, 680, 750 }
	}
	fire_spawn =
	{
		easy = { 110, 130, 200, 220, 330, 360, 410, 420, 440 },
		normal = { 170, 200, 220, 330, 370, 420, 450, 510, 520, 530, 560 },
		hard = { 200, 220, 330, 370, 410, 460, 510, 530, 560, 605, 635, 660, 700, 730 }
	}
	excoriation =
	{
		arms =
		{
			{
				x = 58,
				y = 52,
				cleaned = false,
				bleeding = true,
				dressed = false,
				taped = false,
				under_clothing = false,
				triaged = false
			},
			{
				x = 59,
				y = 62,
				cleaned = false,
				bleeding = true,
				dressed = false,
				taped = false,
				under_clothing = true,
				triaged = false
			},
			{
				x = 57,
				y = 84,
				cleaned = false,
				bleeding = true,
				dressed = false,
				taped = false,
				under_clothing = true,
				triaged = false
			}
		},
		legs =
		{
			{
				x = 60,
				y = 52,
				cleaned = false,
				bleeding = true,
				dressed = false,
				taped = false,
				under_clothing = true,
				triaged = false
			},
			{
				x = 62,
				y = 62,
				cleaned = false,
				bleeding = true,
				dressed = false,
				taped = false,
				under_clothing = true,
				triaged = false
			},
			{
				x = 64,
				y = 84,
				cleaned = false,
				bleeding = true,
				dressed = false,
				taped = false,
				under_clothing = true,
				triaged = false
			}
		},
	}
	fractures = 
	{
		arms =
		{
			{
				x = 36,
				y = 62,
				ice_applied = false,
				bleeding = true,
				dressed = false,
				taped = false,
				under_clothing = true,
				triaged = false,
				spr = 083
			},
		}
	}

	difficulty = "";
	mission_ground = 20
	mission_civ_saved = 0
	mission_fire_put_out = 0
	mission_earnings = 0
	mission_day_time = rnd({ "day", "night" })
	mission_wind_v = rnd({ 0, 0.05, 0.15, 0.3 })
	mission_wind_d = rnd({ "left", "right" })
	mission_wind_roulette = true
	mission_top_speed = 0
	mission_time = 0
	mission_counter = 0
	mission_leave_prompt = false

	low_fuel_prompt = false
	low_fuel_prompt_confirm = false

	block_btns = false
	block_btns_counter = 0

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
		print("finances",48,79,5)
		print("finances",48,78,mm_opt5_c)

		if low_fuel_prompt then
			rectfill(26,48, 100, 79, 8)
			rect(28,50, 98, 77, 7)
			print("warning: low fuel", 30, 53, 7)
			print("[z/🅾️] continue", 34, 62, 7)
			print("[x/❎] back", 42, 70, 7)
		end
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

		print("health $95",15,48,7)
		print("fuel $75",15,58,7)

		selector_pos = (shop_option == 1) and 47 or 57
		spr(018, 5, selector_pos, 1, 1, true)

		print(flr(player.rotor_health) .. "/" .. player.max_rotor_health, 100, 48, 7)
		print(flr(player.rotor_fuel) .. "/" .. player.max_rotor_fuel, 100, 58, 7)

		-- fuel_consumption acc_x max_occup top_speed_x ladder_climb_spd spotlight_height
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
		rectfill(0, 0, 128, 119, (mission_day_time == "day") and 12 or 0)
		spr(020, drop_off_x, 112)

		if (counter % 3 == 0) spr(052, player.x - 8, player.y - 8)
		if (counter % 3 == 0) spr(052, player.x + 8, player.y - 8, 1, 1, true)
		spr(053, player.x, player.y - 8)
		spr(player.vhc_front, player.x, player.y, 1, 1, (player.facing == "right") and true or false)
		if (player.facing != false) spr((mission_day_time == "day") and 003 or 006, (player.facing == "right") and player.x+8 or player.x-8, player.y, 1, 1, (player.facing == "right") and true or false)

		palt(0, false) rectfill(1, 1, 54, 19, 0) palt()
		rectfill(0, 0, 53, 18, 6)

		health = player.rotor_health/player.max_rotor_health
		rotor_health_bar_length = (health > 0.9) and 19 or
		(health > 0.8 and health < 0.9) and 17 or
		(health > 0.7 and health < 0.8) and 15 or
		(health > 0.6 and health < 0.7) and 13 or
		(health > 0.5 and health < 0.6) and 11 or
		(health > 0.4 and health < 0.5) and 9 or
		(health > 0.3 and health < 0.4) and 7 or
		(health > 0.2 and health < 0.3) and 5 or
		(health > 0.1 and health < 0.2) and 3 or 1

		spr(016, 0, 1)
		rectfill(11, 3, 11 + rotor_health_bar_length, 6, 14)
		palt(0, false) palt(2, true)
		spr(026, 10, 0, 2, 1)
		spr(026, 23, 0, 1, 1, true)
		palt()

		fuel_usage = player.rotor_fuel/player.max_rotor_fuel
		rotor_fuel_bar_length = (fuel_usage > 0.9) and 19 or
		(fuel_usage > 0.8 and fuel_usage < 0.9) and 17 or
		(fuel_usage > 0.7 and fuel_usage < 0.8) and 15 or
		(fuel_usage > 0.6 and fuel_usage < 0.7) and 13 or
		(fuel_usage > 0.5 and fuel_usage < 0.6) and 11 or
		(fuel_usage > 0.4 and fuel_usage < 0.5) and 9 or
		(fuel_usage > 0.3 and fuel_usage < 0.4) and 7 or
		(fuel_usage > 0.2 and fuel_usage < 0.3) and 5 or
		(fuel_usage > 0.1 and fuel_usage < 0.2) and 3 or 1

		spr(000, 0, 10)
		rectfill(11, 12, 11 + rotor_fuel_bar_length, 15, 11)
		palt(0, false) palt(2, true)
		spr(026, 10, 9, 2, 1)
		spr(026, 23, 9, 1, 1, true)
		palt()

		spr(048, 32, 1)
		water_drop_spr = (player.water_cap == 0) and 043 or
		(player.water_cap == 1) and 044 or
		(player.water_cap == 2) and 045 or
		(player.water_cap == 3) and 059 or
		(player.water_cap == 4) and 060 or 061
		pal(7, 0) spr(water_drop_spr, 40, 0) pal()
		print(player.max_water_cap, 48, 3, 0)

		spr(032, 32, 10)
		occup_spr = (player.occup == 0) and 043 or
		(player.occup == 1) and 044 or 045
		pal(7, 0) spr(occup_spr, 40, 9) pal()
		print(player.max_occup, 48, 12, 0)

		--[[
		arrow_flip = (drop_off_x > player.x) and true or false
		spr(037, 8 , 33, 1, 1, arrow_flip, false)
		print(abs(flr(drop_off_x - player.x)), 16, 35)
		spr(006,0,32)
		]]--

		col = (mission_day_time == "day") and 0 or 7
		print(count(civ_spawn[difficulty]) - mission_civ_saved .. " left to save!", drop_off_x - 8, 100, col)

		if mission_day_time == "night" then
			sspr(112, 0, 4, 24 + (player.spotlight_height * 8), player.x, player.y + 10)
			sspr(112, 0, 4, 24 + (player.spotlight_height * 8), player.x + 5, player.y + 10, 4, 24 + (player.spotlight_height * 8), true)
			rectfill(player.spotlight_px1, player.spotlight_py1, player.spotlight_px2 - 3, player.spotlight_py2, 2)

			if player.spotlight_height == 0 then
				sspr(104, 0, 4, 4, player.spotlight_px1-2, player.spotlight_py2 + 1)
				sspr(104, 0, 3, 4, player.spotlight_px1+2, player.spotlight_py2 + 1)
			else
				sspr(104, 0, 4, 4, player.spotlight_px1-4, player.spotlight_py2 + 1)
				sspr(104, 0, 4, 4, player.spotlight_px1, player.spotlight_py2 + 1)
				sspr(104, 0, 3, 4, player.spotlight_px1+4, player.spotlight_py2 + 1)
			end
		end

		for i = 1, player.ladder do
			spr(001,player.x,player.y+i*8)
		end

		if (mission_day_time == "night") foreach(fire_pcs,draw_light_source)
		foreach(fire_pcs,draw_fire)
		foreach(civ_pcs,draw_civ)
		foreach(smoke_pcs,draw_smoke)
		foreach(water_drops,draw_water)
		foreach(ground_pcs,draw_ground)

		if mission_leave_prompt then
			rectfill(26,48, 100, 79, 8)
			rect(28,50, 98, 77, 7)
			print("abort mission?", 36, 53, 7)
			print("[z/🅾️] yes ", 44, 62, 7)
			print("[x/❎] no", 46, 70, 7)
		end


		rectfill(104, 1, 126, 9, 0)
		rectfill(105, 0, 127, 8, 6)
		print(flr(mission_time/60)..":"..((mission_time % 60 < 10) and "0"..mission_time % 60 or mission_time % 60), 109, 2, 0)

		
	end

	if curr_screen == 11 then -- triage mode
		rect(0,0,127,127, 7)

		print(current_wounds.blood_level, 64, 2, 7)

		flip_x = (current_wounds.side == "front") and true or false

		if (current_wounds.wound_type == "arms") sspr(0, 58, 11, 35, 50, 24, 22, 70, flip_x)
		if (current_wounds.wound_type == "legs") sspr(34, 58, 14, 120, 50, 12, 28, 240, flip_x)

		--[[
		for j=1, #wounded_civs_pcs do
			local wounded = wounded_civs_pcs[j]
			print(j, 70, 64 + j * 8, 7)
			for k=1, #wounded.wounds do
				local wound = wounded.wounds[k]
				print((wound.cleaned) and "y" or "n", 70 + k * 8, 64 + j * 8, 7)
			end
		end
		]]--

		if current_civ_detailed_wound == 0 then
			spr(070, 110, 8, 2, 2)
			spr(076, 110, 24, 2, 2)
			spr(078, 110, 37, 2, 2)
			spr(108, 109, 52, 2, 2)
			spr(110, 110, 64, 2, 2)
			spr(106, 111, 80, 2, 2)
			spr(072, 111, 96, 2, 2)
		end

		total_blood_loss_level = 0

		for i=1, #current_wounds.wounds do

			local wound = current_wounds.wounds[i]

			if wound.side == current_wounds.side then

				if (wound.cleaned) palt(4, true)
				if (not wound.bleeding) pal(8,14)
				spr(wound.spr, wound.x, wound.y)
				pal()
				palt()
				if (wound.dressed) spr(080, wound.x, wound.y)
				if (wound.taped) spr(081, wound.x, wound.y)

				if i == current_civ_detailed_wound then
					rectfill(60, 26, 112, 108, 4)
					palt(0, false) palt(7, true) spr(097, 60, 26, 1, 1) palt()
					palt(0, false) palt(7, true) spr(097, 105, 26, 1, 1, true, false) palt()
					palt(0, false) palt(7, true) spr(097, 105, 101, 1, 1, true, true) palt()
					palt(0, false) palt(7, true) spr(097, 60, 101, 1, 1, false, true) palt()
					rectfill(63, 29, 109, 105, 7)
					sspr(0, 48, 8, 8, 78, 20, 16, 16)

					print("PT: " .. current_wounds.rescuee_name, 64, 40, 0)
					line(64, 46, 108, 46)

					print("cLEANED?", 64, 54, 0)
					spr((wound.cleaned) and 064 or 065, 100, 54)

					print("sTOPPED \nBLEEDING?", 64, 64, 0)
					spr((not wound.bleeding) and 064 or 065, 100, 68)

					print("dRESSED?", 64, 80, 0)
					spr((wound.dressed) and 064 or 065, 100, 80)

					print("tAPED?", 64, 90, 0)
					spr((wound.taped) and 064 or 065, 100, 90)
				end
			end

			print("w"..i..":"..wound.blood_loss_level, 64, 18 + i * 8, 7)
			total_blood_loss_level += wound.blood_loss_level
		end

		print("tt "..total_blood_loss_level .."," .. flr(total_blood_loss_level), 64, 10, 7)

		rect(12, 28, 18, 108, 2)
		rectfill(13, 21 + (11-flr(current_wounds.blood_level)) * 8, 17, 107, 8)
		pal(12, 8) spr(048, 11, 111) pal()

		if (current_wounds.wearing_clothing and current_wounds.wound_type == "arms") sspr(0, 96, 10, 16, 50, 62, 20, 32, flip_x)
		if (current_wounds.wearing_clothing and current_wounds.wound_type == "legs") sspr(17, 58, 16, 55, 46, 12, 32, 110, flip_x)

		if tool_selected != "none" then
			if (tool_selected == "soap") tool_spr = 076
			if (tool_selected == "gauze") tool_spr = 078
			if (tool_selected == "scissor") tool_spr = 108
			if (tool_selected == "tape") tool_spr = 110
			if (tool_selected == "lens") tool_spr = 106
			spr(tool_spr, triage_cursor_x, triage_cursor_y, 2, 2)
		end

		print(tool_selected, 2, 2, 5) -- debug
		spr(066, triage_cursor_x, triage_cursor_y)
		print(triage_cursor_x..","..triage_cursor_y, 2, 10, 7)
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
		if (btnp(2) and not low_fuel_prompt) mm_option -= 1 sfx(2)
		if (btnp(3) and not low_fuel_prompt) mm_option += 1 sfx(2)

		if (mm_option > 5) mm_option = 1
		if (mm_option < 1) mm_option = 5

		if btnp(4) and not block_btns then
			sfx(1)
			if mm_option == 1 then
				if (player.rotor_fuel <= 5) low_fuel_prompt = true block_btns = true

				if not low_fuel_prompt or low_fuel_prompt_confirm then
					mission_civ_saved = 0 mission_fire_put_out = 0 mission_earnings = 0 difficulty = rnd(difficulties) curr_screen = 2
				else
					if (btnp(4)) low_fuel_prompt_confirm = true
				end
			end
			if (mm_option == 4) curr_screen = 7
			if (mm_option == 2) curr_screen = 8
			if (mm_option == 3) curr_screen = 10 block_btns = true
		end

		if (btnp(5) and low_fuel_prompt) low_fuel_prompt = false low_fuel_prompt_confirm = false
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
				player.finance -= 95
				if (player.rotor_health > player.max_rotor_health) player.rotor_health = player.max_rotor_health
			end
			if shop_option == 2 and player.rotor_fuel < player.max_rotor_fuel then
				player.rotor_fuel = flr(player.rotor_fuel) + 1
				player.finance -= 75
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

		mission_counter += 1
		if (mission_counter % 30 == 0) mission_time += 1
		if mission_time > 0 and mission_time % 15 == 0 then -- default 30
			if mission_wind_roulette then
				mission_wind_roulette = false
				mission_wind_v = rnd({ 0, 0.05, 0.15, 0.3, 0.4, 0.6 }) -- 0, 0.05, 0.15, 0.3
				mission_wind_d = rnd({ "left", "right" })
			end
		else
			mission_wind_roulette = true
		end


		if player.facing != false and mission_wind_v > 0 then
			if player.facing == "left" then
				mission_top_speed = (mission_wind_d == "left") and mission_wind_v * 1 or mission_wind_v * -1
			else
				mission_top_speed = (mission_wind_d == "right") and mission_wind_v * 1 or mission_wind_v * -1
			end
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
		if (not player.rescuing and not mission_leave_prompt) move_rotor()

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

		if mission_leave_prompt then
			if (btnp(4)) for civ in all (civ_pcs) do del(civ_pcs,civ) end
			if (btnp(5)) mission_leave_prompt = false
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
			mission_leave_prompt = false
			mission_counter = 0
			mission_time = 0
			world_x = 0
			drop_off_x = 32
			low_fuel_prompt = false
			low_fuel_prompt_confirm = false

			music(-1)
			prop_sound = false
			block_btns = true
			curr_screen = (#wounded_civs_pcs > 0) and 11 or 9
		end
	end

	if curr_screen == 11 then -- triage mode

		if (btn(0)) triage_cursor_x -= 3
		if (btn(1)) triage_cursor_x += 3
		if (btn(2)) triage_cursor_y -= 3
		if (btn(3)) triage_cursor_y += 3
		if (triage_cursor_x > 120) triage_cursor_x = 120
		if (triage_cursor_y > 120) triage_cursor_y = 120
		if (triage_cursor_x < 0) triage_cursor_x = 0
		if (triage_cursor_y < 0) triage_cursor_y = 0

		if (triage_cursor_x > 100 and triage_cursor_y >= 24 and triage_cursor_y <= 37 and btnp(4)) tool_selected = "soap"
		if (triage_cursor_x > 100 and triage_cursor_y >= 37 and triage_cursor_y <= 51 and btnp(4)) tool_selected = "gauze"
		if (triage_cursor_x > 100 and triage_cursor_y >= 52 and triage_cursor_y <= 67 and btnp(4)) tool_selected = "scissor"
		if (triage_cursor_x > 100 and triage_cursor_y >= 66 and triage_cursor_y <= 80 and btnp(4)) tool_selected = "tape"
		if (triage_cursor_x > 100 and triage_cursor_y >= 80 and triage_cursor_y <= 94 and btnp(4)) tool_selected = "lens"

		if (triage_cursor_x > 100 and triage_cursor_y >= 8 and triage_cursor_y <= 24 and btnp(4)) current_wounds.blood_level += 3
		if (triage_cursor_x > 100 and triage_cursor_y >= 96 and triage_cursor_y <= 120 and btnp(4)) current_wounds.side = (current_wounds.side == "front") and "back" or "front"

		if (current_wounds.blood_level > 10) current_wounds.blood_level = 10

		if (btnp(5)) tool_selected = "none" current_civ_detailed_wound = 0
		if (tool_selected != "lens") current_civ_detailed_wound = 0

		if #current_wounds.wounds == 0 then
			current_wounds.wounds = wounded_civs_pcs[#wounded_civs_pcs].wounds
			current_wounds.wound_type = wounded_civs_pcs[#wounded_civs_pcs].wound_type
			current_wounds.side = "front"
			current_wounds.rescuee_name = wounded_civs_pcs[#wounded_civs_pcs].name
			current_wounds.wearing_clothing = true
			current_wounds.blood_level = wounded_civs_pcs[#wounded_civs_pcs].blood_level
			del(wounded_civs_pcs, wounded_civs_pcs[#wounded_civs_pcs])
		end

		for i=1, #current_wounds.wounds do

			local wound = current_wounds.wounds[i]

			current_wounds.blood_level -= (wound.bleeding) and wound.blood_loss_level or wound.blood_loss_level/2

			if not wound.triaged and wound.side == current_wounds.side then

				if
					triage_cursor_x >= wound.x and
					triage_cursor_x <= wound.x + 8 and
					triage_cursor_y >= wound.y and
					triage_cursor_y <= wound.y + 8
					then
					if btnp(4) then
						if not wound.under_clothing or wound.under_clothing and not current_wounds.wearing_clothing then
							if (tool_selected == "soap" and not wound.cleaned) wound.cleaned = true
							if (tool_selected == "gauze" and not wound.bleeding and not wound.dressed) wound.dressed = true
							if (tool_selected == "gauze" and wound.bleeding) wound.bleeding = false
							if (tool_selected == "tape" and wound.dressed and not wound.taped) wound.taped = true
							if (tool_selected == "lens") current_civ_detailed_wound = i
						end
					end
				end

				if (wound.cleaned and wound.dressed and wound.taped and not wound.bleeding) wound.triaged = true current_wounds_treated += 1
			end
		end

		wound_clothing_x1 = (current_wounds.wound_type == "arms") and 50 or 46
		wound_clothing_y1 = (current_wounds.wound_type == "arms") and 62 or 12
		wound_clothing_x2 = (current_wounds.wound_type == "arms") and 70 or 78
		wound_clothing_y2 = (current_wounds.wound_type == "arms") and 93 or 121

		if
			triage_cursor_x >= wound_clothing_x1 and
			triage_cursor_x <= wound_clothing_x2 and
			triage_cursor_y >= wound_clothing_y1 and
			triage_cursor_y <= wound_clothing_y2
			then
			
			if btnp(4) and tool_selected == "scissor" and current_wounds.wearing_clothing then
				current_wounds.wearing_clothing = false
			end
		end

		if (#current_wounds.wounds == current_wounds_treated) current_wounds_treated = 0 current_wounds.wounds = {}

		if (#wounded_civs_pcs == 0 and #current_wounds.wounds == 0) triage_cursor_x = 64 triage_cursor_y = 64 tool_selected = "none" curr_screen = 9
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
				player.vhc_front = (mission_day_time == "day") and 005 or 008
				world_x -= player.speed_x
			end
		else
			player.vhc_front = (mission_day_time == "day") and 004 or 007
			player.facing = "right"
			if (player.speed_x <= (player.top_speed_x + mission_top_speed)) player.speed_x += player.acc_x
			player.px = world_x
			world_x += player.speed_x
		end
	end

	if left_btn then
		if player.px < world_x then
			if player.speed_x > 0 then
				player.speed_x -= 0.035
				player.facing = false
				player.vhc_front = (mission_day_time == "day") and 005 or 008
				world_x += player.speed_x
			end
		else
			player.vhc_front = (mission_day_time == "day") and 004 or 007
			player.facing = "left"
			if (player.speed_x <= (player.top_speed_x + mission_top_speed)) player.speed_x += player.acc_x
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
		mission_leave_prompt = true
		world_x = 84 
		player.speed_x = 0
		player.px = world_x
	end

	if world_x < max_world_x then
		world_x = max_world_x
		player.speed_x = 0
		player.px = world_x
	end
end

function upd_pkup_area()
	player.px1 = player.x-8
	player.py1 = 112
	player.px2 = player.x+16
	player.py2 = 120

	player.spotlight_px1 = player.x  + 3
	player.spotlight_py1 = player.y  + 10
	player.spotlight_px2 = player.x + 7
	player.spotlight_py2 = player.y  + 33 + (player.spotlight_height * 8)
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
				civ.spr = 8
				civ.health = 10
				civ.rdy_to_climb_up = false
				civ.rdy_to_climb_down = false
				civ.on_board = false
				civ.clock = 0
				civ.name = rnd({ "aNNA", "fRANK", "jOE", "jOHN", "pAULIE", "mARTHA", "bRUCE", "cLARK", "tONY", "mARY", "aNGELA" })
				civ.blood_level = 10
				local wounds = {}

				civ_is_wounded = 2 -- (rnd(1) > 0.55) and rnd({ 1, 2, 3 }) or 0
				if civ_is_wounded > 0 then
					wound_type = rnd({ "arms", "legs" }) -- wip: arms, legs

					for i = 1, civ_is_wounded do
						for k,v in pairs(excoriation) do
							if k == wound_type then
								local wound =
								{
									x = v[i].x,
									y = v[i].y,
									cleaned = v[i].cleaned,
									bleeding = v[i].bleeding,
									dressed = v[i].dressed,
									taped = v[i].taped,
									under_clothing = v[i].under_clothing,
									triaged = v[i].triaged,
									spr = rnd({ 082, 083, 084, 098, 099, 100 }),
									side = rnd({ "front", "back" }),
									blood_loss_level = rnd({ 0.0025, 0.0055, 0.0095 })
								}
								add(wounds, wound)
							end
						end
					end

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
		if (mission_day_time == "day") then
			sspr(civ.spr, 16, 8, 8, civ.x, civ.y)
		else
			draw_y = (flr(player.spotlight_py2) - civ.y) + 1
			if (draw_y > 8 ) draw_y = 8

			
			if (player.px2 < civ.x + 16) then
				limit = ((player.px2 - flr(civ.x))-6 > 0) and (player.px2 - flr(civ.x))-6 or 0
				if (limit > 8) limit = 8

				for i=1, limit do
					sspr(civ.spr,16,0 + i, draw_y, civ.x, civ.y)
				end
			else
				limit = ((player.px2 - flr(civ.x))-6) - 10
				sspr(civ.spr + limit, 16, 8 - limit, draw_y, civ.x + limit, civ.y)
			end
		end
	end
end

function move_civ(civ)
	if civ.on_board == false then
		if (player.mvn_dir == "left") civ.x += player.speed_x
		if (player.mvn_dir == "right") civ.x -= player.speed_x
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
			civ.spr = 16

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
			if (not player.rescuing) civ.spr = 8
		end
	end


	if
		player.ladder == 3 and
		civ.rdy_to_climb_up and
		player.occup < player.max_occup
	then
		civ.clock += 1
		if (civ.clock % 5 == 0) civ.spr += 8
		if (civ.spr > 32) civ.spr = 24
		if (civ.y > player.y) civ.y -= player.ladder_climb_spd
		player.rescuing = true

		if civ.y <= player.y then
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
			if (civ.clock % 5 == 0) civ.spr += 8
			if (civ.spr > 32) civ.spr = 24
			if (civ.y < 112) civ.y += player.ladder_climb_spd

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
	ground_spr = (mission_day_time == "night") and 012 or 017
	spr(ground_spr,ground.x,ground.y)
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
				fire.frequency = rnd({ 5, 10, 15})
				-- fire.smk_cd_time = rnd({ 45, 60 })
				fire.smk_cd = false
				fire.counter = 0
				fire.spr = 056
				fire.radius = 15
				fire.is_wild = (rnd(1) > 0.6) and true or false
				add(fire_pcs, fire)
			end
		end
	end

	fire_pcs_created = true
end

function draw_fire(fire)
	spr(fire.spr,fire.x,fire.y)
end

function draw_light_source(fire)
	circfill(fire.x + 4,fire.y + 6, fire.radius, 2)
end

function update_fire(fire)
	fire.counter += 1
	fire.radius = (counter % 1.5 == 0) and 12 or 11
	if (counter % 2 == 0) fire.spr += 1
	if (fire.spr > 058) fire.spr = 56

	if not smk_cd and fire.counter % fire.frequency == 0 then
		local smoke = {}
		smoke.x = fire.x + rnd({ -2, -1, 1, 2 })
		smoke.y = fire.y
		smoke.spr = 049
		smoke.damage = 0.0175
		add(smoke_pcs, smoke)
	end

	if mission_wind_v > 0.3 and fire.is_wild then
		fire.is_wild = false

		local new_fire = {}
		new_fire.x = (mission_wind_d == "left") and fire.x + 8 or fire.x - 8
		new_fire.y = 112
		new_fire.smk_mh = rnd({ 1, 2, 3 })
		new_fire.smk_h = 0
		-- new_fire.smk_cd_time = rnd({ 45, 60 })
		new_fire.smk_cd = false
		new_fire.counter = 0
		new_fire.spr = 056
		new_fire.frequency = rnd({ 5, 10, 15})
		new_fire.radius = 15
		new_fire.is_wild = (rnd(1) > 0.8) and true or false
		add(fire_pcs, new_fire)
	end

end

function draw_smoke(smoke)
	if (smoke.y < 70) pal(6, 13)
	if (smoke.y < 56) pal(6, 5)
	
	if (mission_day_time == "day") then
		sspr(8, 24, 8, 8, smoke.x, smoke.y)
	else
		draw_y = (flr(player.spotlight_py2) - flr(smoke.y)) + 1
		if (draw_y > 8) draw_y = 8


		if flr(smoke.y) > (flr(player.spotlight_py1) - 4) then
			if (player.px2 < smoke.x + 16) then
				limit = ((player.px2 - flr(smoke.x))-6 > 0) and (player.px2 - flr(smoke.x))-6 or 0
				if (limit > 8) limit = 8

				for i=1, limit do
					sspr(8,24,0 + i, draw_y, smoke.x, smoke.y)
					palt() pal()
				end
			else
				limit = ((player.px2 - flr(smoke.x))-6) - 10
				sspr(8 + limit, 24, 8 - limit, draw_y, smoke.x + limit, smoke.y)
				
			end
		end
	end
	palt() pal()
end

function move_smoke(smoke)
	smoke.y -= 0.95

	if mission_wind_v > 0 then
		if (mission_wind_d == "left") smoke.x -= mission_wind_v
		if (mission_wind_d == "right") smoke.x += mission_wind_v
	end

	if (smoke.y < 70) smoke.spr = 050 smoke.damage = 0.0050
	if (smoke.y < 56) smoke.spr = 051 smoke.damage = 0.025

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
0300033000d00d000000300000b00000000d60000006600000d00000000d600000066000000000000004f000ff44f4ff11111111202000000002000000000000
0030300300dddd000000b0000b3b00000bbbbb0000bbbb000d5d00000ddddd0000dddd0000000004444400000545445031333131020200000002000000000000
0003333300d00d00000030000b3b0000b331c7b00b7c7cb00d5d0000d55d11d00d1111d0000000004cc700000c1c11c033333333202000000002000000000000
0037333300dddd00000030000053bbbb3331ccb00bc7c7b00015dddd555d11d00d1111d00000000041cc06677767767732323223202000000002000000000000
0033337300d00d000000b00000053333333311cbb3bbbb3b000155555555dd1dd5dddd5d76700006655576677666656722222222000000000002000000000000
0033337300dddd000000300000005555555533300333333000001111111155500555555006676665676766600767666022222222000000000002000000000000
0033773300d00d000000b00000000000006006000060060000000000005005000060060000565555555555500565565022222222000000000022000000000000
0003333000dddd000000d00000000000055555600050050000000000011111500050050000051551511515000051150022222222000000000022000000000000
00880880bbbbbbbb0000000000000000000000000004200000b3b300777777770000000099aaaaa9222222222222222222222222000000000022000000000000
087788883b333b3b0000999000000000000000000004200003b33b30c7ccc7c70000000099aaaaa9222222222222222222222222000000000022000000000000
08788888333333330099aa9007070070006ee000000420003b3bb3331cc1c1cc0000000099aaaaa9200000000000000000000002000000000022000000000000
088888783434344309aaa900077c77c00068ee7000042000b3bb33b3111c1c110002900099aaaaa9022222222222222222222220000000000022000000000000
08888878499949940099aa900cccccc0006888e0000420003b33b333c1c1c1cc0029990099aaaaa9022222222222222222222220000000000022000000000000
0088878099999999000099900cc1ccc000688000000440003b3b33b3111111110299a99099aaaaa9022202220222022222202220000000000022000000000000
0008780099999999000000000c11c1c0006000000042420033b3b33311111111299aaa9999aaaaa9020202020202020220202020000000000022000000000000
000080009999999900000000011111100060000004220000033333301111111199aaaaa999aaaaa9200000000000000000000002000000000022000000000000
0005550000ffff0000ffff0000ffff0000ffff0000000000006d5076766635500000000066777776000000000000000000000000000000000222000000000000
0005550000fcec00f0fcec0ff0fcec0000fcec0f00000000067cc5bbbbbbb3350000000066777776000000000000000000000000000000000222000000000000
0005550000feef0050feef0550feef0000feef05000000000dccc5bbbbbb33350000000066777776000000000000000000000000000000000222000000000000
00555550055dd550055dd550055dd550055dd5500000000066ddd6ddbbb333350005600066777776000000000000000000000000000000000222000000000000
05055505505555050055550000555505505555000000000066666653333333350056660066777776070700000777007007700070077700700222000000000000
05055505f0f55f0f00f55f0000f55ffffff55f0000000000d666d1533336d1310566766066777776007000000707007000700070007700700222000000000000
0005050000f00f0000f00f0000f000f00f000f0000000000055dd151155dd1505667776666777776070700000707070000700700070007000222000000000000
0005050000f00f0000f00f0000f0000000000f000000000000011100000111006677777666777776000000000777070007770700077707000222000000000000
0000c0000600600006006000060000000000000000000000006d5076766635500000000000000000000000000000000000000000000000000222000000000000
000c7c000060006000600060006000600000000000000000067cc5ccccccc1150000000000090000000000000000000000000000000000000222000000000000
00c7ccc006060606060000060000000600000000000000000dccc5cccccc11150a0a00a000aa00000a0000000000000000000000000000002222000000000000
00c7ccc0606660606000006060000000000000000000000066ddd6ddccc1111509aaa99000a9a09009aa00000000000000000000000000002222000000000000
0ccccccc060606060000000600000006000000000000000066666651111111150aa9aaa00aaaaaa00aa9a0a00777007007070070077700702222000000000000
0ccccc7c6000600060006000600060000000000000000000d666d1511116d115099899900989a8900a99aaa00077007007070070077000702222000000000000
00c777c00606060006060600000000000000000000000000055dd155555dd15009889890088a9890098999a00007070007770700000707002222000000000000
000ccc00006060606060606060006060000000555555555500011100000111000888888009889880088898900777070000070700077707002222000000000000
0000000b800080000010000000000000000000000000000000066666666600000000000000000000000000ffff00000000000000000000000000000000000000
000000b008080000017100000000000000000000000000000068888888886000000000000000000000000ffffff0000000000000000000000007777700000000
00000b0000800000017710000000000000000000000000000688888888888600000006600000000000000f0ff0f00000000eeeeeeeeee0000076666670000000
b000b0000808000001777100000000000000000000000000068887777788860000006d600000000000000ffffff0000000ee22222222ee000766ddd667000000
0b0b0000800080000177771000000000000000000000000000687007777860000006dd666660000000000ff00ff000000ee7eeeeeeee2ee00776666677777700
00b0000000000000017711000000000000000000000000000068777707786000006dddddddd60000000000ffff0000000ee7eeeeeeee2ee007d77777d7dddd70
00000000000000000011710000000000000000000000000000687000007860000006dd6666dd60000005055ff55050000ee7eeeeeeee2ee007ddddddd7dddd70
000000000000000000000000000000000000000000000000006877777778600000006d60006dd60000550555550555000ee7eeeeeeee2ee007ddddddd7dddd70
06666660000dfd00480004000002000000820000000000000068700000786000000006600006d60000550555550555000ee7eeeeeeee2ee007ddddddd7dddd70
677777660000dfd0848440000042000002048000000000000688777070788600000000000006d600005505555050550002ee77777777ee2007ddddddd7dddd70
6777767600000dfd02480000448844008408000000000000068887777788860000000000006dd60000ff05555050ff00022eeeeeeeeee22007dddd6d67dddd70
67776766d00000df0240000008240000044040000000000006888888888886000006666666dd6000000000000550ff00002222222222220007ddd6d6d7dddd70
67767676fd00000d048400000248000088200000000000000066888888866000006dddddddd60000006767ff0550ff00000222222222200007dd6d6d67777700
67676766dfd000000020400044040000040440000000000000006666666000000006666666600000007676ff0550ff0000000000000000000076d6d670000000
667676760dfd00000002000008000000000000000000000000000066600000000000000000000000000000000550ff0000000000000000000007777700000000
0666666000dfd0000000000000000000000000000000000000000068600000000000000000000000000005555550ff0000000000000000000000000000000000
0006d0000007777748000400000800880002002200000000000000000000000000000000000000000006dddd0000000000000000000000000000000000000000
00600d00007777778484400000488800804288000000000000000000000000000000000000000000006ccccc5000000000000005000000000000000000000000
00d00d0007777777084882804488440044888400000000000000000000000000000000000000000006cc777cc500000000000005000000000000000000000000
000dd0007777777708404402088400880824408800000000000000000000000000000000000000006cc7cccccc50000000000006000000000000000000000000
00dddd00777777770424040008488000088880000000000000000000000000000000066555000000dc7ccccc7c50000000000005000000000000000000000000
66dddddd777777770020404044040000448440000000000000000000000000000000065556000000dc7ccccccc50000000000055600000000000111110000000
6dddddd677777777000200000800008008004080000000000000000000000000000000ccc00000005c7ccccc7c50000000000056600000000111111111110000
dddd6d6677777777000200000000000000040400000000000000000000000000000007cccc0000005ccccccccc50000000000055600000000066111117700000
000000000000000000000000000000000000000000000000000000000000000000007cc0ccc0000005cccc7cc5000000000000506000000000666677777d0000
00000000000000000000000000000000000000000000000000000000000000000007c0cc0ccc0000005ccccc55600000000000606000000000666667777dd000
0000070000000000033333333333333330777777777777770000000000000000007ccc0cc0ccc0000005555505560000000005506600000000666677776ddd00
00007f77000000000333333333333333307ffffffffffff7000000000000000007cc0cc0cc0ccc00000000000055d000000088506880000000666667767ddd00
00077f7f700000000333333333333333307ffffffffffff7000000000000000007ccc0cc0cc0cc000000000000055d000008008080080000006666676760dd00
007f7f7f700000000333333333333333307ffffffffffff7000000000000000000cccc0cc0ccc00000000000000055d000080080800800000111667671110d00
007f7f7f700000000333333333333333307ffffffffffff70000000000000000000ccccccccc0000000000000000050000080080800800000000111110000000
077f7f7f700000000333333333333333307ffffffffffff700000000000000000000000000000000000000000000000000008800088000000000000000000000
7f7fffff700000000333333333333333307ffffffffffff700000000000000000000000000000000000000000000000000000000000000000000000000000000
7f7fffff770000000333333333333333307ffffffffffff700000000000000000000000000000000000000000000000000000000000000000000000000000000
7f7fffff7f7000000333333333333333307ffffffffffff700000000000000000000000000000000000000000000000000000000000000000000000000000000
7fffffff7f70000000333333333333333007fffffffffff700000000000000000000000000000000000000000000000000000000000000000000000000000000
7fffffffff70000000033333333333333007fffffffffff700000000000000000000000000000000000000000000000000000000000000000000000000000000
7fffffffff70000003033333333333333007fffffffffff700000000000000000000000000000000000000000000000000000000000000000000000000000000
7ffffffff700000000003333333333330007ffffffffff7000000000000000000000000000000000000000000000000000000000000000000000000000000000
7ffffffff7000000000333333333333300007fffffffff7000000000000000000000000000000000000000000000000000000000000000000000000000000000
7ffffffff7000000000333333333333300007fffffffff7000000000000000000000000000000000000000000000000000000000000000000000000000000000
07ffffff70000000000333333333333300007fffffffff7000000000000000000000000000000000000000000000000000000000000000000000000000000000
007ffff700000000000333333333003300007fffffffff7000000000000000000000000000000000000000000000000000000000000000000000000000000000
007ffff700000000033333333333033300007ffffffff70000000000000000000000000000000000000000000000000000000000000000000000000000000000
007ffff700000000033333333333033300007ffffffff70000000000000000000000000000000000000000000000000000000000000000000000000000000000
007ffff700000000003333333333303300007ffffffff70000000000000000000000000000000000000000000000000000000000000000000000000000000000
007ffff700000000003333333333333300007ffffffff70000000000000000000000000000000000000000000000000000000000000000000000000000000000
007ffff7000000000033333333333333000007fffffff70000000000000000000000000000000000000000000000000000000000000000000000000000000000
007ffff7000000000033333333333033000007fffffff70000000000000000000000000000000000000000000000000000000000000000000000000000000000
007ffff7000000000033333333333333000007fffffff70000000000000000000000000000000000000000000000000000000000000000000000000000000000
007ffff7000000000033333333333333000007fffffff70000000000000000000000000000000000000000000000000000000000000000000000000000000000
007ffff7000000000033333333333333000007ffffff700000000000000000000000000000000000000000000000000000000000000000000000000000000000
007fffff70000000003333333333333300007fffffff700000000000000000000000000000000000000000000000000000000000000000000000000000000000
007fffff70000000003333333333330000007f7fff7f700000000000000000000000000000000000000000000000000000000000000000000000000000000000
007fffff7000000000333333333300000007fff777ff700000000000000000000000000000000000000000000000000000000000000000000000000000000000
007fffff7000000000033333333300000007fffffff7000000000000000000000000000000000000000000000000000000000000000000000000000000000000
007fffff7000000000033333333300000007fffffff7000000000000000000000000000000000000000000000000000000000000000000000000000000000000
007fffff7000000000033333333300000007ffffffff700000000000000000000000000000000000000000000000000000000000000000000000000000000000
007fffff7000000000033333333330000007ffffffff700000000000000000000000000000000000000000000000000000000000000000000000000000000000
007fffff7000000000033333333333000007ffffffff700000000000000000000000000000000000000000000000000000000000000000000000000000000000
007fffff7000000000033333333303300007ffffffff700000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000033333333333300007ffffffff700000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000033333333303300007fffffff7000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000003333333333300007fffffff7000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00dddddddd00000000003033333333300007fffffff7000000000000000000000000000000000000000000000000000000000000000000000000000000000000
dddddddddd00000000033033333333300007fffffff7000000000000000000000000000000000000000000000000000000000000000000000000000000000000
dddddddddd000000000033333333333000007ffffff7000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0dddddddd0000000000003333333333000007ffffff7000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0dddddddd0000000000333333333333000007ffffff7000000000000000000000000000000000000000000000000000000000000000000000000000000000000
dddddddddd000000000333333333333000007ffffff7000000000000000000000000000000000000000000000000000000000000000000000000000000000000
dddddd6ddd000000000333333333333000007fffff70000000000000000000000000000000000000000000000000000000000000000000000000000000000000
ddddd6dddd000000000333333333333000007fffff70000000000000000000000000000000000000000000000000000000000000000000000000000000000000
ddddddddd00000000003333333333330000007ffff70000000000000000000000000000000000000000000000000000000000000000000000000000000000000
dddddddd0000000000000ddddddd0000000007ffff70000000000000000000000000000000000000000000000000000000000000000000000000000000000000
dd6ddddd000000000004444444444400000007ffff70000000000000000000000000000000000000000000000000000000000000000000000000000000000000
d6ddddd6d0000000000444fffff4440000007ffffff7000000000000000000000000000000000000000000000000000000000000000000000000000000000000
d0dddddddd00000000444f44444f44400007fffffff7000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000d6ddddd0000000044f44fff44f4400007fffffff7000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0dd6dddddd000000004444f444f444400007f7f7f7ff700000000000000000000000000000000000000000000000000000000000000000000000000000000000
dd6dddd6dd0000000044444444444440000777777777700000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000004444444444400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__label__
88888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888
88888ffffff882222228888888888888888888888888888888888888888888888888888888888888888228228888ff88ff888222822888888822888888228888
88888f8888f882888828888888888888888888888888888888888888888888888888888888888888882288822888ffffff888222822888882282888888222888
88888ffffff882888828888888888888888888888888888888888888888888888888888888888888882288822888f8ff8f888222888888228882888888288888
88888888888882888828888888888888888888888888888888888888888888888888888888888888882288822888ffffff888888222888228882888822288888
88888f8f8f88828888288888888888888888888888888888888888888888888888888888888888888822888228888ffff8888228222888882282888222288888
888888f8f8f8822222288888888888888888888888888888888888888888888888888888888888888882282288888f88f8888228222888888822888222888888
88888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555550000000000000000000000000000000000000000000000000000000000000000005555557777777777770000000000000000000000000000005555555
55555550000000000000000000000000000000000000000000000000000000000000000005555557000000000071111111112222222222333333333305555555
55555550000000000000000000000000000000000000000000000000000000000000000005555557000000000071111111112222222222333333333305555555
55555550000000000000000000000000000000000000000000000000000000000000000005555557000000000071111111112222222222333333333305555555
55555550000000000000000000000000000000000000000000000000000000000000000005555557000000000071111111112222222222333333333305555555
55555550000000000000000000000000000000000000000000000000000000000000000005555557000000000071111111112222222222333333333305555555
55555550000000000000000000000000000000000000000000000000000000000000000005555557000000000071111111112222222222333333333305555555
55555550000000000000000000000000000000000000000000000000000000000000000005555557000000000071111111112222222222333333333305555555
55555550000000000000000000000000000000000000000000000000000000000000000005555557000000000071111111112222222222333333333305555555
55555550000000000000000000000000000000000000000000000000000000000000000005555557000000000071111111112222222222333333333305555555
55555550000000000000000000000000000000000000000000000000000000000000000005555557777777777775555555556666666666777777777705555555
55555550000000000000000000000000000000000000000000000000000000000000000005555550444444444455555555556666666666777777777705555555
55555550000000000000000000000000000000000000000000000000000000000000000005555550444444444455555555556666666666777777777705555555
55555550000000000000000000000000000000000000000000000000000000000000000005555550444444444455555555556666666666777777777705555555
55555550000000000000000000000000000000000000000000000000000000000000000005555550444444444455555555556666666666777777777705555555
55555550000000000000000000000000000000000000000000000000000000000000000005555550444444444455555555556666666666777777777705555555
55555550000000000000000000000000000000000000000000000000000000000000000005555550444444444455555555556666666666777777777705555555
55555550000000000000000000000000000000000000000000000000000000000000000005555550444444444455555555556666666666777777777705555555
55555550000000000000000000000000000000000000000000000000000000000000000005555550444444444455555555556666666666777777777705555555
5555555000000000000000000000000000000000000000000000000000000000000000000555555088888888889999999999aaaaaaaaaabbbbbbbbbb05555555
5555555000000000000000000000000000000000000000000000000000000000000000000555555088888888889999999999aaaaaaaaaabbbbbbbbbb05555555
5555555000000000000000000000000000000000000000000000000000000000000000000555555088888888889999999999aaaaaaaaaabbbbbbbbbb05555555
5555555000000000000000000000000000000000000000000000000000000000000000000555555088888888889999999999aaaaaaaaaabbbbbbbbbb05555555
5555555000000000000000000000000000000000000000000000000000000000000000000555555088888888889999999999aaaaaaaaaabbbbbbbbbb05555555
5555555000000000000000000000000000000000000000000000000000000000000000000555555088888888889999999999aaaaaaaaaabbbbbbbbbb05555555
5555555000000000000000000000000000000000000000000000000000000000000000000555555088888888889999999999aaaaaaaaaabbbbbbbbbb05555555
5555555000000000000000000000000000000000000000000000000000000000000000000555555088888888889999999999aaaaaaaaaabbbbbbbbbb05555555
5555555000000000000000000000000000000000000000000000000000000000000000000555555088888888889999999999aaaaaaaaaabbbbbbbbbb05555555
55555550000000000000000000000000000000000000000000000000000000000000000005555550ccccccccccddddddddddeeeeeeeeeeffffffffff05555555
55555550000000000000000000000000000000000000000000000000000000000000000005555550ccccccccccddddddddddeeeeeeeeeeffffffffff05555555
55555550000000000000000000000000000000000000000000000000000000000000000005555550ccccccccccddddddddddeeeeeeeeeeffffffffff05555555
55555550000000000000000000000000000000000000000000000000000000000000000005555550ccccccccccddddddddddeeeeeeeeeeffffffffff05555555
55555550000000000000000000000000000000000000000000000000000000000000000005555550ccccccccccddddddddddeeeeeeeeeeffffffffff05555555
55555550000000000000000000000000000000000000000000000000000000000000000005555550ccccccccccddddddddddeeeeeeeeeeffffffffff05555555
55555550000000000000000000000000000000000000000000000000000000000000000005555550ccccccccccddddddddddeeeeeeeeeeffffffffff05555555
55555550000000000000000000000000000000000000000000000000000000000000000005555550ccccccccccddddddddddeeeeeeeeeeffffffffff05555555
55555550000000000000000000000000000000000000000000000000000000000000000005555550ccccccccccddddddddddeeeeeeeeeeffffffffff05555555
55555550000000000000000000000000000000000000000000000000000000000000000005555550000000000000000000000000000000000000000005555555
55555550000000000000000000000000000000000000000000000000000000000000000005555555555555555555555555555555555555555555555555555555
55555550000000000000000000000000000000000000000000000000000000000000000005555555555555555555555555555555555555555555555555555555
55555550000000000000000000000000000000000000000000000000000000000000000005555555555555555555555555555555555555555555555555555555
55555550000000000000000000000000000000000000000000000000000000000000000005555556666666555556667655555555555555555555555555555555
55555550000000000000000000000000000000000000000000000000000000000000000005555556666666555555666555555555555555555555555555555555
5555555000000000000000000000000000000000000000000000000000000000000000000555555666666655555556dddddddddddddddddddddddd5555555555
555555500000000000000000000000000000000000000000000000000000000000000000055555566606665555555655555555555555555555555d5555555555
55555550000000000000000000000000000000000000000000000000000000000000000005555556666666555555576666666d6666666d666666655555555555
55555550000000000000000000000000000000000000000000000000000000000000000005555556666666555555555555555555555555555555555555555555
55555550000000000000000000000000000000000000000000000000000000000000000005555556666666555555555555555555555555555555555555555555
55555550000000000000000000000000000000000000000000000000000000000000000005555555555555555555555555555555555555555555555555555555
55555550000000000000000000000000000000000000000000000000000000000000000005555555555555555555555555555555555555555555555555555555
55555550000000000000000000000000000000000000000000000000000000000000000005555556665666555555555555566676555555555555555555555555
55555550000000000000000000000000000000000000000000000000000000000000000005555556555556555555555555556665555555555555555555555555
5555555000000000000000000000000000000000000000000000000000000000000000000555555555555555555555ddddddd6dddddddddddddddd5555555555
555555500000000000000000000000000000000000000000000000000000000000000000055555565555565555555655555556555555555555555d5555555555
55555550000000000000000000000000000000000000000000000000000000000000000005555556665666555555576666666d6666666d666666655555555555
55555550000000000000000000000000000000000000000000000000000000000000000005555555555555555555555555555555555555555555555555555555
55555550000000000000000000000000000000000000000000000000000000000000000005555555555555555555555555555555555555555555555555555555
55555550000000000000000000000000000000000000000000000000000000000000000005555555555555555555555555555555555555555555555555555555
55555550000000000000000000000000000000000000000000000000000000000000000005555555555555555555555555555555555555555555555555555555
55555550000000000000000000000000000000000000000000000000000000000000000005555550005550005550005550005550005550005550005550005555
555555500000000000000000000000000000000000000000000000000000000000000000055555011d05011d05011d05011d05011d05011d05011d05011d0555
55555550000000000000000000000000000000000000000000000000000000000000000005555501110501110501110501110501110501110501110501110555
55555550000000000000000000000000000000000000000000000000000000000000000005555501110501110501110501110501110501110501110501110555
55555550000000000000000000000000000000000000000000000000000000000000000005555550005550005550005550005550005550005550005550005555
55555550000000000000000000000000000000000000000000000000000000000000000005555555555555555555555555555555555555555555555555555555
55555550000000000000000000000000000000000000000000000000000000000000000005555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
5555555555555d5555555ddd55555d5d5d5d55555d5d555555555d55555555555555550000000055555555555555555555555555555555555555555555555555
555555555555ddd555555ddd55555555555555555d5d5d55555555d5555575555555550000000056666666666666555555555555577777555555555555555555
55555555555ddddd55555ddd55555d55555d55555d5d5d555555555d555557555555550000000056ddd6ddd6dd6655555666665577dd77755666665556666655
5555555555ddddd555555ddd55555555555555555ddddd5555ddddddd55555755555550000000056d6d666d66d66555566ddd665777d777566ddd66566ddd665
555555555d5ddd55555ddddddd555d55555d555d5ddddd555d5ddddd555555575555550000000056d6d666d66d66555566d6d665777d77756666d665666dd665
555555555d55d555555d55555d55555555555555dddddd555d55ddd5555555557555550000000056d6d666d66d66555566d6d66577ddd77566d666656666d665
555555555ddd5555555ddddddd555d5d5d5d555555ddd5555d555d55555555555555550000000056ddd666d6ddd6555566ddd6657777777566ddd66566ddd665
55555555555555555555555555555555555555555555555555555555555555555555550000000056666666666666555566666665777777756666666566666665
555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555ddddddd566666665ddddddd5ddddddd5
00000000000000000000000000000000000000000000000000000007777777777777777770000000000000000000000000000000000000000000000000000000
0000000b80008000000777770000000000000000000000000000000700000000000000007006d000000000ffff00000000000000000000000000000000000000
000000b0080800000077777700000000000000000000000000000007000000000000000070600d0000000ffffff0000000000000000000000007777700000000
00000b00008000000777777700000000000000000000000000000007000000000000000070d00d0000000f0ff0f00000000eeeeeeeeee0000076666670000000
b000b0000808000077777777000000000000000000000000000000070000000000000000700dd00000000ffffff0000000ee22222222ee000766ddd667000000
0b0b0000800080007777777700000000000000000000000000000007000000000000000070dddd0000000ff00ff000000ee7eeeeeeee2ee00776666677777700
00b00000000000007777777700000000000000000000000000000007000000000000000070dddddd000000ffff0000000ee7eeeeeeee2ee007d77777d7dddd70
00000000000000007777777700000000000000000000000000000007000000000000000070ddddd60005055ff55050000ee7eeeeeeee2ee007ddddddd7dddd70
00000000000000007777777700000000000000000000000000000007000000000000000070dd6d6600550555550555000ee7eeeeeeee2ee007ddddddd7dddd70
06666660000dfd00480004000008000000800000001000000000000700000000000000007000000000550555550555000ee7eeeeeeee2ee007ddddddd7dddd70
677777660000dfd08484400000480000080480000171000000000007000000000000000070000000005505555050550002ee77777777ee2007ddddddd7dddd70
6777767600000dfd084800004488440084080000017710000000000700000000000000007000000000ff05555050ff00022eeeeeeeeee22007dddd6d67dddd70
67776766d00000df0840000008840000044040000177710000000007000000000001000070000000000000000550ff00002222222222220007ddd6d6d7dddd70
67767676fd00000d0484000008480000888000000177771000000007000000000017100070000000005555ff0550ff00000222222222200007dd6d6d67777700
67676766dfd000000080400044040000040440000177110000000007000000000017710070000000005555ff0550ff0000000000000000000076d6d670000000
667676760dfd00000008000008000000000000000011710000000007000000000017771070000000000000000550ff0000000000000000000007777700000000
0666666000dfd0000000000000000000000000000000000000000007000000000017777170000000000005555550ff0000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000077777777777177117700000000006dddd0000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000001171000000000006ccccc5000000000000005000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000006cc777cc500000000000005000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000006cc7cccccc50000000000006000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000066555000000dc7ccccc7c50000000000005000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000065556000000dc7ccccccc50000000000055600000000000111110000000
0000000000000000000000000000000000000000000000000000000000000000000000ccc00000005c7ccccc7c50000000000056600000000111111111110000
0000000000000000000000000000000000000000000000000000000000000000000007cccc0000005ccccccccc50000000000055600000000066111117700000
000000000000000000000000000000000000000000000000000000000000000000007cc0ccc0000005cccc7cc5000000000000506000000000666677777d0000
00000000000000000000000000000000000000000000000000000000000000000007c0cc0ccc0000005ccccc55600000000000606000000000666667777dd000
0000000000000000000000000000000000000000000000000000000000000000007ccc0cc0ccc0000005555505560000000005506600000000666677776ddd00
000000000000000000000000000000000000000000000000000000000000000007cc0cc0cc0ccc00000000000055d000000088506880000000666667767ddd00
000000007000000000000000700000000000000000000000000000000000000007ccc0cc0cc0cc000000000000055d000008008080080000006666676760dd00
000000070770000000000007f77000000000000000000000000000000000000000cccc0cc0ccc00000000000000055d000080080800800000111667671110d00
000000770707000000000077f7f7000000000000000000000000000000000000000ccccccccc0000000000000000050000080080800800000000111110000000
0000070707070000000007f7f7f70000000000000000000000000000000000000000000000000000000000000000000000008800088000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
88888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888
88888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888
88888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888
88888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888
88888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888
88888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888
88888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888

__gff__
0000000000000000000000000000000000000000000000000000000000000000000101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000022480022
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

