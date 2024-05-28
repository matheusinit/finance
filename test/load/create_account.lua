local wrk = require("wrk")

init = function(args)
	wrk.method = "POST"
	wrk.headers["Content-Type"] = "application/x-www-form-urlencoded"
end

response = function(status, headers, body)
	if status == 200 and body then
		-- Extract CSRF token from the meta tag in the HTML body
		-- local token = string.match(body, '<meta name="csrf%-token" content="(.-)" />')
		-- if token then
		-- Update wrk method to POST for the next request
		wrk.method = "POST"
		wrk.body = "name=TestUser&email=test"
			.. math.random(100000)
			.. "@example.com&password=Password1.&password_confirmation=Password1."
		-- wrk.headers["X-CSRF-Token"] = token
		wrk.headers["Content-Type"] = "application/x-www-form-urlencoded"
		-- end
	end
end

-- Function to generate new request each time
request = function()
	if wrk.method == "POST" then
		return wrk.format(nil, "/user/new")
	else
		return wrk.format(nil, "/user")
	end
end
