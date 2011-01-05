OB降臨システム webサービス
========================

Dependencies
------------

* Sinatra
* Mongo DB
* [mac-say-server](https://github.com/shokai/mac-say-server)


Run Server
----------

config

    % cp sample.config.yaml config.yaml

then, edit it.


Instlal Dependencies

    % sudo gem install bundler
    % bundle install


run

    % ruby development.rb


API
---

http://(app_root)/chat.json

* get, post


http://(app_root)/camera

* get, post 240x320 image
* see server/misc/sample\_upload\_client.rb
