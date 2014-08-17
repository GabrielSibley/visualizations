void setup(){
  size(1024, 768);
  noSmooth(); 
  background(0);
  stroke(255);
  fill(0);
  frameRate(60);
}

float hexEdgeLength = 30;
float cos60 = 0.5;
float sin60 = 0.8660254;
int stage;

color[] colors = new color[]{
  color(255, 255, 255),
  color(128, 255, 255),
  color(0, 255, 255),
  color(0, 128, 255),
  color(0, 64, 255),
  color(0, 0, 255)
};

float pingPong(float value, float max){
  float a = value % (max * 2);
  if(a > max){
    return max + max - a;
  }
  return a;
}

void draw(){
  background(0);
  float aperture = pingPong((millis() / 3000f), 0.2);
  for(int i = 0; i < (width / hexEdgeLength * sin60); i++){
    for(int j = -i; j + i < height / hexEdgeLength + 1; j++){
      if(false){//(i * j + i + j) % 4 == 0){
        //Central hex
        drawHex(
          i * sin60 * hexEdgeLength * 2 * sin60,
          (j + i * cos60) * hexEdgeLength * 2 * sin60,
          hexEdgeLength/3 - 1,
          stage + i + abs(j),
          aperture
        );
        //Lower Right hex
        drawHex(
          (i + 0.333) * sin60 * hexEdgeLength * 2 * sin60,
          (j + (i + 0.333) * cos60) * hexEdgeLength * 2 * sin60,
          hexEdgeLength/3 - 1,
          stage + 4 + i + abs(j),
          aperture
        );
        //Lower hex
        drawHex(
          i * sin60 * hexEdgeLength * 2 * sin60,
          (j + 0.333 + i * cos60) * hexEdgeLength * 2 * sin60,
          hexEdgeLength/3 - 1,
          stage + 3 + i + abs(j),
          aperture
        );
        //Lower Left hex
        drawHex(
          (i - 0.333) * sin60 * hexEdgeLength * 2 * sin60,
          (j + 0.333 + (i - 0.333) * cos60) * hexEdgeLength * 2 * sin60,
          hexEdgeLength/3 - 1,
          stage + 2 + i + abs(j),
          aperture
        );
        //Upper Left hex
        drawHex(
          (i - 0.333) * sin60 * hexEdgeLength * 2 * sin60,
          (j + (i - 0.333) * cos60) * hexEdgeLength * 2 * sin60,
          hexEdgeLength/3 - 1,
          stage + 1 + i + abs(j),
          aperture
        );
        //Upper Right hex
        drawHex(
          (i + 0.333) * sin60 * hexEdgeLength * 2 * sin60,
          (j - 0.333 + (i + 0.333) * cos60) * hexEdgeLength * 2 * sin60,
          hexEdgeLength/3 - 1,
          stage + 4 + i + abs(j),
          aperture
        );
        //Upper hex
        drawHex(
          i * sin60 * hexEdgeLength * 2 * sin60,
          (j - 0.333 + i * cos60) * hexEdgeLength * 2 * sin60,
          hexEdgeLength/3 - 1,
          stage + 3 + i + abs(j),
          aperture
        );
      }
      else{
        drawHex(
          i * sin60 * hexEdgeLength * 2 * sin60,
          (j + i * cos60) * hexEdgeLength * 2 * sin60,
          hexEdgeLength - 5,
          stage + i + abs(j),
          aperture
        );
      }
    }
  }
  stage = (int)(millis() / 50);
}

//Draw a hex centered at x, y
void drawHex(float x,
            float y,
            float edgeLength,
            int animStage,
            float aperture){
  //Starting at eastern point and going clockwise
  float[] xVec = new float[]{
    x + edgeLength,
    x + edgeLength * cos60,
    x - edgeLength * cos60,
    x - edgeLength,
    x - edgeLength * cos60,
    x + edgeLength * cos60
  };
  float[] yVec = new float[]{
    y,
    y + edgeLength * sin60,
    y + edgeLength * sin60,
    y,
    y - edgeLength * sin60,
    y - edgeLength * sin60
  };
  noStroke();
  for(int i = 0; i < 6; i++){
    fill(colors[(animStage + i) % 6]);
    float apX = ((xVec[i] + xVec[(i+1)%6])/2 - x) * (aperture);
    float apY = ((yVec[i] + yVec[(i+1)%6])/2 - y) * (aperture);
    triangle(xVec[i] + apX,
      yVec[i] + apY,
      xVec[(i+1)%6] + apX,
      yVec[(i+1)%6] + apY,
      x + apX,
      y + apY
    );
  }
}
