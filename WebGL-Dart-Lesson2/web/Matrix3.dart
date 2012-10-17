class Matrix3 {

  Float32Array dest;
  
  
  
  Matrix3._internal() {
    dest = new Float32Array(9);
  }  
  
  static List<Matrix3> _recycled;
  
  void recycle() {
    if(_recycled == null) _recycled = new List<Matrix3>();
    _recycled.add(this);
  }
  
  static Matrix3 _newMatrix() {
    Matrix3 mat;
    if(_recycled == null) _recycled = new List<Matrix3>();
    if(_recycled.length > 0) {
      mat = _recycled[0];
      _recycled.removeRange(0, 1);
      return mat;
    }
    return new Matrix3._internal();
  }
  
  
  
  
  
  factory Matrix3(double M11, double M12, double M13,
          double M21, double M22, double M23,
          double M31, double M32, double M33) {
    Matrix3 mat = _newMatrix();
    mat.dest[0] = M11;
    mat.dest[1] = M12;
    mat.dest[2] = M13;
    
    mat.dest[3] = M21;
    mat.dest[4] = M22;
    mat.dest[5] = M23;
    
    mat.dest[6] = M31;
    mat.dest[7] = M32;
    mat.dest[8] = M33;
  }
  
  factory Matrix3.zero() {
    Matrix3 mat = _newMatrix();
    for(int i=0; mat.dest.length > i; i++ )
      mat.dest[i] = 0.0;
    return mat;
  }

  

  void set m11(double value) {dest[0] = value;}
  double get m11() => dest[0];
  void set m12(double value) {dest[1] = value;}
  double get m12() => dest[1];
  void set m13(double value) {dest[2] = value;}
  double get m13() => dest[2];
  void set m21(double value) {dest[3] = value;}
  double get m21() => dest[3];
  void set m22(double value) {dest[4] = value;}
  double get m22() => dest[4];
  void set m23(double value) {dest[5] = value;}
  double get m23() => dest[5];
  void set m31(double value) {dest[6] = value;}
  double get m31() => dest[6];
  void set m32(double value) {dest[7] = value;}
  double get m32() => dest[7];
  void set m33(double value) {dest[8] = value;}
  double get m33() => dest[8];

/**
 * Copies the values of one mat3 to another
 *
 * @param {mat3} mat mat3 containing values to copy
 * @param {mat3} dest mat3 receiving copied values
 *
 * @returns {mat3} dest
 */
Matrix3 Copy(Matrix3 mat, [Matrix3 result]) {
    result.dest[0] = mat.dest[0];
    result.dest[1] = mat.dest[1];
    result.dest[2] = mat.dest[2];
    result.dest[3] = mat.dest[3];
    result.dest[4] = mat.dest[4];
    result.dest[5] = mat.dest[5];
    result.dest[6] = mat.dest[6];
    result.dest[7] = mat.dest[7];
    result.dest[8] = mat.dest[8];
    return result;
}

/**
 * Sets a mat3 to an identity matrix
 *
 * @param {mat3} dest mat3 to set
 *
 * @returns dest if specified, otherwise a new mat3
 */
Matrix3 Identity([Matrix3 result]) {
    if(result == null) { result = new Matrix3.zero(); }
    result.dest[0] = 1.0;
    result.dest[1] = 0.0;
    result.dest[2] = 0.0;
    result.dest[3] = 0.0;
    result.dest[4] = 1.0;
    result.dest[5] = 0.0;
    result.dest[6] = 0.0;
    result.dest[7] = 0.0;
    result.dest[8] = 1.0;
    return result;
}

/**
 * Transposes a mat3 (flips the values over the diagonal)
 *
 * Params:
 * @param {mat3} mat mat3 to transpose
 * @param {mat3} [dest] mat3 receiving transposed values. If not specified result is written to mat
 *
 * @returns {mat3} dest is specified, mat otherwise
 */
Matrix3 Transpose(Matrix3 mat, [Matrix3 result]) {
    // If we are transposing ourselves we can skip a few steps but have to cache some values
    if (result == null || mat === result) {
        var a01 = mat.dest[1], a02 = mat.dest[2],
            a12 = mat.dest[5];

        mat.dest[1] = mat.dest[3];
        mat.dest[2] = mat.dest[6];
        mat.dest[3] = a01;
        mat.dest[5] = mat.dest[7];
        mat.dest[6] = a02;
        mat.dest[7] = a12;
        return mat;
    }

    result.dest[0] = mat.dest[0];
    result.dest[1] = mat.dest[3];
    result.dest[2] = mat.dest[6];
    result.dest[3] = mat.dest[1];
    result.dest[4] = mat.dest[4];
    result.dest[5] = mat.dest[7];
    result.dest[6] = mat.dest[2];
    result.dest[7] = mat.dest[5];
    result.dest[8] = mat.dest[8];
    return result;
}

/**
 * Copies the elements of a mat3 into the upper 3x3 elements of a mat4
 *
 * @param {mat3} mat mat3 containing values to copy
 * @param {mat4} [dest] mat4 receiving copied values
 *
 * @returns {mat4} dest if specified, a new mat4 otherwise
 */
Matrix ToMat4(Matrix3 mat, [Matrix result]) {
    if(result == null) { result = new Matrix.zero(); }

    result.dest[15] = 1.0;
    result.dest[14] = 0.0;
    result.dest[13] = 0.0;
    result.dest[12] = 0.0;

    result.dest[11] = 0.0;
    result.dest[10] = mat.dest[8];
    result.dest[9] = mat.dest[7];
    result.dest[8] = mat.dest[6];

    result.dest[7] = 0.0;
    result.dest[6] = mat.dest[5];
    result.dest[5] = mat.dest[4];
    result.dest[4] = mat.dest[3];

    result.dest[3] = 0.0;
    result.dest[2] = mat.dest[2];
    result.dest[1] = mat.dest[1];
    result.dest[0] = mat.dest[0];

    return result;
}

/**
 * Returns a string representation of a mat3
 *
 * @param {mat3} mat mat3 to represent as a string
 *
 * @param {string} String representation of mat
 */
String toString() {
    return "[$m11, $m12, $m13, "
            "$m21, $m22, $m23, "
            "$m31, $m32, $m33]";
}  
}
