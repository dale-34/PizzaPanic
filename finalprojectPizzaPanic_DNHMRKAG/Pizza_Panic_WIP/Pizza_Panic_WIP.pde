// Project: Pizza Panic
// Group Members: Dalena Nguyen, Han Mach,  Renee Kaynor, Alex Garcia-Marin

//importing sound library
import processing.sound.*;

//Globals
SceneManager sm;
int fps = 60;
int xres = 1280; // will be used to resize window if necessary
int yres = 720; // can't be used with initial size() call, because not static variables

//Timers to prevent double-clicks
int clickCooldown = 300;
long lastClick = 0; // timestamp last click
long currTime = millis(); // current recorded time in millis()

//Stores current key presses for movements
boolean keyW = false;
boolean keyA = false;
boolean keyS = false;
boolean keyD = false;

//Fonts
PFont titleFont;
PFont buttonFont;

//Sound files
SoundFile backgroundMusic;
SoundFile ovenDing;
SoundFile chopping;
SoundFile interaction;
SoundFile squeak;

//Collision helper functions
boolean mouseCollide(int x, int y, int rectwidth, int rectlength) {
  if (mouseX >= x && mouseX <= x+rectwidth && mouseY >= y && mouseY <= y+rectlength)
    return true;
  else
    return false;
}

boolean rectCollide(int x1, int y1, int rectwidth1, int rectlength1, int x2, int y2, int rectwidth2, int rectlength2) {
  // true if any sides of the rectangle are touching each other
  // (logic/pseudocode from https://www.jeffreythompson.org/collision-detection/rect-rect.php)
  if (x1 + rectwidth1 >= x2 && x1 <= x2 + rectwidth2 && y1 + rectlength1 >= y2 && y1 <= y2 + rectlength2)
    return true;
  else
    return false;
}

// Manages logic for each screen between game and main menu
// Scene #: 0 = title, 1 = difficulty select, 2 = levels with set difficulties, 3 = instructions
class SceneManager {
  TitleScene title;
  DifficultyScene difficulty;
  GameScene game;
  Player chef;
  GameOver gameover;
  int levelSelect = 0;
  int currScene;

  //Constructor
  SceneManager() {
    title = new TitleScene();
    difficulty = new DifficultyScene();
    game = new GameScene(levelSelect);
    chef = new Player();
    gameover = new GameOver();
    currScene = 0;
  }

  //Switches between different scenes (initalizes new scenes if necessary)
  void changeScene(int scene) {
    currScene = scene;
    // initialize/reset game state
    if (currScene == 2) {
      game = new GameScene(levelSelect);
      game.startGame(chef);
    }
  }

  //Runs display() function of current scene
  void display() {
    switch (currScene) {
    case 0:
      title.display();
      break;
    case 1:
      difficulty.display();
      break;
    case 2:
      game.display();
      chef.display();
      break;
    case 3:
      title.display();
      break;
    case 4:
      gameover.setScore(game.getScore());
      gameover.display();
      break;
    default:
      print("scene number outside of range: display function");
      break;
    }
  }

  //Runs update() function of current scene
  void update() {
    switch (currScene) {
    case 0:
      title.update();
      break;
    case 1:
      difficulty.update();
      break;
    case 2:
      game.update();
      chef.display();
      break;
    case 3:
      title.update();
      break;
   case 4:
      gameover.update();
      break;
    default:
      print("scene number outside of range");
      break;
    }
  }
}

//Scene for main menu screen (has "Play", "Quit", and instructions buttons)
class TitleScene {
  boolean start;
  boolean exit;
  boolean instructions;
  PFont instructionsFont;
  PImage instructionsButton;

  //Constructor
  TitleScene() {
    start = false;
    exit = false;
    instructions = false;
    titleFont = createFont("RubikDoodleShadow-Regular.ttf", 128);
    buttonFont = createFont("SingleDay-Regular.ttf", 95);
    instructionsFont = createFont("MadimiOne-Regular.ttf", 50);
    instructionsButton = loadImage("QuestionMark.png");
  }

