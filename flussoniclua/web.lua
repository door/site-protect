-- Here our secret. It must be the same as in auth script.
local SECRET = "xxx topsecret xxx"


http = {}

http.mktoken = function(req)
   local salt = crypto.rand_hex(16)
   local time = flussonic.now()
   local hashs = {salt, SECRET, req.query.stream, req.query.ip, time, req.query.timespan}
   local hash = crypto.sha1(table.concat(hashs, ""))
   local token =
      "salt:"      .. salt ..
      ".hash:"     .. hash ..
      ".time:"     .. time ..
      ".timespan:" .. req.query.timespan
   return "http", 200, {}, tostring(token) .. "\n"
end
