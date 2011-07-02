#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

def camera_url
  @@conf['camera_server']
end

before '/chat.json' do
  name = cookie[:name]
  addr = env['REMOTE_ADDR']
  user = User.where(:name => name).first
  user = User.new(:name => name) unless user
  user.expire = Time.now.to_i+60
  user.addr = addr
  user.save
end

get '/' do
  @title = 'OB降臨システム'
  haml :index
end

get '/users' do
  haml :users
end

def get_chats(per_page=40, last=nil)
  if !last or last < 1
    chats = Chat.find(:all)
  else
    chats = Chat.where(:time.lt => last)
  end
  return [] if chats.count < 1
  return chats.desc(:time).limit(per_page).map{|i|i.to_hash}
end

def get_users
  User.where(:expire.gt => Time.now.to_i).map{|u|u.to_hash}
end

get '/users.json' do
  content_type 'application/json'
  users = get_users
  local = Array.new
  global = Array.new
  users.each{|u|
    if u[:addr] =~ /#{@@conf['local_ipaddr']}/
      local << u[:name]
    else
      global << u[:name]
    end
  }
  {
    :local => local,
    :global => global,
    :size => local.size+global.size
  }.to_json
end

get '/chat.json' do
  content_type 'application/json'
  per_page = params['per_page'].to_i
  last = params['last'].to_i
  per_page = 40 if !per_page or per_page < 1
  last = nil if !last or last < 1
  chats = get_chats(per_page, last)
  if chats.size > 0
    res = {
      :chats => chats,
      :users => get_users.map{|u| u[:name]},
      :last => chats[0][:time],
      :per_page => per_page
    }
  else
    res = {
      :error => 'no chats',
    }
  end
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
    begin
      Say.new(@@conf['say_api']).post(c.message) unless c.local?
    rescue => e
      STDERR.puts e
    end
    chats = get_chats
    res = {
      :chats => get_chats,
      :users => get_users.map{|u| u[:name]},
      :last => chats[0][:time]
    }
    @mes = res.to_json
  end
end

post '/robot' do
  puts m = params[:message]
  if !m or m.size < 1
    @mes = {:error => 'message required'}.to_json
  else
    uri = URI.parse(@@conf['robot'])
    res = nil
    Net::HTTP.start(uri.host, uri.port){|http|
      res = http.post(uri.path, m)
    }
    puts "response body size : #{res.body.size}(bytes)"
    @mes = res.body
  end
end
