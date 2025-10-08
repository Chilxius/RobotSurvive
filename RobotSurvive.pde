//Game Jam Challenge: One Button
//Robots vs Vampires

//TODO:
//UPGRADES - (MOVE, WEAPON, SUPER, PASSIVE)
//LEVEL - (BLOCKS)
//BADDIES - (BEHAVIOR,COSMETICS)

import processing.sound.*;

Robot testBot;

Map testMap;

StateManager manager = new StateManager();
GameData data;// = new GameData();

ArrayList<MovingThing> movers = new ArrayList<MovingThing>();

PImage tile,wall,cap,grid,deco1;
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

  testMap = new Map(12);
  
  //"test" and "ball"
  testBot = new Robot("test", this);
  testBot.xPos = testMap.startingPoint('x');
  testBot.yPos = testMap.startingPoint('y');
  testBot.speed = 2;
  testBot.angle = QUARTER_PI;
  testBot.angleSpeed = 0.02;
  testBot.xSpd = 1;
  testBot.ySpd = 0;
  
  movers.add(testBot);
  
  //TESTING
  tile = loadImage("tile3.png");
  tile.resize(0,int(data.blockSize));
  wall = loadImage("wall.png");
  wall.resize(0,int(data.blockSize));
  cap = loadImage("wallCap4.png");
  cap.resize(int(data.blockSize),0);
  grid = loadImage("doorGrid3.png");
  grid.resize(int(data.blockSize),0);
  deco1 = loadImage("decor3.png");
  deco1.resize(int(data.blockSize),0);

}

void draw()
{
  background(0);
  testMap.drawBlocks(testBot);
  testBot.show();
  
  moveAllMovers();
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
  
  if( key == ' ' )
    dangerColor = color(200,0,0);
}

public void keyReleased()
{
  testBot.stopTurning();
}
