--[[
	palette rendering example
]]

--pixelated
love.graphics.setDefaultFilter("nearest", "nearest")

local palette_image = require("palette_image")

local pal_id = love.image.newImageData("palette.png")
local pal_img = love.graphics.newImage(pal_id)

local test_img = palette_image:new(love.image.newImageData("out.png"), pal_id)

--palette cycling
local pal_cycle = {
	pal_img,
	love.graphics.newImage("palette_alt1.png"),
	love.graphics.newImage("palette_alt2.png"),
	love.graphics.newImage("palette_alt3.png"),
}
local pal_cycle_timer = 0
function love.update(dt)
	pal_cycle_timer = pal_cycle_timer + dt
	if pal_cycle_timer > 1 then
		--cycle palette images
		table.insert(pal_cycle, table.remove(pal_cycle, 1))
		pal_cycle_timer = 0
	end
end

function love.draw()
	--(positioning)
	love.graphics.translate(10, 10)
	love.graphics.scale(4, 4)
	--draw the coloured data
	test_img:draw(pal_cycle[1])
	--draw the raw texture so you can see what it looks like
	local raw_img = test_img.image
	love.graphics.translate(0, raw_img:getHeight() + 2)
	love.graphics.draw(raw_img)
end

--restart
function love.keypressed(k)
	if love.keyboard.isDown("lctrl") then
		if k == "q" then
			love.event.quit()
		elseif k == "r" then
			love.event.quit("restart")
		end
	end
end
