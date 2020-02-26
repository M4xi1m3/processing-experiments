/**
 * Windows 10 Logo made in Processing
 * @author Maxime "M4x1m3" FRIESS
 * @license WTFPL v2
 */

// Stores angular position of each dots.
int num_points = 5;
float[] alphas = {0, 0, 0, 0, 0, 0, 0};

// Radius of the circles of points.
final float r = 50;

// Size of the window.
final int width = 500;
final int height = 500;

/**
 * Setup function
 *
 * Sets-up the dots position and sets the colors.
 */
void setup() {
    for(int i = 0; i < num_points; i++) {
        alphas[i] = (PI - QUARTER_PI) * i/(num_points-1) + HALF_PI + QUARTER_PI/2 + 2*TWO_PI;
    }
    
    size(500, 500);
    fill(0  , 255, 255);
}

/**
 * Draw function
 *
 * Draws the dots, increment the angular position.
 */
void draw() {
    background(0);
    
    
    
    for(int i = 0; i < num_points; i++) {
        // If the dot is on the top half of the circle, it goes slower.
        if (alphas[i] % TWO_PI >= HALF_PI && alphas[i] % TWO_PI <= PI + HALF_PI) {
            alphas[i] += 0.05;
        } else {
            alphas[i] += 0.15;
        }
        
        // Only display dots which are in the two first rotation.
        // If made 3 rotation, reset to 0.
        if (alphas[i] >= 0 && alphas[i] <= TWO_PI * 2) {
            circle(width/2 + r * -sin(alphas[i]), height/2 + r * cos(alphas[i]), 10);
        } else if (alphas[i] >= TWO_PI * 3) {
            alphas[i] = 0;
        }
    }
}
