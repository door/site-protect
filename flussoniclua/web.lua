-- Here our secret. It must be the same as in auth script.
local SECRET = "xxx topsecret xxx"

-- Here the password for access generator. It must be the same as in site.php.
local TOKEN_GENERATOR_PASSWORD = "change me!";


local check_pass = function(authenticator)
   if not authenticator then
      return false
   end

   local salt, hash = string.match(authenticator, "^([a-z0-9]+)%.([a-z0-9]+)$")
   if not (salt and hash) then
      return false
   end

   return hash == crypto.sha256(salt .. TOKEN_GENERATOR_PASSWORD)
end


http = {}

http.mktoken = function(req)

   if not check_pass(req.query.authenticator) then
      flussonic.log("Unauthorized")
      return "http", 403, {}, "Unauthorized"
   end

   local salt = string.gsub(flussonic.uuid(), "-", "")
   local time = flussonic.now()
   local hashs = {salt, SECRET, req.query.stream, req.query.ip, time, req.query.timespan}
   local hash = crypto.sha256(table.concat(hashs, ""))
   local token =
      "salt:"      .. salt ..
      ".hash:"     .. hash ..
      ".time:"     .. time ..
      ".timespan:" .. req.query.timespan
   return "http", 200, {}, tostring(token) .. "\n"
end
