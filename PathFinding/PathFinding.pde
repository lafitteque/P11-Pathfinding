// This is a program to visualize pathfinding algorithms on a grid with all connection of weight 1 (but the program can easily be modified to any weight map)
// By pressing "T" and clicking you can place the targer
// By pressing "P" and clicking you can place a person (starting point)
// By pressing "W" and clicking you can place walls (not allowing this cell in the path)
// By pressing "D" and clicking you delete walls
// By pressing "R" you can clear the simulation and restart
// The algorithm used is Dijkstra but I would like to improve this program to let the use chose the algorithm he wants by pressing 1 / 2 / 3 / ...



import java.util.ArrayList;

// // // // // // // // // //
// // // Variables // // //
// // // // // // // // // 

// Screen and Grid parameters
int gridWidth = 25;
int cellWidth = 40;
int offset = 1;

// Arrays and lists for dijkstra
int[][] map; // Map of Distances (each value is the distance between the person and the 

IntList neighboursX = new IntList(); // lists of X and Y coordinates for the neighbours
IntList neighboursY = new IntList();

IntList lastLayerX = new IntList(); // lists of X and Y coordinates for the layer of neighbours (in order to compute the next layer of neighbours easily)
IntList lastLayerY = new IntList();

IntList pathX = new IntList();// Lists containing all the cells in the path
IntList pathY = new IntList();

// Persons variables
int[][] persons; // list of persons (for an improved version with more than 1 beginning point)
int maxPersons = 1; 
int indexPerson = 0; // also for improved version, could be replace by a boolean for 1 person only
boolean nextPerson = false; // to know if we draw the path or not
int indexPath = 0; // to know the progress of the path when we draw it


boolean failed = false;

int maxDistanceValue; // the maximum theoretical value possible for a distance

int neighboursNumber; // to know how many neighbours there are and to avoid size() method, we consider 

int[] target = new int[2]; // target coordinates

int mode = -1; // To know if we draw walls / persons / a target or if we delete or if we run the simulation


// // // // // // // // // // // 
// // PathFinding Algorithm // //
// // // // // // // // // // //

void pathfindingDijkstra(){
  
  // when needed, we add neighbours 
  if (!nextPerson){
    if(neighboursNumber == 0){
  
      addNeighbours();
      
      // If there are no more neighbours, we finish the algorithm for this person
      if (neighboursNumber ==0){
        failed = true;
        nextPerson = true;
      }
    }
    // if we have neighbours, we take the first one and compute its distance to the person
    if(neighboursNumber != 0){
      int x_ = neighboursX.get(0);
      int y_ = neighboursY.get(0);
      
      neighboursX.remove(0);
      neighboursY.remove(0);
      
      neighboursNumber--;
      
      // Then we compute the weight of the distance from the person to this cell
      int m1 = maxDistanceValue;
      int m2 = maxDistanceValue;
      int m3 = maxDistanceValue;
      int m4 = maxDistanceValue;
      
      if (x_ - 1 >= 0 && map[x_ - 1][y_] != -1) {
        m1 = map[x_ - 1][y_];
      }
      if (y_ - 1 >= 0 && map[x_][y_ - 1] != -1) {
        m2 = map[x_][y_-1];
      }
      if (x_ + 1 < gridWidth && map[x_ + 1][y_] != -1) {
        m3 = map[x_ + 1][y_];
      }
      if (y_ + 1 < gridWidth && map[x_][y_ + 1] != -1){
        m4 = map[x_][y_ + 1];
      }
      
      map[x_][y_] = min(min(m1 , m2 ), min( m3 , m4 )) + 1;
      
      // If the cell is the target, then we finish the pathFinding
      if (x_ == target[0] && y_ == target[1]){
        nextPerson = true;
        neighboursNumber = 0;
      }
    drawCell(x_,y_,false);
    }
  }
}




