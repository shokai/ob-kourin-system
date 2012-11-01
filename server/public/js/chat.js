
var chat = new Chat();
var timer_sync;
var KC = {tab:9, enter:13, left:37, up:38, right:39, down:40};
var data;
var page_at = 1;

$(function(){
    $('body').click(Notifier.request);
    var name = $.cookie('name');
    if(name != null && name.length > 0){
        $('input#name').val(name);
    }
    CameraServer.start($('div#camera'), camera_url, 500);
    chat.load();
    $('input#post').click(post);
    $('input#message').keydown(function(e){
        if(e.keyCode == KC.enter){
            post();
        }
    });
    timer_sync = setInterval(chat.load, 10000);
    $('div#robot span.button#go').click(function(){robot_post('a')});
    $('div#robot span.button#left').click(function(){robot_post('c')});
    $('div#robot span.button#right').click(function(){robot_post('d')});
    $('div#robot span.button#back').click(function(){robot_post('b')});
    $('div#robot span.button#led').click(function(){robot_post('e')});
    $('div#robot span.button').hover(function() {
		$(this).css("cursor","pointer"); 
	},function(){
		$(this).css("cursor","default"); 
	});

    $('div#chat_paging').html('Load Page'+(page_at+1));
    $('div#chat_paging').click(paging);
    $('div#chat_paging').hover(function() {
		$(this).css("cursor","pointer"); 
	},function(){
		$(this).css("cursor","default"); 
	});
});

var paging = function(page){
    chat.load(function(res){
        if(res.error == null){
            page_at++;
            $('div#chat_paging').html('Load Page'+(page_at+1));
        }
        else{
            $('div#chat_paging').css('visibility', 'hidden');
        }
    },data.chats[data.chats.length-1].time);
}

var robot_post = function(message){
    post_data = {'message' : message};
    $.post(robot_api, post_data, function(res){
    }, 'json');
};

var post = function(){
    var name = $('input#name').val();
    if(name.length > 0){
        $.cookie('name', name, {expires : 14});
        chat.post(name, $('input#message').val());
        $('input#message').val('');
    }
};

var display = function(){
    var div = $('div#users');
    div.html('');
    for(var i = 0; i < data.users.length; i++){
        user = data.users[i];
        var span = $('<span>');
        var img = $('<img>');
        if(user.match("^[a-zA-Z0-9_]+$")) img.attr('src','http://twiticon.herokuapp.com/'+user).attr('title', user);
        else img.attr('src', app_root+'/noname.png').attr('title', user);
        span.append(img);
        div.append(span);
    }

    if(data == null || data.chats.length < 1) return;
    var div = $('div#chat');
    ul = $('<ul />');
    now = Math.floor(new Date().getTime()/1000);
    
    for(var i = 0; i < data.chats.length; i++){
        c = data.chats[i];
        li = $('<li />').addClass('chat');
        span = $('<span />').addClass('chat')
        if(c.local) li.addClass('local');
        else{
            li.addClass('grobal');
            span.prepend('[OB] ');
        }
        tmp = c.name.htmlEscape()+' : ';
        tmp += c.message.htmlEscape().replace_all(/(https?\:[\w\.\~\-\/\?\&\+\=\:\@\%\;\#\%]+)/, '<a href="$1">$1</a>');
        span.append(tmp);
        if(c.name.match("^[a-zA-Z0-9_]+$")){
            img = $('<img>').attr('src', 'http://twiticon.herokuapp.com/'+c.name);
        }
        else{
            img = $('<img>').attr('src', app_root+'/noname.png');
        }
        li.prepend(img);
        li.append(span)
        span_t = $('<span />').addClass('time').append(timeDiff(now, c.time));
        li.append(span_t);
        ul.append(li);
    }
    div.html(ul);
};

function Chat(){
    
    this.merge_chat_data = function(new_data){
        if(new_data.error != null) return;
        if(data == null){
            data = new_data;
            display();
            return;
        }
        else{
            data.users = new_data.users;
        }
        if(data.last != new_data.last){
            for(var i = 0; i < new_data.chats.length; i++){
                var c = new_data.chats[i];
                var contains = false;
                for(var j = 0; j < data.chats.length; j++){
                    if(data.chats[j].id == c.id){
                        contains = true;
                    }
                }
                if(!contains){
                    if(c.name != $.cookie('name')){
                        if(c.name.match("^[a-zA-Z0-9_]+$")) icon = "http://twiticon.herokuapp.com/"+c.name;
                        else icon = app_root+'/noname.png';
                        if(data.last <= c.time) Notifier.notify(icon, c.name, c.message.htmlEscape());
                    }
                    data.chats.push(c);
                }
            }
            data.chats.sort(function(a,b){return b.time-a.time});
            data.last = new_data.last;
            data.count = data.chats.length;
            display();
        }
    };

    this.post = function(name, message){
        if(name == null || message == null || name.length < 1 || message.length < 1){
            return;
        }
        post_data = new Object();
        post_data.name = name;
        post_data.message = message;
        $.post(api, post_data, function(res){
            chat.merge_chat_data(res);
        }, 'json');
    };
    
    this.load = function(on_load, time){
        var url = api;
        if(time) url += "?last="+time;
        $.getJSON(url, function(res){
            chat.merge_chat_data(res);
            if(on_load != null) on_load(res);
        });
    };
};


var Notifier = {};
Notifier.request = function(){
    if(window.webkitNotifications.checkPermission() == 1){
        window.webkitNotifications.requestPermission();
    }
};
Notifier.notify = function(icon, title, body){
    if(window.webkitNotifications.checkPermission() == 0){
        var notif = window.webkitNotifications.createNotification(icon, title, body);
        notif.ondisplay = function(){
            setTimeout(function(){
                if(notif.cancel) notif.cancel();
            }, 3000);
        };
        notif.show();
    }
};
