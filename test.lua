local make_polyamonds = require "polyamonds"

local function print_shape(s)

	for _,t in ipairs(s) do
		io.write(table.concat(t, ","))
		io.write " / "
	end
	print ""
end

local foo = make_polyamonds(6)

for i = 1,6 do
	print "======"
	print(i)
	print ""
	
	for _,v in ipairs(foo[i]) do
		print_shape(v)
	end
end