void addNeighbours(){
  // We look for neighbours at a single distance (we use the last layer in memory to find all the new neighbours)
  
  int lastLayerSize = lastLayerX.size();
  for (int i = 0; i<lastLayerSize ; i++){
    for(int j = -1; j<2 ; j +=2){
      
      // Neighbours on the Left / Right side of the cell
      int x_ = lastLayerX.get(i) + j;
      int y_ = lastLayerY.get(i);
      boolean inBounds = x_>=0 && x_<gridWidth && y_>=0 && y_<gridWidth;
      if (inBounds){ // We check if we look in the window so we can check the second condition
        if(map[x_][y_] == maxDistanceValue){ // We check if the neighbour is accessible
          if (!isInNeighbours(x_ , y_)){ // We check if the neighbour is not already in the list
            
            lastLayerX.append(x_);
            lastLayerY.append(y_);
            
            neighboursX.append(x_);
            neighboursY.append(y_);
            
            neighboursNumber++;
          }
        }
      }
      
      // Neighbours on on top or under the cell
      x_ = lastLayerX.get(i);
      y_ = lastLayerY.get(i) + j;
      inBounds = x_>=0 && x_<gridWidth && y_>=0 && y_<gridWidth;
      if (inBounds){
        if(map[x_][y_] == maxDistanceValue){
          if (!isInNeighbours(x_ , y_)){
            
            lastLayerX.append(x_);
            lastLayerY.append(y_);
            
            neighboursX.append(x_);
            neighboursY.append(y_);
            
            neighboursNumber++;
          }
        }
      }
      
    }
  }
  // We delete the previous layer
  for (int i = 0; i < lastLayerSize ; i++){
    lastLayerX.remove(0);
    lastLayerY.remove(0);
  } 
}


void drawPath(){
  // Draws the path using the distances computed with dijkstra
  
  // We make sure we always begin on the target
  if(indexPath == 0) {
    pathX.append(target[0]);
    pathY.append(target[1]);
    indexPath = 0;
  }
  
  int x_ = pathX.get(indexPath);
  int y_ = pathY.get(indexPath);
  
  indexPath++;
  
  // We look for the neighbour with a lower distance (for weights equal to 1, we just look for actualDistance-1 = distanceToTarget - indexPath)
  int d = map[target[0]][target[1]];
  
  if (x_ - 1 >= 0 && map[x_ - 1][y_] == d-indexPath) {
    x_ -= 1;
  }
  else if (y_ - 1 >= 0 && map[x_][y_ - 1] == d-indexPath) {
    y_ -= 1;
  }
  else if (x_ + 1 < gridWidth && map[x_ + 1][y_] == d-indexPath) {
    x_ += 1;
  }
  else if (y_ + 1 < gridWidth && map[x_][y_ + 1] == d-indexPath){
    y_ += 1;
  }
  
  // We add the cell to our path and draw it
  drawCell(x_,y_,true);
  pathX.append(x_);
  pathY.append(y_);

}


boolean isInNeighbours(int x_ , int y_){
  // To know if a cell is already in the neighbours list
  
  int count = 0;
  while (count < neighboursNumber){
    if (neighboursX.get(count) == x_   &&   neighboursY.get(count) == y_ ) {
      count = neighboursNumber;
    }
    count ++;
  }
  return count == 1 +neighboursNumber;
  
}




// // // // // // // // // // // // // // 
// // Initialization and Main Loop // //
// // // // // // // // // // // // // 

void setup(){
  size(1000,1000);
  background(50);
  init();  
}


void init(){
   // Initilazes the grid and the variables

  neighboursX = new IntList(); 
  neighboursY = new IntList();
  
  lastLayerX = new IntList(); 
  lastLayerY = new IntList();
  
  pathX = new IntList();
  pathY = new IntList();
  
  neighboursNumber = 0;
  
  indexPath = 0 ;
  indexPerson = 0;
  
  maxDistanceValue = gridWidth*gridWidth;
  
  target[0] = -1;
  target[1] = -1;
  
  persons = new int[maxPersons][2];
  for (int i = 0; i<maxPersons;i++){
    persons[i][0] = -1;
  }
  
  map = new int[gridWidth][gridWidth];
  for (int i = 0 ; i< gridWidth ; i++){
    for (int j = 0 ; j< gridWidth ; j++){
      map[i][j] = maxDistanceValue;
    }    
  }
  
  drawCells();
}