  //Display function. Shows buttons, background, and title)
  void display() {
    background(240, 179, 124);

    // Crust Outline
    fill(252, 248, 200);
    noStroke();
    rect(50, 50, width-100, height-100, 28);

    if (!start && !instructions) {
      // Title Text
      fill(125, 8, 8);
      textFont(titleFont);
      text("PIZZA  PANIC !!", 175, 180);

      // Buttons
      textFont(buttonFont);
      fill(231, 106, 76);
      rect(460, 275, 325, 125, 28);
      rect(460, 450, 325, 125, 28);

      // Button Text
      fill(255);
      text("START", 500, 365);
      text("QUIT", 525, 545);

      image(instructionsButton, width-170, height-160, 130, 130);
    }

    //instructions screen
    if (instructions) {
      PImage chef = loadImage("chef4.png");
      PImage ingredients = loadImage("Ingredients.png");
      PImage board = loadImage("cuttingboard.png");
      PImage oven = loadImage("Stove2.png");
      PImage table = loadImage("Table.png");
      textFont(buttonFont);
      fill(231, 106, 76);
      rect(340, 30, 600, 80, 28);
      rect(40, 610, 200, 90, 28);
      fill(255);
      text("INSTRUCTIONS", 360, 95);
      text("BACK", 50, 680);

      translate(0, -30);
      textFont(instructionsFont);
      fill(158, 76, 56);
      text("Use WASD Keys to Move Chef", 330, 230);
      image(chef, 230, 150, 90, 100);
      text("Click on Each Ingredient for the Pizza", 125, 315);
      image(ingredients, 965, 260);
      text("Assemble the Pizza on the Board", 290, 400);
      image(board, 210, 340, 80, 80);
      text("Bake in Oven", 480, 485);
      image(oven, 780, 430, 60, 60);
      text("Deliver to the Table", 445, 570);
      image(table, 360, 495, 60, 90);
      text("AVOID THE RATS!!!", 450, 650);
    }
  }

  //Update function. Detects mouse clicks on each button
  void update() {
    if (mousePressed && millis() > lastClick + clickCooldown) {
      if (!start && !instructions) {
        if (mouseCollide(460, 275, 325, 125)) {
          start = true;
          sm.changeScene(1);
          lastClick = millis();
        } else if (mouseCollide(460, 450, 325, 125)) {
          exit = true;
          exit(); //closes Processing window
        } else if (mouseCollide(width-170, height-160, 130, 130)) {
          instructions = true;
          sm.changeScene(3);
          lastClick = millis();
        }
      }
    }
    if (mousePressed && instructions) {
      if (mouseCollide(40, 610, 200, 90)) {
        instructions = false;
        sm.changeScene(0);
        lastClick = millis();
      }
    }
  }
}

//Scene for difficulty select (has "EASY", "MED", and "HARD" buttons)
class DifficultyScene {

  //Constructor
  DifficultyScene() {
    titleFont = createFont("RubikDoodleShadow-Regular.ttf", 128);
    buttonFont = createFont("SingleDay-Regular.ttf", 95);
  }

  //Display function
  void display() {
    background(240, 179, 124);

    // Crust Outline
    fill(252, 248, 200);
    noStroke();
    rect(50, 50, width-100, height-100, 28);

    // Difficulty Text
    fill(125, 8, 8);
    textFont(titleFont);
    textSize(90);
    text("SELECT  DIFFICULTY", 170, 200);

    // Buttons
    textFont(buttonFont);
    fill(231, 106, 76);
    rect(190, 300, 250, 125, 28);
    rect(520, 300, 250, 125, 28);
    rect(850, 300, 250, 125, 28);

    // Button Text
    fill(255);
    text("EASY", 220, 390);
    text("MED", 570, 390);
    text("HARD", 880, 390);
  }

  //Update function. Detects clicking on difficulty buttons and changes to game scene
  void update() {
    if (mousePressed && millis() > lastClick + clickCooldown) {
      if (mouseCollide(190, 300, 250, 125)) {
        sm.levelSelect = 1;
        sm.changeScene(2);
      } else if (mouseCollide(520, 300, 250, 125)) {
        sm.levelSelect = 2;
        sm.changeScene(2);
      } else if (mouseCollide(850, 300, 250, 125)) {
        sm.levelSelect = 3;
        sm.changeScene(2);
      }

      lastClick = millis();
    }
  }
}

