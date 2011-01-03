
var chat = new Chat();
var timer_sync;
var KC = {tab:9, enter:13, left:37, up:38, right:39, down:40};

$(function(){
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
    chat.post($('input#name').val(), $('input#message').val());
    $('input#message').val('');
};

function display(){
    if(data == null || data.chats.length < 1) return;
    div = $('div#chat');
    div.html('');
    for(var i = 0; i < data.chats.length; i++){
        c = data.chats[i];
        div.append('<ul>');
        div.append('<li>'+c.name+' : '+c.message+'</li>');
        div.append('</ul>');
    }
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
            if(res.error == null){
                data = res;
                display();
            }
        }, 'json');
    };
    
    this.load = function(on_load_func){
        $.getJSON(api, function(res){
            if(res.error == null){
                data = res;
                display();
                if(on_load_func){
                    on_load_func();
                }
            }
        });
    };
};
