return function(str, environment, sandbox)
	local env = setmetatable(
		environment or {}, 
		sandbox and nil or { __index = _G }
	)
	local code = [[
		local result = ''
		local function rwrite(s) result = result .. tostring(s or '') end
		local function write(s)
			result = result .. tostring(s or ''):gsub("[\">/<'&]", {
				["&"] = "&amp;",
				["<"] = "&lt;",
				[">"] = "&gt;",
				['"'] = "&quot;",
				["'"] = "&#39;",
				["/"] = "&#47;"
			})
		end
		rwrite[=[
	]]
	code = code .. str:
		gsub("[][]=[][]", ']=]rwrite"%1"rwrite[=['): -- make sure [[]] in templates is properly escaped
		gsub("<%%=", "]=]rwrite("):
		gsub("<%%", "]=]write("):
		gsub("%%>", ")rwrite[=["):
		gsub("<%?", "]=] "):
		gsub("%?>", " rwrite[=[")
	code = code .. "]=] return result"

	local func = loadstring(code, "template", "t", env)
	return func()
end