//Game over scene
class GameOver {
  int score;
  GameOver() {
    score = 0;
  }

  //set Score
  void setScore(int score) {
      this.score = score;
  }

  //Display function
  void display() {
    background(240, 179, 124);
    // Crust Outline
    fill(252, 248, 200);
    noStroke();
    rect(50, 50, width-100, height-100, 28);

    fill(125, 8, 8);
    textFont(titleFont);
    text("GAME OVER", 230, height/2-100, 100);
    textSize(70);
    //textFont(buttonFont);
    text("SCORE:", width/2 - 230, height/2);
    text(score, width/2 + 90, height/2);

    textFont(buttonFont);
    fill(231, 106, 76);
    rect(500, 500, 250, 125, 28);
    fill(255);
    text("Menu", 530, 580);
  }

  //Update function. Changes Scene Manager back to title scene
  void update() {
    if (mousePressed && millis() > lastClick + clickCooldown) {
      if (mouseCollide(500, 500, 250, 125)) {
        sm = new SceneManager();
        sm.changeScene(0);
      }
      lastClick = millis();
    }
  }
}

//Scene for main game. Contains object sprites, player, obstacles, interactables, score and timer
class GameScene { //not using an abstract "scene" class as there are few scenes
  int difficulty;
  int score;
  int obstacleNum;
  int sauceNum;
  int doughNum;
  int cheeseNum;
  int toppingNum;
  String pizzaState = " ";
  Timer timer;
  GameOver gameover;
  Obstacle[] obstacles;
  Player player;
  int hitCooldown = 0;
  
  //Sprites
  PImage oven, countertop, countertop2, cheese, sauce, dough, topping;
  PImage fridge, board, plant, trashcan, chair1, chair2, table, pizza;
  
  //Constructor. Sets defaults and loads sprites and timer
  GameScene(int diff) {
    difficulty = diff;
    score = 0;
    sauceNum = 0;
    doughNum = 0;
    cheeseNum = 0;
    toppingNum = 0;

    oven = loadImage("Stove2.png");
    countertop = loadImage("IslandLeft.png");
    countertop2 = loadImage("IslandRight.png");
    cheese = loadImage("cheese.png");
    sauce = loadImage("sauce.png");
    dough = loadImage("dough.png");
    topping = loadImage("pepperoni.png");
    fridge = loadImage("Refrigerator2.png");
    board = loadImage("cuttingboard.png");
    plant = loadImage("Plant.png");
    trashcan = loadImage("Trash_can2.png");
    chair1 = loadImage("Chair1.PNG");
    chair2 = loadImage("Chair2.PNG");
    table = loadImage("Table.png");
    pizza = loadImage("pizza.png");

    timer = new Timer(difficulty);
    gameover = new GameOver();
    timer.startTime = second();
  }

  //Display function. Draws all sprites, player, obstacles, and UI
  void display() {
    background(240, 179, 124);

    // Crust Outline
    fill(252, 248, 200);
    noStroke();
    rect(20, 20, width-40, height-40, 28);

    // Left Side
    translate(0, 40);
    image(countertop, width-100, 110, 80, 80);
    image(countertop, width-100, 150, 80, 80);
    image(oven, width-80, 190, 80, 80);

    for (int i = 230; i <= 470; i+=40) {
      image(countertop, width-100, i, 80, 80);
    }

    image(dough, width-85, 305, 60, 60);
    image(cheese, width-85, 340, 60, 60);
    image(sauce, width-80, 385, 50, 50);
    image(topping, width-85, 420, 60, 60);
    image(trashcan, width-80, 480, 60, 140);

    // Right Side
    image(fridge, 20, 160, 70, 80);
    for (int i = 230; i <= 430; i+=40) {
      image(countertop2, 20, i, 80, 80);
    }
    image(board, 20, 310, 80, 80);
    image(plant, 20, 450, 80, 120);

    image(chair1, 530, 200, 80, 120);
    image(table, 590, 200, 80, 120);
    image(chair2, 650, 200, 80, 120);
    timer.display();

    if (difficulty >= 1) {
      obstacles[0].display();
      obstacles[1].display();
    }
    if (difficulty >= 2) {
      obstacles[2].display();
      obstacles[3].display();
    }
    if (difficulty >= 3) {
      obstacles[4].display();
      obstacles[5].display();
    }
    fill(132, 15, 15);

    textFont(buttonFont);
    textSize(70);
    text("SCORE: ", 30, 40);
    textSize(90);
    text(score, 240, 50);

    textSize(40);
    text("x", 85, 650);
    text("x", 185, 650);
    text("x", 282, 650);
    text("x", 383, 650);
    text("x", 475, 650);
    text(pizzaState, 495, 640);
    
    textSize(70);
    image(dough, 30, 600, 60, 60);
    text(doughNum, 100, 650);
    image(sauce, 140, 605, 50, 50);
    text(sauceNum, 200, 650);
    image(cheese, 230, 600, 60, 60);
    text(cheeseNum, 298, 650);
    image(topping, 328, 600, 60, 60);
    text(toppingNum, 398, 650);
    image(pizza, 430, 605, 50, 50);
    
  }

