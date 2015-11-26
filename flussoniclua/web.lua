-- Here our secret. It must be the same as in auth script.
local SECRET = "xxx topsecret xxx"

-- Here the password for access generator. It must be the same as in site.php.
local TOKEN_GENERATOR_PASSWORD = "change me!";



http.mktoken = function(req)
   local authenticator_string = req.query.salt .. req.query.stream .. req.query.ip .. req.query.time .. TOKEN_GENERATOR_PASSWORD
   if req.query.authenticator ~= crypto.sha256(authenticator_string) then
      flussonic.log("Wrong hash")
      return "http", 403, {}, "Unauthorized"
   end

   local time = flussonic.now()

   if math.abs(time - tonumber(req.query.time)) > 300 then
      flussonic.log("Wrong time")
      return "http", 403, {}, "Unauthorized"
   end

   local salt = string.gsub(flussonic.uuid(), "-", "")
   local hashs = {salt, SECRET, req.query.stream, req.query.ip, time, req.query.timespan}
   local hash = crypto.sha256(table.concat(hashs, ""))
   local token =
      "salt:"      .. salt ..
      ".hash:"     .. hash ..
      ".time:"     .. time ..
      ".timespan:" .. req.query.timespan
   return "http", 200, {}, token .. "\n"
end
