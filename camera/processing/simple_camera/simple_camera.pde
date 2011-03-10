import processing.video.*;

Capture camera;
PImage img;

void setup(){
    size(240, 320); // width, height
    camera =  new Capture(this, height, width, 12); // 12fps
}

void draw(){
    rotate(PI/2+PI); // 270度
    image(camera, camera.width*-1, 0);
    saveFrame("camera.jpg"); // capture
    delay(1000);
}

void captureEvent(Capture camera){
    camera.read();
}
