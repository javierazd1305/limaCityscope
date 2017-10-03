import java.util.Collections;
import java.util.*;
import controlP5.*;


Roads roads;
POIs pois;
Blocks blocks;
Agents agents;
ControlP5 cp5;
Layers layer; //this is the vulnerability layer

PrintWriter output; //to get the out of the center of the lanes in a txt file
PGraphics canvas;
boolean run = false;
boolean evacuate = false;
boolean goBlocks = false;
boolean trafficShow =false;
boolean vulnerability = false;
boolean makeInjured = false;
boolean drawPOIpath = false;
boolean addPOI = false;
String filtro;

int dam = 3;

final String roadsPath= "mirafloresRoad.geojson";
final String roadsPath2 = "miraflores.geojson";
final String trafficPath = "traffic/traffic.csv";
final String poisPath = "poisMiraflores.geojson";
final String poisPath1 = "muestreoPOI.csv";
final String poisPath2 = "new_comercios.csv";
final String agentPath = "agents1.json";
final String vulnerabilityPath = "vul.geojson";
void setup(){
  size(1000,640);
  //fullScreen();
  output = createWriter("positions.txt"); 
  roads=new Roads(roadsPath, roadsPath2);
  canvas = createGraphics(width, height);
  pois = new POIs();
  //pois.loadJSON(poisPath, roads);
  pois.loadCSV(poisPath2, roads);
  agents = new Agents();
  agents.loadJSON(agentPath,roads);
  agents.setSpeed(0.1, 5);
  /*
  cp5 = new ControlP5(this);
  cp5.addTextfield("textInput_1").setPosition(10, 10).setSize(100, 20).setAutoClear(false);
  cp5.addBang("Submit").setPosition(10, 35).setSize(50, 20);
  */
  //roads.getLaneCenter(output); if you want to export the lane center of each lane
  roads.trafficLayer(trafficPath);
  layer = new Layers(vulnerabilityPath);
  roads.assignVul();
}

void draw(){
    background(255);
    
    if(run)agents.move();
    canvas.beginDraw();
    canvas.background(255);
    roads.draw( canvas, 1, #E0E3E5);
    if(goBlocks) roads.getBlocks(canvas, 1, #E0E3E5);    
    if(vulnerability){
      layer.drawLayers(canvas);
      //roads.drawLayers(canvas);
    }
    //if(makeInjured) roads.makeInjured();
    agents.draw(canvas);
    if(drawPOIpath){ 
      pois.drawPOIPaths(canvas);
    }
    if(evacuate) pois.printLegend2(canvas,10,10);
    canvas.endDraw();
    
    image(canvas, 0, 0);
  
}

void keyPressed() {
    switch(key) {
        case ' ':
            run = !run;
            break;
        case '+':
            agents.changeSpeed(0.1);
            break;
        case '-':
            agents.changeSpeed(-0.1);
            break;
        case 'b':
            goBlocks = !goBlocks;
            break;
        case 'f':
            roads.getType(filtro);
            break;
        case 'e':
            evacuate = !evacuate;
            if(evacuate){
              pois.makeAvailableZona("ZONA_SEGURA");
            }
            agents.getShortest("ZONA_SEGURA");
            break;
        case 't':
            trafficShow = !trafficShow;
            break;
        case 'v':
            vulnerability = !vulnerability;
            break;
        case '1':
            roads.getType("COMIDA");
            break;
        case '2':
            roads.getType("HOSPEDAJE");
            break;
        case '3':
            roads.getType("DIVERSION");
            break;
         case '4':
            roads.getType("SALUD");
            break;
         case '5':
            roads.getType("EDUCACION");
            break;
         case '6':
            evacuate = !evacuate;
            if(evacuate){
              roads.getType("ZONA_SEGURA");
            }
            break;
         case 'c':
            roads.closeLanes();
            makeInjured = !makeInjured;
            break;
         case 'p':
            drawPOIpath = !drawPOIpath;
            //pois.getWarehouses();
            break;
         case 'a':
            addPOI = !addPOI;
            break;
         case 'z':
            pois.secureZonePath();
            break;
    }
}

void mouseClicked() {
    //agents.select(mouseX, mouseY);
    pois.select(mouseX, mouseY);
    //roads.select(mouseX, mouseY);
    //println(mouseX,mouseY);
    if (addPOI) new Warehouse(roads, "-1","wareHouse","wareHouse",new PVector(mouseX,mouseY),100);
}

/*
void Submit() {
  filtro = cp5.get(Textfield.class,"textInput_1").getText();
}
*/