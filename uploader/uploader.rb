#!/usr/bin/env ruby
require 'rubygems'
require 'yaml'
require 'ArgsParser'
require File.dirname(__FILE__)+'/lib/upload_client'

$KCODE = 'u'

parser = ArgsParser.parser
parser.bind(:loop, :l, 'do loop')
parser.bind(:file, :f, 'upload file')
parser.bind(:interval, :i, 'uplaod interval : default 5 (sec)')
parser.bind(:conf, :c, 'config file : default config.yaml')
parser.bind(:help, :h, 'show help')
first, params = parser.parse(ARGV)

params[:interval] = 5 unless params[:interval]
params[:conf] = File.dirname(__FILE__)+'/config.yaml' unless params[:conf]

unless parser.has_param(:file) or parser.has_param(:help)
  puts parser.help
  exit
end

p params

begin
  conf = YAML::load open(params[:conf]).read
  p conf
rescue => e
  STDERR.puts 'config.yaml load error!'
  STDERR.puts e
  exit 1
end

f = params[:file]
unless File.exists? f
  STDERR.puts 'upload file not exists'
  exit 1
end

last_mtime = 0
loop do
  if File.mtime(f).to_i != last_mtime
    last_mtime = File.mtime(f).to_i
    begin
      url = UploadClient::upload(f, conf['api'])
    rescue => e
      STDERR.puts e
      url = nil
    rescue UploadError => e
      STDERR.puts e
      url = nil
    end
    puts "[#{last_mtime}] #{url}" if url
  end
  break unless params[:loop]
  sleep params[:interval].to_i
end

