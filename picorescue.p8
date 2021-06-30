pico-8 cartridge // http://www.pico-8.com
version 32
__lua__
function _init()

player_strt_y = 64
player = {
	["x"] = 0,
	["px"] = 0,
	["y"] = player_strt_y,
	["py"] = 0,
	["mv_speed"] = 1,
	["on_mission"] = false,
	["speed_x"] = 0,
	["speed_y"] = 0,
	["speed_dir"] = null,
	["mvn_dir"] = null
}

screen = {
	1, -- start
	2, -- rotor
	3, -- human
	4 -- airplane
}

curr_screen = screen[2]
btn_pressed = false
mvn_y = false
mvn_x = false

end

function _draw()
	cls()
		
	if (curr_screen == 2) then
		spr(00,player.x,player.y)
	end
	
	if (curr_screen == 3) then
		spr(00,player.x,player.y)
	end
	
	print(player.x.." "..player.y.." "..player.speed_x.." "..player.speed_y,0,0,11)
		
	print(player.mvn_dir,0,120,11)	
	print(btn_pressed,24,120,11)
	print(player.speed_dir,48,120,11)
	print(mvn_y,72,120,11)
end

function _update()
	
	if (curr_screen == 1) choose_mission()
	if (curr_screen == 2) move_rotor()
	if (curr_screen == 3) move_human()

	upd_rotor_mvmt()
	
 btn_pressed = not (btn() == 0)

	mvn_y = btn(2) or btn(3)
	mvn_x = btn(0) or btn(1)
end
-->8
-- movement

function move_human()
	if (btn(1)) player.x+=player.mv_speed
	if (btn(0)) player.x-=player.mv_speed
	if (btn(3)) player.y+=player.mv_speed
	if (btn(2)) player.y-=player.mv_speed
end

function move_rotor()
	if btn(1)  then
		if player.speed_dir == "left" then
			if player.speed_x > 0 then
				player.speed_x-=0.10
				player.x-=player.speed_x
			else
				player.speed_dir = "right"
			end
		else
			if (player.speed_x <= 2) player.speed_x += 0.05
			player.px=player.x
			player.x+=player.speed_x
			player.speed_dir = "right"
		end
	end
	
	if btn(0) then
		if player.speed_dir == "right" then
			if player.speed_x > 0 then
				player.speed_x-=0.10
				player.x+=player.speed_x
			else
				player.speed_dir = "left"
			end
		else
			if (player.speed_x <= 2) player.speed_x += 0.05
			player.px=player.x
			player.x-=player.speed_x
			player.speed_dir = "left"
		end
	end
	
	if btn(3)	then
		if player.speed_dir == "up" then
			if player.speed_y > 0 then
				player.speed_y-=0.10
				player.y-=player.speed_y
			else
				player.speed_dir = "down"
			end
		else
			if (player.speed_y <= 2) player.speed_y += 0.05
		 player.py = player.y
		 player.y += player.speed_y
		 player.speed_dir = "down"
	 end
	end
	
	if btn(2)	then
		if player.speed_dir == "down" then
			if player.speed_y > 0 then
				player.speed_y-=0.10
				player.y+=player.speed_y
			else
				player.speed_dir = "up"
			end
		else
			if (player.speed_y <= 2) player.speed_y += 0.05
		 player.py = player.y
		 player.y -= player.speed_y
		 player.speed_dir = "up"
		end
	end
end

function upd_rotor_mvmt()
	if btn_pressed == false then
		if player.speed_x > 0 then
			player.speed_x -= 0.025
			if (player.speed_dir == "right") player.x+=player.speed_x
			if (player.speed_dir == "left") player.x-=player.speed_x
		end
		if player.speed_y > 0 then
			player.speed_y -= 0.025
			if (player.speed_dir == "down") player.y+=player.speed_y
			if (player.speed_dir == "up") player.y-=player.speed_y
		end
	end
	
	if mvn_y then
		if player.speed_x > 0 then
			player.speed_x -= 0.05
			if (player.px>player.x) player.x-=player.speed_x
			if (player.px<player.x) player.x+=player.speed_x
		end
	end
	
	if mvn_x then
		if player.speed_y > 0 then
			player.speed_y -= 0.05
			if (player.py>player.y) player.y-=player.speed_y
			if (player.py<player.y) player.y+=player.speed_y
		end
	end
	
	if (player.speed_x > 2) player.speed_x = 2
	if (player.speed_y > 2) player.speed_y = 2
	if (player.speed_x < 0) player.speed_x = 0
	if (player.speed_y < 0) player.speed_y = 0
end
-->8
-- menu navigation

function choose_mission()

	

end
__gfx__
0000000000d000d000ffff0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000ddddd000fcec0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0070070000d000d000feef0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0007700000ddddd0055dd55000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0007700000d000d05055550500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0070070000ddddd0f0f55f0f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000d000d000f00f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000ddddd000f00f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00800800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00088000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00088000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00800800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__gff__
0000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
