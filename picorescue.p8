pico-8 cartridge // http://www.pico-8.com
version 32
__lua__
function _init()
	player_strt_y = 0
	player_strt_x = 64
	player = {
		["x"] = player_strt_x,
		["px"] = player_strt_x,
		["y"] = player_strt_y,
		["py"] = player_strt_y,
		["mv_speed"] = 1,
		["on_mission"] = false,
		["speed_x"] = 0,
		["speed_y"] = 0,
		["mvn_dir"] = null,
		["facing"] = "right",
		["rotor_spr"] = 04,
		["civ_range"] = false,
		["civ_pkup"] = false,
		["water_cpct"] = 2,
		["rotor_health"] = 10,
		["top_speed_x"] = 2,
		["top_speed_y"] = 2,
	}
	
	water_drops={}
	
	screen = {
		1, -- start
		2, -- rotor
		3, -- human
		4 -- airplane
	}
	
	curr_screen = screen[2]
	counter = 0
	
	btn_pressed = false
	mvn_y = false
	mvn_x = false
	left_btn = false
	right_btn = false
	down_btn = false
	up_btn = false
	civ_x = 90
	civ_y = 120
	
	fire_x = 70
	fire_y = 120
	smoke_max_h = 3
	smoke_h = 0
	smoke_max_w = 3
	smoke_w = 0
	smoke_x1 = -5
	smoke_y1 = -5
	smoke_x2 = -5
	smoke_y2 = -5
	ladder=0
end

function _draw()
	cls()

	if (curr_screen == 2) then
		flip_spr = (player.facing == "right") and true or false
		spr_x = (player.facing == "right") and player.x-8 or player.x
		tail_pos = (player.facing == "right") and player.x or player.x-8
		
		spr(player.rotor_spr,spr_x,player.y,1,1,flip_spr)
		if (player.facing != false) spr(03,tail_pos,player.y,1,1,flip_spr)
	end

	if (curr_screen == 3) then
		spr(00,fire_x,player.y)
	end

	spr(02,civ_x,civ_y)
	spr(17,fire_x,fire_y)

	for i = 1, ladder do
		ladder_pos = (player.facing == "left") and fire_x-8 or fire_x
		spr(1,ladder_pos,player.y+i*8)
	end
  
	for i = 1, smoke_h do
		spr(18,fire_x,fire_y-i*8)
	end
	
	for i = 1, smoke_w do
		spr(18,fire_x-i*8,fire_y-24)
		spr(18,fire_x+i*8,fire_y-24)
	end
	
 for i = 0, player.rotor_health do
		rectfill(0,0,player.rotor_health,4, 11)
	end
		
	foreach(water_drops,draw_water)
end

function _update()
	counter+=1
	
	--if (curr_screen == 1) choose_mission()
	if (curr_screen == 2) move_rotor()
	if (curr_screen == 3) move_human()

	-- rotor movement
	upd_rotor_mvmt()
        
 btn_pressed = (btn(1)) or (btn(2)) or (btn(0)) or (btn(3))
	mvn_y = btn(2) or btn(3)
	mvn_x = btn(0) or btn(1)
	right_btn = btn(0)
	left_btn = btn(1)
	up_btn = btn(2)
	down_btn = btn(3)
	
	-- civilian 
	player.civ_range = civ_range()
	player.civ_pkup = civ_pkup()
	move_civ()
	
	-- water smoke and fire
	upd_ladder()
	upd_fire()
 on_smoke()
	
	foreach(water_drops,move_water)
end
-->8
-- movement

function move_human()
	if (btn(1)) fire_x+=player.mv_speed
	if (btn(0)) fire_x-=player.mv_speed
	if (btn(3)) player.y+=player.mv_speed
	if (btn(2)) player.y-=player.mv_speed
end

function move_rotor()
	if right_btn then
		if player.px > fire_x then
			if player.speed_x > 0 then
				player.speed_x -= 0.035
				fire_x -= player.speed_x
				player.facing = false
				player.rotor_spr = 05
			end
		else
			player.rotor_spr = 04
			player.mvn_dir = "right"
			player.facing = "right"
			if (player.speed_x <= player.top_speed_x) player.speed_x += 0.025
			player.px = fire_x
			fire_x += player.speed_x
		end
	end
	
	if left_btn then
		if player.px < fire_x then
			if player.speed_x > 0 then
				player.speed_x -= 0.035
				fire_x += player.speed_x
				player.facing = false
				player.rotor_spr = 05
			end
		else
			player.rotor_spr = 04
			player.mvn_dir = "left"
			player.facing = "left"
			if (player.speed_x <= player.top_speed_x) player.speed_x += 0.025
			player.px = fire_x
			fire_x -= player.speed_x
		end
	end
	
	if up_btn	then
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
	
	if (btnp(4)) drop_water()
end


function upd_rotor_mvmt()
 if player.px < fire_x and mvn_x == false then
  player.px = fire_x
  player.speed_x -= 0.015
  fire_x += player.speed_x
 end

 if player.px > fire_x and mvn_x == false then
  player.px = fire_x
  player.speed_x -= 0.015
  fire_x -= player.speed_x
 end

 if player.py < player.y and mvn_y == false then
  player.py = player.y
  player.speed_y -= 0.015
  player.y += player.speed_y
 end

 if player.py > player.y and mvn_y == false then
  player.py = player.y
  player.speed_y -= 0.015
  player.y -= player.speed_y
 end
	
	if (btn_pressed == false) player.mvn_dir = false

	if player.speed_x < 0 then
		player.speed_x = 0
		player.px = fire_x
	end
	
	if player.speed_y < 0 then
		player.speed_y = 0
		player.py = player.y
	end
