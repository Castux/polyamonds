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

local parallelogram = parallelogram_triangles()

return { parallelogram }