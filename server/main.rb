#!/usr/bin/env ruby

@@saykana = '/usr/local/bin/saykana'

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
  puts `#{@@saykana} #{m}`
  redirect '/'
end

