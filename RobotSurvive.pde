//Game Jam Challenge: One Button
//Robots vs Vampires

//NEXT: Get floppys to transfer
//      Add text for scientist name, ip, collected floppys
//      Get enemies to shove robot
//      Have upgrades do their effect
//      Make level start better
//      Move hitbox to bottom middle

//Get the robot and map un-coupled for end-of-level operations
//De-couple pointer's draw from its move
//Get images centered on wheel chunks
//Replace explosion - this image was downloaded

//Only make movers draw if on screen
//Make installs only happen when wheel stops, not constantly

import processing.sound.*;
import java.util.Collections;
import java.util.Comparator;

Robot robot;
RootNode<Upgrade> upgradeTree;

HUD hud;

Map testMap;
int testMapLevel = 1;

Enemy testEnemy, testEnemy2;

StateManager manager = new StateManager();
GameData data;// = new GameData();

ArrayList<MovingThing> movers = new ArrayList<MovingThing>();
//ArrayList<MovingThing> projectiles = new ArrayList<MovingThing>();
ArrayList<GhostWords> ghostWords = new ArrayList<GhostWords>();

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
  //textFont( createFont("October Crow.ttf", 128) ); //Title - VAMPIRE
  textFont( createFont("OCR-a___.ttf", 128) ); //Normal Font
  
  data = new GameData();
  data.loadImages();
  
  hud = new HUD();
  
  upgradeTree = new RootNode<>( new Upgrade("Root") );
  buildTree();
  
  manager.setState( new SurvivalState() );

  testMap = new Map(1);
  
  //"test" and "ball"
  robot = new Robot("test", this);
  robot.xPos = testMap.startingPoint('x');
  robot.yPos = testMap.startingPoint('y');
  robot.speed = 2;
  robot.angle = QUARTER_PI;
  robot.angleSpeed = 0.02;
  robot.xSpd = 1;
  robot.ySpd = 0;
  createUpgradeTree(robot);
  
  setupTestingStuff();

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
  
  //text(projectiles.size()+"",100,100);
  //text(movers.size()+"",100,200);

}

public void handleGhostWords()
{
  for( GhostWords gw: ghostWords )
    gw.show();
  for( int i = 0; i < ghostWords.size(); i++ )
  {
    ghostWords.get(i).show();
    if(ghostWords.get(i).timer < millis())
    {
      ghostWords.remove(i);
      i--;
    }
  }
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
    
    for( int i = 0; i < movers.size(); i++ )
    {
      if( m instanceof Enemy && movers.get(i) != m && movers.get(i) instanceof Enemy && dist( m.xPos, m.yPos, movers.get(i).xPos, movers.get(i).yPos ) < (movers.get(i).size+m.size)/2 )
      {
        m.shove( movers.get(i) );
        break;
      }
    }
    
    Block b = testMap.intersectingBlock( m );
    if( b != null )
      m.bounce(b);
  }
}

public void checkAllShooters()
{
  for( int i = 0; i < movers.size(); i++ )
  {
    if( movers.get(i) instanceof Enemy )
    {
      Enemy e = (Enemy) movers.get(i);
      e.countDownToShot();
    }
    if( movers.get(i) instanceof Robot )
    {
      Robot r = (Robot) movers.get(i);
      r.activate();
    }
  }
}

public void checkAllMoversForHits()
{
  //Robot, pickups, projectiles, enemies, dangers( bad projectiles)
  for( int i = 0; i < movers.size(); i++ )
  {
    for( int j = i+1; j < movers.size(); j++ )
    {
      
    }
  }
}

public void checkMoversForRemoval()
{
  for( int i = 0; i < movers.size(); i++ )
    movers.get(i).checkExpiration();
    
  for( int i = 0; i < movers.size(); i++ )
    if( movers.get(i).finished )
      movers.remove(i);    
  //for( int i = 0; i < projectiles.size(); i++ )
  //  if( projectiles.get(i).finished )
  //    projectiles.remove(i);
}

public void createUpgradeTree( Robot r )
{ 
  for(String s: upgradeImages.keySet())
  {
    println( s );
    r.upgrades.put(s,false);
  } 
  //println(r.upgrades);
}

public void mousePressed(){keyPressed();}

public void mouseReleased(){keyReleased();}

