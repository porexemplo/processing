PImage init_image, selected_image;
PGraphics hair_image;

int col = color(255,0,0);
int selpix = 0;
int iniMouseX, iniMouseY;
float minr, maxr, ming, maxg, minb, maxb;
float minh, maxh, mins, maxs, minbr, maxbr;
int minx, miny, maxx, maxy;
int minx0, miny0, maxx0, maxy0;
ArrayList<PVector> lastMousePoints = new  ArrayList<PVector>();
boolean alt = false;

int N  = 20;


/**
* @return 1 ou -1 choisi au random
*/
int random_sign() {
  if (int(random(0, 3)) == 1) {
    return -1;
  }
  else {
    return 1;
  }
}


void setup() {
  size(820,761);
  
  // l'image de depart
  init_image = loadImage("skunk.png");
  init_image.loadPixels();
  
  // pour dessiner la zone selectionnee
  selected_image = createImage(init_image.width, init_image.height, ARGB);
  selected_image.loadPixels();
  
  // pour dessiner les poils
  hair_image = createGraphics(init_image.width, init_image.height);

  pixelDensity(displayDensity());
  background(255);
  frameRate(10);
}


void draw() {
  background(255);
  noTint();
  image(init_image,0,0);
  
  //etape 2.3
  // ici on peut jouer sur la teinture de l'image pour faire une
  // animation moins binaire
  if(frameCount%2==0) {
    tint(255, 255, 255, 64);
  }else {
    tint(255, 255, 255, 192);
  }
  image(selected_image,0,0); 

  noTint();
  image(hair_image,0,0);
}

// pour les macs
void keyPressed() {
  if (key == CODED && keyCode == ALT)
    alt=true;
  if (key == '+') {
    N += 10;
    print("Increased the value of N by 10\nCurrent value: ");
    print(N);
    print("\n");
  }
  if (key == '-') {
    if (N == 10) {
      print("N cannot be 0\n");
      } else {
    N -= 10;
    print("Decreased the value of N by 10\nCurrent value: ");
    print(N);
    print("\n");
    }
  }
  if (key == 'r') {
    setup();
  }
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
    col = init_image.pixels[mouseX+mouseY*init_image.width];

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
    for(int j=0; j<init_image.height; j++)
      for(int i=0; i<init_image.width; i++){
        selected_image.pixels[i+j*selected_image.width] = color(0,0,0, 0);
      }
    selected_image.pixels[mouseX+mouseY*selected_image.width] = color(0,0,0);
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
    col = init_image.pixels[mouseX+mouseY*init_image.width];
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
      col = init_image.pixels[x0+y0*init_image.width];
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
      
      selected_image.pixels[x0+y0*selected_image.width] = color(0,0,128); 
      selpix++;      
    }
   
    // en fonction des stats on selectionne tous les points autour qui
    // ressemblent (memes couleurs)
    int iniselpix = selpix-1;
    while(iniselpix!=selpix){
      // on recommence en boucle tant que ca rajoute des points
      iniselpix = selpix;
      selpix = 0;
      for(int j=max(0,miny-1); j<=min(maxy+1,init_image.height-1); j++)
        for(int i=max(0,minx-1); i<=min(maxx+1,init_image.width-1); i++){
          int p = init_image.pixels[i+j*init_image.width];
          boolean tsel = j>miny-1 && j>0 && alpha(selected_image.pixels[i+(j-1)*selected_image.width])>128;
          boolean bsel = j<maxy+1 && j<init_image.height-1 && alpha(selected_image.pixels[i+(j+1)*selected_image.width])>128;
          boolean lsel = i>minx-1 && i>0 && alpha(selected_image.pixels[(i-1)+j*selected_image.width])>128;
          boolean rsel = i<maxx+1 && i<init_image.width-1 && alpha(selected_image.pixels[(i+1)+j*selected_image.width])>128;
          
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
            selected_image.pixels[i+j*selected_image.width] = color(0,0,128); //etape2.1
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


    for (int j=1; j<selected_image.height-1; j++)
      for (int i=1; i<selected_image.width-1; i++){
        if (alpha(selected_image.pixels[i+j*selected_image.width]) > 128) {
          // NOTE: La couleur de la séléction == 255 - couleur de la zone séléctionnée
          color pixelColor = init_image.pixels[i + j*init_image.width];
          selected_image.pixels[i+j*selected_image.width] = color(
            255 - red(pixelColor),
            255 - green(pixelColor),
            255 - blue(pixelColor),
            255
          );
          // selected_image.pixels[i + j*init_image.width] = color(0, 0, 0, 255);
        }
      }
    
    selected_image.updatePixels();
    
  }
}

void mouseReleased(){
  if (iniMouseX>=0){
   //etape 3 et 4
   hair_image.beginDraw();

    // stroke(color(255, 0, 0), 255);

    for (int i = 0; i < selected_image.width; i++)
      for (int j = 0; j < selected_image.height; j++) {
        if (int(random(0, 100))%105 == 0 && alpha(selected_image.pixels[i + j*selected_image.width]) > 128) {
          PVector u = new PVector(0, 0),
                  i_v = new PVector((mouseX-i) / N, (mouseY-j) / N),
                  dot = new PVector(i, j);
          if (i_v.y == 0) continue;

          hair_image.beginShape();
            hair_image.stroke(init_image.get(i, j), 128);
            hair_image.strokeWeight(2);
            hair_image.noFill();
            hair_image.vertex(dot.x, dot.y);
            for (int k = 0; k < N; k++) {
              u.set(4, -4*abs(i_v.x/i_v.y));
              dot.add(i_v);
              dot.add(u.mult(random_sign()));
              hair_image.vertex(dot.x, dot.y);
            }
          hair_image.endShape();
        }
      }
   hair_image.endDraw();
  }
}
