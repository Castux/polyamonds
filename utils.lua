local function copy(t)

	if type(t) == "table" then
		local res = {}
		for k,v in pairs(t) do
			res[k] = copy(v)
		end

		return res
	else
		return t
	end
end

local function equal(a,b)

	if type(a) == "table" and type(b) == "table" then

		for k,v in pairs(a) do
			if not equal(v, b[k]) then
				return false
			end
		end

		for k,v in pairs(b) do
			if not equal(v, a[k]) then
				return false
			end
		end

		return true

	else
		return a == b
	end

end


local function lexicographic_order(a,b)

	assert(#a == #b)

	for i = 1,#a do

		if a[i] ~= b[i] then
			return a[i] < b[i]
		end
	end

	return false
end

return
{
	copy = copy,
	equal = equal,
	lexicographic_order = lexicographic_order
}