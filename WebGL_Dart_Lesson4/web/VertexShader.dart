library VertexShader;


class VertexShader {  
  static int vertexPositionAttribute; //To store position attribute location 
  static int vertexColorAttribute;    //To store color attribute location 
  
  static String shaderCode="""
  
  attribute vec3 aVertexPosition;
  attribute vec4 aVertexColor;
  
  uniform mat4 uMVMatrix;
  uniform mat4 uPMatrix;
  
  varying vec4 vColor;
  
  void main(void) {
  gl_Position = uPMatrix * uMVMatrix * vec4(aVertexPosition, 1.0);
  vColor = aVertexColor;
  } 
  
  """;
}
