local polyamonds = require "polyamonds"
local utils = require "utils"
local draw = require "draw"

local DIRS = {"down", "up"}

local function empty_state(puzzle)

	local triangles = {}

	for _,t in ipairs(puzzle) do

		local x,y,dir = t[1],t[2],t[3]

		triangles[x] = triangles[x] or {}
		triangles[x][y] = triangles[x][y] or {}
		triangles[x][y][dir] = "empty"

	end

	return triangles
end

local function add_shape(state, shape, x, y, id)

	local collision = false

	for _,t in ipairs(shape) do
		local u,v,dir = t[1] + x, t[2] + y, t[3]

		if not state[u] or not state[u][v] or state[u][v][dir] ~= "empty" then
			collision = true
			break
		end
	end

	if collision then
		return false
	end

	for _,t in ipairs(shape) do
		local u,v,dir = t[1] + x, t[2] + y, t[3]
		state[u][v][dir] = id
	end

	return true
end

local function remove_shape(state, shape, x, y)
	for _,t in ipairs(shape) do
		local u,v,dir = t[1] + x, t[2] + y, t[3]
		state[u][v][dir] = "empty"
	end
end

local function solve(puzzle, shapes)

	-- Make all shape variants

	for i,shape in ipairs(shapes) do
		shapes[i] = polyamonds.make_variants(shape)
	end

	-- Build state

	local state = empty_state(puzzle)
	local results = {}

	local ticks = 0

	-- Madness begins

	local function rec(level)

		---[[
		if level > 11 then
			local fp = io.open("test.html", "w")
			fp:write(draw.draw_solver_state(state))
			fp:close()
			os.exit()
		end
		--]]

		if level > #shapes then
			-- Placed all pieces, it's a success!
			table.insert(results, utils.copy(state))
			print("Found solution", #results)
			return
		end


		for _, triangle in ipairs(puzzle) do

			if state[triangle[1]][triangle[2]][triangle[3]] == "empty" then

				for i, variant in ipairs(shapes[level]) do
					if triangle[3] == variant[1][3] then
						
						local success = add_shape(state, variant, triangle[1], triangle[2], level)

						if success then
							rec(level + 1)
							remove_shape(state, variant, triangle[1], triangle[2])
						end

					end
				end
			end
		end
	end

	rec(1)
end

return 
{
	solve = solve
}