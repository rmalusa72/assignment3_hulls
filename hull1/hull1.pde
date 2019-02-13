import java.util.ArrayList;

class Point{
  public float x, y;
}

void setup(){
  
}

ArrayList<Point> findHullNaively(ArrayList<Point> input_points){
  ArrayList<Point> hull = new ArrayList<Point>();
  Point a, b;
  
  for (int i=0; i<input_points.size(); i++){
    a = input_points.get(i);
    for (int j=i+1; j<input_points.size(); j++){
      b = input_points.get(j);
      
      // The two enclosing loops will iterate through every pair of points a,b
      // Now we need to compare every other point to the line ab
      
      boolean left = false; // Whether we have encountered a point to the left
      boolean right = false; // Whether we have encountered a point to the right
      boolean all_on_same_side = true;
      
      for (int k = 0; k<input_points.size(); k++){
        if (k!=i && k!=j){
          Point c = input_points.get(k);
          int side = checkSide(a, b, c);
          
          if (side == -1){
            left = true;
            if(right){
             all_on_same_side = false;
             break;
            }
          }else if (side == 1){
            right = true;
            if(left){
             all_on_same_side = false;
             break;
            }
          }
        }
      }
      
      if (all_on_same_side){
        hull.add(a);
        hull.add(b);
      }
    }
  }
  
  // Remove duplicates
  ArrayList<Point> hull_without_duplicates = new ArrayList<Point>();
  for (int i=0; i<hull.size(); i++){
    if (!hull_without_duplicates.contains(hull.get(i))){
      hull_without_duplicates.add(hull.get(i)); 
    }
  }
  
  return hull_without_duplicates;
}

// Returns -1 if the point c is on the left side of the directed line segment AB,
// 0 if it is on AB and 1 if it is to the right
int checkSide(Point a, Point b, Point c){
  
  return 0;
}