  //Method for initializing/resetting game timer
  void startGame(Player _player) {
    timer.start();
    int obstacleNum = difficulty*2;
    obstacles = new Obstacle[obstacleNum];
    initializeObstacles();
    player = _player;
  }

  //Checks if the player collides with one of the obstacles and adjusts game state
  void playerObstacleCollisionCheck() {
    if (millis() - hitCooldown > 500) {
      int hitCheck = 0;
      if (difficulty >= 1) {
        if (rectCollide(sm.chef.xpos+10, sm.chef.ypos, 30, 40, obstacles[0].xpos, obstacles[0].ypos, obstacles[0].xsize, obstacles[0].ysize))
          hitCheck = 1;
        if (rectCollide(sm.chef.xpos+10, sm.chef.ypos, 30, 40, obstacles[1].xpos, obstacles[1].ypos, obstacles[1].xsize, obstacles[1].ysize))
          hitCheck = 1;
      }
      if (difficulty >= 2) {
        if (rectCollide(sm.chef.xpos+10, sm.chef.ypos, 30, 40, obstacles[2].xpos, obstacles[2].ypos, obstacles[2].xsize, obstacles[2].ysize))
          hitCheck = 1;
        if (rectCollide(sm.chef.xpos+10, sm.chef.ypos, 30, 40, obstacles[3].xpos, obstacles[3].ypos, obstacles[3].xsize, obstacles[3].ysize))
          hitCheck = 1;
      }
      if (difficulty >= 3) {
        if (rectCollide(sm.chef.xpos+10, sm.chef.ypos, 30, 40, obstacles[4].xpos, obstacles[4].ypos, obstacles[4].xsize, obstacles[4].ysize))
          hitCheck = 1;
        if (rectCollide(sm.chef.xpos+10, sm.chef.ypos, 30, 40, obstacles[4].xpos, obstacles[4].ypos, obstacles[4].xsize, obstacles[4].ysize))
          hitCheck = 1;
      }
      if (hitCheck == 1) {
          if (sauceNum  > 0)
            sauceNum = 0;
          if ( doughNum  > 0)
            doughNum = 0;
          if (cheeseNum  > 0)
            cheeseNum  = 0;
          if (toppingNum > 0)
            toppingNum  = 0;
          if (pizzaState == "COOKED" || pizzaState == "RAW") {
            pizzaState = " "; 
          }
          squeak.amp(1.0);
          squeak.play();
          hitCooldown = millis();
        }
      }
    }

  //Update function. Checks player collision and updates obstacle positions
  void update() {
    if (!timer.game) { // Times out, Game over
      gameover.score = score;
      sm.changeScene(4);
    }
    if (difficulty != 0) {
      playerObstacleCollisionCheck();
    }
    if (difficulty >= 1) {
      obstacles[0].update();
      obstacles[1].update();
    }
    if (difficulty >= 2) {
      obstacles[2].update();
      obstacles[3].update();
    }
    if (difficulty >= 3) {
      obstacles[4].update();
      obstacles[5].update();
    }
  }

