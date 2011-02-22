require 'rubygems'
require 'bundler/setup'
require 'rack'
require 'sinatra/reloader'
require 'bson'
require 'mongoid'
gem 'mongoid','>=2.0.0.rc.7'
require 'yaml'
require File.dirname(__FILE__)+'/models/chat'
require File.dirname(__FILE__)+'/say'

begin
  @@conf = YAML::load open(File.dirname(__FILE__)+'/config.yaml').read
  p @@conf
rescue => e
  STDERR.puts 'config.yaml load error!'
  STDERR.puts e
end