public void keyPressed()
{
  manager.reactToPress();
  if( key == 'm' )
    new Missile(robot);
  if( key == 'd' )
    new Disc(robot);
  if( key == 'k' )
    testEnemy.dead = true;
  if( key == 'l' )
    new Laser(robot);
  if( key == '1' )
    robot.activateUpgrade("Armor Up 1");
  if( key == '2' )
    robot.activateUpgrade("Armor Up 2");
  if( key == '3' )
    robot.activateUpgrade("Armor Up 3");
  if( key == ' ' )
    robot.armor--;
  if( key == 'q' )
    new GhostWords( 25, testEnemy.xPos, testEnemy.yPos );
  if( key == 'w' )
    new GhostWords( "Press to Spin Upgrade Wheel", width*2/3, height-150 );
  if( key == 'b' )
    robot.activateUpgrade("Blast Radius 1");
  if( key == 'x' )
    robot.activateUpgrade("Blast Radius 2");
  if( key == 'f' )
    new Fireball(testEnemy);
    
  //println(mouseX + " " + mouseY);
}

public void keyReleased()
{
  manager.reactToRelease();
}

public void setupTestingStuff()
{  
  //robot.activateUpgrade("Movement Speed 4");
  //robot.activateUpgrade("Rotation Speed 3");
  robot.activateUpgrade("Fast Disc");
  robot.activateUpgrade("Disc Bounce 3");
  robot.activateUpgrade("Extended Laser 1");
  robot.activateUpgrade("Tunneling Laser");
  
  movers.add(robot);
  
  testEnemy = new Enemy( new MummyBehavior(), robot, 1 );
  testEnemy.xPos = 500;
  testEnemy.yPos = 1300;
  
  movers.add(testEnemy);
  
  //movers.add( new Enemy( new GhostBehavior(), robot, 1 ) );
  //movers.get( movers.size()-1 ).xPos = 400;
  //movers.get( movers.size()-1 ).yPos = 300;
  
  //movers.add( new Enemy( new ZombieBehavior(), robot, 1 ) );
  //movers.get( movers.size()-1 ).xPos = 400;
  //movers.get( movers.size()-1 ).yPos = 400;
  
  //movers.add( new Enemy( new SkeletonBehavior(), robot, 1 ) );
  //movers.get( movers.size()-1 ).xPos = 400;
  //movers.get( movers.size()-1 ).yPos = 500;
  
  //movers.add( new Enemy( new MummyBehavior(), robot, 1 ) );
  //movers.get( movers.size()-1 ).xPos = 400;
  //movers.get( movers.size()-1 ).yPos = 600;
  
  //movers.add( new Enemy( new GhoulBehavior(), robot, 1 ) );
  //movers.get( movers.size()-1 ).xPos = 400;
  //movers.get( movers.size()-1 ).yPos = 700;
  
  //movers.add( new Enemy( new VampireBehavior(), robot, 1 ) );
  //movers.get( movers.size()-1 ).xPos = 400;
  //movers.get( movers.size()-1 ).yPos = 800;
  
  movers.add( new Enemy( new BansheeBehavior(), robot, 1 ) );
  movers.get( movers.size()-1 ).xPos = 400;
  movers.get( movers.size()-1 ).yPos = 900;
  
  //movers.add( new Enemy( new BansheeBehavior(), robot, 1 ) );
  //movers.get( movers.size()-1 ).xPos = 1200;
  //movers.get( movers.size()-1 ).yPos = 300;
  
  //movers.add( new Enemy( new BrainBehavior(), robot, 1 ) );
  //movers.get( movers.size()-1 ).xPos = 1200;
  //movers.get( movers.size()-1 ).yPos = 600;
  
  //movers.add( new Enemy( new LichBehavior(), robot, 1 ) );
  //movers.get( movers.size()-1 ).xPos = 1200;
  //movers.get( movers.size()-1 ).yPos = 900;
  
  //movers.add( new Enemy( new MonsterBehavior(), robot, 1 ) );
  //movers.get( movers.size()-1 ).xPos = 1200;
  //movers.get( movers.size()-1 ).yPos = 1200;
  
  //movers.add( new Enemy( new MageBehavior(), robot, 1 ) );
  //movers.get( movers.size()-1 ).xPos = 1200;
  //movers.get( movers.size()-1 ).yPos = 1050;
  
  //testWheel = new ChoiceWheel( robot, width*2/3, height/2, height*0.7 );
  //testWheel.addUpgrade( new Upgrade("Piercing Laser") );
  //testWheel.addUpgrade( new Upgrade("Bouncing Laser") );
  //testWheel.addUpgrade( new Upgrade("Disc Bounce 2") );
  //testWheel.addUpgrade( new Upgrade("Bouncing Missile") );
  //testWheel.buildWheel(4);
}