  //Creates obstacles for obstacle array
  void initializeObstacles() {
    switch(difficulty) {
    case 1:
      obstacles[0] = new Obstacle(450, 200, 0);
      obstacles[1] = new Obstacle(750, 400, 1);
      break;
    case 2:
      obstacles[0] = new Obstacle(450, 200, 0);
      obstacles[1] = new Obstacle(750, 400, 1);
      obstacles[2] = new Obstacle(400, 500, 2);
      obstacles[3] = new Obstacle(600, 400, 3);
      break;
    case 3:
      obstacles[0] = new Obstacle(450, 200, 0);
      obstacles[1] = new Obstacle(750, 400, 1);
      obstacles[2] = new Obstacle(400, 500, 2);
      obstacles[3] = new Obstacle(600, 400, 3);
      obstacles[4] = new Obstacle(550, 150, 3);
      obstacles[5] = new Obstacle(450, 100, 2);
      break;
    default:
      print("no difficulty provided");
      break;
    }
  }

  //gets Score
  int getScore() {
    return score;
  }

  //Increments dough state
  void addDough() {
    doughNum++;
  }
  
  //Increments sauce state
  void addSauce() {
    sauceNum++;
  }
  
  //Increments cheese state
  void addCheese() {
    cheeseNum++;
  }
  
  //Increments topping state
  void addTopping() {
    toppingNum++;
  }
  
  //Changes pizza state from " " to "RAW", decrements all ingredient states
  void makePizza() {
    if (pizzaState == " ") {
      if (doughNum > 0 && toppingNum > 0 && sauceNum > 0 && cheeseNum > 0) {
      doughNum--;
      toppingNum--;
      sauceNum--;
      cheeseNum--;
      pizzaState = "RAW";
      chopping.amp(1.0);
      chopping.play();
      }
    }
  }

  //Changes pizza state from "RAW" to "COOKED"
  void cookPizza() {
    if (pizzaState == "RAW") {
      pizzaState = "COOKED";
      ovenDing.amp(1.0);
      ovenDing.play();
    }
  }
  
  //Changes pizza state from "COOKED" to " " and increases score
  void deliverPizza() {
    if (pizzaState == "COOKED") {
      score += 100;
      pizzaState = " ";
      interaction.amp(1.0);
      interaction.play();
    }
  }
}

//Stores player information/logic
class Player {
  int xpos;
  int ypos;
  int speed;
  int i = 0;
  int j = 0;
  char dir = 'd';
  int idleFrameCounter = 0; //idle animation frame delay

  //Sprites
  PImage[] runForward = new PImage[18];
  PImage[] idle = new PImage[3];
  PImage[] runBack = new PImage[18];

  //Constructor. Loads sprites and initial position
  Player() {
    idle[0] = loadImage("idle1.png");
    idle[1] = loadImage("idle2.png");
    idle[2] = loadImage("idle3.png");
    runForward[0] = loadImage("chef1.png");
    runForward[1] = loadImage("chef1.png");
    runForward[2] = loadImage("chef1.png");
    runForward[3] = loadImage("chef2.png");
    runForward[4] = loadImage("chef2.png");
    runForward[5] = loadImage("chef2.png");
    runForward[6] = loadImage("chef3.png");
    runForward[7] = loadImage("chef3.png");
    runForward[8] = loadImage("chef3.png");
    runForward[9] = loadImage("chef4.png");
    runForward[10] = loadImage("chef4.png");
    runForward[11] = loadImage("chef4.png");
    runForward[12] = loadImage("chef5.png");
    runForward[13] = loadImage("chef5.png");
    runForward[14] = loadImage("chef5.png");
    runForward[15] = loadImage("chef6.png");
    runForward[16] = loadImage("chef6.png");
    runForward[17] = loadImage("chef6.png");
        
    for (int j = 0; j < 18; j++) {
      runForward[j].resize(75, 75);
    }
    for (int j = 0; j < 3; j++) {
      idle[j].resize(75, 75);
    }
    for (int j = 0; j < 18; j++) {
      runBack[j] = mirrorImage(runForward[j]);
    }

    xpos = 20;
    ypos = 45;
    speed = 4;
  }

  //Display function. Increments through sprite img arrays based on movement
  void display() {
    if (keyPressed) {
      if (dir == 'd') {
        image(runForward[i], xpos, ypos);
      }
      else if (dir == 'a') {
        image(runBack[i], xpos, ypos);
      }
    }
    else if (!keyPressed) {
      idleFrameCounter++;
      if (idleFrameCounter >= 15) {
        j = (j + 1) % idle.length;
        idleFrameCounter = 0;
      }
      image(idle[j], xpos, ypos);
    }
  }

