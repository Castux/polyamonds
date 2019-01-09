local utils = require "utils"
local polyamonds = require "polyamonds"

local function parallelogram_triangles()

	local tris = {}
	
	for x = 0,8 do
		table.insert(tris, {x, 0, "up"})
		
		for y = 1,3 do
			table.insert(tris, {x, y, "down"})			
			table.insert(tris, {x, y, "up"})			
		end
		
		table.insert(tris, {x, 4, "down"})
	end
	
	
	return tris
end

local function triangles_to_puzzle(tris)
	
	local points = {}
	
	for _,t in ipairs(tris) do
		
		local t = utils.copy(t)
		polyamonds.uncanonize_triangle(t)
		
		for _,p in ipairs(t) do
			points[p[1]..":"..p[2]] = p
		end
	end
	
	local res = {}
	for _,p in pairs(points) do
		table.insert(res, p)
	end
	
	return
	{
		triangles = tris,
		points = res
	}
end

local parallelogram = triangles_to_puzzle(parallelogram_triangles())

return { parallelogram }