// Main Loop
// Manages modes 

void draw(){
  if (keyPressed){
    if (key == 'w' || key == 'W'){
      mode = 0;
    }
    if (key == 'p' || key == 'P'){
      mode = 1;
    }
    if (key == 't' || key == 'T'){
      mode = 2;
    }
    if (key == 'd' || key == 'D'){
      mode = 3;
    }
    if (key == 'b' ){
      mode = 4;
    }
    if (key == 'r'){
      init();
      mode = -1; // no mode selected
    }
  }
  
  if (mode == 0){
  // place Walls
    placeWall();
  }
  
  if (mode == 1){
  // place Person
    placePerson();
  }
  
  if (mode == 2){
  // place Target
    placeTarget();
  }
  
  if (mode == 3){
  // Delete
    delete();
  }
  if (mode == 4){
    // Run simulation
    
    // While we don't find the target we use the PathFinding algorithm
    if (!nextPerson && indexPerson < maxPersons){
      pathfindingDijkstra();
    }
    else if (!failed && indexPerson < maxPersons){ // If we found it, we draw the shortest path
      
      // We only draw the needed cells (we draw persons and target to avoid drawing the path on top of them)
      drawPath();
      drawPersons();
      drawTarget();
      
      if (map[target[0]][target[1]] == indexPath){ // If we finished, we make sure nothing else is run
        failed = false;
        nextPerson = false;
        indexPerson = indexPerson + 1 ;
      }
      
    }
    else if (indexPerson < maxPersons){ // If we don't find the target, then we make sure nothing else is run
      failed = false;
      nextPerson = false;
      indexPerson ++;
    }
    
  }
 

 
}





// // // // // // // // // // // // // // // // // //
// // // // // // All Possible Modes // // // // // 
// // // // // // // // // // // // // // // // // 

void placeWall(){
  // When possible, we place a wall (exception value of -1)
  if (mousePressed){
    
    boolean isOnPerson = mouseX/cellWidth == persons[0][0] && mouseY/cellWidth == persons[0][1];
    boolean isOnTarget = mouseX/cellWidth == target[0] && mouseY/cellWidth == target[1];
    boolean isInBounds = mouseX/cellWidth >=0 && mouseX/cellWidth < gridWidth && mouseY/cellWidth >= 0 && mouseY/cellWidth < gridWidth;
    if (isInBounds && !isOnPerson && !isOnTarget) {
      map[int(mouseX/cellWidth)][int(mouseY/cellWidth)] =  -1;
      drawCell(int(mouseX/cellWidth) , int(mouseY/cellWidth) , false);
    }
    
  }
  
}

void placePerson(){
  // When possible, we place a person (value of 0) and make sure the previous person placed is delete
  if (mousePressed){
    
    boolean isOnTarget = mouseX/cellWidth == target[0] && mouseY/cellWidth == target[1];
    boolean isInBounds = mouseX/cellWidth >=0 && mouseX/cellWidth < gridWidth && mouseY/cellWidth >= 0 && mouseY/cellWidth < gridWidth;
    if (isInBounds && !isOnTarget) {
      if (lastLayerX.size() > 0){
        map[lastLayerX.get(0)][lastLayerY.get(0)] = maxDistanceValue;

        drawCell(persons[0][0] , persons[0][1] , false);

        lastLayerX.remove(0);
        lastLayerY.remove(0);
        
      }
      map[int(mouseX/cellWidth)][int(mouseY/cellWidth)] = 0;
      
      persons[indexPerson][0] = int(mouseX/cellWidth);
      persons[indexPerson][1] = int(mouseY/cellWidth);

      

      lastLayerX.append(int(mouseX/cellWidth));
      lastLayerY.append(int(mouseY/cellWidth));
      drawPersons();
      
      indexPerson = (indexPerson + 1)  % maxPersons;
    }
  }
}