  //Moves player position and checks for collision with static objects
  void move(char direction) {
    i = (i + 1) % runForward.length;
    if (direction == 'w') {
      if (!rectCollide(xpos, ypos-speed, 40, 50, width-100, 100, 60, 480) && !rectCollide(xpos, ypos-speed, 40, 50, 20, 150, 60, 380) && !rectCollide(xpos, ypos-speed, 40, 50, 520, 215, 190, 75) && ypos-speed > -40)
        ypos -= speed;
    } else if (direction == 's') {
      if (!rectCollide(xpos, ypos+speed, 40, 50, width-100, 100, 60, 480) && !rectCollide(xpos, ypos+speed, 40, 50, 20, 150, 60, 380) && !rectCollide(xpos, ypos+speed, 40, 50, 520, 215, 190, 75) && ypos+speed+30 < height-100)
        ypos += speed;
    } else if (direction == 'a') {
      if (!rectCollide(xpos-speed, ypos, 40, 50, width-100, 100, 60, 480) && !rectCollide(xpos-speed, ypos, 40, 50, 20, 150, 60, 380) && !rectCollide(xpos-speed, ypos, 40, 50, 520, 215, 190, 75) && xpos-speed > 0)
        xpos -= speed;
        dir = 'a';
    } else if (direction == 'd') {
      if (!rectCollide(xpos+speed, ypos, 40, 50, width-100, 100, 60, 480) && !rectCollide(xpos+speed, ypos, 40, 50, 20, 150, 60, 380) && !rectCollide(xpos+speed, ypos, 40, 50, 520, 215, 190, 75) && xpos+speed < width-80)
        xpos += speed;
        dir = 'd';
    }

  }
  
  //Mirrors PImage as default Processing mirror function does not retain transparency
  PImage mirrorImage(PImage src) {
    PImage mirroredImage = createImage(src.width, src.height, ARGB); // Use ARGB mode to handle transparency
    mirroredImage.loadPixels();
    src.loadPixels();
  
    for (int y = 0; y < src.height; y++) {
      for (int x = 0; x < src.width; x++) {
        // Calculate the corresponding pixel in the mirrored image
        int mirroredX = src.width - 1 - x;
        int indexSrc = x + y * src.width;
        int indexDest = mirroredX + y * src.width;
      
        // Get the color components of the pixel from the original image
        int srcColor = src.pixels[indexSrc];
        int srcAlpha = (srcColor >> 24) & 0xFF;
        int srcRed = (srcColor >> 16) & 0xFF;
        int srcGreen = (srcColor >> 8) & 0xFF;
        int srcBlue = srcColor & 0xFF;
      
        // Set the corresponding pixel in the mirrored image with transparency
        int mirroredColor = (srcAlpha << 24) | (srcRed << 16) | (srcGreen << 8) | srcBlue;
        mirroredImage.pixels[indexDest] = mirroredColor;
      }
    }
    mirroredImage.updatePixels();
    return mirroredImage;
  }
}

// Stores obstacle information
class Obstacle {
  int xpos;
  int ypos;
  int xmin;
  int xmax;
  int ymin;
  int ymax;
  int speed;
  int direction;
  int size;
  int ysize;
  int xsize;
  int i = 0;

  //Sprites
  PImage[] ratfront = new PImage[9];
  PImage [] ratback = new PImage[9];
  PImage[] ratright = new PImage[9];
  PImage[] ratleft = new PImage[9];

