import java.util.ArrayList;

class Point{
  float x, y;
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
      
      // Iterate through every pair of points a,b
      
      
      
    }
  }
     
  
  return hull;
}
