
Array.prototype.to_s = function(){return this.join('');};
Array.prototype.flatten = function(nil){
    result = new Array();
    for(var i = 0; i < this.length; i++){
	item = this[i];
	if($.isArray(item)) for(var j = 0; j < item.length; j++) result.push(item[j]);
	else result.push(item);
    }
    return result;
};
Array.prototype.contains = function(obj){
    for(var i = 0; i < this.length; i++){
	if(this[i] == obj) return true;
    }
    return false;
};

String.prototype.replace_all = function(regex, replace_str, delimiter){
    if(!this.match(regex)) return this;
    tmp = this.split(delimiter);
    result = '';
    for(var i = 0; i < tmp.length; i++){
	var line;
	if(i < tmp.length-1) line = tmp[i]+delimiter;
	else line = tmp[i];
	result += line.replace(regex, replace_str);
    }
    return result;
};

String.prototype.htmlEscape = function(){
    var span = document.createElement('span');
    var txt =  document.createTextNode('');
    span.appendChild(txt);
    txt.data = this;
    return span.innerHTML;
};

var timeDiff = function(time_a, time_b){
    if(time_a > time_b) d = time_a - time_b;
    else d = time_b - time_a;
    if(d > 2678400) return '約'+Math.floor(d/2678400)+'ヶ月前';
    else if(d > 86400) return Math.floor(d/86400)+'日前';
    else if(d > 3600) return Math.floor(d/3600)+'時間前';
    else if(d > 60) return Math.floor(d/60)+'分前';
    else if(d > 0) return Math.floor(d)+'秒前';
    else return "";
}