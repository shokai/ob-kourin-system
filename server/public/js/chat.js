
var chat = new Chat();
var timer_sync;
var timer_camera;
var KC = {tab:9, enter:13, left:37, up:38, right:39, down:40};
var data;
var page_at = 1;

$(function(){
    var name = $.cookie('name')
    if(name != null && name.length > 0){
        $('input#name').val(name);
    }
    chat.load();
    $('input#post').click(post);
    $('input#message').keydown(function(e){
        if(e.keyCode == KC.enter){
            post();
        }
    });
    timer_sync = setInterval(chat.load, 20000);
    timer_camera = setInterval(reload_camera, 5000);
    $('div#robot span.button#go').click(function(){robot_post('a')});
    $('div#robot span.button#left').click(function(){robot_post('c')});
    $('div#robot span.button#right').click(function(){robot_post('d')});
    $('div#robot span.button#back').click(function(){robot_post('b')});
    $('div#robot span.button').hover(function() {
		$(this).css("cursor","pointer"); 
	},function(){
		$(this).css("cursor","default"); 
	});

    //$('div#chat_paging').click(paging(++page_at));
    $('div#chat_paging').hover(function() {
		$(this).css("cursor","pointer"); 
	},function(){
		$(this).css("cursor","default"); 
	});
});

function reload_camera(){
    div = $('div#camera');
    img = $('<img src="'+camera_url+'?time='+new Date().getTime()+'" width="240" height="320">')
    div.html(img);
};

function robot_post(message){
    post_data = {'message' : message};
    $.post(robot_api, post_data, function(res){
    }, 'json');
};

function post(){
    var name = $('input#name').val();
    if(name.length > 0){
        $.cookie('name', name);
        chat.post(name, $('input#message').val());
        $('input#message').val('');
    }
};

function display(){
    if(data == null || data.chats.length < 1) return;
    div = $('div#chat');
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
        if(c.name.match("^[a-zA-Z0-9_]+$")) li.prepend('<img src="http://gadgtwit.appspot.com/twicon/'+c.name+'" width="48" height="48" />');
        li.append(span)
        span_t = $('<span />').addClass('time').append(timeDiff(now, c.time));
        li.append(span_t);
        ul.append(li);
    }
    div.html('');
    div.append(ul);    
};

function Chat(){
    
    this.merge_chat_data = function(new_data){
        if(new_data.error != null) return;
        if(data == null){
            data = new_data;
            display();
            return;
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
                if(!contains) data.chats.push(c);
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
    
    this.load = function(){
        $.getJSON(api, function(res){
            chat.merge_chat_data(res);
        });
    };
};
