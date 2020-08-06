--[[
	module to handle

	generating an indexed image from a given rgb input and rgb palette
	drawing an indexed image with a rgb palette (can be different)

	note: not optimal, by any stretch of the imagination!
		however, it does show the process of converting an image into
		an efficient format 

		possible improvements
			- support 2d palettes
			- remove push/pop and allow setting a global palette
			- improve auto-batching
]]

local palette_shader = love.graphics.newShader([[
uniform Image palette;
uniform float palette_size;
vec4 effect(vec4 c, Image t, vec2 uv, vec2 px) {
	float idx = Texel(t, uv).r;
	vec2 pal_uv = vec2(idx + (0.5 / palette_size), 0.5);
	return Texel(palette, pal_uv);
} 
]])

local function clamp01(v)
	return math.max(0, math.min(v, 1))
end

local function encode_rgb(r, g, b)
	return 
		math.floor(clamp01(r) * 255)
		+ math.floor(clamp01(g) * 255) * 255
		+ math.floor(clamp01(b) * 255) * 255 * 255
end

local palette_image = {}
palette_image._mt = {__index = palette_image}

function palette_image:new(rgb_image_data, rgb_palette_data)
	local w, h = rgb_image_data:getDimensions()
	local indexed_id = love.image.newImageData(w, h, "r8")
	local pw = rgb_palette_data:getWidth()
	--generate palette to colour mapping
	local col_to_pal = {}
	for i = 0, pw - 1 do
		local pal_rgb = encode_rgb(rgb_palette_data:getPixel(i, 0))
		col_to_pal[pal_rgb] = i
	end
	--remap to indexed image data
	indexed_id:mapPixel(function(x, y)
		local i_rgb = encode_rgb(rgb_image_data:getPixel(x, y))
		local i = col_to_pal[i_rgb] / (pw - 1)
		return i, 0, 0, 1
	end)
	return setmetatable({
		image = love.graphics.newImage(indexed_id)
	}, self._mt)
end

function palette_image:draw(palette_image)
	love.graphics.push("all")
	palette_shader:send("palette", palette_image)
	palette_shader:send("palette_size", palette_image:getWidth())
	love.graphics.setShader(palette_shader)
	love.graphics.draw(self.image)
	love.graphics.pop()
end

return palette_image
