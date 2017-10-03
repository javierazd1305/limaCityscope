/**
* POIs - Facade to simplify manipulation of Pois of Interest in simulation
* @author        Marc Vilella & Javier Zarate
* @version       1.1
* @see           Facade
*/
public class POIs extends Facade<POI> {

    /**
    * Initiate pois of interest facade and agents' Factory
    * @param roads  Roadmap where agents will be placed and move
    */
    public POIs() {
        factory = new POIFactory();
    }
     public void loadCSV(String path, Roads roadmap) {
        File file = new File( dataPath(path) );
        if( !file.exists() ) println("ERROR! CSV file does not exist");
        else items.addAll( ((POIFactory)factory).loadCSV(path, roadmap) );
    }
    public void getWarehouses(){
      //println(pois.count(),"warehouse:");
      for (POI poi : pois.getAll()){
        if (poi.NAME.equals("wareHouse")){
          println(poi.toString());
          Warehouse latent = (Warehouse) poi;
          latent.makeAccessible();
        }
      }
    }
    
    public void makeAvailableZona(String type){
       for (POI poi : pois.getAll()){
        if (poi.TYPE.equals(type)){
           poi.access = Accessible.ALL;
        }
      }
    }
    
    public void makeUnavailableZona(String type){
       for (POI poi : pois.getAll()){
        if (poi.TYPE.equals(type)){
           poi.access = Accessible.NULL;
        }
      }
    }
    
    public void drawPOIPaths(PGraphics canvas){
      for (POI poi : pois.getAll()){
        if (poi instanceof SecureZone){
           SecureZone latent = (SecureZone) poi;
            for(Path path : latent.pathWarehouses){
              float valor = map(path.getLength(),0,700,0,1);
              color occupColor = lerpColor(#FFFF00, #FF0000, valor);
              path.draw(canvas, 1, occupColor);
            }
        }
      }
    }
    
    public void printLegend(PGraphics canvas, int x, int y) {
        String txt = "";
        canvas.textAlign(LEFT, TOP);
        canvas.textSize(8);
        for(POI poi : pois.getAll()){
          if (poi instanceof Warehouse){
            Warehouse latent = (Warehouse) poi;
            for(POI goPOI : latent.poisToGo){
              float timesToGo =(float) goPOI.crowd.size() / (float) latent.helpDelivered;
              txt += goPOI.NAME + ": " + str(timesToGo) + "\n"; 
            }
            txt += "\n";
          }
        }
        canvas.stroke(0);
        canvas.text(txt, x, y);
   }
   
    public void printLegend2(PGraphics canvas, int x, int y) {
        String txt = "";
        canvas.textAlign(LEFT, TOP);
        canvas.textSize(8);
        for(POI poi : pois.getAll()){
          if (poi instanceof SecureZone){
              SecureZone latent = (SecureZone) poi;
              txt += poi.NAME + "  Help People:"+ str(latent.crowd.size()) + "\n"; 
          }
        }
        canvas.stroke(0);
        canvas.text(txt, x, y);
   }
    
   public void secureZonePath(){
     ArrayList wholePaths = new ArrayList();
     for(POI poi : pois.getAll()){
       if(poi instanceof SecureZone){
         SecureZone latent = (SecureZone) poi;
         ArrayList pathLatent = latent.getPathWarehouses();
         wholePaths.add(pathLatent);
       }
     }
     optimizePaths(wholePaths);
   }
   
   public void optimizePaths(ArrayList wholePaths){
    ArrayList newArray = new ArrayList();
    ArrayList lll = (ArrayList) wholePaths.get(0);
    //println(lll.size());
    ArrayList aaa = (ArrayList) lll.get(0);
    //println(aaa.get(0));
    //println(aaa.size());
    int indice = 0;
    for(int i = 0; i < wholePaths.size(); i++){ //i num scure zones
      float minDist = 100000;
      ArrayList candidate = new ArrayList();  
      for(int j = 0; j < lll.size(); j++ ){ // num warehouses
        ArrayList bbb = (ArrayList)wholePaths.get(i);
        ArrayList ccc = (ArrayList) bbb.get(j);
        float distPath = (float) ccc.get(2);
        if(distPath < minDist){
          minDist = distPath;
          candidate = ccc;
          indice = j;
        }
      }
      //println(candidate.get(2), indice);
      SecureZone addPath = (SecureZone)candidate.get(3);
      Path pathAdd = (Path) candidate.get(1);
      addPath.pathWarehouses.add(pathAdd);
    }
    

  }
}

/**
* POIFactory - Factory to generate diferent Points of Interest from diferent sources 
* @author        Marc Vilella
* @version       1.0
* @see           Factory
*/
private class POIFactory extends Factory {
    
