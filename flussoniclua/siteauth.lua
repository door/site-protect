local SECRET = "xxx topsecret xxx"


if not req.token then
   return false, {}
end

local tparams = {}

-- there is no gmatch in luerl :-(
for _,k in pairs({"salt", "hash", "time", "timespan"}) do
   local v = string.match(req.token, k .. ":([a-z0-9]+)")
   if not v then
      return false, {}
   end
   tparams[k] = v
end

local hashs = {tparams.salt, SECRET, req.name, req.ip, tparams.time, tparams.timespan}
local hash = crypto.sha256(table.concat(hashs, ""))

if hash ~= tparams.hash then
   return false, {["code"] = 403, ["message"] = "Invalid hash"}
end

local now = flussonic.now()

local starttime = tonumber(tparams.time)
local endtime = starttime + tonumber(tparams.timespan)

if now < starttime then
   return false, {["code"] = 403, ["message"] = "Too early"}
end

if now > endtime then
   return false, {["code"] = 403, ["message"] = "Too late"}
end

return true, {}
