#include <avr/io.h>
#include <avr/interrupt.h>
#include <util/delay.h>
#define TCNT1_BOTTOM 49896    //割り込み周期:50msec

boolean ADC_FLAG = false;
int AnalogData;

int sig = 0;
int ledR = -1;
int ledG = -1;
int ledGtmp = -1;
int spd=255; // 1~255の値にする
int motor_delay = 3000; // モーターを動かす時間

void setup(){
  Serial.begin(4800);
  pinMode(2,OUTPUT); // 左モーター用ドライバピン
  pinMode(4,OUTPUT); // 左モーター用ドライバピン
  pinMode(7,OUTPUT); // 右モーター用ドライバピン
  pinMode(8,OUTPUT); // 右モーター用ドライバピン
  pinMode(12,OUTPUT);//緑LED
  pinMode(13,OUTPUT);//赤LED
  TIMSK1 = (1<<TOIE1); //タイマ/カウンタ1割り込み使用
  TCCR1A = 0;//タイマ使用
  TCCR1B = 5;//分周数:1024 == ck/1024 
  TCNT1 = 0;//タイマ/カウンタ1初期化
  sei(); // 全割り込み許可
  AnalogData = 0;
  motor_stop();
  ledROff();
}

void ledROn(){
  digitalWrite(13,HIGH);
  Serial.println("ledR_on");
}

void ledROff(){
  digitalWrite(13,LOW);
  Serial.println("ledR_off");
}

void ledGOn(){
  digitalWrite(12,HIGH);
  Serial.println("ledG_on");
}

void ledGOff(){
  digitalWrite(12,LOW);
  Serial.println("ledG_off");
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
      delay(motor_delay);
      motor_stop();
      break;
    case 'b':
      motor_back();
      delay(motor_delay);
      motor_stop();
      break;
    case 'c':
      motor_left();
      delay(motor_delay);
      motor_stop();
      break;
    case 'd':
      motor_right();
      delay(motor_delay);
      motor_stop();
      break;
    case 'e':
      ledR = ledR * (-1);
      if(ledR<=0) ledROff();
      else ledROn();
      break;
    case 'f'://コックピットLEDをon
      ledG = 1;
      ledGtmp = 1;
      if(ledG<=0) ledGOff();
      else ledGOn();
      break;
    case 'g'://コックピットLEDをoff
      ledG = -1;
      ledGtmp = -1;
      if(ledG<=0) ledGOff();
      else ledGOn();
      break;
    }
  }
    
  if((ADC_FLAG == true)&&(ledG == 1)){ //フラグが真なら処理
    if(ledGtmp < 0){
      ledGOff(); 
    }else{
      ledGOn();
    }
    ledGtmp = ledGtmp * (-1);
    ADC_FLAG = false;
  }
}

ISR(TIMER1_OVF_vect){
  TCNT1 = TCNT1_BOTTOM;
  ADC_FLAG = true;
}
