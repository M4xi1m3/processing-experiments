/**
 * Ensemble de Mandelbrot
 *
 * @author Maxime "M4x1m3" FRIESS
 * @license WTFPL v2
 * @version 1.0.0
 */

final int width = 1200, height = 800;
final int recurrence = 1000, borne = 10;

double x1, y1, x2, y2;
int drawTime;

int startx, starty, endx, endy;

int[] mandelbrotArray;

double dmap(double v, double a, double b, double c, double d) {
    return (v - a) * (d - c) / (b - a) + c;
}

double dmax(double a, double b) {
    return (a >= b) ? a : b;
}

double dmin(double a, double b) {
    return (a <= b) ? a : b;
}

void reloadMandelbrot() {
    int start = millis();
    
    for(double i = 0; i < width; i++) {
        for(double j = 0; j < height; j++) {
            double a = dmap(i, 0, width, x1, x2);
            double b = dmap(j, 0, height, y1, y2);
            
            double x = 0, y = 0;
            double num = 0;
            
            for(int k = 0; k < recurrence; k++) {
                double tx = x*x - y*y + a;
                y = 2 * x * y + b;
                x = tx;
                
                if (x > borne && y > borne) {
                    num = k;
                    break;
                }
            }
            
            if (x < borne && y < borne) {
                mandelbrotArray[(int)i + (int)j * width] = color(100);
            } else {
                mandelbrotArray[(int)i + (int)j * width] = color((float)dmap(num, 0, recurrence, 0, 100), 100, 100);
            }
        }
    }
    
    int end = millis();
    
    drawTime = end - start;
}

void drawMandelbrot() {
    loadPixels();
    for(int i = 0; i < pixels.length; i++) {
        pixels[i] = mandelbrotArray[i];
    }
    updatePixels();
}

double cap(double min, double val, double max) {
    return dmin(max, dmax(min, val));
}

void keyPressed() {
    if (key == 'r') {
        setup();
    }
}

void mousePressed() {
    startx = mouseX;
    starty = mouseY;
    endx = startx;
    endy = starty;
    fill(0);
}

void mouseDragged() {
    endx = mouseX;
    endy = mouseY;
}

void mouseReleased() {
    
    int size = endx - startx;
    
    double nx1 = dmap(startx,        0, width,  x1, x2);
    double nx2 = dmap(startx + size, 0, width,  x1, x2);
    double ny1 = dmap(starty,        0, height, y1, y2);
    double ny2 = dmap(starty + size * height/width, 0, height, y1, y2);
    
    x1 = nx1;
    x2 = nx2;
    y1 = ny1;
    y2 = ny2;
    
    endx = endy = startx = starty = 0;
    
    reloadMandelbrot();
}

void setup() {
    size(1200, 800);
    colorMode(HSB, 100);
    background(0);
    textSize(16);
    
    x1 = -2;
    y1 = -1;
    x2 = 1;
    y2 = 1;
    drawTime = 0;

    startx = 0;
    starty = 0;
    endx = 0;
    endy = 0;
    
    mandelbrotArray = new int[width * height];
    
    reloadMandelbrot();
}

void draw() {
    drawMandelbrot();
    fill(0);
    text(String.format("Mandelbrot (%d ms)", drawTime), 8, 24);
    text(String.format("Area x(%e;%e) - y(%e;%e) - D(%e;%e)", x1, x2, y1, y2, x2-x1, y2-y1), 8, 40);
    fill(0, 64);
    
    rect(startx, starty, endx - startx, (endx - startx) * height/width);
}
