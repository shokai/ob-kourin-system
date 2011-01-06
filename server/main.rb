#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

before do
  Mongoid.configure{|conf|
    conf.master = Mongo::Connection.new(@@conf['mongo_server'], @@conf['mongo_port']).db(@@conf['mongo_dbname'])
  }
end

def app_root
  "#{env['rack.url_scheme']}://#{env['HTTP_HOST']}#{env['SCRIPT_NAME']}"
end

def camera_url
  "#{app_root}/camera"
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
    Say.new(@@conf['say_api']).post(c.message) unless c.local?
    res = {
      :chats => recent_chats,
      :count => recent_chats.count,
      :last => recent_chats[0][:time]
    }
    @mes = res.to_json
  end
end

get '/camera' do
  last = Dir.glob(File.dirname(__FILE__)+'/'+@@conf['camera_dir']+'/*.jpg').sort{|a,b|
    a.to_i <=> b.to_i
  }.last
  content_type 'image/jpg'
  File.open(last)
end

post '/camera' do
  if !params[:file]
    @mes = {:error => 'error'}.to_json
  else
    camera_dir = File.dirname(__FILE__)+'/'+@@conf['camera_dir']
    Dir.mkdir(camera_dir) unless File.exists? camera_dir
    name = "#{camera_dir}/#{Time.now.to_i}.jpg"
    File.open(name, 'wb'){|f|
      f.write params[:file][:tempfile].read
    }
    if File.exists? name
      @mes = {
        :url => camera_url,
        :size => File.size(name)
      }.to_json
    end
  end
end

post '/robot' do
  puts m = params[:message]
  require 'socket'
  begin
    s = TCPSocket.open('127.0.0.1', 8782)
    s.puts m
  rescue => e
    STDERR.puts e
  end
  @mes = {
    :message => m
  }.to_json
end
