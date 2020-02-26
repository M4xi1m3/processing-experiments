/**
 * Simple and slow algorythm to ge the convex hull surrounding a cloud of points.
 *
 * @author Maxime "M4x1m3" FRIESS
 * @license WTFPL v2
 * @version 1.0.0
 */

import java.util.Collections;

/**
 * Simple interface for class which generates points.
 */
public interface PointGenerator {
    /**
     * Generates a point.
     *
     * @param   pos     position of the point in the list of points.
     *
     * @return  a single generated point.
     */
    public Point run(int pos);
}

/**
 * Class used to generate points randombly
 */
public class RandomPointGenerator implements PointGenerator {
    float min, max;
    
    /**
     * Constructor. Points will be generated between (min, min) and (max, max).
     *
     * @param   min     min x and y.
     * @param   max     max x and y.
     */
    public RandomPointGenerator(float min, float max) {
        this.min = min;
        this.max = max;
    }
    
    /**
     * @see PointGenerator#run
     */
    public Point run(int pos) {
        return new Point(random(min, max), random(min, max));
    }
}

/**
 * Class describing a 2D vector.
 * Could have used {@link PVector} but decided not to.
 * "You don't use a train to transport a single fridge, do you?"
 * (And i like OOP so I don't mind adding classes :p)
 */
public class Vec {
    public float x, y;
    
    /**
     * Create a vector from its two coordinates.
     *
     * @param   x       Vector's x coordinate.
     * @param   y       Vector's x coordinate.
     */
    public Vec(float x, float y) {
        this.x = x;
        this.y = y;
    }
    
    /**
     * Create a vector from two points.
     * Vx = Bx - Ax;
     * Vy = By - Ay;
     *
     * @param   a       beginning.
     * @param   b       end.
     */
    public Vec(Point a, Point b) {
        this.x = b.x - a.x;
        this.y = b.y - a.y;
    }
    
    /**
     * Calculates determinant of vectors, aka normal of cross product.
     * det (AB,AC) = (Xb - Xa) * (Yc - Ya) - (Yb - Ya) * (Xc - Xa)
     * We assume this and other to start from same point A, beeing at (0,0).
     * Thus we have det (AB,AC) = Xb * Yc - Yb * Xc
     *
     * @param   other   bector to calculate determinant with.
     */
    public float det(Vec other) {
        return (this.x * other.y) - (other.x * this.y);
    }
}

/**
 * Represents a point.
 */
public class Point implements Comparable<Point> {
    public float x, y;
    
    /**
     * Create a points from its coordinates.
     *
     * @param   x       X of the point.
     * @param   y       Y of the point.
     */
    public Point(float x, float y) {
        this.x = x;
        this.y = y;
    }
    
    /**
     * Draws the point
     */
    public void draw() {
        point(x, y);
    }
    
    /**
     * Draws a line between this and p.
     *
     * @param   p       End of the line.
     *
     * @return  p, this is use so that we can chain drawing: a.draw(b).draw(c);
     */
    public Point draw(Point p) {
        line((int) this.x, (int) this.y, (int) p.x, (int) p.y);
        return p;
    }
    
    /**
     * Function used to compare two points.
     * We are comparing the X coordinates of the points.
     * @see Comparable#compareTo
     *
     * @param   p       Point to compare with.
     *
     * @return  - negative number if this.x < p.x
     *          - 0 if this.x == p.x
     *          - positive number if this.x > p.x
     */
    @Override
    public int compareTo(Point p) {
        return (int) (this.x - p.x);
    }
    
    /**
     * Gets string representation of point.
     *
     * @return  A string representation in the form of x;y
     */
    @Override
    public String toString() {
        return this.x + ";" + this.y;
    }
    
    public boolean equals(Object x) {
        if (x != null && x.getClass() == Point.class) {
            Point p = (Point) x;
            return p.x == this.x && p.y == this.y;
        } else {
            return false;
        }
    }
}