  //Constructor. Loads sprite img arrays and sets position/direction
  Obstacle(int x, int y, int dir) {
    ratright[0] = loadImage("rat1.png");
    ratright[1] = loadImage("rat1.png");
    ratright[2] = loadImage("rat1.png");
    ratright[3] = loadImage("rat2.png");
    ratright[4] = loadImage("rat2.png");
    ratright[5] = loadImage("rat2.png");
    ratright[6] = loadImage("rat3.png");
    ratright[7] = loadImage("rat3.png");
    ratright[8] = loadImage("rat3.png");

    ratleft[0] = loadImage("ratleft1.png");
    ratleft[1] = loadImage("ratleft1.png");
    ratleft[2] = loadImage("ratleft1.png");
    ratleft[3] = loadImage("ratleft2.png");
    ratleft[4] = loadImage("ratleft2.png");
    ratleft[5] = loadImage("ratleft2.png");
    ratleft[6] = loadImage("ratleft3.png");
    ratleft[7] = loadImage("ratleft3.png");
    ratleft[8] = loadImage("ratleft3.png");
    
    ratfront[0] = loadImage("ratfront1.png");
    ratfront[1] = loadImage("ratfront1.png");
    ratfront[2] = loadImage("ratfront1.png");
    ratfront[3] = loadImage("ratfront2.png");
    ratfront[4] = loadImage("ratfront2.png");
    ratfront[5] = loadImage("ratfront2.png");
    ratfront[6] = loadImage("ratfront3.png");
    ratfront[7] = loadImage("ratfront3.png");
    ratfront[8] = loadImage("ratfront3.png");

    ratback[0] = loadImage("ratback1.png");
    ratback[1] = loadImage("ratback1.png");
    ratback[2] = loadImage("ratback1.png");
    ratback[3] = loadImage("ratback2.png");
    ratback[4] = loadImage("ratback2.png");
    ratback[5] = loadImage("ratback2.png");
    ratback[6] = loadImage("ratback3.png");
    ratback[7] = loadImage("ratback3.png");
    ratback[8] = loadImage("ratback3.png");

    xpos = x;
    ypos = y;
    size = 50;
    ysize = 50;
    xsize = 50;
    speed = int(random(2, 5));
    direction = dir;
    ymin = 100;
    ymax = 600;
    xmin = 200;
    xmax = 1000;

    for (int i = 0; i < 9; i++) {
      ratfront[i].resize(size, size);
      ratback[i].resize(size, size);
      ratleft[i].resize(size, size);
      ratright[i].resize(size, size);
    }
  }

  //Moves obstacle according to direction
  void move() {
    switch(direction) {
    case 0: // up
      ypos -= speed;
      if (ypos <= ymin)
        direction = 1;
      break;
    case 1: //down
      ypos += speed;
      if (ypos >= ymax)
        direction = 0;
      break;
    case 2: //left
      xpos -= speed;
      if (xpos <= xmin)
        direction = 3;
      break;
    case 3: //right
      xpos += speed;
      if (xpos >= xmax)
        direction = 2;
      break;
    default:
      print("No direction provided");
      break;
    }
  }

  //Update function. Calls move() and increments sprite img arrays
  void update() {
    move();
    if (i != 5) {
       i++;
    } else {
      i = 0;
    }
    //print("obst updates");
  }

  //Display function. Used sprite img array depends on direction
  void display() {
    if (direction == 1) {
      image(ratfront[i], xpos, ypos);
    }
    if (direction == 0) {
      image(ratback[i], xpos, ypos);
    }
    if (direction == 2) {
      image(ratleft[i], xpos, ypos);
    }
    if (direction == 3) {
      image(ratright[i], xpos, ypos);
    }
  }
}

//Tracks time remaining during gameplay
class Timer { //will track time remaining during gameplay
  int startTime; //time in seconds
  int totalTime;
  boolean game = true;
  PFont font = createFont("digital-7.ttf", 120);
  
  //Constructor. Changes initial time based on difficulty
  Timer(int difficulty) {
    switch (difficulty) {
    case 1: //easy
      totalTime = 120000;
      break;
    case 2: //medium
      totalTime = 90000;
      break;
    case 3: //hard
      totalTime = 60000;
      break;
    default:
      print("Invalid difficulty");
      break;
    }
  }

  //Display function. Decrements timer every frame and calculates MINUTE:SECOND notation
  void display() {
    fill(132, 15, 15);
    textFont(font);
    int currentTime = millis();
    int elapsedTime = (currentTime - startTime);
    int timeLeft = totalTime - elapsedTime; //time left in seconds
    if (timeLeft >= 0) {
      int minutes = (timeLeft / 1000) / 60;
      int seconds = (timeLeft / 1000) % 60;
      String timeString = nf(minutes, 1) + ":" + nf(seconds, 2);
      text(timeString, width-230, 80);
    }  else {
      game = false;
    }
  }

