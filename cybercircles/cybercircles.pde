void setup(){
  size(1024, 840);
  noSmooth(); 
  background(0);
  stroke(255);
  fill(0);
  frameRate(60);
  //wedge init
  wedges = new Wedge[80];
  for(int i = 0; i < wedges.length; i++){
    wedges[i] = new Wedge();
    wedges[i].x = 512;
    wedges[i].y = 420;
    wedges[i].r = 90 + (i+2) * 15;
    wedges[i].thickness = 64;
    wedges[i].phi = 0;
    wedges[i].theta = radians(360);
  }
}

float pingPong(float value, float max){
  float a = value % (max * 2);
  if(a > max){
    return max + max - a;
  }
  return a;
}

int heat = 0;
Wedge[] wedges;

void draw(){
  background(0);

  for(int i = 0; i < wedges.length; i++){
    wedges[i].update();
  }  
}

class Wedge{
  //wedge properties
  float x; float y; float r; float thickness; float phi; float theta;
  
  //dynamism
  float targetSpeed;
  float targetSpeedTime;
  float targetRadius;
  float targetRadiusTime;
  float targetTheta;
  float targetThetaTime;
  float speed;
  boolean capSpeedThicknessEffect;
  float speedThicknessEffectCap; //Actually an effective minimum speed
  
  float getRandomTargetSpeed(){
    float speedRange = pingPong(
      (sin(millis() / 20000.0)+1) * 20,
      4
    );
    float speedMin = 3 + 2 * sin(millis() / 13000.0);
    return radians(random(speedMin, speedMin + speedRange));
    //return radians(random(2, max(2, 10 - millis() / 10000.0)));
  }
  
  boolean checkPointInWedge(float px, float py){
    px -= x;
    py -= y;
    //check pt is in thickness of wedge
    float pr = sqrt(px*px+py*py);
    if(pr < r || pr > r + thickness){
      return false;
    }
    //check pt is in arc of wedge
    float ptheta = atan2(py, px); // in range -PI, PI
    //get ptheta normalized and bound to 0, TAU
    float normalizedPtheta = (ptheta - phi) % TAU;
    if(normalizedPtheta < 0){
      normalizedPtheta += TAU;
    }
    //assume non-negative theta for now
    if(normalizedPtheta <= theta){
      return true;
    }    
    return false;
  }
  
  void update(){
    phi += speed;
    //faster lines are thinner, bigger lines are thinner, lines toward the outside are thinner
    if(capSpeedThicknessEffect){
      thickness = 40 / (max(speedThicknessEffectCap, abs(speed)) * theta * sqrt(r));
    }
    else{
      thickness = 40 / (abs(speed) * theta * sqrt(r));
    }
    
    if(millis() > targetSpeedTime){
      //choose new target speed
      targetSpeedTime = millis() + random(600, 4000);
      targetSpeed = getRandomTargetSpeed();
      if(random(1) < 0.1){
        //If reversing directions, don't get any thicker while performing the reverse
        capSpeedThicknessEffect = speed >= radians(-2);
        speedThicknessEffectCap = max(abs(speed), radians(2)); 
        targetSpeed = -targetSpeed;
      }
      else{
        capSpeedThicknessEffect = speed <= radians(2); //traveling less than min CCW speed
        speedThicknessEffectCap = max(abs(speed), radians(2));
      }
    }
    
    if(millis() > targetRadiusTime){
      targetRadiusTime = millis() + random(600, 4000);
      targetRadius = random(20, 420);
      //targetRadius = random(20, 300);
    }
    
    if(millis() > targetThetaTime){
      targetThetaTime = millis() + random(600, 4000);
      targetTheta = radians(random(20, 240));
    }
    
    speed = speed * 0.96 + targetSpeed * 0.04;
    r = r * 0.96 + targetRadius * 0.04;
    theta = theta * 0.96 + targetTheta * 0.04;
    
    blendMode(ADD);
    //Taller lines (more thick less radius) are more intense and whiter
    //faster lines are also more intense if they are thin
    float lerp = thickness / r * 0.3;
    if(thickness < 10){
      lerp += degrees(abs(speed)) * 10 / thickness ;
    }
    color c;
    //measure y from bottom of screen because wedge drawing is doing its own flipping
    if(checkPointInWedge(mouseX, height-mouseY)){
      c = color(180, 20, 20);
    }
    else if(speed >= 0){
      c = lerpColor(color(20, 20, 100), color(120, 120, 200), lerp);
    }
    else{
      c = lerpColor(color(100, 100, 100), color(200, 200, 200), lerp);
    }
    noStroke();
    fill(c);
    
    drawWedge(x, y, r, thickness, phi, theta, max(8, r / 20));
  }
}

//Draw an arc centered at x, y, with given radius,
//starting angle (phi), and subtended angle (theta) (in radians)
//quality is line segments per radian
//TODO: Make work with negative theta value
void drawArc(float x, float y, float r, float phi, float theta, float quality){
  noFill();
  beginShape();
  int firstFullSegmentAnchor = ceil(phi * quality);
  int lastFullSegmentAnchor = floor((phi+theta) * quality);
  float angle = phi;
  vertex(x + cos(angle) * r, y - sin(angle) * r);
  for(int i = firstFullSegmentAnchor; i < lastFullSegmentAnchor; i++){
    angle = i/quality;
    vertex(x + cos(angle) * r, y - sin(angle) * r);
    angle = (i+1)/quality;
    vertex(x + cos(angle) * r, y - sin(angle) * r);
  }
  angle = phi + theta;
  vertex(x + cos(angle) * r, y - sin(angle) * r);
  endShape();
}

void drawWedge(float x, float y, float r, float thickness, float phi, float theta, float quality){
  beginShape();
  int firstFullSegmentAnchor = ceil(phi * quality);
  int lastFullSegmentAnchor = floor((phi+theta) * quality);
  float angle = phi;
  //Forwards
  vertex(x + cos(angle) * r, y - sin(angle) * r);
  for(int i = firstFullSegmentAnchor; i < lastFullSegmentAnchor; i++){
    angle = i/quality;
    vertex(x + cos(angle) * r, y - sin(angle) * r);
    angle = (i+1)/quality;
    vertex(x + cos(angle) * r, y - sin(angle) * r);
  }
  angle = phi + theta;
  vertex(x + cos(angle) * r, y - sin(angle) * r);
  //And reverse
  r = r + thickness;
  vertex(x + cos(angle) * r, y - sin(angle) * r);
  
  for(int i = lastFullSegmentAnchor-1; i > firstFullSegmentAnchor; i--){
    angle = i/quality;
    vertex(x + cos(angle) * r, y - sin(angle) * r);
    angle = (i-1)/quality;
    vertex(x + cos(angle) * r, y - sin(angle) * r);
  }
  vertex(x + cos(phi) * r, y - sin(phi) * r);
  endShape(CLOSE);
}

void mousePressed(){
  heat = millis() + 1000;
}
