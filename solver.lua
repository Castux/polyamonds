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

	return
	{
		triangles = triangles,
		used_pieces = {}
	}
end

local function add_shape(state, shape, x, y, id)

	local collision = false

	for _,t in ipairs(shape) do
		local u,v,dir = t[1] + x, t[2] + y, t[3]

		if not state.triangles[u] or not state.triangles[u][v] or state.triangles[u][v][dir] ~= "empty" then
			collision = true
			break
		end
	end

	if collision then
		return false
	end

	for _,t in ipairs(shape) do
		local u,v,dir = t[1] + x, t[2] + y, t[3]
		state.triangles[u][v][dir] = id
	end

	state.used_pieces[id] = true
	return true
end

local function remove_shape(state, shape, x, y, id)
	for _,t in ipairs(shape) do
		local u,v,dir = t[1] + x, t[2] + y, t[3]
		state.triangles[u][v][dir] = "empty"
	end
	state.used_pieces[id] = nil
end

local function reduce_symmetries(variants, symmetries)
	
	local added = {}
	
	for _,variant in ipairs(variants) do
		if not added[i] then
			
			local others = polyamonds.make_variants(variant, symmetries)
			for _,other in ipairs(others) do
				for i,previous in ipairs(variants) do
				
					if utils.equal(other,previous) then
						if i == 1 then
							added[i] = "base"
						else
							added[i] = "duplicate"
						end
					end
				end
			end
			
		end
	end
	
	local result = {}
	
	for i,v in ipairs(variants) do
		if added[i] == "base" then
			table.insert(result, v)
		end
	end
	
	return result
end

local function solve(puzzle, shapes)

	-- Sorting the triangles forces the solver to fill full rows
	-- before moving on, eliminating large branches of the search tree

	table.sort(puzzle, utils.lexicographic_order)

	-- Make all shape variants

	for i,shape in ipairs(shapes) do
		shapes[i] = polyamonds.make_variants(shape)
	end
	
	-- Reduce the biggest variant to a single shape to remove symmetries in the results
	-- FIXME: should reduce a shape depending on the symmetry group of the puzzle
	
	for i,variants in ipairs(shapes) do
		if #variants == 12 then
			shapes[i] = reduce_symmetries(variants, puzzle.symmetries)
			break
		end
	end

	-- Build state

	local state = empty_state(puzzle)
	local results = {}

	local ticks = 0

	-- Madness begins

	local function rec(level)

		if level > #puzzle then
			
			-- Filled all triangles, it's a success!
			table.insert(results, utils.copy(state))
			print("Found solution", #results)

			return
		end

		local triangle = puzzle[level]

		if state.triangles[triangle[1]][triangle[2]][triangle[3]] == "empty" then

			-- Try to fit an unused shape in there

			for shape_id,variants in ipairs(shapes) do
				if not state.used_pieces[shape_id] then
					for _,variant in ipairs(variants) do

						-- Try to fit all triangles of the right orientation in the hole

						for _,t in ipairs(variant) do
							if triangle[3] == t[3] then

								local dx = triangle[1] - t[1]
								local dy = triangle[2] - t[2]

								local success = add_shape(state, variant, dx, dy, shape_id)

								if success then
									rec(level + 1)
									remove_shape(state, variant, dx, dy, shape_id)
								end
							end
						end
					end
				end
			end
		else
			rec(level + 1)
		end
	end

	rec(1)
	
	return results
end

return 
{
	solve = solve
}