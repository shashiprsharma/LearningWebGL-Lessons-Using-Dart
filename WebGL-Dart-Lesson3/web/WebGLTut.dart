
import 'dart:html';
import 'dart:math';

import 'glmatrix.dart';
import 'VertexShader.dart';
import 'FragmentShader.dart';


class MatrixStack
{
  List<Matrix> matrixStack;
  
  MatrixStack(){
    this.matrixStack =  new List();
  }
  
  void push(Matrix mat)
  {    
    this.matrixStack.add(mat.clone());
  }
  
  Matrix pop()
  {
    return this.matrixStack.removeLast();
  }
}


class VertexBuffer
{
  int numItems;
  int itemSize;
  WebGLBuffer buffer;
  
  VertexBuffer()
  {
    buffer = null;
    numItems = 0;
    itemSize = 0;    
  }
  
}
class Shape
{
  Shape(){
    vertexPosition = new VertexBuffer();
    vertexColor = new VertexBuffer();    
  }
  VertexBuffer vertexPosition;
  VertexBuffer vertexColor;
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
  //int vertexPositionAttribute;
   
  Matrix mvMatrix;  
  MatrixStack matrixStack;
  Matrix pMatrix;

  Shape aTriangle;
  Shape aSquare;
    
  double rTri;
  double rSquare;
  
  WebGLTest()
  {
    this.canvas = query("#canvas1");
    this.aspect = this.canvas.width / this.canvas.height;
    matrixStack = new MatrixStack();
    rTri = 0.0;
    rSquare = 0.0;
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
      ret = FragmentShader.shaderCode;
    }
    else if(fileName.contains("vertex",0))
    {
      ret = VertexShader.shaderCode;;
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
    
    VertexShader.vertexPositionAttribute = this.GL.getAttribLocation(program, "aVertexPosition");
    this.GL.enableVertexAttribArray(VertexShader.vertexPositionAttribute);
    
    VertexShader.vertexColorAttribute = this.GL.getAttribLocation(program, "aVertexColor");
    this.GL.enableVertexAttribArray(VertexShader.vertexColorAttribute);
    
    pMatrixUniform = this.GL.getUniformLocation(program, "uPMatrix");
    mvMatrixUniform = this.GL.getUniformLocation(program, "uMVMatrix");
    
    return true;
  }
  
