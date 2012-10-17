class Vector2 implements Hashable {
  Float32Array dest;
  
  Vector2(double x, double y) {
    dest = new Float32Array(2);
    dest[0] = x;
    dest[1] = y;
  }
  
  
  double get X() => dest[0];
  void set X(double x) { dest[0] = x; }
  
  double get Y() => dest[1];
  void set Y(double y) { dest[1] = y; }
  
  String toString() => "[$X, $Y]";
  
  bool operator==(Object object) {
    if (object is! Vector2) return false;  
    return X == object.X && Y == object.Y;
  }
  
  int hashCode() {
    var erg  = 37;
        erg += 37 * X.hashCode();
        erg += 37 * Y.hashCode() * erg;
    return erg;
  }

}
