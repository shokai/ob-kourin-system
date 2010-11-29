#!/usr/bin/env ruby
require 'yaml'

begin
  @@conf = YAML::load open(File.dirname(__FILE__)+'/config.yaml').read
  p @@conf
rescue => e
  STDERR.puts 'config.yaml load error!'
  STDERR.puts e
end


@@saykana = 

def app_root
  "#{env['rack.url_scheme']}://#{env['HTTP_HOST']}#{env['SCRIPT_NAME']}"
end

get '/' do
<<EOF
<form method="post" action="#{app_root}/say">
  <input type="text" name="message"> <input type="submit" name="say" value="say">
</form>
EOF
end

post '/say' do
  puts m = params['message']
  puts `#{@@conf['saykana']} #{m}`
  redirect '/'
end

