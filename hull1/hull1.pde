import java.util.ArrayList;

void setup(){
  
  // generate input points (by hand for now)
  ArrayList<Point> points = new ArrayList<Point>();
  points.add(new Point(1,0));
  points.add(new Point(0,1));
  points.add(new Point(0,0));
  points.add(new Point(1,1));
  
  // find hull points
  ArrayList<Point> hull = naiveHull(points);
  for (int i=0; i<hull.size(); i++){
    System.out.println(hull.get(i)); 
  }
  
  
  
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
  
  for (int i=0; i<hull_pairs.size(); i++){
    System.out.println(hull_pairs.get(i).first + " " + hull_pairs.get(i).second); 
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

class PointPair{
  public Point first, second; 
  
  public PointPair(Point _first, Point _second){
    first = _first;
    second = _second;
  }
}
