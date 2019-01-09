local polyamonds = require "polyamonds"
local draw = require "draw"
local puzzles = require "puzzles"
local solver = require "solver"

local html_header = [[
<!DOCTYPE html>
<html>
<head>
	<meta charset="utf-8">
	<title>%s</title>
</head>
<body>
]]

local html_title = [[
<h1>%s</h1>
]]

local html_footer = [[
</body>
</html>
]]


local function make_polyamonds_html(fp, min_size, max_size)

	max_size = max_size or min_size

	local title = "Polyamonds of size " .. min_size

	if min_size < max_size then
		title = title .. " to " .. max_size
	end

	fp:write(string.format(html_header, title))

	local shapes = polyamonds.make_polyamonds(max_size)

	for size = min_size,max_size do

		fp:write(string.format(html_title, "Size " .. size))

		for _,shape in ipairs(shapes[size]) do
			local svg = draw.draw_shape(shape)
			fp:write(svg, '\n')
		end
	end

	fp:write(html_footer)
end

local function make_puzzle_html(fp, puzzle)
	
	local shapes = polyamonds.make_polyamonds(6)[6]
	local results = solver.solve(puzzle, shapes)
	
	fp:write(string.format(html_header, "Polyamond puzzle"))
	fp:write(string.format(html_title, #results .. " solutions"))
	
	for _,result in ipairs(results) do
		fp:write(draw.draw_solver_state(result), "\n")
	end
	
	fp:write(html_footer)
end

local function make_all_puzzles()
	
	for i,puzzle in ipairs(puzzles) do
		print "========="
		print ("Puzzle " .. i)
		
		local fp = io.open("puzzle" .. i .. ".html", "w")
		make_puzzle_html(fp, puzzle)
		fp:close()
	end
	
end

--[[
local fp = io.open("polyamonds.html", "w")
make_polyamonds_html(fp, 1, 6)
fp:close()
--]]

make_all_puzzles()