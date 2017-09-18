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
            int capacity   = props.isNull("CAPACITY") ? 0 : props.getInt("CAPACITY");
            
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
            int capacity        = 10;
            String type         = row.getString("GIRO");
            int size            = 4;
            pois.add( new POI(roads, str(count), name, type, location, capacity) );
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
    protected final Accessible access;
    
    protected ArrayList<Agent> crowd = new ArrayList();
    protected float occupancy;
    
    private float size = 4;
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
        return NAME + " [" + crowd.size() + " / " + CAPACITY + "]";
    }
}