/**
 * default variables : frameCount, 
 */

PImage init_image, selected_image;
PGraphics hair_image;

int col = color(255, 0, 0);
int selpix = 0;
int iniMouseX, iniMouseY;
float minRed, maxRed, minGreen, maxGreen, minBlue, maxBlue;
float minHue, maxHue, minSaturation, maxSaturation, minbr, maxbr;
int minX, minY, maxX, maxY;
int minX0, minY0, maxX0, maxY0;
ArrayList<PVector> lastMousePoints = new  ArrayList<PVector>();
boolean alt = false; // used to add macOS support

void setup() {

  size(820,761);
  
  // loading initial image
  init_image = loadImage("skunk.png");
  init_image.loadPixels();
  
  // drawing selected zone - same area as init_image
  selected_image = createImage(init_image.width, init_image.height, ARGB);
  selected_image.loadPixels();
  
  // drawing hairs
  hair_image = createGraphics(init_image.width, init_image.height);

  pixelDensity(displayDensity());
  // setting background as white -> init_image is a png
  background(255);
  frameRate(10);
}


void draw() {
  background(255);
  noTint(); // no tint for init_image
  image(init_image, 0, 0);
  
  // etape 2.3
  // tint can be adjusted here to create less binary animations
  if (frameCount % 2==0) {
    tint(255, 255, 255, 64); // tint for selected_image
  } else {
    tint(255, 255, 255, 192);
  }

  image(selected_image, 0, 0);

  noTint();
  image(hair_image,0,0);
  // printArray(selected_image.pixels);
}

// adding macOS support for rightClick
/*
void keyPressed() {
  if (key == CODED && keyCode == ALT)
    alt = true;
}

void keyReleased() {
  if (key == CODED && keyCode == ALT)
    alt = false;
}
*/


void mousePressed() {
  if (mouseButton == LEFT) {
    // NOTE : if pressed left button (either simple press || drag & drop), selection is restarted
    iniMouseX = -1;
    lastMousePoints.clear();
    col = init_image.pixels[mouseX + mouseY * init_image.width];

    // NOTE : resetting all selection stats variables to zero
    maxRed = minRed = red(col);
    maxGreen = minGreen = green(col);
    maxBlue = minBlue = blue(col);
    minHue = maxHue = hue(col);
    minSaturation = saturation(col);
    minX = maxX = mouseX;
    minY = maxY = mouseY;
    minX0 = maxX0 = mouseX;
    minY0 = maxY0 = mouseY;
    
    selpix = 1;

    // NOTE : resetting all of selected_image pixels to transparent state
    for(int j = 0; j < init_image.height; j++)
      for(int i = 0; i < init_image.width; i++) {
        selected_image.pixels[i + j * selected_image.width] = color(0, 0, 0, 0);
      }
    selected_image.pixels[mouseX + mouseY * selected_image.width] = color(0, 0, 0);
  }
  else if (mouseButton == RIGHT /*|| (mouseButton == LEFT && alt*/) {
    // NOTE : if started a drag & drop with the right mouse button or Alt for macOS
    iniMouseX = mouseX;
    iniMouseY = mouseY;
  }
}

