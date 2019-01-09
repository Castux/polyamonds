local polyamonds = require "polyamonds"
local draw = require "draw"

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
<h1>Size %d</h1>
]]

local html_footer = [[
</body>
</html>
]]


function make_html(fp, min_size, max_size)

	max_size = max_size or min_size

	local title = "Polyamonds of size " .. min_size

	if min_size < max_size then
		title = title .. " to " .. max_size
	end

	fp:write(string.format(html_header, title))

	local shapes = polyamonds.make_polyamonds(max_size)

	for size = min_size,max_size do

		fp:write(string.format(html_title, size))

		for _,shape in ipairs(shapes[size]) do
			local svg = draw.draw_shape(shape)
			fp:write(svg, '\n')
		end
	end

	fp:write(html_footer)
end

local fp = io.open("polyamonds.html", "w")
make_html(fp, 1, 12)
fp:close()