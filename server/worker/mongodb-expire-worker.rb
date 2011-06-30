#!/usr/bin/env ruby
require 'rubygems'
require 'mongo'
require 'ArgsParser'
require 'yaml'

parser = ArgsParser.parser
parser.bind(:loop, :l, 'do loop', false)
parser.bind(:interval, :i, 'loop interval(sec)', 60)
parser.bind(:verbose, :v, 'print details', false)
parser.bind(:help, :h, 'show help')
first, params = parser.parse(ARGV)

if parser.has_option(:help)
  puts 'ruby mongodb-expire-worker -loop -i 60'
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
    if params[:verbose]
      count = db['users'].count
      puts "#{count} users - #{Time.now}"
    end
  rescue => e
    STDERR.puts e
    exit 1
  end
  sleep params[:interval].to_i
  break unless params[:loop]
end
