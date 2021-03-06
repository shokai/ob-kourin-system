OB降臨システム
=============

Components
----------

* robot (Arduino)
* robot-http-server (Ruby 1.8.7)
* server (Sinatra 1.2, Ruby 1.8.7, MongoDB 1.6+)
* camera (Processing)
* camera-server and uploader (Ruby 1.8.7)
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

run robot/robot.ino with [Arduino](http://arduino.cc/).


Robot-Http-Server
-----------------

install dependencies

    % gem install serialport eventmachine eventmachine_httpserver json ArgsParser

run

    % robot-http-server/robot-http-server /dev/tty.usbdevice -bps 4800 -post_interval 5000


Run Camera-Server
-----------------

    % ruby camera-server/camera-server.rb

=> port 8784


Camera and Uploader
-------------------

run camera (camera/processing/simple\_camera/simple\_camera.pde) with [Processing](http://processing.org/)

install dependencies of uploader.

    % gem install ArgsParser json

run uploader.

    % ruby camera-server/uploader.rb -f camera/processing/simple_camera/camera.jpg -u http://hostname:8784/ -i 1 -loop


Developers
==========

* [Sho Hashimoto](https://github.com/shokai)
* [Kyo Hirota](https://github.com/tomoyo-kousaka)