end
-->8
-- civ fire smoke water

function civ_range()
	status = false
	
	if
		fire_x >= civ_x-24 and
		fire_x <= civ_x+24 and
		player.y+24 >= civ_y and
		player.y+24 <= civ_y+7 then
		status = true
	end
	
	return status
end

function civ_pkup()
	status = false
	
	if
		fire_x >= civ_x-1 and
		fire_x <= civ_x+1 and
		player.y+24 >= civ_y and
		player.y+24 <= civ_y+7 then
		status = true
	end	
	
	return status
end

function move_civ()
	if player.civ_range then
		if (fire_x <= civ_x) civ_x -= 0.25
		if (fire_x >= civ_x) civ_x += 0.25
	end
end

function upd_ladder()
	if player.civ_pkup then
		if counter%30==0 and ladder < 3 then
			ladder+=1
		end
	else	
		if counter%30==0 and ladder > 0 then
			ladder-=1
		end
	end
end

function upd_fire()
	if counter%15==0 and smoke_h < smoke_max_h then
		smoke_h+=1
	end
	
	if smoke_h == smoke_max_h then
		if counter%15==0 and smoke_w < smoke_max_w then
			smoke_w+=1

			smoke_x1 = fire_x-smoke_w*8
			smoke_y1 = fire_y-smoke_h*8-2
			smoke_x2 = fire_x+smoke_w*8+8
			smoke_y2 = fire_y-16
		end
	end
end

function drop_water()
	local water = {}
	water.x = fire_x
	water.y = player.y + 8
	water.speed = 0
	add(water_drops,water)
end

function draw_water(water)
	spr(19,water.x,water.y,1,1,false,true)
end

function move_water(water)
 if (water.speed < 2) water.speed += 0.15
 water.y += water.speed
 
 if
 	water.x >= fire_x-2 and
 	water.x <= fire_x+10 and
 	water.y >= fire_y and
 	water.y <= fire_y+8
	then
		fire_x = -5
		fire_y = -5
	end
 
 if (water .y >= 128) del(water_drops,water)
end

function on_smoke()
	if
		fire_x >= smoke_x1 and
		fire_x <= smoke_x2 and
		player.y >= smoke_y1 and
		player.y <= smoke_y2
	then
		if (counter%30==0) player.rotor_health -= 1
	end
end
-->8
--[[

map(0,0,fire_x-i*8,fire_y-24,1,1)
map(0,0,fire_x+i*8,fire_y-24,1,1)
	
]]--
__gfx__
0000000000d00d0000ffff0000b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000dddd0000fcec000b3b0000bbbbbb0000bbbb0000000000000000000000000000000000000000000000000000000000000000000000000000000000
0070070000d00d0000feef000b3b000b3331c7b00b7777b000000000000000000000000000000000000000000000000000000000000000000000000000000000
0007700000dddd00055dd5500053bbb33331ccb00bccccb000000000000000000000000000000000000000000000000000000000000000000000000000000000
0007700000d00d005055550500053333333311cbb311113b00000000000000000000000000000000000000000000000000000000000000000000000000000000
0070070000dddd00f0f55f0f00005555555533300333333000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000d00d0000f00f0000000000006006000060060000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000dddd0000f00f0000000000055555600050050000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000600600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000060006000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
008008000a0a00a00606060607070070000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0008800009aaa99060666060077c77c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000880000aa9aaa0060606060cccccc0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0080080009989990600060000cc1ccc0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000009889890060606000c11c1c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000088888800060606001111110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__label__
bb00bbb0bbb00000b000b000bb00bbb00000b000bb000000bbb0bbb0bbb0bbb00000bbb00000bbb0000000000000000000000000000000000000000000000000
0b00b000b0b00000b000b0000b0000b00000b0000b000000b0b0b000b0b000b0000000b00000b0b0000000000000000000000000000000000000000000000000
0b00bbb0b0b00000bbb0bbb00b0000b00000bbb00b000000b0b0bbb0b0b000b00000bbb00000b0b0000000000000000000000000000000000000000000000000
0b0000b0b0b00000b0b0b0b00b0000b00000b0b00b000000b0b000b0b0b000b00000b0000000b0b0000000000000000000000000000000000000000000000000
bbb0bbb0bbb00b00bbb0bbb0bbb000b00000bbb0bbb00b00bbb0bbb0bbb000b00000bbb00000bbb0000000000000000000000000000000000000000000000000
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
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
bb00bb00bbb0b0000bb00000bbb0bbb0b0b0bbb000000000b0b0bbb00000000000000000bbb0bbb0b0b0bbb000000000bbb0bbb0b0b0bbb00000000000000000
b000b0b00b00b00000b000000b00b0b0b0b0b00000000000b0b0b0b000000000000000000b00b0b0b0b0b000000000000b00b0b0b0b0b0000000000000000000
b000b0b00b00b00000b000000b00bb00b0b0bb0000000000b0b0bbb000000000000000000b00bb00b0b0bb00000000000b00bb00b0b0bb000000000000000000
b000b0b00b00b00000b000000b00b0b0b0b0b00000000000b0b0b00000000000000000000b00b0b0b0b0b000000000000b00b0b0b0b0b0000000000000000000
bb00b0b0bbb0bbb00bb000000b00b0b00bb0bbb0000000000bb0b00000000000000000000b00b0b00bb0bbb0000000000b00b0b00bb0bbb00000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000

__gff__
0000010000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