/**
 * Generates an ArrayList<Point> containing num points.
 *
 * @param   num     number of points to generate.
 * @param   g       PointGenerator to use.
 *
 * @return  an ArrayList<Point> containing the generated points.
 */
public static ArrayList<Point> generatePoints(int num, PointGenerator g) {
    ArrayList<Point> out = new ArrayList<Point>();
    
    for(int i = 0; i < num; i++) {
        out.add(g.run(i));
    }
    
    return out;
}

/**
 * Check if point C is to the "left" of vector AB.
 *
 * @param   a       Point A.
 * @param   b       Point B.
 * @param   c       Point C, to check if on left of AB.
 *
 * @return  true if C on the left of AB. false otherwise.
 */
boolean isPointLeft(Point a, Point b, Point c) {
    Vec ab = new Vec(a, b);
    Vec ac = new Vec(a, c);
    
    return ab.det(ac) > 0;
}

/**
 * Magic slow af function to get the point which makes a
 * vector with p having no points on the left.
 *
 * @param   p       Base point of vector.
 * @param   points  List of points.
 *
 * @return  The single point making a vector with p such as
 *          there are none other points on the left of that vector.
 */
Point getMostLeftPoint(Point p, ArrayList<Point> points) {
    for(int i = 0; i < points.size(); i++) {
        boolean points_left = false;
        Point p2 = points.get(i);
        
        if (p2 == p) continue;
        
        for(int j = i; j < points.size(); j++) {
            Point p3 = points.get(j);
            if (isPointLeft(p, p2, p3)) {
                points_left = true;
                break;
            }
        }
        
        if (!points_left) {
            return p2;
        }
    }
    
    // Should never happen.
    return null;
}

// Bunch of global variables.
ArrayList<Point> points;
ArrayList<Point> convex_hull;
Point p, p2;
boolean done;

/**
 * Draws the point list.
 */
void drawPoints() {
    for(Point p : points) {
        p.draw();
    }
}

/**
 * Draw the hull contained in the `convex_hull` ArrayList<Point>
 */
void drawHull() {
    for(int i = 0; i < convex_hull.size() - 1; i++) {
        convex_hull.get(i).draw(convex_hull.get(i+1));
    }
    
    if (convex_hull.size() > 0 && done) {
        convex_hull.get(0).draw(convex_hull.get(convex_hull.size() - 1));
    }
}

/**
 * Handles key presses.
 *
 * Resets the script when R is pressed.
 */
void keyPressed() {
    if (key == 'r') {
        setup();
    }
}

/**
 * Handles mouse clicks.
 *
 * Steps forward in generating the hull when clicked.
 */
void mouseClicked() {
    if (done) return;

    p2 = getMostLeftPoint(p, points);
    p = p2;
    
    if (points.get(0).equals(p)) {
        done = true;

        return;
    }
    
    convex_hull.add(p);
}

/**
 * Init the script.
 */
void setup() {
    size(800, 800);
    
    done = false;
    points = generatePoints(50, new RandomPointGenerator(10, 790));

    Collections.sort(points);
    
    convex_hull = new ArrayList<Point>();
    convex_hull.add(points.get(0));
    
    p = points.get(0);
    p2 = null;
    
    // mouseClicked();
}

/**
 * Draws the points, the hull and some informative text.
 */
void draw() {
    background(0);
    
    stroke(255);
    strokeWeight(3);
    
    drawPoints();
    
    stroke(color(0, 0, 255));
    points.get(0).draw();
    
    strokeWeight(1);
    stroke(color(255, 0, 0));
    
    drawHull();
    
    fill(color(0, 255, 0));
    text("Convex Hull v1.0.0 - Maxime \"M4x1m3\" FRIESS - WTFPL v2", 8, 16);
    text("Click to adwance - R to reset.", 8, 27);
    
    for(int i = 0; i < convex_hull.size(); i++) {
        text(i + " - " + convex_hull.get(i), 8, 27 + 11 * (i + 1));
    }
    
    if(done) {
        text("DONE!", 8, 27 + 11 * (convex_hull.size() + 1));
    }
}


