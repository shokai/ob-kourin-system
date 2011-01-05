import processing.video.*;

Capture camera;

void setup(){
  size(320, 240); // width, height
  camera =  new Capture(this, width, height, 1); // 1fps
}

void draw(){
  image(camera, 0, 0);
  saveFrame("camera.jpg"); // capture
  delay(1000);
}

void captureEvent(Capture camera){
  camera.read();
}

