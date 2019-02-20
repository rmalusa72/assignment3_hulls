import java.util.ArrayList;
import java.util.Comparator;
import java.util.Collections;

int WINDOW_SIZE = 600; 
int LEFT_OF_LINE = -1;
int ON_LINE = 0;
int RIGHT_OF_LINE = 1;

ArrayList<Point> points;
ArrayList<Point> hull;

void setup(){
  surface.setSize(WINDOW_SIZE, WINDOW_SIZE);
  noLoop();
}

void draw(){
  ArrayList<Point> nicePoints = new ArrayList<Point>();
  nicePoints.add(new Point(10,10));
  nicePoints.add(new Point(200, 200));
  nicePoints.add(new Point(500, 50));
  nicePoints.add(new Point(30, 400));
  nicePoints.add(new Point(150, 150));
  
  ArrayList<Point> collinearityPoints = new ArrayList<Point>();
  collinearityPoints.add(new Point(100,100));
  collinearityPoints.add(new Point(150, 150));
  collinearityPoints.add(new Point(200, 200));
  collinearityPoints.add(new Point(100, 200));
  collinearityPoints.add(new Point(200, 100));
  collinearityPoints.add(new Point(100, 150));
  
  ArrayList<Point> linearPoints = new ArrayList<Point>();
  linearPoints.add(new Point(100, 100));
  linearPoints.add(new Point(100, 200));
  linearPoints.add(new Point(100, 300));
  linearPoints.add(new Point(100, 400));
  
  ArrayList<Point> nearCircularPoints = generatePoints(300, 300, 200, 20);
  
  ArrayList<Point> random1000 = generatePoints(300, 300, 200, 1000);
  ArrayList<Point> random10000 = generatePoints(300, 300, 200, 10000);
  ArrayList<Point> random1000000 = generatePoints(300, 300, 200, 1000000);

  points = nicePoints;
  hull = naiveHull(points);
  println(hull);
  drawPoints();
  saveFrame("nice_points_naive.png");
  hull = grahamScan(points);
  println(hull);
  drawPoints();
  saveFrame("nice_points_graham.png");
  
  points = collinearityPoints;
  hull = naiveHull(points);
  println(hull);
  drawPoints();
  saveFrame("degenerate_points_naive.png");
  hull = grahamScan(points);
  println(hull);
  drawPoints();
  saveFrame("degenerate_points_graham.png");
  
  points = linearPoints;
  hull = naiveHull(points);
  println(hull);
  drawPoints();
  saveFrame("linear_points_naive.png");
  hull = grahamScan(points);
  println(hull);
  drawPoints();
  saveFrame("linear_points_graham.png");
  
  points = nearCircularPoints;
  hull = naiveHull(points);
  println(hull);
  drawPoints();
  saveFrame("circular_points_naive.png");
  hull = grahamScan(points);
  println(hull);
  drawPoints();
  saveFrame("circular_points_graham.png");
  
  points = random1000;
  int naiveStart = millis();
  hull = naiveHull(points);
  int naiveEnd = millis();
  drawPoints();
  saveFrame("thousand_points.png");
  println("Naive algorithm on 1000 points: " + (naiveEnd-naiveStart) + " milliseconds");
  int grahamStart = millis();
  hull = grahamScan(points);
  int grahamEnd = millis();
  println("Graham scan algorithm on 1000 points: " + (grahamEnd-grahamStart) + " milliseconds");
  
  points = random10000;
  naiveStart = millis();
  hull = naiveHull(points);
  naiveEnd = millis();
  println("Naive algorithm on 10000 points: " + (naiveEnd-naiveStart) + " milliseconds");
  grahamStart = millis();
  hull = grahamScan(points);
  grahamEnd = millis();
  println("Graham scan algorithm on 10000 points: " + (grahamEnd-grahamStart) + " milliseconds");
  
  points = random1000000;
  grahamStart = millis();
  hull = grahamScan(points);
  grahamEnd = millis();
  println("Graham scan algorithm on 1000000 points: " + (grahamEnd-grahamStart) + " milliseconds");
  naiveStart = millis();
  hull = naiveHull(points);
  naiveEnd = millis();
  println("Naive algorithm on 1000000 points: " + (naiveEnd-naiveStart) + " milliseconds");

}

