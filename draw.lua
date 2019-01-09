local polyamonds = require "polyamonds"
local utils = require "utils"

local copy = utils.copy
local equal = utils.equal

local TRI_HEIGHT = math.sin(math.pi / 3)

local function to_cartesian(x,y)

	local u,v

	u = 1 * x + 0.5        * y
	v = 0 * x + TRI_HEIGHT * y

	return u,v
end

local function draw_triangle(t, ox, oy, margin)

	local res = {}
	table.insert(res, '<polygon points="')

	for _,p in ipairs(t) do
		table.insert(res, tostring(p[1] - ox + margin))
		table.insert(res, ',')
		table.insert(res, tostring(p[2] - oy + margin))
		table.insert(res, ' ')
	end

	table.insert(res, '"/>')

	return table.concat(res)
end

local function draw_shape(s)
	
	local scale = 30
	
	-- Bounding box

	local s = copy(s)
	local minx,miny = math.huge, math.huge
	local maxx,maxy = -math.huge, -math.huge

	for _,t in ipairs(s) do
		
		polyamonds.uncanonize_triangle(t)	
		for i,p in ipairs(t) do
			
			p[1],p[2] = to_cartesian(p[1],p[2])
			p[1] = p[1] * scale
			p[2] = p[2] * scale
			
			
			minx = math.min(minx, p[1])
			miny = math.min(miny, p[2])
			maxx = math.max(maxx, p[1])
			maxy = math.max(maxy, p[2])
		end
	end
	
	-- Draw everything shifted to positive values
	
	local res = {}
	
	local margin = scale / 2
	local w = maxx - minx + 2 * margin
	local h = maxy - miny + 2 * margin

	table.insert(res, string.format('<svg height="%f" width="%f">', h, w))
	table.insert(res, '<g style="fill:skyblue;stroke:black;stroke-width:1">')

	for _,t in ipairs(s) do
		table.insert(res, draw_triangle(t, minx, miny, margin))		
	end

	table.insert(res, '</g>')
	table.insert(res, '</svg>')

	return table.concat(res, "\n")
end


return
{
	draw_shape = draw_shape
}