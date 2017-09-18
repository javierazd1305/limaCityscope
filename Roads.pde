/**
* Roads - Facade to simplify manipulation of the whole simulation
* @author        Marc Vilella & Javier Zarate
* @version       1.1
* @see           Facade
*/

public PVector[] boundaries;
public ArrayList<PVector> puntos = new ArrayList();

public class Roads extends Facade<Node>{
  
  /**
  *Contructor that calls RoadFabric
  *@file is the file of the roads
  *@file2 is the file of the blocks
  */
  public Roads(String file, String file2){
    factory = new RoadFactory();
    this.loadJSON(file,this);
    readBlocks(file2);
  }
  
  /**
  *Add a node in the roads
  *Asign an ID that is equals to the length of the items
  */
  public void add(Node node) {
    if(node.getID() == -1) {
      node.setID(items.size());
      items.add(node);
     }
  }
  
  /**
  *Create all the blocks like a array of PVectors
  *@return alls the blocks
  */
  public void readBlocks(String File){
    JSONObject roadNetwork=loadJSONObject(File);
    JSONArray lanes =roadNetwork.getJSONArray("features");
    //println(boundaries);
    
    for(int i=0; i<lanes.size();i++){
        JSONObject lane =lanes.getJSONObject(i);
        JSONArray points=lane.getJSONObject("geometry").getJSONArray("coordinates");
        points = points.getJSONArray(0);
        //points = points.getJSONArray(0).getJSONArray(0);
        puntos = new ArrayList();
        for(int j=0; j<points.size(); j++){
           PVector point= toXY(points.getJSONArray(j).getFloat(1),points.getJSONArray(j).getFloat(0));
           puntos.add(point);
        }
        blocks = new Blocks(puntos);
      
    }
    println("finish blocks");    
  }
  
  /**
  *Draw all the nodes
  *Call the draw functions of other classes
  */
  public void draw(PGraphics canvas, int stroke, color c) {
     for(Node node : items) node.draw(canvas, stroke, c);
  }
  
  /**
  *draw the layers created in the Layer class
  */
    public void drawLayers(PGraphics canvas){
        for(Node node : items){
          for (Lane lane: node.lanes){
            boolean in = (boolean) layer.contains(lane.center).get(0);
            if(in){
            //if(layer.contains(lane.center)){
              float damage = (int)layer.contains(lane.center).get(1);
              damage = map(damage,1,5,255,0);
              canvas.stroke(255,damage,0,60);
              for(int i = 1; i < lane.vertices.size(); i++) {
                PVector prevVertex = lane.vertices.get(i-1);
                PVector vertex = lane.vertices.get(i);
                canvas.line(prevVertex.x, prevVertex.y, vertex.x, vertex.y);
              } 
            }  
         }
      }
    }
    