  //Start or reset the timer
  void start() {
    startTime = millis();
    game = true;
  }
}

//Run-time setup. Initializes SceneManager and sound effects
void setup() {
  size(1280, 720);
  sm = new SceneManager();
  frameRate(fps);

 backgroundMusic = new SoundFile(this, "Music/Alex-Productions - Cooking Gypsy Jazz _ Cooking.mp3");
 backgroundMusic.amp(.18);
 backgroundMusic.loop();
 
 ovenDing = new SoundFile(this, "Music/microwave-ding-104123.mp3");
 chopping = new SoundFile(this, "Music/539476__nataliedg__natalie-godinez-knife-chop.wav");
 interaction = new SoundFile(this, "Music/3-down-fast-1-106142.mp3");
 squeak = new SoundFile(this, "Music/cute-animal-squeak-4-188098.mp3");
 
}

//Moves player based on user input
void updatePlayer() {
  if (keyW) sm.chef.move('w');
  if (keyS) sm.chef.move('s');
  if (keyA) sm.chef.move('a');
  if (keyD) sm.chef.move('d');
}

//Calls appropriate update() and display() functions through the Scene Manager
void draw() {
  sm.update();
  sm.display();
  updatePlayer();
}

//keyPressed() override that toggles movement key presses and update player accordingly
void keyPressed() {
  switch(key) {
    case 'W':
    case 'w':
      keyW = true;
      break;
    case 'A':
    case 'a':
      keyA = true;
      break;
    case 'S':
    case 's':
      keyS = true;
      break;
    case 'D':
    case 'd':
      keyD = true;
      break;
  }
  if (sm.currScene == 2) {
    //sm.chef.move(key);
    updatePlayer();
  }
}

//keyReleased() override that untoggles movement key presses 
void keyReleased() {
  switch(key) {
    case 'W':
    case 'w':
      keyW = false;
      break;
    case 'A':
    case 'a':
      keyA = false;
      break;
    case 'S':
    case 's':
      keyS = false;
      break;
    case 'D':
    case 'd':
      keyD = false;
      break;
  }
}

//mouseClicked() override that adjusts game state based on mouse and player position when clicking, plays appropriate sound effect

void mouseClicked() {  
  //dough
  if (mouseX > width-100 && mouseY > 350 && mouseY < 390 && rectCollide(sm.chef.xpos, sm.chef.ypos, 60, 60, width-150, 300, 40, 30)) {
    sm.game.addDough();
    interaction.amp(1.0);
    interaction.play();
  }
  //cheese
  else if (mouseX > width-100 && mouseY > 390 && mouseY < 430 && rectCollide(sm.chef.xpos, sm.chef.ypos, 60, 60, width-150, 340, 40, 30)) {
    sm.game.addCheese();
    interaction.amp(1.0);
    interaction.play();
  }
  //sauce
  else if (mouseX > width-100 && mouseY > 430 && mouseY < 470 && rectCollide(sm.chef.xpos, sm.chef.ypos, 60, 60, width-150, 380, 40, 30)) {
    sm.game.addSauce();
    interaction.amp(1.0);
    interaction.play();
  }
  //topping
  else if (mouseX > width-100 && mouseY > 470 && mouseY < 510 && rectCollide(sm.chef.xpos, sm.chef.ypos, 60, 60, width-150, 410, 40, 30)) {
    sm.game.addTopping();
    interaction.amp(1.0);
    interaction.play();
  }
  else if (mouseX > 590 && mouseX < 670 && mouseY > 200 && mouseY < 320 && rectCollide(sm.chef.xpos, sm.chef.ypos, 60, 60, 550, 170, 150, 190)) {
    sm.game.deliverPizza();
  }
  else if (mouseX > 20 && mouseX < 100 && mouseY > 350 && mouseY < 430 && rectCollide(sm.chef.xpos, sm.chef.ypos, 60, 60, 20, 300, 140, 90)) {
    sm.game.makePizza();
  }
  else if (mouseX > width-100 && mouseY > 230 && mouseY < 270 && rectCollide(sm.chef.xpos, sm.chef.ypos, 60, 60, width-150, 180, 40, 30)) {
    sm.game.cookPizza();
  }

}
