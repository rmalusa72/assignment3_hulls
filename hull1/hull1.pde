import java.util.ArrayList;
import java.util.Comparator;
import java.util.Collections;

ArrayList<Point> points = new ArrayList<Point>();
ArrayList<Point> hull = new ArrayList<Point>();

void setup(){
  surface.setSize(600,600);
  background(255);
  noLoop();
  
  // generate input points (by hand for now)
  points = generatePoints(600, 600, 5);
  
  /*
  // find hull points
  hull = naiveHull(points);
  for (int i=0; i<hull.size(); i++){
    System.out.println(hull.get(i)); 
  }
  */
  
  print("Points:");
  for(int i=0; i<points.size(); i++){
    System.out.println(points.get(i)); 
  }
  hull = grahamScan(points);
  

}

void draw(){
  stroke(0);
  for (int i=0; i<points.size(); i++){
    Point pt = points.get(i);
    circle(pt.x, 600-pt.y, 5);
  }
  stroke(255, 0, 0);
  noFill();
  
  /*
  Point hl = hull.get(0);
  circle(hl.x, 600-hl.y, 10);
  Point last_hl = hl;
  
  for (int i=1; i<hull.size(); i++){
    hl = hull.get(i);
    circle(hl.x, 600-hl.y, 10);
    line(last_hl.x, 600-last_hl.y, hl.x, 600-hl.y);
    last_hl = hl;
    
    
  }
  
  hl = hull.get(0);
  line(last_hl.x, 600-last_hl.y, hl.x, 600-hl.y);
  */
}

ArrayList<Point> naiveHull(ArrayList<Point> input_points){
  ArrayList<PointPair> hull_pairs = new ArrayList<PointPair>();
  Point a, b, c;
  
  for (int i=0; i<input_points.size(); i++){
    a = input_points.get(i);
    for (int j=0; j<input_points.size(); j++){
      if (i != j){
        b = input_points.get(j);

        // a, b will iterate through every pair of distinct points
        boolean onHull = true;
        
        for (int k=0; k<input_points.size(); k++){
          if (k!=i && k!=j){
            c = input_points.get(k);
            
            int side = sideCheck(a,b,c);
            if (side == -1){
              // c is to the left of ab
              onHull = false;
              break;
            } else if (side == 0){
              // c is on ab
              // figure out which one is in the middle. if c isn't in the middle, pair is not valid
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
        
        if (onHull){
          hull_pairs.add(new PointPair(a,b));
        }
        
      }
    }
  }
  
  // Process hullpair to put in order, remove duplicates
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
  
  float min_y = input.get(0).y;
  Point lowest_point = input.get(0);
  int lowest_point_index = 0;
  Point pt;
  
  // Find rightmost bottom point
  for(int i=1; i<input.size(); i++){
    pt = input.get(i);
    if (pt.y < min_y){
      lowest_point = pt;
      min_y = pt.y;
      lowest_point_index = i;
    } else if (pt.y == min_y){
      if (pt.x > lowest_point.x){
        lowest_point = pt;
        min_y = pt.y;
        lowest_point_index = i;
      }
    }
  }
 
  // calculate angles with all other points and sort, getting rid of any points that lie on another ray
  // iterate through checking angle at each step
  // et voila 
  
  System.out.println("lowest point:" + lowest_point);
  
  ArrayList<Point> angular_sorted = angularSort(input, lowest_point_index);
  for (int i=0; i<angular_sorted.size(); i++){
    System.out.println(angular_sorted.get(i)); 
  }
  
  return new ArrayList<Point>();
}

ArrayList<Point> generatePoints(float maxx, float maxy, int num_points){
  ArrayList<Point> rtn = new ArrayList<Point>();
  for (int i=0; i<num_points; i++){
    rtn.add(new Point(random(maxx), random(maxy)));
  }
  return rtn;
}

// Angular sort with deletion of points that are on rays
// Assuming anchor_index points to rightmost bottom point 
ArrayList<Point> angularSort(ArrayList<Point> input, int anchor_index){
  ArrayList<PointWithArccos> to_be_sorted = new ArrayList<PointWithArccos>();
  
  // for each point, find the angle its ray with anchor makes with x axis
  // angles range from 0 to 180, so cosine is monotonically decreasing? so we don't actually have to take arc cosine
  // cos (theta) = u dot v / (|u| * |v|)
  // since our u is [1, 0], u dot v is v.y and |u|*|v| is |v|
  
  for (int i=0; i<input.size(); i++){
    if (i != anchor_index){
      
      Point pt = input.get(i);
      to_be_sorted.add(new PointWithArccos(pt, new Fraction(pt.y, (float)distance(new Point(0,0), pt))));
      
    }
  }
  
  // Sort points by corresponding arccos
  Collections.sort(to_be_sorted, new SortByAngle());
  
  // Iterate through and remove doubles (which will be next to each other)
  ArrayList<Point> sorted = new ArrayList<Point>();
  sorted.add(to_be_sorted.get(0).pt);
  PointWithArccos last_pt = to_be_sorted.get(0);
  for (int i=1; i<to_be_sorted.size(); i++){
     PointWithArccos pt = to_be_sorted.get(i);
     if (!pt.arccos.equals(last_pt.arccos)){
       sorted.add(pt.pt);
       last_pt = pt;
     }
  }
  
  // Return sorted list 
  return sorted;
}

// Returns 1 if c is to the right of ab, 0 if c is on ab, -1 otherwise
int sideCheck(Point a, Point b, Point c){
  
  // We want the coefficient of i in the cross product of vectors ab and ac
  // (The other two coefficients should be zero, and the sign of this one gives the side)
  
  // ab = [b.x - a.x, b.y - a.y]
  // ac = [c.x - a.x, c.y - a.y]
  
  // we want ab.x * ac.y - ab.y * ac.x
  
  float i_coefficient = (b.x-a.x)*(c.y-a.y) - (b.y-a.y)*(c.x-a.x);
  if (i_coefficient > 0){
    return 1;
  } else if (i_coefficient == 0){
    return 0;
  } else {
    return -1;
  }
}

double distance(Point a, Point b){
  return Math.pow((double)(a.x - b.x),2) + Math.pow((double)(a.y - b.y), 2);
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

class PointWithArccos{
  Point pt; 
  Fraction arccos;
  
  public PointWithArccos(Point _pt, Fraction _arccos){
    pt = _pt;
    arccos = _arccos;
  }
}

class SortByAngle implements Comparator<PointWithArccos>{
  int compare(PointWithArccos p1, PointWithArccos p2){
    return p1.arccos.compareTo(p2.arccos);
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
  
  public int compareTo(Fraction f){
    if(this.n * f.d == this.d*f.n){
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
  public boolean equals(Object o){
    if (o instanceof Fraction){
      return (this.compareTo((Fraction) o) == 0);
    }
    return false;
  }
}
