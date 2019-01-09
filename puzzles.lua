local utils = require "utils"
local polyamonds = require "polyamonds"

local function parallelogram()

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

local function trihex()

	local tris = {

		-- Small trapeze

		{0, 0, "up"},
		{1, 0, "up"},
		{2, 0, "up"},
		{3, 0, "up"},

		{0, 1, "down"},
		{1, 1, "down"},
		{2, 1, "down"},

		{0, 1, "up"},
		{1, 1, "up"},
		{2, 1, "up"},

		{0, 2, "down"},
		{1, 2, "down"}
	}


	-- Duplicate and flip down horizontally

	local tmp = {}

	for i,v in ipairs(tris) do
		table.insert(tmp, {v[1] + v[2], -v[2], v[3] == "up" and "down" or "up"})
	end

	for i,v in ipairs(tmp) do
		table.insert(tris, v)
	end
	
	-- Rotate by 60 twice

	tmp = utils.copy(tris)
	for i,v in ipairs(tmp) do
		polyamonds.rotate_triangle(v)
		polyamonds.rotate_triangle(v)
		
		table.insert(tris, utils.copy(v))
		
		polyamonds.rotate_triangle(v)
		polyamonds.rotate_triangle(v)
		
		table.insert(tris, utils.copy(v))
	end

	return tris
end

return { parallelogram(), trihex() }