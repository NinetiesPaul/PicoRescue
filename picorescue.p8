pico-8 cartridge // http://www.pico-8.com
version 32
__lua__
function _init()

player = {
	["x"] = 0,
	["y"] = 64,
	["mv_speed"] = 1,
	["on_mission"] = false,
	["speed"] = 0,
	["speed_dir"] = "left"
}

btn_pressed = false

screen = {
	1, -- start
	2, -- rotor
	3, -- human
	4 -- airplane
}

curr_screen = screen[3]

end

function _draw()
	cls()
	
	print(curr_screen,0,0,11)
	
	if (curr_screen == 2) then
		spr(00,player.x,player.y)
	end
	
	if (curr_screen == 3) then
		spr(00,player.x,player.y)
	end
	
	print(player.x.." "..player.speed,64,0,11)
	
	print(btn_pressed,0,120,11)
	print(player.speed_dir,32,120,11)
end

function _update()
	
	if (curr_screen == 1) choose_mission()
	if (curr_screen == 2) move_rotor()
	if (curr_screen == 3) move_human()

	upd_rotor_mvmt()
	
 btn_pressed = not (btn() == 0)

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
			if player.speed > 0 then
				player.speed-=0.10
				player.x-=player.speed
			else
				player.speed_dir = "right"
			end
		else
			if (player.speed <= 2) player.speed += 0.05
			player.x+=player.speed
			player.speed_dir = "right"
		end
	end
	
	if btn(0) then
		if player.speed_dir == "right" then
			if player.speed > 0 then
				player.speed-=0.10
				player.x+=player.speed
			else
				player.speed_dir = "left"
			end
		else
			if (player.speed <= 2) player.speed += 0.05
			player.x-=player.speed
			player.speed_dir = "left"
		end
	end
	
	--if (btn(3)	and player.speed < 2) player.y+=player.mv_speed
	--if (btn(2)	and player.speed < 2) player.y-=player.mv_speed
end

function upd_rotor_mvmt()
	if btn_pressed == false then
			if (player.speed > 0) player.speed -= 0.05				
			if (player.speed_dir == "right") player.x+=player.speed
			if (player.speed_dir == "left") player.x-=player.speed
	end
	
	if (player.speed > 2) player.speed = 2
	if (player.speed < 0) player.speed = 0
end
-->8
-- navigation

function choose_mission()

	

end
__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