void mouseDragged() {
  if (mouseButton == LEFT) {
    // on rajoute un point de drag&drop dans la selection
    // NOTE : image.pixels returns a 1 dimesion array with the image pixels
    col = init_image.pixels[mouseX + mouseY * init_image.width];
    maxRed = minRed = red(col);
    maxGreen = minGreen = green(col);
    maxBlue = minBlue = blue(col);
    minHue = hue(col);
    maxHue = hue(col);
    minSaturation = saturation(col);
    minX = maxX = mouseX;
    minY = maxY = mouseY;
    
    // on ne garde en memoire que les 25 derniers points pour pas trop 
    // rajouter de travail
    if (lastMousePoints.size() > 25)
      lastMousePoints.remove(lastMousePoints.size()-1);
    lastMousePoints.add(0,new PVector(mouseX, mouseY, col));
    
    // pour les 25 derniers points on met a jour les stats
    for(PVector v:lastMousePoints){
      int x0 = int(v.x);
      int y0 = int(v.y);
      col = init_image.pixels[x0+y0*init_image.width];
      minRed = min(minRed, red(col));
      maxRed = max(maxRed, red(col));
      minGreen = min(minGreen, green(col));
      maxGreen = max(maxGreen, green(col));
      minBlue = min(minBlue, blue(col));
      maxBlue = max(maxBlue, blue(col));
      
      minHue = min(minHue, hue(col));
      maxHue = max(maxHue, hue(col));
      minSaturation = min(minSaturation, saturation(col));
      maxSaturation = max(maxSaturation, saturation(col));
      minbr = min(minbr, brightness(col));
      maxbr = max(maxbr, brightness(col));
      
      minX = min(minX, x0);
      maxX = max(maxX, x0);
      minY = min(minY, y0);
      maxY = max(maxY, y0);
      
      selected_image.pixels[x0+y0*selected_image.width] = color(0,0,128); 
      selpix++;      
    }
   
    // en fonction des stats on selectionne tous les points autour qui
    // ressemblent (memes couleurs)
    int iniselpix = selpix-1;
    while(iniselpix != selpix){
      // on recommence en boucle tant que ca rajoute des points
      iniselpix = selpix;
      selpix = 0;
      for(int j=max(0,minY-1); j<=min(maxY+1,init_image.height-1); j++)
        for(int i=max(0,minX-1); i<=min(maxX+1,init_image.width-1); i++){
          int p = init_image.pixels[i+j*init_image.width];
          boolean tsel = j>minY-1 && j>0 && alpha(selected_image.pixels[i+(j-1)*selected_image.width])>128;
          boolean bsel = j<maxY+1 && j<init_image.height-1 && alpha(selected_image.pixels[i+(j+1)*selected_image.width])>128;
          boolean lsel = i>minX-1 && i>0 && alpha(selected_image.pixels[(i-1)+j*selected_image.width])>128;
          boolean rsel = i<maxX+1 && i<init_image.width-1 && alpha(selected_image.pixels[(i+1)+j*selected_image.width])>128;
          
          float avgr = (minRed+maxRed)/2, gapr = (maxRed-minRed)/2;
          float avgg = (minGreen+maxGreen)/2, gapg = (maxGreen-minGreen)/2;
          float avgb = (minBlue+maxBlue)/2, gapb = (maxBlue-minBlue)/2;
          
          float avgh = (minHue+maxHue)/2, gaph = (maxHue-minHue)/2;
          float avgs = (minSaturation+maxSaturation)/2, gaps = (maxSaturation-minSaturation)/2;
          float avgbr = (minbr+maxbr)/2, gapbr = (maxbr-minbr)/2;
          
          float tol = 1.0+((tsel?0.05:0) + (bsel?0.05:0) + (lsel?0.05:0) + (rsel?0.05:0));
          if (red(p)  >=avgr-gapr*tol && red(p)  <=avgr+gapr*tol &&
              green(p)>=avgg-gapg*tol && green(p)<=avgg+gapg*tol &&
              blue(p) >=avgb-gapb*tol && blue(p) <=avgb+gapb*tol && 
              hue(p)        >=avgh-gaph*tol && hue(p)        <=avgh+gaph*tol &&
              saturation(p) >=avgs-gaps*tol && saturation(p) <=avgs+gaps*tol &&
              brightness(p) >=avgbr-gapbr*tol && brightness(p) <=avgbr+gapbr*tol && 
              (tsel || bsel || lsel || rsel)){
            selected_image.pixels[i+j*selected_image.width] = color(0,0,128); //etape2.1
            selpix++;
            minX = min(minX, i);
            maxX = max(maxX, i);
            minY = min(minY, j);
            maxY = max(maxY, j);
            minX0 = min(minX0, i);
            maxX0 = max(maxX0, i);
            minY0 = min(minY0, j);
            maxY0 = max(maxY0, j);            
          }
        }      
    }
    
    //etape2.2
    // ici on peut bidouiller les couleurs des pixels selectionnes
    // en fonction de leur position ou de leur voisin
    for (int j = 1; j < selected_image.height - 1; j++)
      for (int i = 1; i < selected_image.width - 1; i++){
        if (alpha(selected_image.pixels[i+j*selected_image.width]) > 128)
          selected_image.pixels[i+j*selected_image.width] = color(128,0,0, 255);
      }
    
    selected_image.updatePixels();
    
  }
}

void mouseReleased(){
  if (iniMouseX>=0){
   //etape 3 et 4
   img3.beginDraw();
   //img3.noFill();
   for (int j = 1; j < selected_image.height - 1; j++)
      for (int i = 1; i < selected_image.width - 1; i++){
        if (alpha(selected_image.pixels[i+j*selected_image.width]) > 128 ){
            img3.line(i, j, mouseX, mouseY);
        }
      }
   img3.endDraw();

   img3.beginDraw();
   img3.line(i, j, mouseX, mouseY);
   img3.endDraw();
  }
}

noFill();
vertex(i, j);
vertex(something, otherthing);
vertex(mouseX, mouseY);
