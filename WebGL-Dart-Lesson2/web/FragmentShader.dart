#library("FragmentShader");


class FragmentShader {
  
  static String shaderCode="""

  precision mediump float;

  varying vec4 vColor;

  void main(void) {
  gl_FragColor = vColor;
  }

  """;
}
