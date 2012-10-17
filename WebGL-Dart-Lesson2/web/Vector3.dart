class Vector3 implements Hashable {
  Float32Array dest;
  
  

  
  Vector3._internal() {
    dest = new Float32Array(3);
  }
  
  static List<Vector3> _recycled;
  
  void recycle() {
    if(_recycled == null) _recycled = new List<Vector3>();
    _recycled.add(this);
  }
  
  static Vector3 _createVector() {
    Vector3 vec;
    if(_recycled == null) _recycled = new List<Vector3>();
    if(_recycled.length > 0) {
      vec = _recycled[0];
      _recycled.removeRange(0, 1);
      return vec;
    }
    return new Vector3._internal();
  }
  
  
  // Constructors
  
  factory Vector3.forward() {
    Vector3 vec = _createVector();
    vec.dest[0] = 0;
    vec.dest[1] = 0;
    vec.dest[2] = -1;
    return vec;    
  }
  
  factory Vector3.fromValues(double x, double y, double z) {
    Vector3 vec = _createVector();
    vec.dest[0] = x;
    vec.dest[1] = y;
    vec.dest[2] = z;
    return vec;
  }
  
  factory Vector3.zero() {
    return _createVector();
  }
  
  factory Vector3.fromSingleValues(double value) {
    Vector3 vec = _createVector();
    vec.dest[0] = value;
    vec.dest[1] = value;
    vec.dest[2] = value;
    return vec;
  }
  
  factory Vector3.fromList(List<double> list) {
    Vector3 vec = _createVector();
    vec.dest[0] = list[0] == null ? 0.0 : list[0].toDouble();
    vec.dest[1] = list[1] == null ? 0.0 : list[1].toDouble();
    vec.dest[2] = list[2] == null ? 0.0 : list[2].toDouble();
    return vec;
  }
  
  factory Vector3([double x = 0.0, double y = 0.0, double z = 0.0]) {
    Vector3 vec = _createVector();
    vec.dest[0] = x.toDouble();
    vec.dest[1] = y.toDouble();
    vec.dest[2] = z.toDouble();
    return vec;
  }
  
  
  double get X() => dest[0];
  void set X(double val) { dest[0] = val;}
  double get Y() => dest[1];
  void set Y(double val) { dest[1] = val;}
  double get Z() => dest[2];
  void set Z(double val) { dest[2] = val;}
  
  void setXYZ(double x, double y, double z) {
    dest[0] = x;
    dest[1] = y;
    dest[2] = z;
  }
  
  

  
  
  /**
   * Clones object [vec].
   * Writes it into [result] or creates a new Vector3 if not specified.
   */
  static Vector3 Clone(Vector3 vec, [Vector3 result]) {
    if(result == null) result = new Vector3.zero();
    result.dest[0] = vec.dest[0];
    result.dest[1] = vec.dest[1];
    result.dest[2] = vec.dest[2];
    return result;
  }
  
  /// Clones this Vector3 object
  Vector3 clone([Vector3 result]) {
    return Vector3.Clone(this, result);
  }

  /**
   * Performs a vector addition between [vec] and [other].
   * Writes it into [result] or creates a new Vector3 if not specified.
   */
  static Vector3 Add(Vector3 vec, Vector3 other, [Vector3 result]) {
    if(result == null) result = new Vector3.zero();

    result.dest[0] = vec.dest[0] + other.dest[0];
    result.dest[1] = vec.dest[1] + other.dest[1];
    result.dest[2] = vec.dest[2] + other.dest[2];
    return result;
  }
  Vector3 add(Vector3 vec) => Vector3.Add(this, vec, this);
  /**
   * Performs a vector subtraction between [vec] and [other].
   * Writes it into [result] or creates a new Vector3 if not specified.
   */
  static Vector3 Subtract(Vector3 vec, Vector3 other, [Vector3 result]) {
    if(result == null) result = new Vector3.zero();

    result.dest[0] = vec.dest[0] - other.dest[0];
    result.dest[1] = vec.dest[1] - other.dest[1];
    result.dest[2] = vec.dest[2] - other.dest[2];
    return result;
  }
  Vector3 subtract(Vector3 vec) => Vector3.Subtract(this, vec, this);

  /**
   * Performs a vector multiplication between [vec] and [value].
   * writes it into [result] or creates a new Vector3 if not specified
   */  
  static Vector3 MultiplyValue(Vector3 vec, double value, [Vector3 result]) {
    if(result == null) result = new Vector3.zero();
    result.dest[0] = vec.dest[0] * value;
    result.dest[1] = vec.dest[1] * value;
    result.dest[2] = vec.dest[2] * value;
    return result;    
  }
  Vector3 multiplyValue(double value) => MultiplyValue(this,value,this);
  /**
   * Performs a vector multiplication between [vec] and [other].
   * writes it into [result] or creates a new Vector3 if not specified
   */
  static Vector3 Multiply(Vector3 vec, Vector3 other, [Vector3 result]) {
    if(result == null) result = new Vector3.zero();
    result.dest[0] = vec.dest[0] * other.dest[0];
    result.dest[1] = vec.dest[1] * other.dest[1];
    result.dest[2] = vec.dest[2] * other.dest[2];
    return result;
  }
/// Performs a vector multiplication between this and [other].
  Vector3 multiply(Vector3 other) => Multiply(this,other,this);

  /**
   * Transforms a [vec] with the given [quat]
   * Writes it into [result] or creates a new Vector3 if not specified
   */
  static Vector3 MultiplyQuat( Vector3 vec, Quaternion quat, [Vector3 result]) {
    if(result == null) { result = new Vector3.zero(); }
  
    var x = vec.dest[0], y = vec.dest[1], z = vec.dest[2],
        qx = quat.dest[0], qy = quat.dest[1], qz = quat.dest[2], qw = quat.dest[3],
  
        // calculate quat * vec
        ix = qw * x + qy * z - qz * y,
        iy = qw * y + qz * x - qx * z,
        iz = qw * z + qx * y - qy * x,
        iw = -qx * x - qy * y - qz * z;
  
    // calculate result * inverse quat
    result.dest[0] = ix * qw + iw * -qx + iy * -qz - iz * -qy;
    result.dest[1] = iy * qw + iw * -qy + iz * -qx - ix * -qz;
    result.dest[2] = iz * qw + iw * -qz + ix * -qy - iy * -qx;
  
    return result;
  }
  Vector3 multiplyQuat(Quaternion quat) => Vector3.MultiplyQuat(this,quat,this);
  
  
  
  /**
   * Negates the components of a [vec]
   * Writes it into [result] or creates a new Vector3 if not specified.
   */
  static Vector3 Negate(Vector3 vec, [Vector3 result]) {
    if(result == null) result = new Vector3.zero();
  
    result.dest[0] = -vec.dest[0];
    result.dest[1] = -vec.dest[1];
    result.dest[2] = -vec.dest[2];
    return result;
  }
  /// Negate this
  Vector3 negate() => Vector3.Negate(this,this);

  /**
   * Multiplies the components of [vec] by a scalar value [val]
   * Writes it into [result] or creates a new Vector3 if not specified.
   */
  static Vector3 Scale(Vector3 vec, double val, [Vector3 result]) {
      if (result == null || vec === result) {
          vec.dest[0] *= val;
          vec.dest[1] *= val;
          vec.dest[2] *= val;
          return vec;
      }

      result.dest[0] = vec.dest[0] * val;
      result.dest[1] = vec.dest[1] * val;
      result.dest[2] = vec.dest[2] * val;
      return result;
  }
  
  Vector3 scale(double scaleVal) => Scale(this,scaleVal, this);

  /**
   * Generates a unit vector of the same direction as the provided [vec]
   * If vector length is 0, returns [0, 0, 0]
   * Writes it into [result] or creates a new Vector3 if not specified.
   */
  static Vector3 Normalize(Vector3 vec, [Vector3 result]) {
      if(result == null) result = new Vector3.zero();

      var x = vec.dest[0], y = vec.dest[1], z = vec.dest[2],
          len = sqrt(x * x + y * y + z * z);

      if (len.isNaN()) {
          result.dest[0] = 0.0;
          result.dest[1] = 0.0;
          result.dest[2] = 0.0;
          return result;
      } else if (len === 1) {
          result.dest[0] = x;
          result.dest[1] = y;
          result.dest[2] = z;
          return result;
      }

      len = 1 / len;
      result.dest[0] = x * len;
      result.dest[1] = y * len;
      result.dest[2] = z * len;
      return result;
  }
  /// Normalize this
  /// If vector length is 0, returns [0, 0, 0]
  Vector3 normalize() => Normalize(this,this);

 /**
   * Generates the cross product of [vec] and [other]
   * Writes it into [result] or creates a new Vector3 if not specified.
   */
  static Vector3 Cross(Vector3 vec, Vector3 other, [Vector3 result]) {
    if(result == null) result = new Vector3.zero();

    var x = vec.dest[0], y = vec.dest[1], z = vec.dest[2],
        x2 = other.dest[0], y2 = other.dest[1], z2 = other.dest[2];

    result.dest[0] = y * z2 - z * y2;
    result.dest[1] = z * x2 - x * z2;
    result.dest[2] = x * y2 - y * x2;
    return result;
  }
  Vector3 cross(Vector3 other) => Cross(this,other,this);
  
 /**
   *  Restricts [value] to be within [min] and [max].
   *  Writes it into [result] or creates a new Vector3 if not specified.
   */
  static Vector3 Clamp(Vector3 value, Vector3 min, Vector3 max, [Vector3 result])
  {
    if(result == null) result = new Vector3.zero();
    double x = value.X;
    x = (x > max.X) ? max.X : x;
    x = (x < min.X) ? min.X : x;

    double y = value.Y;
    y = (y > max.Y) ? max.Y : y;
    y = (y < min.Y) ? min.Y : y;

    double z = value.Z;
    z = (z > max.Z) ? max.Z : z;
    z = (z < min.Z) ? min.Z : z;

    result.setXYZ(x, y, z);
    return result;
  }
  /// Restricts this to be within [min] and [max].
  Vector3 clamp(Vector3 min, Vector3 max) => Clamp(this,min,max,this);

  /// Caclulates the length of this
  double get length() => sqrt(pow(X,2) + pow(Y,2) + pow(Z,2) );
  double get lengthSquare() => pow(X,2) + pow(Y,2) + pow(Z,2);

  /**
   * Caclulates the dot product of [vec] and [other]
   * Writes it into [result] or creates a new Vector3 if not specified.
   */
  static double Dot(Vector3 vec, [Vector3 other]) {
    if(other == null) other = vec;
      return vec.dest[0] * other.dest[0] + vec.dest[1] * other.dest[1] + vec.dest[2] * other.dest[2];
  }
  double dot([Vector3 other]) => Dot(this,other);

  /**
   * Generates a unit vector pointing from [vec] vector to [other]
   * Writes it into [result] or creates a new Vector3 if not specified.
   */
  static Vector3 Direction(Vector3 vec, Vector3 other, [Vector3 result]) {
      if(result == null) result = new Vector3.zero();

      var x = vec.dest[0] - other.dest[0],
          y = vec.dest[1] - other.dest[1],
          z = vec.dest[2] - other.dest[2],
          len = sqrt(x * x + y * y + z * z);

      if (len.isNaN()) {
          result.dest[0] = 0.0;
          result.dest[1] = 0.0;
          result.dest[2] = 0.0;
          return result;
      }

      len = 1 / len;
      result.dest[0] = x * len;
      result.dest[1] = y * len;
      result.dest[2] = z * len;
      return result;
  }
  
  /**
   * Transforms [vec] with the [mat], writes it into [result] or into an new Vector3
   * 4th vector component is implicitly '1'
   */
  static Vector3 MultiplyMatrix(Vector3 vec, Matrix mat, [Vector3 result]) {
      if(result == null) result = new Vector3.zero();
  
      var x = vec.dest[0], y = vec.dest[1], z = vec.dest[2];
  
      result.dest[0] = mat.dest[0] * x + mat.dest[4] * y + mat.dest[8] * z + mat.dest[12];
      result.dest[1] = mat.dest[1] * x + mat.dest[5] * y + mat.dest[9] * z + mat.dest[13];
      result.dest[2] = mat.dest[2] * x + mat.dest[6] * y + mat.dest[10] * z + mat.dest[14];
  
      return result;
  }
  Vector3 multiplyMat(Matrix mat) => MultiplyMatrix(this,mat,this);
  

  /**
   * Performs a linear interpolation with [lerpVal] between [vec] and [other]
   * Writes it into [result] or creates a new Vector3 if not specified.
   */
  static Vector3 Lerp(Vector3 vec, Vector3 other, double lerpVal, [Vector3 result]) {
    if(result == null) result = new Vector3.zero();

    result.dest[0] = vec.dest[0] + lerpVal * (other.dest[0] - vec.dest[0]);
    result.dest[1] = vec.dest[1] + lerpVal * (other.dest[1] - vec.dest[1]);
    result.dest[2] = vec.dest[2] + lerpVal * (other.dest[2] - vec.dest[2]);
  
    return result;
  }
  /// Performs a linear interpolation with [lerpVal] between [this] and [other]
  void lerp(Vector3 other, double lerpVal) {
    Lerp(this, other, lerpVal, this);
  }
  

  /**
   * Calculates the euclidian distance between [vec] and [other]
   * Writes it into [result] or creates a new Vector3 if not specified.
   */
  static double Distance(Vector3 vec, Vector3 other) {
    var x = other.dest[0] - vec.dest[0],
        y = other.dest[1] - vec.dest[1],
        z = other.dest[2] - vec.dest[2];
        
    return sqrt(x*x + y*y + z*z);
  }
  double distance(Vector3 other) => Vector3.Distance(this, other);
  
  static double DistanceSquared(Vector3 vec, Vector3 other) {
    var x = other.dest[0] - vec.dest[0],
        y = other.dest[1] - vec.dest[1],
        z = other.dest[2] - vec.dest[2];
        
    return (x*x + y*y + z*z);
  }
  double distanceSquared(Vector3 other) => Vector3.DistanceSquared(this, other);


  /**
   * Projects the [vec] from screen space into object space
   * Based on the <a href="http://webcvs.freedesktop.org/mesa/Mesa/src/glu/mesa/project.c?revision=1.4&view=markup">Mesa gluUnProject implementation</a>
   *
   * @param {vec3} vec Screen-space vector to project
   * @param {mat4} view View matrix
   * @param {mat4} proj Projection matrix
   * @param {vec4} viewport Viewport as given to gl.viewport [x, y, width, height]
   * @param {vec3} [dest] vec3 receiving unprojected result. If not specified result is written to vec
   *
   * @returns {vec3} dest if specified, vec otherwise
   */
  static Vector3 Unproject(int posX, int posY, double posZ, Matrix view, Matrix proj,
                           int viewportX, int viewportY, int viewportWidth, int viewPortHeight,
                           [Vector3 result]) {
  //static Vector3 Unproject(Vector3 vec, Matrix view, Matrix proj, Vector4 viewport, [Vector3 result]) {
    if(result == null) result = new Vector3.zero();
    
    Matrix m = new Matrix.zero();
    Vector4 v = new Vector4.zero();
    //var x = 
    //var y = 
    
    v.dest[0] = (posX - viewportX) * 2.0 / viewportWidth  - 1.0;
    v.dest[1] = (posY - viewportY) * 2.0 / viewPortHeight - 1.0;
    v.dest[2] = 2.0 * posZ - 1.0;
    v.dest[3] = 1.0;
    
    Matrix.Multiply(proj, view, m);
    if(m.inverse() == null) { return null; }
    
    Matrix.MultiplyVec4(m, v, v);
    if(v.dest[3] === 0.0) { return null; }
    
    result.dest[0] = v.dest[0] / v.dest[3];
    result.dest[1] = v.dest[1] / v.dest[3];
    result.dest[2] = v.dest[2] / v.dest[3];
    
    /*
    if(unprojectDirection != null) {
      v.dest[0] = x;
      v.dest[1] = y;
      v.dest[2] = 0.0;
      v.dest[3] = 1.0;
      m = new Matrix.zero();
      Matrix.Multiply(proj, view, m);
      Matrix.MultiplyVec4(m, v);
      unprojectDirection.dest[0] = v.dest[0] / v.dest[3];
      unprojectDirection.dest[1] = v.dest[1] / v.dest[3];
      unprojectDirection.dest[2] = v.dest[2] / v.dest[3];
      //unprojectDirection.subtract(result);

      
    }*/
    
    m.recycle();
    v.recycle();
    
    return result;
  }

  bool operator==(Object object) {
    if (object is! Vector3) return false;  
    return X == object.X && Y == object.Y && Z == object.Z;
  }
  
  static Vector3 Project(Vector3 pos, Matrix view, Matrix proj, int viewportWidth, int viewPortHeight, [Vector3 result]) {
    if(result == null) result = new Vector3.zero();
    Vector4 v = new Vector4(pos.X,pos.Y,pos.Z,1.0);
    Matrix pv = Matrix.Multiply(proj, view);
    v = Matrix.MultiplyVec4(pv, v, v);
    result.dest[0] = (v.X + 1) * (viewportWidth / 2);
    result.dest[1] = (v.Y + 1) * (viewPortHeight / 2);
    result.dest[2] = v.dest[2];
    pv.recycle();
    v.recycle();
    
    return result;
  }
  
  
  
  /**
   * Returns a string representation of this vector
   */
  String toString() => "[$X, $Y, $Z]";
  int hashCode() {
    // fix till hashCode works proper on doubles
    return "[$X, $Y, $Z]".hashCode();
    var erg  = 37;
        erg  = 37 * X.hashCode();
        erg += 37 * Y.hashCode();
        erg += 37 * Z.hashCode();
    return erg;
  }
  
  
  
}
