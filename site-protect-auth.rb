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
  print_params params
  p [SECRET, params["name"], params["ip"]]
  token = Digest::SHA1.hexdigest [SECRET, params["name"], params["ip"]] . join('|')
  if token != params["token"]
    halt 401
  end
  "OK"
end