void placeTarget(){
  // We write in memory the position of the target and make sure the previous position of the target is delete
  if (mousePressed){
    
    boolean isOnPerson = mouseX/cellWidth == persons[0][0] && mouseY/cellWidth == persons[0][1];
    boolean isInBounds = mouseX/cellWidth >=0 && mouseX/cellWidth < gridWidth && mouseY/cellWidth >= 0 && mouseY/cellWidth < gridWidth;
    if (isInBounds && !isOnPerson) {
      if (target[0]>=0){
        drawCell(target[0] , target[1] , false);
      }
      target[0] = int(mouseX/cellWidth);
      target[1] = int(mouseY/cellWidth);
      drawTarget();
    }
  }
}

void delete(){
  // We set the value to maxDistance (which is used as the infinity here) when possible
  if (mousePressed ){
    
    boolean isOnPerson = mouseX/cellWidth == persons[0][0] && mouseY/cellWidth == persons[0][1];
    boolean isOnTarget = mouseX/cellWidth == target[0] && mouseY/cellWidth == target[1];
    boolean isInBounds = mouseX/cellWidth >=0 && mouseX/cellWidth < gridWidth && mouseY/cellWidth >= 0 && mouseY/cellWidth < gridWidth;
    if (isInBounds && !isOnPerson && !isOnTarget) {
      map[int(mouseX/cellWidth)][int(mouseY/cellWidth)] =  maxDistanceValue;
      drawCell(int(mouseX/cellWidth) , int(mouseY/cellWidth) , false);
    }
    
  }
}




// // // // // // // // // // // // // 
// // Functions to draw the cells // // 
// // // // // // // // // // // // // 

void drawCells(){
  
 for (int i = 0; i< gridWidth; i++){
   for (int j = 0; j< gridWidth; j++){
      drawCell(i,j,false);
   } 
 }

 drawPersons();
 drawTarget();
}


void drawCell(int i, int j, boolean path){
  
  // When we know the shortest path, we draw it
  if (path) {
    push();
    noStroke();
    fill(0 , 200 , 0);
    rect(i*cellWidth + offset,j*cellWidth + offset, cellWidth-2*offset, cellWidth-2*offset);
    pop();
  }
  
  // When a cell has not been explored and is not a wall, we draw it in white
  else if (map[i][j] == maxDistanceValue){
    push();
    noStroke();
    fill(255);
    rect(i*cellWidth + offset, j*cellWidth + offset, cellWidth-2*offset, cellWidth-2*offset);
    pop();
  }
  
  // If a cell has been explored, we draw and write the distance from the person on it
  else if(map[i][j] > 0){
    push();
    noStroke();
    fill(0 , 150 , 150);
    rect(i*cellWidth + offset, j*cellWidth + offset, cellWidth-2*offset, cellWidth-2*offset);
    pop();
    text(map[i][j], (i + 0.3)*cellWidth + offset, (j + 0.6)*cellWidth + offset);
  }
  
  // If the value is -1, we draw a black cell (wall)
  else{
    push();
    noStroke();
    fill(0);
    rect(i*cellWidth + offset, j*cellWidth + offset, cellWidth-2*offset, cellWidth-2*offset);
    pop();
  }
  
}



void drawPersons(){
 int count = 0;
 while(count <maxPersons && persons[count][0] != -1){ // For next version, to manage various persons
   push();
   noStroke();
   fill(0,0,255);
   rect(persons[count][0]*cellWidth + offset, persons[count][1]*cellWidth + offset, cellWidth-2*offset, cellWidth-2*offset);
   pop();
   count++;
 }
}

void drawTarget(){
 push();
 noStroke();
 fill(255,0,0);
 rect(target[0]*cellWidth + offset, target[1]*cellWidth + offset, cellWidth-2*offset, cellWidth-2*offset);
 pop();
}
