
import 'dart:html';
import 'dart:math';

import 'glmatrix.dart';


class Triangle
{
  Triangle(){
    buffer = null;
    numItems = 0;
    itemSize = 0;
  }
  WebGLBuffer buffer;
  int numItems;
  int itemSize;
}

class Square
{
  Square(){
    buffer = null;
    numItems = 0;
    itemSize = 0;
  }
  WebGLBuffer buffer;
  int numItems;
  int itemSize;
}

class WebGLTest
{

  num rotatePos = 0;
  WebGLRenderingContext GL;
  WebGLProgram program;
  CanvasElement canvas;
  double aspect;
  
  WebGLUniformLocation pMatrixUniform;
  WebGLUniformLocation mvMatrixUniform;
  int vertexPositionAttribute;
   
  Matrix mvMatrix;
  Matrix pMatrix;

  Triangle triangleVertexPositionBuffer;
  Square squareVertexPositionBuffer;
  
 
  WebGLTest()
  {
    this.canvas = query("#canvas1");
    this.aspect = this.canvas.width / this.canvas.height;
  }
  
  bool initGL()
  {
    
    this.GL = this.canvas.getContext("experimental-webgl");
    
    if(this.GL == null)
    {
      return false;
    }    
    return true;
  }
  
  String readShaderFromFile(String fileName)
  {
    //Not Reading shaders from file yet just returning Strings
    
    String ret;
    if(fileName.contains("fragment", 0))
    {
      ret = """
              precision mediump float;

              void main(void) {
                  gl_FragColor = vec4(1.0, 1.0, 1.0, 1.0);
              }
            """;
    }
    else if(fileName.contains("vertex",0))
    {
      ret = """
              attribute vec3 aVertexPosition;

              uniform mat4 uMVMatrix;
              uniform mat4 uPMatrix;

              void main(void) {
                  gl_Position = uPMatrix * uMVMatrix * vec4(aVertexPosition, 1.0);
              } 
            """;
    }
    
    return ret;

  }
  
  bool initShaders()
  {
    //Create vertex shader from source and compile
    WebGLShader vertexShader = this.GL.createShader(WebGLRenderingContext.VERTEX_SHADER);
    this.GL.shaderSource(vertexShader, this.readShaderFromFile("vertex"));
    this.GL.compileShader(vertexShader);
      
    //Create fragment shader from source and compile
    WebGLShader fragmentShader = this.GL.createShader(WebGLRenderingContext.FRAGMENT_SHADER);
    this.GL.shaderSource(fragmentShader, this.readShaderFromFile("fragment"));
    this.GL.compileShader(fragmentShader);
    
    //Attach the shaders to the program, link them and use the program
    WebGLProgram p = this.GL.createProgram();
    this.GL.attachShader(p, vertexShader);
    this.GL.attachShader(p, fragmentShader);
    this.GL.linkProgram(p);
    this.GL.useProgram(p);
    
    
    if (!this.GL.getShaderParameter(vertexShader, WebGLRenderingContext.COMPILE_STATUS)) { 
      print(this.GL.getShaderInfoLog(vertexShader));
    }
    
    if (!this.GL.getShaderParameter(fragmentShader, WebGLRenderingContext.COMPILE_STATUS)) { 
      print(this.GL.getShaderInfoLog(fragmentShader));
    }
    
    if (!this.GL.getProgramParameter(p, WebGLRenderingContext.LINK_STATUS)) { 
      print(this.GL.getProgramInfoLog(p));
    }
        
    this.program = p; 
    
    vertexPositionAttribute = this.GL.getAttribLocation(program, "aVertexPosition");
    this.GL.enableVertexAttribArray(vertexPositionAttribute);
    
    pMatrixUniform = this.GL.getUniformLocation(program, "uPMatrix");
    mvMatrixUniform = this.GL.getUniformLocation(program, "uMVMatrix");
    
    return true;
  }
  
