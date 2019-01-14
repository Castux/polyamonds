-- Basis is (right, north-east)
-- Triangles are initially written as triplets of points
-- then canonized into their leftmost point, and whether they are pointing "up" or "down"
-- Shapes are canonized by sorting their triangles in lexicographic order and translating them to have
-- their first point at (0,0)

local utils = require "utils"

local copy = utils.copy
local equal = utils.equal
local lexicographic_order = utils.lexicographic_order

-- Angle expressed as multiples of 60 degrees

local function rotate_point(x,y,angle)

	local angle = angle or 1

	local u,v = x,y

	for i = 1,angle do
		u,v = 0 * u - 1 * v, 
		      1 * u + 1 * v
	end
	
	return u,v
end

local function uncanonize_triangle(t)

	local x,y,d = t[1],t[2],t[3]

	t[1] = {x, y}
	t[2] = {x + 1, y}
	t[3] = d == "up" and {x, y + 1} or {x + 1, y - 1}

end

local function canonize_triangle(t)

	table.sort(t, lexicographic_order)

	assert(t[1][1] + 1 == t[3][1])

	local dy = t[2][2] - t[1][2]
	assert(dy == 1 or dy == -1)

	t[1], t[2] = t[1][1], t[1][2]
	t[3] = dy == 1 and "up" or "down"
end

local function rotate_triangle(t, angle)

	uncanonize_triangle(t)

	for i = 1,3 do
		t[i][1],t[i][2] = rotate_point(t[i][1], t[i][2], angle)
	end

	canonize_triangle(t)
end

local function mirror_triangle(t)

	uncanonize_triangle(t)

	for i = 1,3 do
		t[i][1],t[i][2] = t[i][2],t[i][1]
	end

	canonize_triangle(t)
end


local function rotate_shape(s, angle)

	for _,t in ipairs(s) do
		rotate_triangle(t, angle)
	end
end

local function mirror_shape(s)

	for _,t in ipairs(s) do
		mirror_triangle(t)
	end
end

local function canonize_shape(s)

	table.sort(s, lexicographic_order)

	local ox,oy = s[1][1],s[1][2]

	for i,t in ipairs(s) do
		t[1] = t[1] - ox
		t[2] = t[2] - oy
	end
end

-- A symmetry group is:
-- C (cyclic: only rotations) or D (dihedral, also includes reflections)
-- 1, 2, 3, or 6

local full_symmetries = "D6"

local function parse_symmetry(symmetries)
	
	assert(type(symmetries) == "string")
	
	local group_type = symmetries:sub(1,1)
	assert(group_type == "C" or group_type == "D")
	
	local sides = tonumber(symmetries:sub(2,2))
	assert(sides == 1 or sides == 2 or sides == 3 or sides == 6)
	
	return group_type, sides
end

-- Apply symmetries to a shape to find all possible variants

local function make_variants(s, symmetries, unique)
	
	local symmetries = symmetries or full_symmetries
	local group_type, sides = parse_symmetry(symmetries)
	
	local candidates = {}
	
	local angle = 6 / sides

	for i = 0,sides-1 do
		
		local tmp = copy(s)
		
		rotate_shape(tmp, i * angle)
		table.insert(candidates, tmp)
		
		if group_type == "D" then
			tmp = copy(tmp)
			mirror_shape(tmp)
			table.insert(candidates, tmp)
		end
		
	end

	local variants = {}

	for _,v in ipairs(candidates) do

		canonize_shape(v)
		local unique = true

		for _,previous in ipairs(variants) do
			if equal(previous, v) then
				unique = false
				break
			end
		end

		if unique then
			table.insert(variants, v)
		end

	end

	return variants
end


--The opposite: find all variants that are *not* equivalent via given symmetry.

local function make_unique(s, symmetries)
	
	local symmetries = symmetries or full_symmetries
	local group_type, sides = parse_symmetry(symmetries)
	
	local candidates = {}
	
	local angle = 6 / sides

	for i = 0,angle do
		
		local tmp = copy(s)
		
		rotate_shape(tmp, i)
		table.insert(candidates, tmp)
		
		if group_type == "C" then
			tmp = copy(tmp)
			mirror_shape(tmp)
			table.insert(candidates, tmp)
		end
		
	end

	local variants = {}

	for _,v in ipairs(candidates) do

		canonize_shape(v)
		local unique = true

		for _,previous in ipairs(variants) do
			if equal(previous, v) then
				unique = false
				break
			end
		end

		if unique then
			table.insert(variants, v)
		end

	end

	return variants
end

local function triangle_neighbours(t)

	local res = {}

	if t[3] == "up" then

		res[1] = {t[1],t[2],"down"}
		res[2] = {t[1],t[2]+1,"down"}
		res[3] = {t[1]-1,t[2]+1,"down"}

	else

		res[1] = {t[1],t[2],"up"}
		res[2] = {t[1],t[2]-1,"up"}
		res[3] = {t[1]+1,t[2]-1,"up"}

	end

	return res
end

local function shape_neighbours(s)

	local candidates = {}

	for _,t in ipairs(s) do
		for i,v in ipairs(triangle_neighbours(t)) do
			table.insert(candidates, v)
		end
	end

	local result = {}

	for i,v in ipairs(candidates) do

		-- no duplicates

		local ok = true

		for _,previous in ipairs(result) do
			if equal(previous, v) then
				ok = false
				break
			end
		end

		-- no collision with the shape itself
		for _,inside in ipairs(s) do
			if equal(inside, v) then
				ok = false
				break
			end
		end

		if ok then
			table.insert(result, v)
		end
	end

	return result
end

local function plus_one_shapes(s)

	local result = {}

	for _,neighbour in ipairs(shape_neighbours(s)) do

		-- Add one triangle

		local new_shape = copy(s)
		table.insert(new_shape, neighbour)

		-- Generate all variants

		local variants = make_variants(new_shape)

		-- Check that none is in the list already

		local new = true

		for _,variant in ipairs(variants) do
			for _,previous in ipairs(result) do

				if equal(previous, variant) then
					new = false
					break
				end

				if new == false then
					break
				end
			end
		end

		if new then
			table.insert(result, variants[1])
		end

	end

	return result
end

local function make_polyamonds(n)

	local monomond =
	{
		{0, 0, "up"}
	}

	local shapes = {}
	shapes[1] = { monomond }

	for i = 1,n-1 do

		shapes[i+1] = {}

		-- For each piece of size N

		for _,current in ipairs(shapes[i]) do

			-- Make all pieces of size N+1

			for _,plus_one in ipairs(plus_one_shapes(current)) do

				local unique = true

				-- Only keep new ones by comparing all variants

				for _,variant in ipairs(make_variants(plus_one)) do
					for _,previous in ipairs(shapes[i+1]) do
						if equal(previous, variant) then
							unique = false
							break
						end
					end

					if not unique then break end
				end

				if unique then
					table.insert(shapes[i+1], plus_one)
				end
			end
		end
	end

	return shapes
end

return 
{
	make_polyamonds = make_polyamonds,
	uncanonize_triangle = uncanonize_triangle,
	make_variants = make_variants,
	make_unique = make_unique,
	rotate_triangle = rotate_triangle,
}
