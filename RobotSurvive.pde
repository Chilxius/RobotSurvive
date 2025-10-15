//Game Jam Challenge: One Button
//Robots vs Vampires

//TODO:
//UPGRADES - (MOVE, WEAPON, SUPER, PASSIVE)
//LEVEL - (BLOCKS)
//BADDIES - (BEHAVIOR,COSMETICS)

//Get the robot and map un-coupled for end-of-level operations
//De-couple pointer's draw from its move
//Get images centered on wheel chunks

//Improvement: change laser to spinning lasers that show direciton - still need a vector indicator

import processing.sound.*;
import java.util.Collections;
import java.util.Comparator;

Robot testBot;

Map testMap;
int testMapLevel = 1;

Enemy testEnemy, testEnemy2;

StateManager manager = new StateManager();
GameData data;// = new GameData();

ArrayList<MovingThing> movers = new ArrayList<MovingThing>();

color dangerColor = color(0,0,200);

ChoiceWheel testWheel;

void setup()
{
  //size(1200, 800);
  fullScreen();
  rectMode(CENTER);
  imageMode(CENTER);
  noSmooth();
  frameRate(120);
  textAlign(CENTER);
  
  //textFont( createFont("SFTransRobotics.ttf", 128) ); //Title - ROBOT
  textFont( createFont("October Crow.ttf", 128) ); //Title - VAMPIRE
  //textFont( createFont("OCR-a___.ttf", 128) ); //Normal Font
  
  data = new GameData();
  
  manager.setState( new SurvivalState() );

  testMap = new Map(1);
  
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
  
  testEnemy = new Enemy( new GhostBehavior(), testBot, 1 );
  testEnemy.xPos = 500;
  testEnemy.yPos = 1300;
  
  movers.add(testEnemy);
  
  testEnemy2 = new Enemy( new ZombieBehavior(), testBot, 1 );
  testEnemy2.xPos = 500;
  testEnemy2.yPos = 900;
  
  movers.add(testEnemy2);
  
  testWheel = new ChoiceWheel( testBot, width/2, height/2, height*0.7 );
  testWheel.addUpgrade( new Upgrade() );
  //testWheel.segments.get(0).image = loadImage("testFace2.png");
  testWheel.addUpgrade( new Upgrade() );
  testWheel.addUpgrade( new Upgrade() );
  //testWheel.segments.get(2).image = loadImage("testFace2.png");
  testWheel.addUpgrade( new Upgrade() );
  //testWheel.addUpgrade( new Upgrade() );
  //testWheel.addUpgrade( new Upgrade() );
  
  data.loadImages();
}

void draw()
{
  background(0);
  manager.display();
  
  ////TESTING TITLE SPLASH
  //background(200);
  
  //fill(50,100,50);
  //textFont( createFont("TechnoBoard-519Ej.ttf", 128) ); //Title - ROBOT
  //textSize(180);
  //text("ROBOTS",width/2,height/3+50);
  
  //fill(0);
  //textFont( createFont("Javanese Text", 128) );
  //textSize(75);
  //text("vs",width/2,height/2-30);
  
  //fill(100,0,0);
  //textFont( createFont("October Crow.ttf", 128) ); //Title - VAMPIRE
  //textSize(175);
  //translate(width/2+25,height*2.0/3-25);
  //rotate(-0.2);
  //text("VAMPIRES",0,0);
}

//Got help from ChatGPT - this shoud work unless there are thousands of objects
public void showAllMovers()
{
  ArrayList<MovingThing> sorted = new ArrayList<MovingThing>(movers);
  
  // Make sure we're calling the method on the list itself
  Collections.sort(sorted, new Comparator<MovingThing>() {
    public int compare(MovingThing a, MovingThing b) {
      return Float.compare(a.yPos, b.yPos);
    }
  });
  
  for (MovingThing o : sorted)
    o.show();
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

public void mousePressed(){keyPressed();}

public void mouseReleased(){keyReleased();}

public void keyPressed()
{
  manager.reactToPress();
}

public void keyReleased()
{
  manager.reactToRelease();
}
