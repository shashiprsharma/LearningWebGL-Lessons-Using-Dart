class Vector4 {
  Float32Array dest;
  
  
  Vector4._internal() {
    dest = new Float32Array(4);
  }  
  
  static List<Vector4> _recycled;
  
  void recycle() {
    if(_recycled == null) _recycled = new List<Vector4>();
    _recycled.add(this);
  }
  
  static Vector4 _createVector() {
    Vector4 vec;
    if(_recycled == null) _recycled = new List<Vector4>();
    if(_recycled.length > 0) {
      vec = _recycled[0];
      _recycled.removeRange(0, 1);
      return vec;
    }
    return new Vector4._internal();
  }
  
  
  
  
  //Float32Array dest;

  
  factory Vector4(double x, double y, double z, double w) {
    Vector4 vec = _createVector();
    vec.dest[0] = x;
    vec.dest[1] = y;
    vec.dest[2] = z;
    vec.dest[3] = w;
    return vec;
  }
  
  factory Vector4.zero() {
    return _createVector();
  }
  
  factory Vector4.fromList(List<double> list) {
    Vector4 vec = _createVector();
    vec.dest[0] = list[0] == null ? 0 : list[0];
    vec.dest[1] = list[1] == null ? 0 : list[1];
    vec.dest[2] = list[2] == null ? 0 : list[2];
    vec.dest[3] = list[3] == null ? 0 : list[3];
    return vec;
  }
  
  
  double get X() => dest[0];
  void set X(double val) { dest[0] = val;}
  double get Y() => dest[1];
  void set Y(double val) { dest[1] = val;}
  double get Z() => dest[2];
  void set Z(double val) { dest[2] = val;}
  double get W() => dest[3];
  void set W(double val) { dest[3] = val;}
  
  /**
   * Returns a string representation of this vector
   */
  String toString() => "[$X, $Y, $Z, $W]";
  
}
