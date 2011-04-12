int sig = 0;
int led = -1;
int spd=255; // 1~255の値にする

void setup(){
  Serial.begin(4800);
  pinMode(2,OUTPUT); // 左モーター用ドライバピン
  pinMode(4,OUTPUT); // 左モーター用ドライバピン
  pinMode(7,OUTPUT); // 右モーター用ドライバピン
  pinMode(8,OUTPUT); // 右モーター用ドライバピン
  pinMode(13,OUTPUT);
  motor_stop();
  ledOff();
}

void ledOn(){
  digitalWrite(13,HIGH);
  Serial.println("led_on");
}

void ledOff(){
  digitalWrite(13,LOW);
  Serial.println("led_off");
}

void motor_stop(){
  digitalWrite(2,LOW);
  digitalWrite(4,LOW);
  analogWrite(5,1);
  digitalWrite(7,LOW);
  digitalWrite(8,LOW);
  analogWrite(9,1);
  Serial.println("motor_stop");
}

void motor_go(){
  digitalWrite(2,HIGH);
  digitalWrite(4,LOW);
  analogWrite(5,spd);
  digitalWrite(7,HIGH);
  digitalWrite(8,LOW);
  analogWrite(9,spd);
  Serial.println("motor_go");
}

void motor_back(){
  digitalWrite(2,LOW);
  digitalWrite(4,HIGH);
  analogWrite(5,spd);
  digitalWrite(7,LOW);
  digitalWrite(8,HIGH);
  analogWrite(9,spd);
  Serial.println("motor_back");
}

void motor_left(){
  digitalWrite(2,HIGH);
  digitalWrite(4,LOW);
  analogWrite(5,spd);
  digitalWrite(7,LOW);
  digitalWrite(8,HIGH);
  analogWrite(9,spd);
  Serial.println("motor_right");
}

void motor_right(){
  digitalWrite(2,LOW);
  digitalWrite(4,HIGH);
  analogWrite(5,spd);
  digitalWrite(7,HIGH);
  digitalWrite(8,LOW);
  analogWrite(9,spd);
  Serial.println("motor_left");
}

void loop(){
  if(Serial.available()>0){ // データの読み込み
    sig=Serial.read();
    switch(sig){
    case 'a':
      motor_go();
      delay(5000);
      motor_stop();
      break;
    case 'b':
      motor_back();
      delay(5000);
      motor_stop();
      break;
    case 'c':
      motor_left();
      delay(5000);
      motor_stop();
      break;
    case 'd':
      motor_right();
      delay(5000);
      motor_stop();
      break;
    case 'e':
      led = led * (-1);
      if(led<=0) ledOff();
      else ledOn();
      break;
    }
  }
}
