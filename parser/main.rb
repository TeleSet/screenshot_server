#!/usr/bin/env ruby

require 'net/http'
require 'json'

####### settings session #########
$login = 'api'
$passwd = 'yL8bXCf3eymvLN_new'
$url = 'http://fl.tlnt.iptvapi.net:8080'
$url_streams = '/flussonic/api/v3/streams?limit=1000'
$fileexport = '/opt/API/streams.list'
##################################

def json
  uri = URI $url + $url_streams

  req = Net::HTTP::Get.new uri

  req.basic_auth $login, $passwd

  res = Net::HTTP.start uri.hostname, uri.port do |http|
    http.request(req)
  end

  JSON.parse(res.body)['streams']
end

def streams
  streams = json.select do |stream|
    stats = stream.fetch 'stats', {}

    stream['name'] &&
    stats['alive'] &&
    stats['running'] &&
    stats['dvr_enabled'] &&
    stats['ts_delay'] &&
    stats['ts_delay'] < 1000 * 10 
  end

  streams
    .map { |stream| stream['name'] }
    .join("\n")
end

print "\e[H\e[2J" # clear
File.write $fileexport, streams
