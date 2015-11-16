#!/usr/bin/ruby2.0

require 'net/http'
require 'sinatra'
require 'sinatra/reloader'
require 'json'
require 'digest/sha1'

require_relative './site-protect.conf'


get '/' do
  @streams = get_streams
  erb :index
end


get '/:stream' do
  token = Digest::SHA1.hexdigest [SECRET, params["stream"], request.ip] . join('|')
  @embed = "#{FLUSSONIC_URL}:8080/#{params["stream"]}/embed.html?dvr=false&token=#{token}"
  erb :pl
end


# Retrieve all static streams from FLussonic.
# This may me done manual instead.
def get_streams
  url = "#{FLUSSONIC_URL}/flussonic/api/get_config"
  config = get_json url, FLUSSONIC_USER, FLUSSONIC_PASS
  streams = []
  config["config"] . each do |entry|
    next unless entry["entry"] == "stream"
    stream = entry["value"]["name"]
    name = stream
    meta = entry["value"]["options"]["meta"] || []
    meta . each do |k,v|
      if k == "name"
        name = v
      end
    end
    streams << [stream, name]
  end
  streams
end


def get_json url, user, pass
  uri = URI(url)
  req = Net::HTTP::Get.new(uri)
  req.basic_auth user, pass

  res = Net::HTTP.start(uri.hostname, uri.port) do |http|
    http.request(req)
  end

  JSON.parse res.body
end



__END__

@@index
<html>

<ul>
<% @streams . each do |stream, name| %>

  <li>
    <a href="<%= "#{stream}?name=#{name}" %>"> <%= name %> </a>
  </li>
  
<% end %>
</ul>


</html>


@@pl

<html>
<%= params["name"] %>
<br><br>
<iframe frameborder="0" style="width:853px; height:480px;" src="<%= @embed %>"> </iframe>
</html>
