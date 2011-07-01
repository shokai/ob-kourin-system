#!/usr/bin/env ruby
require 'rubygems'
require 'mongo'
require 'ArgsParser'
require 'yaml'
require 'uri'
require 'net/http'

parser = ArgsParser.parser
parser.bind(:loop, :l, 'do loop', false)
parser.bind(:interval, :i, 'loop interval(sec)', 60)
parser.bind(:verbose, :v, 'print details', false)
parser.bind(:help, :h, 'show help')
first, params = parser.parse(ARGV)

if parser.has_option(:help)
  puts 'ruby user-watcher.rb -loop -i 60'
  puts parser.help
  exit
end

begin
  conf = YAML::load open(File.dirname(__FILE__)+'/../config.yaml').read
rescue => e
  STDERR.puts 'config.yaml load error!'
  STDERR.puts e
  exit 1
end

begin
  mongo = Mongo::Connection.new(conf['mongo_server'], conf['mongo_port'])
  db = mongo.db(conf['mongo_dbname'])
rescue => e
  STDERR.puts 'MongoDB connection error!'
  STDERR.puts e
  exit 1
end

loop do
  begin
    db['users'].remove({:expire => {:$lt => Time.now.to_i}})
    count = db['users'].find({:addr => /[^#{conf['local_ipaddr']}]/}).count
    puts "#{count} users - #{Time.now}" if params[:verbose]
    if count > 0
      robot_msg = 'f'
    else
      robot_msg = 'g'
    end
    uri = URI.parse(conf['robot'])
    Net::HTTP.start(uri.host, uri.port){|http|
        res = http.post(uri.path, robot_msg)
    }
  rescue Timeout::Error => e
    STDERR.puts e
  rescue => e
    STDERR.puts e
  end
  break unless params[:loop]
  sleep params[:interval].to_i
end
