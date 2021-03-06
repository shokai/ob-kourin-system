require 'rubygems'
require 'bundler/setup'
require 'rack'
require 'sinatra/reloader' if development?
require 'haml'
require 'bson'
require 'mongoid'
require 'yaml'
require 'net/http'
require 'uri'
require File.dirname(__FILE__)+'/models/chat'
require File.dirname(__FILE__)+'/models/user'
require File.dirname(__FILE__)+'/say'

begin
  @@conf = YAML::load open(File.dirname(__FILE__)+'/config.yaml').read
  p @@conf
rescue => e
  STDERR.puts 'config.yaml load error!'
  STDERR.puts e
end

Mongoid.configure{|conf|
  conf.master = Mongo::Connection.new(@@conf['mongo_server'], @@conf['mongo_port']).db(@@conf['mongo_dbname'])
}

def app_root
  "#{env['rack.url_scheme']}://#{env['HTTP_HOST']}#{env['SCRIPT_NAME']}"
end

def cookie
  cookie = Hash.new
  begin
    env['HTTP_COOKIE'].split(';').each{|i|
      kv = i.split('=')
      cookie[URI.decode(kv[0].strip).to_sym] = URI.decode kv[1]
    }
  rescue
    cookie = Hash.new
  end
  cookie
end