    /**
    * Load POIs form JSON file
    */
    public ArrayList<POI> loadJSON(File JSONFile, Roads roads) {
        
        print("Loading POIs... ");
        ArrayList<POI> pois = new ArrayList();
        int count = count();
        JSONArray JSONPois = loadJSONObject(JSONFile).getJSONArray("features");
        for(int i = 0; i < JSONPois.size(); i++) {
            JSONObject poi = JSONPois.getJSONObject(i);
            
            JSONObject props = poi.getJSONObject("properties");
            
            String name    = props.isNull("name") ? "null" : props.getString("name");
            String type    = props.isNull("type") ? "null" : props.getString("type");
            int capacity   = props.isNull("CAPACITY") ? 10 : props.getInt("CAPACITY");
            
            JSONArray coords = poi.getJSONObject("geometry").getJSONArray("coordinates");
            PVector location = roads.toXY( coords.getFloat(1), coords.getFloat(0) );
            if( location.x > 0 && location.x < width && location.y > 0 && location.y < height ) {
                    pois.add( new POI(roads, str(count), name, type, location, capacity) );
                    counter.increment(type);
                    count++;
            }
             
        }
        println("LOADED");
        return pois;  
    }
    
        
    public ArrayList<POI> loadCSV(String path, Roads roads) {
        
        print("Loading POIs... ");
        ArrayList<POI> pois = new ArrayList();
        int count = count();
        
        Table table = loadTable(path, "header");
        for(TableRow row : table.rows()) {
            String name         = row.getString("NOMBRE");
            PVector location    = roads.toXY(row.getFloat("GEO_Y"), row.getFloat("GEO_X"));
            Float capacity        = row.getFloat("CAPACIDAD");
            if (Float.isNaN(capacity)){ capacity = 30.0;}
            String type         = row.getString("HOMOLOGACION");
            if(type.equals("ZONA_SEGURA")){
              pois.add(new SecureZone(roads, str(count), name, type, location, int(capacity)));
            }else{
              pois.add( new POI(roads, str(count), name, type, location, int(capacity)) );
            }
            counter.increment(type); 
            count++;
        }
        println("LOADED");
        return pois;
    }
}
/**
* POI -  Abstract class describing a Point of Interest, that is a destination for agents in simulation
* @author        Marc Vilella
* @version       2.0
*/
public class POI extends Node {

    protected final String ID;
    protected final String NAME;
    protected final int CAPACITY;
    protected Accessible access;
    
    protected ArrayList<Agent> crowd = new ArrayList();
    protected float occupancy;
    
    protected float size = 2;
    public String TYPE;
    //private Node NODE;
    //private final PVector POSITION;
    //private boolean selected;
    
    
    
    /**
    * Initiate POI with specific name and capacity, and places it in the roadmap
    * @param roads  Roadmap to place the POI
    * @param id  ID of the POI
    * @param position  Position of the POI
    * @param name  name of the POI
    * @param capacity  Customers capacity of the POI
    */
    public POI(Roads roads, String id, String name, String type, PVector position,int capacity) {
        super(position);
        ID = id;
        NAME = name;
        CAPACITY = capacity;
        TYPE = type;
        access = Accessible.create(type);
        place(roads);
    }
    
    
    /**
    * Create a node in the roadmap linked to the POI and connects it to the closest lane
    * @param roads  Roadmap to add the POI
    */
    
    public void place(Roads roads) {
        roads.connect(this);
    } 
    
    @Override
    public boolean allows(Agent agent) {
        return access.allows(agent);
    }
    
    /**
    *Check the typo of a POI
    */
    public boolean isType(String tipo) {
        if(TYPE.equals(tipo)){
          return true;
        }
        return false;
    }
   
    /**
    * Get POI drawing size
    * @return POI size
    */
    public float getSize() {
        return size;
    }
    
    
    /**
    * Add agent to the hosted list as long as POI's crowd is under its maximum capacity, meaning agent is staying in POI
    * @param agent  Agent to host
    * @return true if agent is hosted, false otherwise
    */
    public boolean host(Agent agent) {
        if(this.allows(agent) && crowd.size() < CAPACITY) {
            crowd.add(agent);
            update();
            return true;
        }
        return false;
    }
    
    
    /**
    * Remove agent from hosted list, meaning agent has left the POI
    * @param agent  Agent to host
    */
    public void unhost(Agent agent) {
        crowd.remove(agent);
        update();
    }
    
    
    /**
    * Update POIs variables: occupancy and drawing size
    */
    protected void update() {
        occupancy = (float)crowd.size() / CAPACITY;
        //size = (5 + 10 * occupancy); //hace que el POI se vuelva mas grande por el tema de capacidad
    }
    
    
    /**
    * Draw POI in screen, with different effects depending on its status
    */
    @Override
    public void draw(PGraphics canvas, int stroke, color c) {
        color occColor = lerpColor(#77DD77, #FF6666, occupancy);
        
        canvas.rectMode(CENTER); canvas.noFill(); canvas.stroke(occColor); canvas.strokeWeight(1);
        canvas.rect(position.x, position.y, size, size);

        if( selected ) {
            canvas.fill(0); canvas.textAlign(CENTER, BOTTOM);
            canvas.text(this.toString(), position.x, position.y - size / 2);
        }
    }


    /**
    * Select POI if mouse is hover
    * @param mouseX  Horizontal mouse position in screen
    * @param mouseY  Vertical mouse position in screen
    * @return true if POI is selected, false otherwise
    */
    public boolean select(int mouseX, int mouseY) {
        selected = dist(position.x, position.y, mouseX, mouseY) <= size;
        return selected;
    }
    
    
    /**
    * Return agent description (NAME, OCCUPANCY and CAPACITY)
    * @return POI description
    */
    public String toString() {
        return NAME + " " +TYPE + " [" + crowd.size() + " / " + CAPACITY + "]" + "occupancy: " + str(occupancy)+ access;
    }
    

}

private class SecureZone extends POI{
  int helpNeeded = crowd.size();
  ArrayList<Path> pathWarehouses = new ArrayList();
  public SecureZone(Roads roads, String id, String name, String type, PVector position,int capacity){
    super(roads, id, name,type, position, capacity);
    this.access = Accessible.NULL;
  }
  public Path findPathPOI(POI toPOI){
      Path tempPath = new Path(this, roads);
      tempPath.findPath(this, toPOI);
      return tempPath;   
  }
  
