//Game Jam Challenge: One Button
//Robots vs Vampires

//TODO:
//UPGRADES - (MOVE, WEAPON, SUPER, PASSIVE)
//LEVEL - (BLOCKS)
//BADDIES - (BEHAVIOR,COSMETICS)

//Get the robot and map un-coupled for end-of-level operations
//Make Robot accelerate

//Improvement: change laser to spinning lasers that show direciton - still need a vector indicator

import processing.sound.*;

Robot testBot;

Map testMap;
int testMapLevel = 1;

StateManager manager = new StateManager();
GameData data;// = new GameData();

ArrayList<MovingThing> movers = new ArrayList<MovingThing>();

PImage tile,wall,cap,grid,decor[],exit,girder,g_back,g_front;
color dangerColor = color(0,0,200);

void setup()
{
  //size(1200, 800);
  fullScreen();
  rectMode(CENTER);
  imageMode(CENTER);
  noSmooth();
  frameRate(120);
  
  data = new GameData();

  testMap = new Map(1);
  
  //"test" and "ball"
  testBot = new Robot("test", this);
  testBot.xPos = testMap.startingPoint('x');
  testBot.yPos = testMap.startingPoint('y');
  testBot.speed = 2.5;
  testBot.angle = QUARTER_PI;
  testBot.angleSpeed = 0.02;
  testBot.xSpd = 1;
  testBot.ySpd = 0;
  
  movers.add(testBot);
  

  
  loadImages();
}

void draw()
{
  background(0);
  testMap.drawBlocks(testBot,0);
  testMap.drawBlocks(testBot,1);
  testBot.show();
  testMap.drawBlocks(testBot,2);
  
  if(testMap.exiting)
    testMap.lowerExit();
  else
    moveAllMovers();
    
  if( testMap.fade >= 255 )
  {
    testMap = new Map(++testMapLevel);
  
    testBot.xPos = testMap.startingPoint('x');
    testBot.yPos = testMap.startingPoint('y');

  }
}

public void moveAllMovers()
{
  for( MovingThing m: movers )
  {
    m.move();
    Block b = testMap.intersectingBlock( m );
    if( b != null )
    {
      m.bounce(b);
    }
  }
}

public void loadImages()
{
  tile = loadImage("tile3.png");
  tile.resize(0,int(data.blockSize));
  wall = loadImage("wallLong9.png");
  wall.resize(0,int(data.blockSize*1.25));
  cap = loadImage("wallCap4.png");
  cap.resize(int(data.blockSize),0);
  grid = loadImage("doorGrid3.png");
  grid.resize(int(data.blockSize),0);
  exit = loadImage("exit.png");
  exit.resize(int(data.blockSize),0);
  girder = loadImage("girder2.png");
  girder.resize(int(data.blockSize),0);
  g_back = loadImage("girder_back.png");
  g_back.resize(int(data.blockSize),0);
  g_front = loadImage("girder_back.png");
  g_front.resize(int(data.blockSize)*2,0);
  decor = new PImage[4];
  decor[0] = loadImage("decor0.png");
  decor[0].resize(int(data.blockSize),0);
  decor[1] = loadImage("decor1.png");
  decor[1].resize(int(data.blockSize),0);
  decor[2] = loadImage("decor2_2.png");
  decor[2].resize(int(data.blockSize),0);
  decor[3] = loadImage("decor3.png");
  decor[3].resize(int(data.blockSize),0);
}

public void mousePressed()
{
  keyPressed();
  //testBot.cosmetics.sounds.move();
  //testBot.cosmetics = new TestDecorator( testBot.cosmetics );
}

public void mouseReleased()
{
  keyReleased();
  //testBot.cosmetics.sounds.hurt();
}

public void keyPressed()
{
  //testBot.cosmetics.sounds.levelUp();
  testBot.startTurning();
  
  //if( key == ' ' )
  //  dangerColor = color(200,0,0);
}

public void keyReleased()
{
  testBot.stopTurning();
}
