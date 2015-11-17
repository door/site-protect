#!/usr/bin/ruby2.0

require 'sinatra'
require 'sinatra/reloader'
require 'json'

require_relative './site-protect.conf'


def print_params params
  params . to_a . sort . each do |k, v|
    puts "#{k} = #{v}"
  end
end


get '/' do
  ts = params["token"] . split('.')
  hash = ts.shift

  tparams = {}
  ts . each do |s|
    s =~ /^([a-z]+)=(.+)$/ or next
    tparams[$1] = $2
  end

  time = tparams["time"] . to_i
  timespan = tparams["timespan"] . to_i

  hashs = [SECRET, params["name"], params["ip"], time, timespan]
  hash2 = Digest::SHA1.hexdigest hashs . join
  if hash2 != hash
    halt 401, "fail"
  end

  now = Time.now.to_i
  if now < time || now > (time+timespan)
    halt 401, "not in time"
  end

  "ok"
end
