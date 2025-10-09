//Game Jam Challenge: One Button
//Robots vs Vampires

//TODO:
//UPGRADES - (MOVE, WEAPON, SUPER, PASSIVE)
//LEVEL - (BLOCKS)
//BADDIES - (BEHAVIOR,COSMETICS)

//Get the robot and map un-coupled for end-of-level operations
//Make Robot accelerate
//Sort enemies in y-pos order to prevent higher enemies overlapping

//Improvement: change laser to spinning lasers that show direciton - still need a vector indicator

import processing.sound.*;

Robot testBot;

Map testMap;
int testMapLevel = 1;

Enemy testEnemy, testEnemy2;

StateManager manager = new StateManager();
GameData data;// = new GameData();

ArrayList<MovingThing> movers = new ArrayList<MovingThing>();

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
  
  testEnemy = new Enemy( new GhostBehavior(), testBot, 1 );
  testEnemy.xPos = 500;
  testEnemy.yPos = 1300;
  
  movers.add(testEnemy);
  
  testEnemy2 = new Enemy( new ZombieBehavior(), testBot, 1 );
  testEnemy2.xPos = 500;
  testEnemy2.yPos = 1200;
  
  movers.add(testEnemy2);
  
  data.loadImages();
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
  
  testEnemy.show();
  testEnemy2.show();
}

public void moveAllMovers()
{
  for( MovingThing m: movers )
  {
    m.move();
    
    if( m instanceof Enemy )
    {
      Enemy e = (Enemy) m;
      if( !e.behavior.corporeal )
        continue;
    }
    
    Block b = testMap.intersectingBlock( m );
    if( b != null )
      m.bounce(b);
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
  
  //if( key == ' ' )
  //  dangerColor = color(200,0,0);
}

public void keyReleased()
{
  testBot.stopTurning();
}
