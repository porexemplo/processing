PImage img, img2;
PGraphics img3;

int col = color(255,0,0);
int selpix = 0;
int iniMouseX, iniMouseY;
float minr, maxr, ming, maxg, minb, maxb;
float minh, maxh, mins, maxs, minbr, maxbr;
int minx, miny, maxx, maxy;
int minx0, miny0, maxx0, maxy0;
ArrayList<PVector> lastMousePoints = new  ArrayList<PVector>();
boolean alt = false;

void setup() {
  size(820,761);
  
  // l'image de depart
  img = loadImage("skunk.png");
  img.loadPixels();
  
  // pour dessiner la zone selectionnee
  img2 = createImage(img.width, img.height, ARGB);
  img2.loadPixels();
  
  // pour dessiner les poils
  img3 = createGraphics(img.width, img.height);

  pixelDensity(displayDensity());
  background(255);
  frameRate(10);
}


void draw() {
  background(255);
  noTint();
  image(img,0,0);
  
  //etape 2.3
  // ici on peut jouer sur la teinture de l'image pour faire une
  // animation moins binaire
  if(frameCount%2==0) {
    tint(255, 255, 255, 64);
  }else {
    tint(255, 255, 255, 192);
  }
  image(img2,0,0); 

  noTint();
  image(img3,0,0);
}

// pour les macs
void keyPressed() {
  if (key == CODED && keyCode == ALT)
    alt=true;
}

void keyReleased() {
  if (key == CODED && keyCode == ALT)
    alt=false;
}


void mousePressed(){
  if (mouseButton == LEFT){
    // si on commence un drag & drop avec le bouton gauche, on selectionne 
    iniMouseX = -1;
    lastMousePoints.clear();
    col = img.pixels[mouseX+mouseY*img.width];

    // on recommence toute la selection  donc on remet a zero toutes les variables
    // qui concernent les stats de la selection
    maxr = minr = red(col);
    maxg = ming = green(col);
    maxb = minb = blue(col);
    minh = hue(col);
    maxh = hue(col);
    mins = saturation(col);
    minx = maxx = mouseX;
    miny = maxy = mouseY;
    minx0 = maxx0 = mouseX;
    miny0 = maxy0 = mouseY;
    
    selpix = 1;
    // on recommence toute la selection donc on remet tous les pixels transparents
    for(int j=0; j<img.height; j++)
      for(int i=0; i<img.width; i++){
        img2.pixels[i+j*img2.width] = color(0,0,0, 0);
      }
    img2.pixels[mouseX+mouseY*img2.width] = color(0,0,0);
  }
  else if (mouseButton == RIGHT || (mouseButton == LEFT && alt)){
    // si on commence un drag & drop avec le bouton droit (ou avec la touche alt pour les macs)
    iniMouseX = mouseX;
    iniMouseY = mouseY;
  }
}