  void initBuffers()
  {
    //Setup Triangle's buffer
    this.triangleVertexPositionBuffer = new Triangle();
    this.triangleVertexPositionBuffer.buffer = this.GL.createBuffer();
    this.GL.bindBuffer(WebGLRenderingContext.ARRAY_BUFFER, this.triangleVertexPositionBuffer.buffer);
    
    List list = [
                  0.0,  1.0,  0.0,
                 -1.0, -1.0,  0.0,
                  1.0, -1.0,  0.0
                ];    
    Float32Array vertices = new Float32Array.fromList(list);
    
    this.GL.bufferData(WebGLRenderingContext.ARRAY_BUFFER, vertices, WebGLRenderingContext.STATIC_DRAW);
    this.triangleVertexPositionBuffer.numItems = 3;
    this.triangleVertexPositionBuffer.itemSize = 3;
    
    
    //Setup Square's buffer
    this.squareVertexPositionBuffer = new Square();
    this.squareVertexPositionBuffer.buffer = this.GL.createBuffer();
    this.GL.bindBuffer(WebGLRenderingContext.ARRAY_BUFFER, this.squareVertexPositionBuffer.buffer);
    
    list = [
              1.0,  1.0,  0.0,
             -1.0,  1.0,  0.0,
              1.0, -1.0,  0.0,
             -1.0, -1.0,  0.0 
           ];   
    //vertices.clear();
    vertices = new Float32Array.fromList(list);
    
    this.GL.bufferData(WebGLRenderingContext.ARRAY_BUFFER, vertices, WebGLRenderingContext.STATIC_DRAW);
    this.squareVertexPositionBuffer.numItems = 4;
    this.squareVertexPositionBuffer.itemSize = 3;
       
    
  }
  
  void setMatrixUniforms()
  {
    this.GL.uniformMatrix4fv(pMatrixUniform, false, pMatrix.dest);
    this.GL.uniformMatrix4fv(mvMatrixUniform, false, mvMatrix.dest);
  }
  
  void drawScene()
  {
    //Setup Viewport and clear it
    this.GL.viewport(0, 0, this.canvas.width, this.canvas.height);
    this.GL.clear(WebGLRenderingContext.COLOR_BUFFER_BIT | WebGLRenderingContext.DEPTH_BUFFER_BIT);
    
    mvMatrix = new Matrix.identity();
    pMatrix = new Matrix.identity();
    
    //Setup Perspective and Model view matrix
    Matrix.Perspective(45.0, aspect, 0.1, 100.0, pMatrix);
    Matrix.Identity(mvMatrix);
    
    //set Model View matrix to the position where triangle needs to be drawn
    mvMatrix.translate(new Vector3(-1.5,0.0,-7.0));
    
    //Put triangle in the buffer and draw
    this.GL.bindBuffer(WebGLRenderingContext.ARRAY_BUFFER, triangleVertexPositionBuffer.buffer);
    this.GL.vertexAttribPointer(vertexPositionAttribute, triangleVertexPositionBuffer.itemSize, WebGLRenderingContext.FLOAT, false, 0, 0);
    setMatrixUniforms();
    this.GL.drawArrays(WebGLRenderingContext.TRIANGLES, 0, triangleVertexPositionBuffer.numItems);
    
    //set Model View matrix to the position where Square needs be drawn
    mvMatrix.translate(new Vector3(3.0, 0.0, 0.0));
    
    //Put Square in the buffer and draw
    this.GL.bindBuffer(WebGLRenderingContext.ARRAY_BUFFER, squareVertexPositionBuffer.buffer);
    this.GL.vertexAttribPointer(vertexPositionAttribute, squareVertexPositionBuffer.itemSize, WebGLRenderingContext.FLOAT, false, 0, 0);
    setMatrixUniforms();
    this.GL.drawArrays(WebGLRenderingContext.TRIANGLE_STRIP, 0, squareVertexPositionBuffer.numItems);    
    
  }
  
  void run()
  {
    this.initGL();
    this.initShaders();
    this.initBuffers();
    this.GL.clearColor(0.0, 0.0, 0.0, 1.0);
    this.GL.enable(WebGLRenderingContext.DEPTH_TEST);
    this.drawScene();

  }
  
}

void main() {
  WebGLTest demo = new WebGLTest();
  
  if(demo.initGL())
  {
    demo.run();
  }
  else
  {
    print('This is not working');
  }
}

