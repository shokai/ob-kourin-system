#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

def camera_url
  "#{app_root}/camera"
end

get '/' do
  @title = 'OB降臨システム'
  haml :index
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
      :count => chats.count,
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
      :chats => chats,
      :count => chats.count,
      :last => chats[0][:time]
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
