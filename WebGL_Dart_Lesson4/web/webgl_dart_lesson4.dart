
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
    vertexIndex = new VertexBuffer();
  }
  VertexBuffer vertexPosition;
  VertexBuffer vertexColor;
  VertexBuffer vertexIndex;
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

  Shape aPyramid;
  Shape aCube;
    
  double rPyramid;
  double rCube;
  
  WebGLTest()
  {
    this.canvas = query("#canvas1");
    this.aspect = this.canvas.width / this.canvas.height;
    matrixStack = new MatrixStack();
    rPyramid = 0.0;
    rCube = 0.0;
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
    //Setup Pyramid's Position Buffer
    this.aPyramid = new Shape();
    this.aPyramid.vertexPosition.buffer = this.GL.createBuffer();    
    this.GL.bindBuffer(WebGLRenderingContext.ARRAY_BUFFER, this.aPyramid.vertexPosition.buffer);
    
    List list = [
                  //Front Face
                  0.0,  1.0,  0.0,
                 -1.0, -1.0,  1.0,
                  1.0, -1.0,  1.0,
                  //Right Face
                  0.0,  1.0,  0.0,
                  1.0, -1.0,  1.0,
                  1.0, -1.0,  -1.0,
                  //Back Face
                  0.0,  1.0,  0.0,
                  1.0, -1.0,  -1.0,
                  -1.0, -1.0,  -1.0,
                  //Left Face
                  0.0,  1.0,  0.0,
                  -1.0, -1.0,  -1.0,
                  -1.0, -1.0,  1.0
                ];
    
    Float32Array vertices = new Float32Array.fromList(list);
    
    this.GL.bufferData(WebGLRenderingContext.ARRAY_BUFFER, vertices, WebGLRenderingContext.STATIC_DRAW);
    this.aPyramid.vertexPosition.numItems = 12;
    this.aPyramid.vertexPosition.itemSize = 3;
    
    //Setup Pyramid's Color Buffer
    this.aPyramid.vertexColor.buffer = this.GL.createBuffer();
    this.GL.bindBuffer(WebGLRenderingContext.ARRAY_BUFFER, this.aPyramid.vertexColor.buffer);
    
    list = [
              //Front Face
              1.0,  0.0,  0.0,  1.0,
              0.0,  1.0,  0.0,  1.0,
              0.0,  0.0,  1.0,  1.0,
              // Right face
              1.0,  0.0,  0.0,  1.0,
              0.0,  0.0,  1.0,  1.0,
              0.0,  1.0, 0.0,  1.0,
              // Back face
              1.0,  0.0,  0.0,  1.0,
              0.0,  1.0,  0.0,  1.0,
              0.0,  0.0,  1.0,  1.0,
              // Left face
              1.0,  0.0,  0.0,  1.0,
              0.0,  0.0,  1.0,  1.0,
              0.0,  1.0,  0.0,  1.0
           ];
    Float32Array color = new Float32Array.fromList(list);
    this.GL.bufferData(WebGLRenderingContext.ARRAY_BUFFER, color, WebGLRenderingContext.STATIC_DRAW);
    this.aPyramid.vertexColor.numItems = 12;
    this.aPyramid.vertexColor.itemSize = 4;
    
        
    
    
    
    
    //Setup Cube's Position Buffer
    this.aCube = new Shape();
    this.aCube.vertexPosition.buffer = this.GL.createBuffer();
    this.GL.bindBuffer(WebGLRenderingContext.ARRAY_BUFFER, this.aCube.vertexPosition.buffer);
    
    list = [
              // Front face
              -1.0, -1.0,  1.0,
              1.0, -1.0,  1.0,
              1.0,  1.0,  1.0,
              -1.0,  1.0,  1.0,
              
              // Back face
              -1.0, -1.0, -1.0,
              -1.0,  1.0, -1.0,
              1.0,  1.0, -1.0,
              1.0, -1.0, -1.0,
              
              // Top face
              -1.0,  1.0, -1.0,
              -1.0,  1.0,  1.0,
              1.0,  1.0,  1.0,
              1.0,  1.0, -1.0,
              
              // Bottom face
              -1.0, -1.0, -1.0,
              1.0, -1.0, -1.0,
              1.0, -1.0,  1.0,
              -1.0, -1.0,  1.0,
              
              // Right face
              1.0, -1.0, -1.0,
              1.0,  1.0, -1.0,
              1.0,  1.0,  1.0,
              1.0, -1.0,  1.0,
              
              // Left face
              -1.0, -1.0, -1.0,
              -1.0, -1.0,  1.0,
              -1.0,  1.0,  1.0,
              -1.0,  1.0, -1.0
           ];   
    //vertices.clear();
    vertices = new Float32Array.fromList(list);
    
    this.GL.bufferData(WebGLRenderingContext.ARRAY_BUFFER, vertices, WebGLRenderingContext.STATIC_DRAW);
    this.aCube.vertexPosition.numItems = 24;
    this.aCube.vertexPosition.itemSize = 3;
    
    
    //Setup Cube's Color Buffer
    this.aCube.vertexColor.buffer = this.GL.createBuffer();
    this.GL.bindBuffer(WebGLRenderingContext.ARRAY_BUFFER, this.aCube.vertexColor.buffer);
    
    //Add color for only one vertex of each face. Then use a loop to add color for all vertices
    list = [
            [1.0, 0.0, 0.0, 1.0],   //Front Face
            [1.0, 1.0, 0.0, 1.0],   //Back Face
            [0.0, 1.0, 0.0, 1.0],   // Top face
            [1.0, 0.5, 0.5, 1.0],   // Bottom face
            [1.0, 0.0, 1.0, 1.0],   // Right face
            [0.0, 0.0, 1.0, 1.0]    // Left face            
            ];

    
    List newList = new List();
    //Loop copying one vertex color value to all vertices of a face
    for(List l in list){
      for(int i=0; i<4; i++){
        newList.add(l);
      }
    }
    
    list.clear();
    for(int i=0; i<newList.length;i++){
      for(int j=0; j<newList.elementAt(i).length;j++){
        list.add(newList.elementAt(i).elementAt(j));
      }
    }
    color = new Float32Array.fromList(list);
    
    this.GL.bufferData(WebGLRenderingContext.ARRAY_BUFFER, color, WebGLRenderingContext.STATIC_DRAW);
    this.aCube.vertexColor.numItems = 24;
    this.aCube.vertexColor.itemSize = 4;
    
    //Setup Cube's Index buffer
    this.aCube.vertexIndex.buffer = this.GL.createBuffer();
    this.GL.bindBuffer(WebGLRenderingContext.ELEMENT_ARRAY_BUFFER, this.aCube.vertexIndex.buffer);
    
    list = [
            0, 1, 2,      0, 2, 3,    //Front Face
            4, 5, 6,      4, 6, 7,    // Back face
            8, 9, 10,     8, 10, 11,  // Top face
            12, 13, 14,   12, 14, 15, // Bottom face
            16, 17, 18,   16, 18, 19, // Right face
            20, 21, 22,   20, 22, 23  // Left face            
            ];
    
    Uint16Array indices = new Uint16Array.fromList(list);
    
    this.GL.bufferData(WebGLRenderingContext.ELEMENT_ARRAY_BUFFER, indices, WebGLRenderingContext.STATIC_DRAW);
    this.aCube.vertexIndex.numItems = 36;
    this.aCube.vertexIndex.itemSize = 1;
    
    
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
    
    
    
    //set Model View matrix to the position where Pyramid needs to be drawn
    mvMatrix.translate(new Vector3(-1.5,0.0,-8.0));
    
    matrixStack.push(mvMatrix);
    Matrix.Rotate(mvMatrix,  degToRad(rPyramid), new Vector3(0.0, 1.0, 0.0));
    
    //Put Pyramid's vertex positions and color in the buffer and draw
    //Vertex Positions
    this.GL.bindBuffer(WebGLRenderingContext.ARRAY_BUFFER, aPyramid.vertexPosition.buffer);
    this.GL.vertexAttribPointer(VertexShader.vertexPositionAttribute, aPyramid.vertexPosition.itemSize, WebGLRenderingContext.FLOAT, false, 0, 0);
    //Color
    this.GL.bindBuffer(WebGLRenderingContext.ARRAY_BUFFER, aPyramid.vertexColor.buffer);
    this.GL.vertexAttribPointer(VertexShader.vertexColorAttribute, aPyramid.vertexColor.itemSize, WebGLRenderingContext.FLOAT, false, 0, 0);
    
    setMatrixUniforms();
    this.GL.drawArrays(WebGLRenderingContext.TRIANGLES, 0, aPyramid.vertexPosition.numItems);
    
    mvMatrix = matrixStack.pop();
    
    
    
    //set Model View matrix to the position where Cube needs be drawn
    mvMatrix.translate(new Vector3(3.0, 0.0, 0.0));
    
    matrixStack.push(mvMatrix);
    Matrix.Rotate(mvMatrix,  degToRad(rCube), new Vector3(1.0, 1.0, 1.0));
    
    //Put Cube's vertex positions and color in the buffer and draw
    //Vertex Positions
    this.GL.bindBuffer(WebGLRenderingContext.ARRAY_BUFFER, aCube.vertexPosition.buffer);
    this.GL.vertexAttribPointer(VertexShader.vertexPositionAttribute, aCube.vertexPosition.itemSize, WebGLRenderingContext.FLOAT, false, 0, 0);
    //Color
    this.GL.bindBuffer(WebGLRenderingContext.ARRAY_BUFFER, aCube.vertexColor.buffer);
    this.GL.vertexAttribPointer(VertexShader.vertexColorAttribute, aCube.vertexColor.itemSize, WebGLRenderingContext.FLOAT, false, 0, 0);
    //Indices
    this.GL.bindBuffer(WebGLRenderingContext.ELEMENT_ARRAY_BUFFER, aCube.vertexIndex.buffer);
    
    setMatrixUniforms();
    //this.GL.drawArrays(WebGLRenderingContext.TRIANGLE_STRIP, 0, aCube.vertexPosition.numItems);
    this.GL.drawElements(WebGLRenderingContext.TRIANGLES, aCube.vertexIndex.numItems, WebGLRenderingContext.UNSIGNED_SHORT, 0);
    
    mvMatrix = matrixStack.pop();
    
  }

  int lastTime = 0;
  void animate()
  {
    DateTime d = new DateTime.now();
    int timeNow = d.millisecondsSinceEpoch;
    if(lastTime!=0)
    {
      int elapsed = timeNow - lastTime;
      //int elapsed = 2;
      rPyramid = rPyramid % 360;
      rCube = rCube % 360;
      this.rPyramid += ((90 * elapsed) / 1000.0).toDouble();
      this.rCube -= ((75 * elapsed) / 1000.0).toDouble();
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

