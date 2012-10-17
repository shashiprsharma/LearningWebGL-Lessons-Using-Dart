class Quaternion implements Hashable {
  static final PIOVER180 = PI/180;
  static final PI180 = PI*180;

  Float32Array dest;

  // internal recycleSystem
  
  Quaternion._internal() {
    dest = new Float32Array(4);
  }  
  static List<Quaternion> _recycled;
  
  void recycle() {
    if(_recycled == null) _recycled = new List<Quaternion>();
    _recycled.add(this);
  }
  
  static Quaternion _createQuaternion() {
    Quaternion  quat;
    if(_recycled == null) _recycled = new List<Quaternion>();
    if(_recycled.length > 0) {
      quat = _recycled[0];
      _recycled.removeRange(0, 1);
      return quat;
    }
    return new Quaternion._internal();
  }
  
  
  // Constructors

  factory Quaternion.zero() {
    return _createQuaternion(); 
  }
  
  factory Quaternion.fromList(List<double> list) {
    Quaternion quat = _createQuaternion();
    quat.X = list[0] == null ? 0 : list[0];
    quat.Y = list[1] == null ? 0 : list[1];
    quat.Z = list[2] == null ? 0 : list[2];
    quat.W = list[3] == null ? 0 : list[3];
    return quat;
  }
  
  factory Quaternion.fromEuler(double pitch, double yaw, double roll) => _createQuaternion().eulerToQuat(pitch,yaw,roll);
  factory Quaternion.fromDirection(Vector3 vecDir) {
    Quaternion result = _createQuaternion();
    Vector3 vUp = new Vector3(0.0, 0.0, 1.0);
    Vector3 vRight = Vector3.Cross(vUp, vecDir);
    vUp = Vector3.Cross(vecDir, vRight, vUp);
  
    result.W = sqrt(1.0 + vRight.X + vUp.Y + vecDir.Z) / 2.0;
   
    double scale = result.W * 4.0;
   
    result.X = ((vecDir.Y - vUp.Z) / scale);
    result.Y = ((vRight.Z - vecDir.X) / scale);
    result.Z = ((vUp.X - vRight.Y) / scale);
    vUp.recycle();
    vRight.recycle();
    return result.normalize();
  }
  
  factory Quaternion([double x, double y, double z, double w]) {
    Quaternion quat = _createQuaternion();
    quat.dest[0] = x == null ? 0.0 : x;
    quat.dest[1] = y == null ? 0.0 : y;
    quat.dest[2] = z == null ? 0.0 : z;
    quat.dest[2] = w == null ? 1.0 : w;
    return quat;
  }
  

  
  double get X() => dest[0];
  void set X(double val) { dest[0] = val.toDouble();}
  double get Y() => dest[1];
  void set Y(double val) { dest[1] = val.toDouble();}
  double get Z() => dest[2];
  void set Z(double val) { dest[2] = val.toDouble();}
  double get W() => dest[3];
  void set W(double val) { dest[3] = val.toDouble();}
  
  /**
   * Clones the values of [quat] to [result] or creates a new Quaterion if [result] is null
   *
   * @param {quat4} quat quat4 containing values to copy
   * @param {quat4} dest quat4 receiving copied values
   *
   * @returns {quat4} dest
   */
  static Quaternion Clone( Quaternion quat, [Quaternion result]) {
    if(result == null) result = new Quaternion.zero();
      result.dest[0] = quat.dest[0];
      result.dest[1] = quat.dest[1];
      result.dest[2] = quat.dest[2];
      result.dest[3] = quat.dest[3];
  
      return result;
  }
  
  Quaternion clone([Quaternion result]) => Quaternion.Clone(this,result);
  
  /**
   * Calculates the W component of [quat] from the X, Y, and Z components.
   * Writes the calculation into [result] or creates a new Quaternion.
   * Assumes that quaternion is 1 unit in length. 
   * Any existing W component will be ignored.
   */
  static Quaternion CalculateW( Quaternion quat, [Quaternion result]) {
      var x = quat.dest[0], y = quat.dest[1], z = quat.dest[2];
  
      if(result == null) result = new Quaternion.zero();
      if (quat === result) {
          quat.dest[3] = -sqrt((1.0 - x * x - y * y - z * z).abs());
          return quat;
      }
      result.dest[0] = x;
      result.dest[1] = y;
      result.dest[2] = z;
      result.dest[3] = -sqrt((1.0 - x * x - y * y - z * z).abs());
      return result;
  }
  Quaternion calcW() =>CalculateW(this,this);
  
  /**
   * Identifies this Quaternion
   */
  Quaternion identify() {
    X = 0.0;
    Y = 0.0;
    Z = 0.0;
    W = 1.0;
    return this;
  }

  /**
   * Rotates [result] to look at [direction] with the [up].
   * Creates a new Quaternion if result is null.
   */
  static Quaternion LookAt(Vector3 direction, Vector3 up, [Quaternion result]) {
    Vector3 z = Vector3.Normalize(direction);
    Vector3 x = Vector3.Cross(up,direction);
    Vector3 y = Vector3.Cross(direction,x);

    result = FromAxes(x,y,z, result);
    x.recycle();
    y.recycle();
    z.recycle();
    return result;
  }
  Quaternion lookAt(Vector3 direction, Vector3 upDir) => LookAt(direction,upDir,this);
  
  
  /**
   * Rotates [result] to mach the rotation of the three axis [xAxis] [yAxis] [zAxis]
   * Creates a new Quaternion if result is null.
   */  
  static Quaternion FromAxes(Vector3 xAxis, Vector3 yAxis, Vector3 zAxis, [Quaternion result]) {
    return fromRotationMatrix(xAxis.X, yAxis.X, zAxis.X, xAxis.Y, yAxis.Y,
            zAxis.Y, xAxis.Z, yAxis.Z, zAxis.Z, result);
  }
  
  /**
   * Rotates [result] to mach RotationMatrix
   * Creates a new Quaternion if result is null.
   */  
  static Quaternion fromRotationMatrix(double m11, double m12, double m13,
                                              double m21, double m22, double m23,
                                              double m31, double m32, double m33, [Quaternion result]) {
    if(result == null) result = new Quaternion.zero();
    var r = m11 + m22 + m33;
    
    if (r >= 0) {
      var s = sqrt(r + 1);
      result.W = 0.5 * s;
      s = 0.5 / s;
      result.X = (m32 - m23) * s;
      result.Y = (m13 - m31) * s;
      result.Z = (m21 - m12) * s;
    } else if ((m11 > m22) && (m11 > m33)) {
      var s = sqrt(1.0 + m11 - m22 - m33);
      result.X = s * 0.5;
      s = 0.5 / s;
      result.Y = (m21 + m12) * s;
      result.Z = (m13 + m31) * s;
      result.W = (m32 - m23) * s;
    } else if (m22 > m33) {
      var s = sqrt(1.0 + m22 - m11 - m33);
      result.Y = s * 0.5;
      s = 0.5 / s;
      result.X = (m21 + m12) * s;
      result.Z = (m32 + m23) * s;
      result.W = (m13 - m31) * s;
    } else {
      var s = sqrt(1.0 + m33 - m11 - m22);
      result.Z = s * 0.5;
      s = 0.5 / s;
      result.X = (m13 + m31) * s;
      result.Y = (m32 + m23) * s;
      result.W = (m21 - m12) * s;
    }
    
    return result;
  }

  
  /**
   * Rotates [result] to mach RotationMatrix
   * Creates a new Quaternion if result is null.
   */ 
  static Quaternion DirectionToQuaternion(Vector3 vecDir, [Quaternion result]) {
   if(result == null) result = new Quaternion.zero();
      Vector3 vUp = new Vector3(0.0, 0.0, 1.0);
      Vector3 vRight = Vector3.Cross(vUp, vecDir);
      vUp = Vector3.Cross(vecDir, vRight, vUp);

      result.W = sqrt(1.0 + vRight.X + vUp.Y + vecDir.Z) / 2.0;
      
      double scale = result.W * 4.0;
      
      result.X = ((vecDir.Y - vUp.Z) / scale);
      result.Y = ((vRight.Z - vecDir.X) / scale);
      result.Z = ((vUp.X - vRight.Y) / scale);
      vUp.recycle();
      vRight.recycle();
      

      return result.normalize();
  }
  Quaternion dirToQuat(Vector3 vecDir) => DirectionToQuaternion(vecDir,this);
  
  
  /**
   * Calculates the up Vector of this quaterion and writes it into [result]
   * Creates a new Quaternion if result is null.
   */ 
  Vector3 up([Vector3 result]) {
    if (result == null) result = new Vector3.zero();
  
    var dotself = dest[0] * dest[0] + dest[1] * dest[1] + dest[2] * dest[2] + dest[3] * dest[3];
    if (dotself != 1.0)
      dotself = (1.0 / sqrt(dotself));
    
    var xx = dest[0] * dest[0] * dotself;
    var xy = dest[0] * dest[1] * dotself;
    var xz = dest[0] * dest[2] * dotself;
    var xw = dest[0] * dest[3] * dotself;
    var yy = dest[1] * dest[1] * dotself;
    var yz = dest[1] * dest[2] * dotself;
    var yw = dest[1] * dest[3] * dotself;
    var zz = dest[2] * dest[2] * dotself;
    var zw = dest[2] * dest[3] * dotself;
    result.dest[0]  =     2 * ( xy - zw );
    result.dest[1]  = 1 - 2 * ( xx + zz );
    result.dest[2]  =     2 * ( yz + xw );
    return result;
  }
  /**
   * Calculates the left Vector of this quaterion and writes it into [result]
   * Creates a new Quaternion if result is null.
   */ 
  Vector3 left([Vector3 result]) {
    if (result == null) result = new Vector3.zero();
  
    var dotself = dest[0] * dest[0] + dest[1] * dest[1] + dest[2] * dest[2] + dest[3] * dest[3];
    if (dotself != 1.0)
      dotself = (1.0 / sqrt(dotself));
    
    var xx = dest[0] * dest[0] * dotself;
    var xy = dest[0] * dest[1] * dotself;
    var xz = dest[0] * dest[2] * dotself;
    var xw = dest[0] * dest[3] * dotself;
    var yy = dest[1] * dest[1] * dotself;
    var yz = dest[1] * dest[2] * dotself;
    var yw = dest[1] * dest[3] * dotself;
    var zz = dest[2] * dest[2] * dotself;
    var zw = dest[2] * dest[3] * dotself;

    result.dest[0]  = 1 - 2 * ( yy + zz );
    result.dest[1]  =     2 * ( xy + zw );
    result.dest[2]  =     2 * ( xz - yw );
    return result;
  }
  /**
   * Calculates the forward Vector of this quaterion and writes it into [result]
   * Creates a new Quaternion if result is null.
   */ 
  Vector3 forward([Vector3 result]) {
    if (result == null) result = new Vector3.zero();
  
    var dotself = dest[0] * dest[0] + dest[1] * dest[1] + dest[2] * dest[2] + dest[3] * dest[3];
    if (dotself != 1.0)
      dotself = (1.0 / sqrt(dotself));
    
    var xx = dest[0] * dest[0] * dotself;
    var xy = dest[0] * dest[1] * dotself;
    var xz = dest[0] * dest[2] * dotself;
    var xw = dest[0] * dest[3] * dotself;
    var yy = dest[1] * dest[1] * dotself;
    var yz = dest[1] * dest[2] * dotself;
    var yw = dest[1] * dest[3] * dotself;
    var zz = dest[2] * dest[2] * dotself;
    var zw = dest[2] * dest[3] * dotself;
    result.dest[0]  =     2 * ( xz + yw );
    result.dest[1]  =     2 * ( yz - xw );
    result.dest[2]  = 1 - 2 * ( xx + yy );
    return result;
  }
  
  
  
  
  Quaternion RotateFromAxisAnge(double x, double y, double z, double angle, [Quaternion result]) {
    if(result == null) result = new Quaternion.zero();
    double res = sin( angle / 2.0 );

    x *= res;
    y *= res;
    z *= res;

    double w = cos( angle / 2.0 );

    result.X = x;
    result.Y = y;
    result.Z = z;
    result.W = w;
    return result.normalize();
  }
  Quaternion rotateFromAxisAngle(double x, double y, double z, double angle) => RotateFromAxisAnge(x,y,z,angle,this);
  
  
  Quaternion RotateX( Quaternion quat, double angle, [Quaternion result]) {
    if(result == null) result = new Quaternion.zero();
    result.X = quat.X + cos(angle/2);
    result.Y = quat.Y + sin(angle/2);
    result.Z = quat.Z;
    result.W = quat.W;
    return result;
    
  }
  Quaternion rotX(double angle) => RotateX(this,angle,this);
  
  Quaternion RotateY( Quaternion quat, double angle, [Quaternion result]) {
    if(result == null) result = new Quaternion.zero();
    result.X = quat.X + cos(angle/2);
    result.Y = quat.Y;
    result.Z = quat.Z + sin(angle/2);
    result.W = quat.W;
    return result;
    
  }
  Quaternion rotY(double angle) => RotateY(this,angle,this);
  
  Quaternion RotateZ( Quaternion quat, double angle, [Quaternion result]) {
    if(result == null) result = new Quaternion.zero();
    result.X = quat.X + cos(angle/2);
    result.Y = quat.Y;
    result.Z = quat.Z;
    result.W = quat.W = sin(angle/2);
    return result;
    
  }
  Quaternion rotZ(double angle) => RotateZ(this,angle,this);
  
  
  /**
   * Calculates the dot product of two quaternions
   *
   * @param {quat4} quat First operand
   * @param {quat4} quat2 Second operand
   *
   * @return {number} Dot product of quat and quat2
   */
  static double Dot( Quaternion quat, Quaternion quat2){
    return quat.dest[0]*quat2.dest[0] + quat.dest[1]*quat2.dest[1] + quat.dest[2]*quat2.dest[2] + quat.dest[3]*quat2.dest[3];
  }
  double dot(Quaternion quat) => Dot(this,quat);
  
  /**
   * Calculates the inverse of a quat4
   *
   * @param {quat4} quat quat4 to calculate inverse of
   * @param {quat4} [dest] quat4 receiving inverse values. If not specified result is written to quat
   *
   * @returns {quat4} dest if specified, quat otherwise
   */
  static Quaternion Inverse( Quaternion quat, [Quaternion result]) {
      var q0 = quat.dest[0], q1 = quat.dest[1], q2 = quat.dest[2], q3 = quat.dest[3],
          tdot = q0*q0 + q1*q1 + q2*q2 + q3*q3,
          invDot = tdot == 0 ? 1.0/tdot : 0;
      
      // TODO: Would be faster to return [0,0,0,0] immediately if dot == 0
      
      if(result == null) result = new Quaternion.zero();
      if (quat === result) {
          quat.dest[0] *= -invDot;
          quat.dest[1] *= -invDot;
          quat.dest[2] *= -invDot;
          quat.dest[3] *= invDot;
          return quat;
      }
      result.dest[0] = -quat.dest[0]*invDot;
      result.dest[1] = -quat.dest[1]*invDot;
      result.dest[2] = -quat.dest[2]*invDot;
      result.dest[3] = quat.dest[3]*invDot;
      return result;
  }
  
  
  /**
   * Calculates the conjugate of a quat4
   * If the quaternion is normalized, this function is faster than static Quaternion inverse and produces the same result.
   *
   * @param {quat4} quat quat4 to calculate conjugate of
   * @param {quat4} [dest] quat4 receiving conjugate values. If not specified result is written to quat
   *
   * @returns {quat4} dest if specified, quat otherwise
   */
  static Quaternion Conjugate( Quaternion quat, [Quaternion result]) {
      if(result == null) result = new Quaternion.zero();
      if (quat === result) {
          quat.dest[0] *= -1;
          quat.dest[1] *= -1;
          quat.dest[2] *= -1;
          return quat;
      }
      result.dest[0] = -quat.dest[0];
      result.dest[1] = -quat.dest[1];
      result.dest[2] = -quat.dest[2];
      result.dest[3] = quat.dest[3];
      return result;
  }
  
  
  /**
   * Calculates the length of a quat4
   *
   * Params:
   * @param {quat4} quat quat4 to calculate length of
   *
   * @returns Length of quat
   */
  double length() {
      var x = dest[0], y = dest[1], z = dest[2], w = dest[3];
      return sqrt(x * x + y * y + z * z + w * w);
  }
  
  /**
   * Generates a unit quaternion of the same direction as the provided quat4
   * If quaternion length is 0, returns [0, 0, 0, 0]
   *
   * @param {quat4} quat quat4 to normalize
   * @param {quat4} [dest] quat4 receiving operation result. If not specified result is written to quat
   *
   * @returns {quat4} dest if specified, quat otherwise
   */
  static Quaternion Normalize( Quaternion quat, [Quaternion result]) {
      if(result == null) result = new Quaternion.zero();
  
      var x = quat.dest[0], y = quat.dest[1], z = quat.dest[2], w = quat.dest[3],
          len = sqrt(x * x + y * y + z * z + w * w);
      if (len === 0) {
          result.dest[0] = 0.0;
          result.dest[1] = 0.0;
          result.dest[2] = 0.0;
          result.dest[3] = 0.0;
          return result;
      }
      len = 1 / len;
      result.dest[0] = x * len;
      result.dest[1] = y * len;
      result.dest[2] = z * len;
      result.dest[3] = w * len;
  
      return result;
  }
  Quaternion normalize() => Normalize(this,this);

  
  static Quaternion EulerToQuaterion(double pitch, double yaw, double roll, [Quaternion result]) {
  //http://content.gpwiki.org/index.php/OpenGL:Tutorials:Using_Quaternions_to_represent_rotation
    if(result == null) result = new Quaternion.zero();
    double p = pitch * PIOVER180 / 2.0;
    double y = yaw * PIOVER180 / 2.0;
    double r = roll * PIOVER180 / 2.0;
   
    double sinp = sin(p);
    double siny = sin(y);
    double sinr = sin(r);
    double cosp = cos(p);
    double cosy = cos(y);
    double cosr = cos(r);
   
    result.X = sinr * cosp * cosy - cosr * sinp * siny;
    result.Y = cosr * sinp * cosy + sinr * cosp * siny;
    result.Z = cosr * cosp * siny - sinr * sinp * cosy;
    result.W = cosr * cosp * cosy + sinr * sinp * siny;
    result.normalize(); 
    return result;
  }
  Quaternion eulerToQuat(double pitch, double yaw, double roll) => EulerToQuaterion(pitch,yaw,roll,this);

  
  
  
  

  
  
  static Vector3 QuatToEuler(Quaternion quat, [Vector3 result]) {
    if(result == null) result = new Vector3.zero();
    double sqw;
    double sqx;
    double sqy;
    double sqz;
    
    double rotxrad;
    double rotyrad;
    double rotzrad;
    
    sqw = quat.W * quat.W;
    sqx = quat.X * quat.X;
    sqy = quat.Y * quat.Y;
    sqz = quat.Z * quat.Z;
    
    rotxrad = atan2(2.0 * ( quat.Y * quat.Z + quat.X * quat.W ) , ( -sqx - sqy + sqz + sqw ));
    rotyrad = asin(-2.0 * ( quat.X * quat.Z - quat.Y * quat.W ));
    rotzrad = atan2(2.0 * ( quat.X * quat.Y + quat.Z * quat.W ) , (  sqx - sqy - sqz + sqw ));
    
    // rad to degree!
    result.X = rotxrad * PI180;
    result.Y = rotyrad * PI180;
    result.Z = rotzrad * PI180;
    
    return result;
  }
  Vector3 toEuler([Vector3 result]) => QuatToEuler(this,result);
  
    

  
  /**
   * Calculates a 3x3 matrix from the given quat4
   *
   * @param {quat4} quat quat4 to create matrix from
   * @param {mat3} [dest] mat3 receiving operation result
   *
   * @returns {mat3} dest if specified, a new mat3 otherwise
   */
  static Matrix3 ToMat3( Quaternion quat, [Matrix3 result]) {
    if(result == null) { result = new Matrix3.zero(); }

    var x = quat.dest[0], y = quat.dest[1], z = quat.dest[2], w = quat.dest[3],
        x2 = x + x,
        y2 = y + y,
        z2 = z + z,

        xx = x * x2,
        xy = x * y2,
        xz = x * z2,
        yy = y * y2,
        yz = y * z2,
        zz = z * z2,
        wx = w * x2,
        wy = w * y2,
        wz = w * z2;

    result.dest[0] = 1 - (yy + zz);
    result.dest[1] = xy + wz;
    result.dest[2] = xz - wy;

    result.dest[3] = xy - wz;
    result.dest[4] = 1 - (xx + zz);
    result.dest[5] = yz + wx;

    result.dest[6] = xz + wy;
    result.dest[7] = yz - wx;
    result.dest[8] = 1 - (xx + yy);

    return result;
  }
  
  /**
   * Calculates a 4x4 matrix from the given quat4
   *
   * @param {quat4} quat quat4 to create matrix from
   * @param {mat4} [dest] mat4 receiving operation result
   *
   * @returns {mat4} dest if specified, a new mat4 otherwise
   */
  static Matrix ToMat4( Quaternion quat, [Matrix result]) {
    if(result == null) { result = new Matrix.zero(); }

    var x = quat.dest[0], y = quat.dest[1], z = quat.dest[2], w = quat.dest[3],
        x2 = x + x,
        y2 = y + y,
        z2 = z + z,

        xx = x * x2,
        xy = x * y2,
        xz = x * z2,
        yy = y * y2,
        yz = y * z2,
        zz = z * z2,
        wx = w * x2,
        wy = w * y2,
        wz = w * z2;

    result.dest[0] = 1 - (yy + zz);
    result.dest[1] = xy + wz;
    result.dest[2] = xz - wy;
    result.dest[3] = 0.0;

    result.dest[4] = xy - wz;
    result.dest[5] = 1 - (xx + zz);
    result.dest[6] = yz + wx;
    result.dest[7] = 0.0;

    result.dest[8] = xz + wy;
    result.dest[9] = yz - wx;
    result.dest[10] = 1 - (xx + yy);
    result.dest[11] = 0.0;

    result.dest[12] = 0.0;
    result.dest[13] = 0.0;
    result.dest[14] = 0.0;
    result.dest[15] = 1.0;

    return result;
  }
  
  
  static Quaternion Add(Quaternion quad, Quaternion quad2, Quaternion result) {
    if (result == null) result = new Quaternion.zero();
    result.dest[0] = quad.dest[0] + quad2.dest[0];
    result.dest[1] = quad.dest[1] + quad2.dest[1];
    result.dest[2] = quad.dest[2] + quad2.dest[2];
    result.dest[3] = quad.dest[3] + quad2.dest[3];
    return result;
  }
  Quaternion add(Quaternion quad) => Add(this, quad, this);
  
  /**
   * Performs a quaternion multiplication
   *
   * @param {quat4} quat First operand
   * @param {quat4} quat2 Second operand
   * @param {quat4} [dest] quat4 receiving operation result. If not specified result is written to quat
   *
   * @returns {quat4} dest if specified, quat otherwise
   */
  static Quaternion Multiply( Quaternion quat, Quaternion quat2, [Quaternion result]) {
    if(result == null) result = new Quaternion.zero();

    var qax = quat.dest[0], qay = quat.dest[1], qaz = quat.dest[2], qaw = quat.dest[3],
        qbx = quat2.dest[0], qby = quat2.dest[1], qbz = quat2.dest[2], qbw = quat2.dest[3];

    result.dest[0] = qax * qbw + qaw * qbx + qay * qbz - qaz * qby;
    result.dest[1] = qay * qbw + qaw * qby + qaz * qbx - qax * qbz;
    result.dest[2] = qaz * qbw + qaw * qbz + qax * qby - qay * qbx;
    result.dest[3] = qaw * qbw - qax * qbx - qay * qby - qaz * qbz;

    return result;
  }
  Quaternion multiply(Quaternion quat) => Multiply(this,quat,this);
  
  
  static Vector3 MultiplyVector3( Quaternion quat, Vector3 vec, [Vector3 result]) {
    if(result == null) result = new Vector3.zero();
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
  Vector3 multiplyVec3(Vector3 vec, [Vector3 result]) => MultiplyVector3(this,vec,result);
  
  /**
   * <code>mult</code> multiplies a quaternion about a matrix. The
   * resulting vector is returned.
   *
   * @param vec
   *            vec to multiply against.
   * @param store
   *            a quaternion to store the result in.  created if null is passed.
   * @return store = this * vec
   */
  static Quaternion MultiplyMat(Quaternion quat, Matrix mat, [Quaternion result]) {
    if (result == null) result = new Quaternion.zero();
  
    double x = mat.m11 * quat.X + mat.m21 * quat.Y + mat.m31 * quat.Z + mat.m41 * quat.W;
    double y = mat.m12 * quat.X + mat.m22 * quat.Y + mat.m32 * quat.Z + mat.m42 * quat.W;
    double z = mat.m13 * quat.X + mat.m23 * quat.Y + mat.m33 * quat.Z + mat.m43 * quat.W;
    double w = mat.m14 * quat.X + mat.m24 * quat.Y + mat.m34 * quat.Z + mat.m44 * quat.W;
    result.X = x;
    result.Y = y;
    result.Z = z;
    result.W = w;
  
    return result;
  }
  Quaternion multiplyMat(Matrix mat) => MultiplyMat(this,mat,this);
  
  Quaternion MultiplyValue(Quaternion quat, num value, [Quaternion result]) {
    if (result == null) result = new Quaternion.zero();
    quat.X *= value;
    quat.Y *= value;
    quat.Z *= value;
    quat.W *= value;
    return quat;
  }
  Quaternion multiplyVal(num value) => MultiplyValue(this,value,this);
  
  
  /**
   * Performs a spherical linear interpolation between two quat4
   *
   * @param {quat4} quat First quaternion
   * @param {quat4} quat2 Second quaternion
   * @param {number} slerp Interpolation amount between the two inputs
   * @param {quat4} [dest] quat4 receiving operation result. If not specified result is written to quat
   *
   * @returns {quat4} dest if specified, quat otherwise
   */
  static Quaternion Slerp( Quaternion quat, Quaternion quat2, double slerpVal, [Quaternion result]) {
      if(result == null) { result = new Quaternion.zero(); }
  
      var cosHalfTheta = quat.dest[0] * quat2.dest[0] + quat.dest[1] * quat2.dest[1] + quat.dest[2] * quat2.dest[2] + quat.dest[3] * quat2.dest[3],
          halfTheta,
          sinHalfTheta,
          ratioA,
          ratioB;
  
      if ((cosHalfTheta).abs() >= 1.0) {
          if (result !== quat) {
              result.dest[0] = quat.dest[0];
              result.dest[1] = quat.dest[1];
              
              
              result.dest[2] = quat.dest[2];
              result.dest[3] = quat.dest[3];
          }
          return result;
      }
  
      halfTheta = acos(cosHalfTheta);
      sinHalfTheta = sqrt(1.0 - cosHalfTheta * cosHalfTheta);
  
      if ((sinHalfTheta).abs() < 0.001) {
          result.dest[0] = (quat.dest[0] * 0.5 + quat2.dest[0] * 0.5);
          result.dest[1] = (quat.dest[1] * 0.5 + quat2.dest[1] * 0.5);
          result.dest[2] = (quat.dest[2] * 0.5 + quat2.dest[2] * 0.5);
          result.dest[3] = (quat.dest[3] * 0.5 + quat2.dest[3] * 0.5);
          return result;
      }
  
      ratioA = sin((1 - slerpVal) * halfTheta) / sinHalfTheta;
      ratioB = sin(slerpVal * halfTheta) / sinHalfTheta;
  
      result.dest[0] = (quat.dest[0] * ratioA + quat2.dest[0] * ratioB);
      result.dest[1] = (quat.dest[1] * ratioA + quat2.dest[1] * ratioB);
      result.dest[2] = (quat.dest[2] * ratioA + quat2.dest[2] * ratioB);
      result.dest[3] = (quat.dest[3] * ratioA + quat2.dest[3] * ratioB);
  
      return result;
  }
  
  /**
   * Returns a string representation of a quaternion
   *
   * @param {quat4} quat quat4 to represent as a string
   *
   * @returns {string} String representation of quat
   */
  String toString() => "[$X, $Y, $Z, $W]";
  
  bool operator==(Object object) {
    if (object is! Quaternion) return false;
    return X == object.X && Y == object.Y && Z == object.Z && W == object.W;
  }
  
  int hashCode() {
    var erg  = 37;
        erg += 37 * X.hashCode();
        erg += 37 * Y.hashCode() * erg;
        erg += 37 * Z.hashCode() * erg;
        erg += 37 * W.hashCode() * erg;
    return erg;
  }
}
