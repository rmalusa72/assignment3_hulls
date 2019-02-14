import java.util.ArrayList;

class Point{
  public float x, y;
  
  // TODO implement equals method
}

class PointPair{
  public Point first, second; 
  
  public PointPair(Point _first, Point _second){
    first = _first;
    second = _second;
  }
}

void setup(){
  
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
        
        // TODO: deal with degenerate cases; discard any point that is on line maybe? 
        for (int k=0; k<input_points.size(); k++){
          if (k!=i && k!=j){
            c = input_points.get(k);
            if (!isOnRight(a,b,c)){
              onHull = false;
              break;
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
  
  for (int i=1; i<hull_pairs.size(); i++){
    
    PointPair pair = hull_pairs.get(i);
    
    // If first item of pair in question matches last item in list, 
    // add the second item of the pair to the list
    if (pair.first.equals(hull.get(hull.size()-1))){
      hull.add(pair.second);
    }
  }
  
  return hull;
}

// Returns true if c is to the right of ab, false otherwise
boolean isOnRight(Point a, Point b, Point c){
  // TODO implement this. and account for case where c is on ab
  return true;
}