void mouseDragged(){
  if (mouseButton == LEFT){
    // on rajoute un point de drag&drop dans la selection
    col = img.pixels[mouseX+mouseY*img.width];
    maxr = minr = red(col);
    maxg = ming = green(col);
    maxb = minb = blue(col);
    minh = hue(col);
    maxh = hue(col);
    mins = saturation(col);
    minx = maxx = mouseX;
    miny = maxy = mouseY;
    
    // on ne garde en memoire que les 25 derniers points pour pas trop 
    // rajouter de travail
    if (lastMousePoints.size()>25)
      lastMousePoints.remove(lastMousePoints.size()-1);
    lastMousePoints.add(0,new PVector(mouseX, mouseY, col));
    
    // pour les 25 derniers points on met a jour les stats
    for(PVector v:lastMousePoints){
      int x0 = int(v.x);
      int y0 = int(v.y);
      col = img.pixels[x0+y0*img.width];
      minr = min(minr, red(col));
      maxr = max(maxr, red(col));
      ming = min(ming, green(col));
      maxg = max(maxg, green(col));
      minb = min(minb, blue(col));
      maxb = max(maxb, blue(col));
      
      minh = min(minh, hue(col));
      maxh = max(maxh, hue(col));
      mins = min(mins, saturation(col));
      maxs = max(maxs, saturation(col));
      minbr = min(minbr, brightness(col));
      maxbr = max(maxbr, brightness(col));
      
      minx = min(minx, x0);
      maxx = max(maxx, x0);
      miny = min(miny, y0);
      maxy = max(maxy, y0);
      
      img2.pixels[x0+y0*img2.width] = color(0,0,128); 
      selpix++;      
    }
   
    // en fonction des stats on selectionne tous les points autour qui
    // ressemblent (memes couleurs)
    int iniselpix = selpix-1;
    while(iniselpix!=selpix){
      // on recommence en boucle tant que ca rajoute des points
      iniselpix = selpix;
      selpix = 0;
      for(int j=max(0,miny-1); j<=min(maxy+1,img.height-1); j++)
        for(int i=max(0,minx-1); i<=min(maxx+1,img.width-1); i++){
          int p = img.pixels[i+j*img.width];
          boolean tsel = j>miny-1 && j>0 && alpha(img2.pixels[i+(j-1)*img2.width])>128;
          boolean bsel = j<maxy+1 && j<img.height-1 && alpha(img2.pixels[i+(j+1)*img2.width])>128;
          boolean lsel = i>minx-1 && i>0 && alpha(img2.pixels[(i-1)+j*img2.width])>128;
          boolean rsel = i<maxx+1 && i<img.width-1 && alpha(img2.pixels[(i+1)+j*img2.width])>128;
          
          float avgr = (minr+maxr)/2, gapr = (maxr-minr)/2;
          float avgg = (ming+maxg)/2, gapg = (maxg-ming)/2;
          float avgb = (minb+maxb)/2, gapb = (maxb-minb)/2;
          
          float avgh = (minh+maxh)/2, gaph = (maxh-minh)/2;
          float avgs = (mins+maxs)/2, gaps = (maxs-mins)/2;
          float avgbr = (minbr+maxbr)/2, gapbr = (maxbr-minbr)/2;
          
          float tol = 1.0+((tsel?0.05:0) + (bsel?0.05:0) + (lsel?0.05:0) + (rsel?0.05:0));
          if (red(p)  >=avgr-gapr*tol && red(p)  <=avgr+gapr*tol &&
              green(p)>=avgg-gapg*tol && green(p)<=avgg+gapg*tol &&
              blue(p) >=avgb-gapb*tol && blue(p) <=avgb+gapb*tol && 
              hue(p)        >=avgh-gaph*tol && hue(p)        <=avgh+gaph*tol &&
              saturation(p) >=avgs-gaps*tol && saturation(p) <=avgs+gaps*tol &&
              brightness(p) >=avgbr-gapbr*tol && brightness(p) <=avgbr+gapbr*tol && 
              (tsel || bsel || lsel || rsel)){
            img2.pixels[i+j*img2.width] = color(0,0,128); //etape2.1
            selpix++;
            minx = min(minx, i);
            maxx = max(maxx, i);
            miny = min(miny, j);
            maxy = max(maxy, j);
            minx0 = min(minx0, i);
            maxx0 = max(maxx0, i);
            miny0 = min(miny0, j);
            maxy0 = max(maxy0, j);            
          }
        }      
    }
    
    //etape2.2
    // ici on peut bidouiller les couleurs des pixels selectionnes
    // en fonction de leur position ou de leur voisin
    for (int j=1; j<img2.height-1; j++)
      for (int i=1; i<img2.width-1; i++){
        if (alpha(img2.pixels[i+j*img2.width])>128)
          img2.pixels[i+j*img2.width] = color(0,0,0, 255);
      }
    
    img2.updatePixels();
    
  }
}

void mouseReleased(){
  if (iniMouseX>=0){
   //etape 3 et 4
  }
}
