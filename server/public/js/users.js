$(function(){
    get_users();
    setInterval(get_users, 60000);
    setInterval(display_users, 10000);
});

var data = {};
var user_i = 0;
var get_users = function(){
    $.getJSON(api, function(res){
        data = res;
        display_users();
    });
};

var display_users = function(){
    $('#users').html('');
    if(data.global.length < 1) return;
    if(user_i > data.global.length-1) user_i = 0;
    var user = data.global[user_i];
    var img = $('<img>');
    if(user.match("^[a-zA-Z0-9_]+$")) img.attr('src','http://twiticon.herokuapp.com/'+user).attr('title', user);
    else img.attr('src', app_root+'/noname.png').attr('title', user);
    var xy = window.innerHeight;
    if(xy > window.innerWidth/2) xy = window.innerWidth/2;
    img.attr('width', xy*0.7).attr('height', xy*0.7);
    $('#users').append(img);
    $('#users').append($('<div>').append(user).css('font-size',xy/5));
    user_i++;
};