void drawPoints(){
  clear();
  background(255);
  
  // Draw all points
  stroke(0);
  for (int i=0; i<points.size(); i++){
    Point pt = points.get(i);
    circle(pt.x, 600-pt.y, 5);
  }
  
  // Circle hull points and draw lines between them
  stroke(255, 0, 0);
  noFill();
  Point hull_point;
  Point last_point = hull.get(0);
  for (int i=0; i<hull.size(); i++){
    hull_point = hull.get(i);
    circle(hull_point.x, 600-hull_point.y, 10);
    line(last_point.x, 600-last_point.y, hull_point.x, 600-hull_point.y);
    last_point = hull_point; 
  }
  
  hull_point = hull.get(0);
  line(last_point.x, 600-last_point.y, hull_point.x, 600-hull_point.y);
}

ArrayList<Point> naiveHull(ArrayList<Point> input_points){
  
  ArrayList<PointPair> hull_pairs = new ArrayList<PointPair>();
  Point a, b, c;
  
  for (int i=0; i<input_points.size(); i++){
    a = input_points.get(i);
    for (int j=0; j<input_points.size(); j++){
      if (i != j){
        b = input_points.get(j);
        boolean onHull = true;
        for (int k=0; k<input_points.size(); k++){
          if (k!=i && k!=j){
            c = input_points.get(k);
            int side = sideCheck(a,b,c);
            if (side == LEFT_OF_LINE){
              // c is to the left of ab, so ab is not a valid hull pair and we need not examine more points
              onHull = false;
              break;
            } else if (side == ON_LINE){
              // ac is parallel to ab; if c is between a and b, ab could still be valid, otherwise not
              double ab_distance = distance(a,b);
              double bc_distance = distance(b,c);
              double ac_distance = distance(a,c);
              if (ab_distance < ac_distance || ab_distance < bc_distance){
                onHull = false;
                break;
              }
            }
          }
        }
        
        // If all other points were on or to the right of ab, a and b are on the hull (in that order)
        if (onHull){
          hull_pairs.add(new PointPair(a,b));
        }
      }
    }
  }
  
  // Process hull pairs to join disordered pairs into a single sequence
  // We start with an arbitrary pair of points (the first), then at each
  // step, we search for the pair that begins with the point that is 
  // currently last in our list of hull points, to "hook" pairs together.
  ArrayList<Point> hull = new ArrayList<Point>();
  hull.add(hull_pairs.get(0).first);
  hull.add(hull_pairs.get(0).second);
  
  while (hull.size() < hull_pairs.size()){
    Point hook = hull.get(hull.size()-1);
    for (int i=0; i<hull_pairs.size(); i++){
      if (hull_pairs.get(i).first.equals(hook)){
        hull.add(hull_pairs.get(i).second);
      }
    }
  }
  return hull;
}

ArrayList<Point> grahamScan(ArrayList<Point> input){
  
  // Find rightmost bottom point (the "anchor" of the angular sort)
  int anchor_index = 0;
  Point anchor = input.get(0);
  Point pt; 
  
  for (int i=1; i<input.size(); i++){
    pt = input.get(i);
    if (pt.y < anchor.y || (pt.y == anchor.y && pt.x > anchor.x)){
      anchor_index = i;
      anchor = pt;
    }
  }

  // Angular sort orders points by angle and deletes points that lie on another ray
  ArrayList<Point> angular_sorted = angularSort(input, anchor_index);
  
  // Add first two points, then iterate through adding points and checking angle
  ArrayList<Point> hull = new ArrayList<Point>();
  hull.add(anchor);
  hull.add(angular_sorted.get(0));
  Point nextPoint;
  
  int i=1; 
  while (i < angular_sorted.size()){
    nextPoint = angular_sorted.get(i);
    int side = sideCheck(hull.get(hull.size()-2), hull.get(hull.size()-1), nextPoint);
    if (side == LEFT_OF_LINE){
      // Legal left turn is formed
      hull.add(nextPoint);
      i += 1;
    } else {
      // Right turn is formed, remove last point
      hull.remove(hull.size()-1);
    }
  }
  return hull;
}

ArrayList<Point> generatePoints(float center_x, float center_y, float radius, int num_points){
  ArrayList<Point> rtn = new ArrayList<Point>();
  float angle;
  for (int i=0; i<num_points; i++){
    angle = random(0, 360);
    rtn.add(new Point(center_x + cos(angle)*radius, center_y + sin(angle)*radius));
  }
  return rtn;
}

