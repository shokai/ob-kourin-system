
var chat = new Chat();
var timer_sync;
var KC = {tab:9, enter:13, left:37, up:38, right:39, down:40};

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
    timer_sync = setInterval(chat.load, 10000);
});

var data;

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
    for(var i = 0; i < data.chats.length; i++){
        c = data.chats[i];
        li = $('<li />').addClass('chat');
        if(c.local) li.addClass('local');
        else li.addClass('grobal').prepend('[OB] ');
        li.append(c.name+' : '+c.message);
        if(c.name.match("^[a-zA-Z0-9_]+$")) li.prepend('<img src="http://gadgtwit.appspot.com/twicon/'+c.name+'" />');
        console.log(c.user_id);
        ul.append(li);
    }
    div.html('');
    div.append(ul);    
};

function Chat(){
    this.post = function(name, message){
        if(name == null || message == null || name.length < 1 || message.length < 1){
            return;
        }
        post_data = new Object();
        post_data.name = name;
        post_data.message = message;
        $.post(api, post_data, function(res){
            if(res.error == null && (data == null || res.last != data.last)){
                data = res;
                display();
            }
        }, 'json');
    };
    
    this.load = function(on_load_func){
        $.getJSON(api, function(res){
            if(res.error == null && (data == null || res.last != data.last)){
                data = res;
                display();
                if(on_load_func){
                    on_load_func();
                }
            }
        });
    };
};
