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
  "#{app_root}/#{@@conf['camera_file']}"
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
  redirect camera_url
end

post '/camera' do
  if !params[:file]
    @mes = {:error => 'error'}.to_json
  else
    tmp = File.dirname(__FILE__)+'/public/tmp.jpg'
    name = File.dirname(__FILE__)+'/public/'+@@conf['camera_file']
    File.open(tmp, 'wb'){|f|
      f.write params[:file][:tempfile].read
    }
    if File.exists? tmp
      FileUtils.chmod(0755, tmp)
      if File.exists? name
        File.delete(name)
      end
      File.rename(tmp, name)
      @mes = {
        :url => camera_url,
        :size => File.size(name)
      }.to_json
    end
  end
end