     /**
     *Draw the whole lanes but the color is modified by the values of ms and ratio
     */
     public void drawLanesTraffic(PGraphics canvas, int stroke, color c) {
        for(Node node : items)
          for (Lane lane: node.lanes){           
            //th
            float valor = map(lane.ms, 4.85, 5.02,0.0, 1.0);
            float newStroke = map(lane.ratio,0,1.8,0,5);
            color occupColor = lerpColor(#FFFFFF, #FF0000, valor);
            canvas.stroke(occupColor, 127); canvas.strokeWeight(int(newStroke));
            for(int i = 1; i < lane.vertices.size(); i++) {
            PVector prevVertex = lane.vertices.get(i-1);
            PVector vertex = lane.vertices.get(i);
            canvas.line(prevVertex.x, prevVertex.y, vertex.x, vertex.y); 
          }  
        }
      }
      
    /**
    *Get all the center of the lanes
    *Export this center points as lat long
    *The name of the file is defined in limaCityscope
    */
    public void getLaneCenter(PrintWriter output){
      for(Node node: items){
        if (node instanceof POI){
          continue;
        }
        else{
          for(Lane lane : node.lanes){
            output.println(reverseXY(lane.center.x, lane.center.y));
          }
        }
      }
      output.flush();
      output.close();
      println("created file");
    }
    
    /**
    *Loop throw all the nodes and it is a POI
    *change the size
    *This is for filtering porpuses
    */
    public void getType(String tipo){
      for (Node node: items){
        boolean poi =  node instanceof POI;
        if (poi){
          POI punto = (POI) node;
          if(punto.isType(tipo)){
           punto.size = 8;
          }else{
           punto.size = 1;
          }
        }
      }
    }
    
    /**
    *Draw the blocks in a canvas
    */
    public void getBlocks(PGraphics canvas, int stroke, color c){
      blocks.getAll(canvas,stroke,c);
    }
    
    /**
    *Get the traffic data from a file
    *All lanes ms and ratio are updated
    */
    public void trafficLayer(String path){
      print("Loading Traffic Layer... ");

        int count=0;
        Table table = loadTable(path, "header");
        for(TableRow row : table.rows()) {
            PVector location    = roads.toXY(row.getFloat("lat"), row.getFloat("lng"));
            float ms        = row.getFloat("ms");
            float ratio         = row.getFloat("ratio");
            count += 1;
            Lane minLane = findClosestLane(location);
            minLane.ms = ms;
            minLane.ratio = ratio;  
        }
        println(count);
        println("traffc layer done!");
    }
    
    /**
    *Call node select function
    */
     public void select(int mouseX, int mouseY) {
        for(Node node : items) node.select(mouseX, mouseY);
    }
       
    /**
    *Connect a POI to the road
    *add the POI to the item arrayList
    */
      private void connect(POI poi) { 
        Lane closestLane = findClosestLane(poi.getPosition());
        Lane closestLaneBack = closestLane.findContrariwise();
        PVector closestPoint = closestLane.findClosestPoint(poi.getPosition());
        
        Node connectionNode = new Node(closestPoint);
        connectionNode = closestLane.split(connectionNode);
        if(closestLaneBack != null) connectionNode = closestLaneBack.split(connectionNode);
        this.add(connectionNode);
        
        poi.connectBoth(connectionNode, null, "Access", poi.access);
        add(poi);
        
    }
    /**
    Find the closes lane realtive to the center position
    */
      public Lane findClosestLane(PVector position) {
        Float minDistance = Float.NaN;
        Lane closestLane = null;
        for(Node node : items) {
            for(Lane lane : node.outboundLanes()) {
                PVector linePoint = lane.findClosestPoint(position);
                float distance = position.dist(linePoint);
                if(minDistance.isNaN() || distance < minDistance) {
                    minDistance = distance;
                    closestLane = lane;
                }
            }
        }
        return closestLane;
    }
    /**
    *Map the lat lon to a UTM coordinates
    *Map the UTM to the canvas size
    *@return a mapped value
    */
      public PVector toXY(float lat, float lon){
                PVector projPoint = Projection.toUTM(lat, lon, Projection.Datum.WGS84);
        return new PVector(
            map(projPoint.x, boundaries[0].x, boundaries[1].x, 0+100, width-100),
            map(projPoint.y, boundaries[0].y, boundaries[1].y, height-100, 0+100)
        );
      }
      
     /**
     *Unmap a point in a canvas to lat lng
     *@return unmapped point
     */
      public PVector reverseXY(float lat, float lon){
        return new PVector(
          map(lat, 0+100, width-100, boundaries[0].x, boundaries[1].x),
          map(lon, height-100, 0+100, boundaries[0].y, boundaries[1].y)
        );
      }
}


/**
* AgentFactory - Factory to generate the roads 
* @author        Marc Vilella & Javier Zarate
* @version       1.1
* @see           Factory
*/
public class RoadFactory extends Factory<Node>{
  