  void initBuffers()
  {
    //Setup Triangle's Position Buffer
    this.aTriangle = new Shape();
    this.aTriangle.vertexPosition.buffer = this.GL.createBuffer();    
    this.GL.bindBuffer(WebGLRenderingContext.ARRAY_BUFFER, this.aTriangle.vertexPosition.buffer);
    
    List list = [
                  0.0,  1.0,  0.0,
                 -1.0, -1.0,  0.0,
                  1.0, -1.0,  0.0
                ];    
    Float32Array vertices = new Float32Array.fromList(list);
    
    this.GL.bufferData(WebGLRenderingContext.ARRAY_BUFFER, vertices, WebGLRenderingContext.STATIC_DRAW);
    this.aTriangle.vertexPosition.numItems = 3;
    this.aTriangle.vertexPosition.itemSize = 3;
    
    //Setup Triangle's Color Buffer
    this.aTriangle.vertexColor.buffer = this.GL.createBuffer();
    this.GL.bindBuffer(WebGLRenderingContext.ARRAY_BUFFER, this.aTriangle.vertexColor.buffer);
    
    list = [
              1.0,  0.0,  0.0,  1.0,
              0.0,  1.0,  0.0,  1.0,
              0.0,  0.0,  1.0,  1.0
           ];
    Float32Array color = new Float32Array.fromList(list);
    this.GL.bufferData(WebGLRenderingContext.ARRAY_BUFFER, color, WebGLRenderingContext.STATIC_DRAW);
    this.aTriangle.vertexColor.numItems = 3;
    this.aTriangle.vertexColor.itemSize = 4;
    
        
    
    
    
    
    //Setup Square's Position Buffer
    this.aSquare = new Shape();
    this.aSquare.vertexPosition.buffer = this.GL.createBuffer();
    this.GL.bindBuffer(WebGLRenderingContext.ARRAY_BUFFER, this.aSquare.vertexPosition.buffer);
    
    list = [
              1.0,  1.0,  0.0,
             -1.0,  1.0,  0.0,
              1.0, -1.0,  0.0,
             -1.0, -1.0,  0.0 
           ];   
    //vertices.clear();
    vertices = new Float32Array.fromList(list);
    
    this.GL.bufferData(WebGLRenderingContext.ARRAY_BUFFER, vertices, WebGLRenderingContext.STATIC_DRAW);
    this.aSquare.vertexPosition.numItems = 4;
    this.aSquare.vertexPosition.itemSize = 3;
    
    
    //Setup Square's Color Buffer
    this.aSquare.vertexColor.buffer = this.GL.createBuffer();
    this.GL.bindBuffer(WebGLRenderingContext.ARRAY_BUFFER, this.aSquare.vertexColor.buffer);
    
    list = [];
    for(int i=0; i<4; i++){
      list.addAll([0.5, 0.5, 1.0, 1.0]); //Same color for all 4 vertex positions
    }
    color = new Float32Array.fromList(list);
    
    this.GL.bufferData(WebGLRenderingContext.ARRAY_BUFFER, color, WebGLRenderingContext.STATIC_DRAW);
    this.aSquare.vertexColor.numItems = 4;
    this.aSquare.vertexColor.itemSize = 4;
    
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
    
    matrixStack.push(mvMatrix);
    Matrix.Rotate(mvMatrix,  degToRad(rTri), new Vector3(0.0, 1.0, 0.0));
    
    //Put triangle's vertex positions and color in the buffer and draw
    //Vertex Positions
    this.GL.bindBuffer(WebGLRenderingContext.ARRAY_BUFFER, aTriangle.vertexPosition.buffer);
    this.GL.vertexAttribPointer(VertexShader.vertexPositionAttribute, aTriangle.vertexPosition.itemSize, WebGLRenderingContext.FLOAT, false, 0, 0);
    //Color
    this.GL.bindBuffer(WebGLRenderingContext.ARRAY_BUFFER, aTriangle.vertexColor.buffer);
    this.GL.vertexAttribPointer(VertexShader.vertexColorAttribute, aTriangle.vertexColor.itemSize, WebGLRenderingContext.FLOAT, false, 0, 0);
    
    setMatrixUniforms();
    this.GL.drawArrays(WebGLRenderingContext.TRIANGLES, 0, aTriangle.vertexPosition.numItems);
    
    mvMatrix = matrixStack.pop();
    
    
    
    //set Model View matrix to the position where Square needs be drawn
    mvMatrix.translate(new Vector3(3.0, 0.0, 0.0));
    
    matrixStack.push(mvMatrix);
    Matrix.Rotate(mvMatrix,  degToRad(rSquare), new Vector3(1.0, 0.0, 0.0));
    
    //Put Square's vertex positions and color in the buffer and draw
    //Vertex Positions
    this.GL.bindBuffer(WebGLRenderingContext.ARRAY_BUFFER, aSquare.vertexPosition.buffer);
    this.GL.vertexAttribPointer(VertexShader.vertexPositionAttribute, aSquare.vertexPosition.itemSize, WebGLRenderingContext.FLOAT, false, 0, 0);
    //Color
    this.GL.bindBuffer(WebGLRenderingContext.ARRAY_BUFFER, aSquare.vertexColor.buffer);
    this.GL.vertexAttribPointer(VertexShader.vertexColorAttribute, aSquare.vertexColor.itemSize, WebGLRenderingContext.FLOAT, false, 0, 0);
    setMatrixUniforms();
    this.GL.drawArrays(WebGLRenderingContext.TRIANGLE_STRIP, 0, aSquare.vertexPosition.numItems);
    
    mvMatrix = matrixStack.pop();
    
  }

  int lastTime = 0;
  void animate()
  {
    Date d = new Date.now();
    int timeNow = d.millisecondsSinceEpoch;
    if(lastTime!=0)
    {
      int elapsed = timeNow - lastTime;
      //int elapsed = 2;
      rTri = rTri % 360;
      rSquare = rSquare % 360;
      this.rTri += ((90 * elapsed) / 1000.0).toDouble();
      this.rSquare += ((75 * elapsed) / 1000.0).toDouble();
    }
    lastTime = timeNow;
  }
  
  void tick(double highResTime)
  {    
    window.requestAnimationFrame(tick);    
    this.drawScene();
    this.animate();
    
    
  }
  
  void run()
  {
    this.initGL();
    this.initShaders();
    this.initBuffers();
    this.GL.clearColor(0.0, 0.0, 0.0, 1.0);
    this.GL.enable(WebGLRenderingContext.DEPTH_TEST);
    //this.drawScene();
    this.tick(10.0);

  }
  
}

double degToRad(double degrees){
  double ret =  degrees * PI.toDouble()/180.0;
  return ret;
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

