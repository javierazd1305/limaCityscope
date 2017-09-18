/**
* Blocks         Block is the representation of the block
* @author        Javier Zarate
* @version       1.0
*/
public ArrayList allBlocks = new ArrayList();
public ArrayList <PShape> shapes = new ArrayList();

public class Blocks{
  ArrayList vertex;
  int area;
  PVector midPoint;
  
  /**
  @vertexs PVectors that build the whole block.
  */
  public Blocks(ArrayList vertexs){
    this.vertex = vertexs;
    allBlocks.add(vertex);
    
  }
  
  /**
  *draw the blocks in the canvas
  */
  public void getAll(PGraphics canvas, int stroke, color c){
    for(int i = 0; i < allBlocks.size(); i++){
      ArrayList lala = new ArrayList();
      lala = (ArrayList) allBlocks.get(i);
      for(int j = 1; j < lala.size(); j++){
        PVector vertex = new PVector();
        PVector prevVertex = new PVector();
        vertex = (PVector) lala.get(j);
        prevVertex = (PVector) lala.get(j-1);
        //println(vertex);
        canvas.strokeWeight(stroke);
        canvas.stroke(0,0,255,20); 
        canvas.line(prevVertex.x, prevVertex.y, vertex.x, vertex.y);
      }
    }
    
  }
 
}