local polyamonds = require "polyamonds"
local draw = require "draw"
local puzzles = require "puzzles"

local p = puzzles[1]
local t = draw.draw_shape(p.triangles)

local fp = io.open("test.svg", "w")
fp:write(t)
fp:close()

print(#p.points)