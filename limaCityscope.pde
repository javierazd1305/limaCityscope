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
String filtro;

int dam = 3;

final String roadsPath= "mirafloresRoad.geojson";
final String roadsPath2 = "miraflores.geojson";
final String trafficPath = "traffic/traffic.csv";
final String poisPath = "poisMiraflores.geojson";
final String poisPath1 = "comercios.csvs";
final String agentPath = "agents.json";
final String vulnerabilityPath = "vul.geojson";
void setup(){
  size(1000,640);
  output = createWriter("positions.txt"); 
  roads=new Roads(roadsPath, roadsPath2);
  canvas = createGraphics(width, height);
  pois = new POIs();
  pois.loadJSON(poisPath, roads);
  //pois.loadCSV(poisPath1, roads);
  agents = new Agents();
  agents.loadJSON(agentPath,roads);
  agents.setSpeed(0.1, 5);
  
  cp5 = new ControlP5(this);
  cp5.addTextfield("textInput_1").setPosition(10, 10).setSize(100, 20).setAutoClear(false);
  cp5.addBang("Submit").setPosition(10, 35).setSize(50, 20);
  
  //roads.getLaneCenter(output); if you want to export the lane center of each lane
  roads.trafficLayer(trafficPath);
  layer = new Layers(vulnerabilityPath);
}

void draw(){
    background(255);
    if(evacuate) agents.moveEvacuate();
    if(run)agents.move();
    canvas.beginDraw();
    canvas.background(255);
    roads.draw( canvas, 1, #E0E3E5);
    if(goBlocks) roads.getBlocks(canvas, 1, #E0E3E5);
    if(trafficShow) roads.drawLanesTraffic(canvas, 1, #E0E3E5);
    
    if(vulnerability){
      layer.drawLayers(canvas);
      roads.drawLayers(canvas);
    }
    agents.draw(canvas);
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
            run = !run;
            agents.getShortest();
            break;
        case 't':
            trafficShow = !trafficShow;
            break;
        case 'v':
            vulnerability = !vulnerability;
            break;
    }
}

void mouseClicked() {
    agents.select(mouseX, mouseY);
    pois.select(mouseX, mouseY);
    roads.select(mouseX, mouseY);
    println(mouseX,mouseY);
}

 
void Submit() {
  filtro = cp5.get(Textfield.class,"textInput_1").getText();
}