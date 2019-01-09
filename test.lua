local polyamonds = require "polyamonds"
local draw = require "draw"
local puzzles = require "puzzles"
local solver = require "solver"

local p = puzzles[2]
local t = draw.draw_shape(p)

local fp = io.open("test.html", "w")
fp:write(t)
fp:close()