// Angular sort with deletion of points that are on rays,
// where anchor_index points to the rightmost bottom point
// that is used to sort
ArrayList<Point> angularSort(ArrayList<Point> input, int anchor_index){
  ArrayList<PointWithCos> pointAnglePairs = new ArrayList<PointWithCos>();
  Point anchor = input.get(anchor_index);
  
  // we want to sort by the angle that the ray between each 
  // point and the anchor point makes with the x axis; these angles range
  // from 0 to 180 degrees, so we can use just the cosine values, knowing
  // that they are monotonically decreasing for this range
  
  // cos (theta) = u dot v / (|u| * |v|)
  // since our u is [1, 0], u dot v is v.x and |u|*|v| is |v|
  for (int i=0; i<input.size(); i++){
    if (i != anchor_index){
      Point pt = input.get(i);
      pointAnglePairs.add(new PointWithCos(pt, new Fraction(pt.x - anchor.x, (float)distance(anchor, pt))));
    }
  }
  
  // Sort points by corresponding cosine
  Collections.sort(pointAnglePairs, new SortByCosine());
  
  // Iterate through and remove doubles (which will be next to each other), and discard angles
  ArrayList<Point> sorted = new ArrayList<Point>();
  PointWithCos lastPoint = pointAnglePairs.get(0);
  sorted.add(pointAnglePairs.get(0).pt);
  
  for (int i=1; i<pointAnglePairs.size(); i++){
    PointWithCos nextPoint = pointAnglePairs.get(i);
    if(!nextPoint.cosine.equals(lastPoint.cosine)){
      sorted.add(nextPoint.pt);
      lastPoint = nextPoint;
    } else {
      // Keep whichever is further from anchor point
      if (distance(anchor, nextPoint.pt) > distance(anchor, lastPoint.pt)){
        sorted.set(sorted.size()-1, nextPoint.pt);
      }
    }
  }
  
  // Return sorted list 
  return sorted;
}

// Checks position of c with respect to ab and returns LEFT_OF_LINE, ON_LINE or RIGHT_OF_LINE
int sideCheck(Point a, Point b, Point c){
  
  // We want the coefficient of i in the cross product of vectors ab and ac
  // (The other two coefficients should be zero, and the sign of this one gives the side)
  // ab = [b.x - a.x, b.y - a.y]
  // ac = [c.x - a.x, c.y - a.y]
  // so we want ab.x * ac.y - ab.y * ac.x
  
  float i_coefficient = (b.x-a.x)*(c.y-a.y) - (b.y-a.y)*(c.x-a.x);
  if (i_coefficient > 0){
    return RIGHT_OF_LINE;
  } else if (i_coefficient == 0){
    return ON_LINE;
  } else {
    return LEFT_OF_LINE;
  }
}

double distance(Point a, Point b){
  return Math.sqrt(Math.pow((double)(a.x - b.x),2) + Math.pow((double)(a.y - b.y), 2));
}

boolean fuzzyEquals(float a, float b){
  if (a==b){
    return true; 
  } else if (a < b && a + 0.00000001 > b){
    return true;
  } else if (b < a && b + 0.00000001 > a){
    return true;
  }
  return false;
  
}

class Point{
  public float x, y;
  
  public Point(float _x, float _y){
    x = _x;
    y = _y;
  }
  
  @Override
  public boolean equals(Object o){
    if (o instanceof Point){
      return (this.x == ((Point)o).x && this.y == ((Point)o).y);
    }
    return false;
  }
  
  @Override
  public String toString(){
    return this.x + "," + this.y;
  }
}

class PointWithCos{
  Point pt; 
  Fraction cosine;
  
  public PointWithCos(Point _pt, Fraction _cosine){
    pt = _pt;
    cosine = _cosine;
  }
  
  @Override
  public String toString(){
    return this.pt + " " + this.cosine; 
  }
}

class SortByCosine implements Comparator<PointWithCos>{
  int compare(PointWithCos p1, PointWithCos p2){
    return p1.cosine.compareTo(p2.cosine);
  }
}

class PointPair{
  public Point first, second; 
  
  public PointPair(Point _first, Point _second){
    first = _first;
    second = _second;
  }
}

class Fraction implements Comparable<Fraction>{
  public float n, d;
  
  public Fraction(float numerator, float denominator){
    n = numerator;
    d = denominator;
  }
  
  @Override
  public int compareTo(Fraction f){
    if(fuzzyEquals(this.n*f.d, f.n*this.d)){
      return 0; 
    } else {
      if (this.n/this.d < f.n/f.d){
        return -1; 
      } else {
        return 1; 
      }
    }
  }
  
  @Override
  public String toString(){
    return this.n + "/" + this.d + ": " + (this.n/this.d); 
  }
  
  @Override
  public boolean equals(Object o){
    if (o instanceof Fraction){
      return (this.compareTo((Fraction) o) == 0);
    }
    return false;
  }
}
