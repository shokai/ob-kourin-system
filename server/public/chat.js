
var chat = new Chat();
var timer_sync;
$(function(){
    chat.load();
    $('input#post').click(function(){
        chat.post();
        $('input#message').val('');
    });
    timer_sync = setInterval(chat.load, 10000);
});

var data;

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
    this.post = function(){
        post_data = new Object();
        post_data.name = $('input#name').val();
        post_data.message = $('input#message').val();
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