  public ArrayList getPathWarehouses(){
    ArrayList send = new ArrayList();
    for(POI poi : pois.getAll()){
      if(poi instanceof Warehouse){
        ArrayList latent = new ArrayList();
        Path pathWarehouse = findPathPOI(poi);
        float distance = pathWarehouse.getLength();
        latent.add(poi);
        latent.add(pathWarehouse);
        latent.add(distance);
        latent.add(this);
        send.add(latent);
      }
    }
    return send;
  }
  

  
   @Override
    public void draw(PGraphics canvas, int stroke, color c) {
        color occColor = lerpColor(#77DD77, #FF6666, occupancy);
        
        canvas.rectMode(CENTER); canvas.noFill(); canvas.stroke(occColor); canvas.strokeWeight(1);
        canvas.rect(position.x, position.y, size, size);

        if( selected ) {
            canvas.fill(0); canvas.textAlign(CENTER, BOTTOM);
            canvas.text(this.toString(), position.x, position.y - size / 2);
            for(int i = 0; i < pathWarehouses.size(); i++){ 
              Path latent = (Path) pathWarehouses.get(i);
              float valor = map(latent.getLength(),0,700,0,1);
              color occupColor = lerpColor(#FFFF00, #FF0000, valor);
              latent.draw(canvas, 1, occupColor);
            }
            
        }
        
        if (evacuate){
          canvas.fill(0); canvas.textAlign(CENTER, BOTTOM);
          canvas.text(str(crowd.size()), position.x, position.y - size / 2);
        }
   }



}


private class Warehouse extends POI{
   //protected  Accessible access;
   Path path;
   ArrayList <POI> poisToGo = new ArrayList();
   ArrayList <Path> pathEvacuate = new ArrayList();
   int helpDelivered = 10;
   public Warehouse(Roads roads, String id, String name, String type, PVector position,int capacity) {
        super(roads, id, name,type, position, capacity);
        this.access = Accessible.NULL;
        getAllPOItoGo(); //new
        //path = new Path(this, roads);
        //findPathPOI();
        pois.add(this);
    }
    public void makeAccessible(){
      this.access = Accessible.ALL;
    }
    
    public void getAllPOItoGo(){
      for(POI poi : pois.getAll()){
        if(poi instanceof SecureZone){
          poi.access = Accessible.ALL;
          findPathPOI(poi);
          this.poisToGo.add(poi);
        }
      }
    }
    public void findPathPOI(POI toPOI){
      Path tempPath = new Path(this, roads);
      pathEvacuate.add(tempPath);
      tempPath.findPath(this, toPOI);;
    }
    
    public POI poiTopoi(){
      ArrayList <POI> evacuatedAreas = new ArrayList();
      for(POI poi : pois.getAll()){
        if(poi.TYPE.equals("ZONA_SEGURA")){
          evacuatedAreas.add(poi);          
        }
      }
      POI newDestinationWare = evacuatedAreas.get( round(random(0, evacuatedAreas.size()-1)) );
      return newDestinationWare;
      
    }
    
    public void drawPath(PGraphics canvas){
      //path.draw(canvas, 1, #FF0000);
      for (Path pathdraw : pathEvacuate){
        float valor = map(pathdraw.getLength(),0,700,0,1);
        color occupColor = lerpColor(#FFFF00, #FF0000, valor);
        pathdraw.draw(canvas, 1, occupColor);
      }
    }
    public void findPathPOI(){
      makeAccessible();
      POI toPOI = poiTopoi();
      path.findPath(this, toPOI);
    }
    
    @Override
    public void draw(PGraphics canvas, int stroke, color c) {
        color occColor = lerpColor(#77DD77, #FF6666, occupancy);
        
        canvas.rectMode(CENTER); canvas.noFill(); canvas.stroke(occColor); canvas.strokeWeight(1);
        canvas.rect(position.x, position.y, 2, 2);

        if( selected ) {
            canvas.fill(0); canvas.textAlign(CENTER, BOTTOM);
            for (Path pathdraw : pathEvacuate){
              float valor = map(pathdraw.getLength(),0,700,0,1);
              color occupColor = lerpColor(#FFFF00, #FF0000, valor);
              pathdraw.draw(canvas, 1, occupColor);
            }
        }
    }
   
}