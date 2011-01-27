import processing.video.*;

Capture camera;
PImage img;

void setup(){
    size(240, 320); // width, height
    camera =  new Capture(this, height, width, 12); // 12fps
}

void draw(){
    rotate(PI/2); // 90度
    image(camera, 0, camera.height*-1);
    saveFrame("camera.jpg"); // capture
    delay(1000);
}

void captureEvent(Capture camera){
    camera.read();
}
