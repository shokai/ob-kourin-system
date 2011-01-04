#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
require 'yaml'

begin
  @@conf = YAML::load open(File.dirname(__FILE__)+'/config.yaml').read
  p @@conf
rescue => e
  STDERR.puts 'config.yaml load error!'
  STDERR.puts e
end

before do
  Mongoid.configure{|conf|
    conf.master = Mongo::Connection.new(@@conf['mongo_server'], @@conf['mongo_port']).db(@@conf['mongo_dbname'])
  }
end

def app_root
  "#{env['rack.url_scheme']}://#{env['HTTP_HOST']}#{env['SCRIPT_NAME']}"
end

get '/' do
  @title = 'OB降臨システム'
  haml :index
end

def recent_chats(limit=40)
  return @recent_chats if @recent_chats
  @recent_chats = Chat.find(:all, :limit => limit).desc(:time).map{|i|i.to_hash}
end

get '/chat.json' do
  content_type 'application/json'
  res = {
    :chats => recent_chats,
    :count => recent_chats.count,
    :last => recent_chats[0][:time]
  }
  @mes = res.to_json
end

post '/chat.json' do
  content_type 'application/json'
  addr = env['REMOTE_ADDR']
  m = params[:message]
  name = params[:name]
  if addr.to_s.size < 1 or m.to_s.size < 1 or name.to_s.size < 1
    status 500
    @mes = {:error => 'param "name" and "message" required'}.to_json
  else
    time = Time.now.to_i
    c = Chat.new(:name => name, :message => m, :time => time, :addr => addr)
    c.save
    res = {
      :chats => recent_chats,
      :count => recent_chats.count,
      :last => recent_chats[0][:time]
    }
    @mes = res.to_json
  end
end
