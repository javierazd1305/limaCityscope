/**
* Layers - Polygons which gives some value to a node attribute
* @author        Javier Zarate
* @version       1.0
*/

ArrayList<Layer> layers = new ArrayList();

class Layers{
  /**
  *Constructor
  *@path String with the path to the file
  */
  public Layers(String path){
    JSONObject roadNetwork=loadJSONObject(path);
    JSONArray lanes =roadNetwork.getJSONArray("features");
    //println(boundaries);
    print("Loading Vulmap... ");
    for(int i=0; i<lanes.size();i++){
        JSONObject lane =lanes.getJSONObject(i);
        JSONArray points=lane.getJSONObject("geometry").getJSONArray("coordinates");
        java.awt.Polygon p = new java.awt.Polygon();
        for(int j=0; j<points.size(); j++){
          //println(points.getJSONArray(j).getFloat(0) , points.getJSONArray(j).getFloat(1));
          PVector point= roads.toXY(points.getJSONArray(j).getFloat(1),points.getJSONArray(j).getFloat(0));
          //println(point);
          p.addPoint(int(point.x), int(point.y));
        }
        String name = lane.getJSONObject("properties").getString("name");
        int damage = lane.getJSONObject("properties").getInt("damage");
        new Layer(p,damage);
    }
    println("LOADED");
  }
  
  
  /**
  *Draw layers in the canvas
  */
  public void drawLayers(PGraphics canvas){
    for(int j = 0; j < layers.size(); j++){
        java.awt.Polygon set = new java.awt.Polygon();
        Layer lay = layers.get(j);
        set = (java.awt.Polygon) lay.points;
        canvas.noStroke();
        canvas.beginShape();
        float damage = lay.damage;
        //canvas.fill(255,0,0,20);
        damage = map(damage,1,5,255,0);
        canvas.fill(255,damage,0,60);
        for (int i = 0; i < set.npoints; i++) {
         canvas.vertex(set.xpoints[i], set.ypoints[i]);
        }
        canvas.endShape();
    }
  }
  
  /**
  *Verified if a PVector is in a layer area
  *@eval is a Pvector to be evaluated 
  */
    public ArrayList contains(PVector eval){
    boolean in = false;
    ArrayList result = new ArrayList();
    for(int j = 0; j < layers.size(); j++){
        java.awt.Polygon set = new java.awt.Polygon();
        Layer lay = layers.get(j);
        set = (java.awt.Polygon) lay.points;
        in = set.contains(eval.x,eval.y);
        if(in == true){
          result.add(in);
          result.add(lay.damage);
          return result;
          //return in;
        }
    }
    //return in;
    result.add(in);
    result.add(-1);
    return result;
  }
}

/**
* Layer - Polygon with same properties that if a node is inside will inherited
* @author        Javier Zarate
* @version       1.0
*/

class Layer{
  int damage;
  java.awt.Polygon points;
  public Layer(java.awt.Polygon setPoints, int damage){
    this.damage = damage;
    java.awt.Polygon points = new java.awt.Polygon();
    points = setPoints;
    this.points = points;
    layers.add(this);
  } 
}