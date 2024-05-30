init = function(args)
	wrk.method = "GET"
	wrk.headers["Content-Type"] = "application/json"
	token_fetched = false
end

local function run_command(command)
	local handle = io.popen(command)
	local result = handle:read("*a")
	handle:close()
	return result
end

function table_to_string(tbl)
	local result = {}
	local function recurse(t, indent)
		local braceIndent = indent .. "  "
		table.insert(result, indent .. "{\n")
		for k, v in pairs(t) do
			local key = type(k) == "string" and string.format("%q", k) or k
			if type(v) == "table" then
				table.insert(result, braceIndent .. "[" .. key .. "] = ")
				recurse(v, braceIndent)
			else
				local value = type(v) == "string" and string.format("%q", v) or tostring(v)
				table.insert(result, braceIndent .. "[" .. key .. "] = " .. value .. ",\n")
			end
		end
		table.insert(result, indent .. "},\n")
	end
	recurse(tbl, "")
	return table.concat(result)
end

request = function()
	if not token_fetched then
		return wrk.format(nil, "/csrf_token")
	else
		local email = run_command("fakedata email -l 1 | tr -d '\n'")
		local body = "name=TestUser&email=" .. email .. "&password=Password1.&password_confirmation=Password1."
		return wrk.format("POST", "/user/new", wrk.headers, body)
	end
end

-- Handling the response to extract CSRF token and cookies
response = function(status, headers, body)
	if not token_fetched and status == 200 then
		-- Extract CSRF token from JSON response
		local token = string.match(body, '"csrf_token":"(.-)"')
		if token then
			-- Extract session cookie
			local cookies = headers["set-cookie"]

			if cookies then
				-- Extract all cookies
				local session_cookies = {}
				for cookie in string.gmatch(cookies, "([^,]+)") do
					local session_cookie = string.match(cookie, "(.-);")
					if session_cookie then
						table.insert(session_cookies, session_cookie)
					end
				end
				wrk.headers["Cookie"] = table.concat(session_cookies, "; ")
			end

			token_fetched = true
			wrk.headers["X-CSRF-Token"] = token
			wrk.method = "POST"
			wrk.headers["Content-Type"] = "application/x-www-form-urlencoded"
		end
	end
end