  public ArrayList<Node>  loadJSON(File file, Roads roads){
    JSONObject roadNetwork=loadJSONObject(file);
    JSONArray lanes =roadNetwork.getJSONArray("features");
    boundaries = findBound(lanes);
    for(int i=0; i<lanes.size();i++){
        JSONObject lane =lanes.getJSONObject(i);
        JSONObject props= lane.getJSONObject("properties");
        Accessible access = props.isNull("type") ? Accessible.ALL : Accessible.create( props.getString("type") );
        String name = props.isNull("name") ? "null" : props.getString("name");
        boolean oneWay=props.isNull("oneway")? false:props.getInt("oneway")==1? true:false;
        String direction=props.isNull("direction")? null: props.getString("direction");
        JSONArray points=lane.getJSONObject("geometry").getJSONArray("coordinates");
        
        Node prevNode=null;
        ArrayList vertices=new ArrayList();
        
         for(int j=0; j<points.size(); j++){
           PVector point=roads.toXY(points.getJSONArray(j).getFloat(1),points.getJSONArray(j).getFloat(0));
           puntos.add(point);
           vertices.add(point);
           
           Node currNode=getNodeIfVertex(roads,point);
           if(currNode != null) {
                        if(prevNode != null && j < points.size()-1) {
                            if(oneWay) prevNode.connect(currNode, vertices, name, access);
                            else prevNode.connectBoth(currNode, vertices, name, access);
                            vertices = new ArrayList();
                            vertices.add(point);
                            prevNode = currNode;
                        }
                    } else currNode = new Node(point);
                    
                    if(prevNode == null) {
                        prevNode = currNode;
                        currNode.place(roads);
                    } else if(j == points.size()-1) {
                        if(oneWay) prevNode.connect(currNode, vertices, name, access);
                        else prevNode.connectBoth(currNode, vertices, name, access);
                        currNode.place(roads);
                        if(direction != null) currNode.setDirection(direction);
                    }
         }
    }
    //println(puntos);
    println("LOADED");
    return new ArrayList();
  }
  
  /**
  *Evaluate if a node exists in the current road.
  *return a new node if it is not in the roads, null otherwise
  */
  private Node getNodeIfVertex(Roads roads, PVector position) {
        for(Node node : roads.getAll()) {
            if( position.equals(node.getPosition()) ) return node;
            for(Lane lane : node.outboundLanes()) {
                if( position.equals(lane.getEnd().getPosition()) ) return lane.getEnd();
                else if( lane.contains(position) ) {
                    Lane laneBack = lane.findContrariwise();
                    Node newNode = new Node(position);
                    if(lane.divide(newNode)) {
                        if(laneBack != null) laneBack.divide(newNode);
                        newNode.place(roads);
                        return newNode;
                    }
                }
            }
        }
        return null;
    }
 
 /**
 *Get the bound of the roads
 @return the bounding box in UTM coordinates
 */
  
  public PVector[] findBound(JSONArray lanes){
    float minLat = Float.MAX_VALUE;
    float maxLat=-(Float.MAX_VALUE);
    float minLon=Float.MAX_VALUE;
    float maxLon= -(Float.MAX_VALUE);
    for(int i=0; i<lanes.size();i++){
        JSONObject lane =lanes.getJSONObject(i);
        JSONArray points=lane.getJSONObject("geometry").getJSONArray("coordinates");
        for(int j=0; j<points.size(); j++){
          float lat = points.getJSONArray(j).getFloat(1);
          float lon = points.getJSONArray(j).getFloat(0);
            minLat=min(minLat,lat);
            maxLat=max(maxLat,lat);
            minLon=min(minLon,lon);
            maxLon=max(maxLon,lon);
        }
    }
        return new PVector[] {
            Projection.toUTM(minLat, minLon, Projection.Datum.WGS84),
            Projection.toUTM(maxLat, maxLon, Projection.Datum.WGS84)
        };
  }
}
  
  