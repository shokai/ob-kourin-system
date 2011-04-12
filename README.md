OB降臨システム
=============

Components
----------

* camera (Processing)
* robot (Arduino)
* robot-http-server (Ruby 1.8.7)
* server (Sinatra 1.2, Ruby 1.8.7, MongoDB 1.6+)
* uploader (Ruby 1.8.7)
* [mac-say-server](https://github.com/shokai/mac-say-server)


Server
------

config

    % cd server
    % cp sample.config.yaml config.yaml

then, edit it.


Instlal Dependencies

    % gem install bundler
    % bundle install


run

    % ruby development.rb

or, use Passenger.


API
---

http://(app_root)/chat.json

* get, post


http://(app_root)/camera

* get, post 240x320 image
* see server/misc/sample\_upload\_client.rb


Robot
-----

run robot/robot.pde with [Arduino](http://arduino.cc/).


Robot-Http-Server
-----------------

install dependencies

    % gem install serialport eventmachine eventmachine_httpserver json ArgsParser

run

    % robot-http-server/robot-http-server /dev/tty.usbdevice -bps 4800 -post_interval 5000


Camera and Uploader
-------------------

run camera (camera/processing/simple\_camera/simple\_camera.pde) with [Processing](http://processing.org/)

run uploader

    % cd uploader
    % cp sample.config.yaml config.yaml
    % ruby uploader.rb -help
    % ruby uploader.rb -c config.yaml -l -i 5 -f ../camera/processing/simple_camera/camera.jpg
