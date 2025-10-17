//Game Jam Challenge: One Button
//Robots vs Vampires

//Get the robot and map un-coupled for end-of-level operations
//De-couple pointer's draw from its move
//Get images centered on wheel chunks
//Replace explosion - this image was downloaded

//Only make movers draw if on screen

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
  //robot.fullName = "Artifice Enforcer Enforcer Enforcer [Experimental]";
  //robot.fullName = "Bob";
  createUpgradeTree(robot);
  //robot.upgrades.put("Rotation Speed 2",true);
  //robot.upgrades.put("Extended Laser 2",true);
  //robot.upgrades.put("Bouncing Laser",true);
  //robot.upgrades.put("Movement Speed 4",true);
  //robot.upgrades.put("Laser 1",true);
  //robot.upgrades.put("Laser 2",true);
  //robot.upgrades.put("Laser 3",true);
  //robot.upgrades.put("Laser 4",true);
  
  //robot.activateUpgrade("Laser 1");
  //robot.activateUpgrade("Laser 2");
  //robot.activateUpgrade("Laser 3");
  //robot.activateUpgrade("Laser 4");
  //robot.activateUpgrade("Extended Laser 1");
  //robot.activateUpgrade("Extended Laser 2");
  //robot.activateUpgrade("Movement Speed 1");
  //robot.activateUpgrade("Movement Speed 2");
  robot.activateUpgrade("Rotation Speed 1");
  //robot.activateUpgrade("Turn-Slow");
  //robot.activateUpgrade("Bouncing Laser");
  //robot.activateUpgrade("Shield 1");
  //robot.activateUpgrade("Shield Regeneration");
  //robot.activateUpgrade("Armor Up 2");
  //robot.activateUpgrade("Magnet 1");
  robot.activateUpgrade("Movement Speed 2");
  
  //guide = new TurnGuide( 100, height-100, robot );
  
  movers.add(robot);
  
  testEnemy = new Enemy( new SkeletonBehavior(), robot, 1 );
  testEnemy.xPos = 500;
  testEnemy.yPos = 1300;
  
  movers.add(testEnemy);
  
  testEnemy2 = new Enemy( new GhostBehavior(), robot, 1 );
  testEnemy2.xPos = 500;
  testEnemy2.yPos = 900;
  
  movers.add(testEnemy2);
  
  testWheel = new ChoiceWheel( robot, width*2/3, height/2, height*0.7 );
  testWheel.addUpgrade( new Upgrade("Movement Speed 1") );
  //testWheel.segments.get(0).image = loadImage("testFace2.png");
  testWheel.addUpgrade( new Upgrade("Shield 3") );
  testWheel.addUpgrade( new Upgrade("Laser 1") );
  //testWheel.segments.get(2).image = loadImage("testFace2.png");
  testWheel.addUpgrade( new Upgrade("Piercing Laser") );
  //testWheel.addUpgrade( new Upgrade() );
  //testWheel.addUpgrade( new Upgrade() );
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

//Create tree here
public void createUpgradeTree( Robot r )
{
  //String [] upgradeNames =
  //{
  //  "Movement Speed 1",
  //  "Movement Speed 2",
  //  "Movement Speed 3",
  //  "Movement Speed 4",
  //  "Knockback Resist",
  //  "Pushback",
  //  "Forceful Pushback",
  //  "Rotation Speed 1",
  //  "Rotation Speed 2",
  //  "Rotation Speed 3",
  //  "Turn-slow",
  //  "Turn-stop",
    
  //  "Armor Up 1",
  //  "Armor Up 2",
  //  "Armor Up 3",
  //  "Armor Regeneration",
  //  "Shield 1",
  //  "Shield 2",
  //  "Shield 3",
  //  "Shield Regeneration",
  //  "Magnet 1",
  //  "Magnet 2",
    
  //  "Laser 1",
  //  "Laser 2",
  //  "Laser 3",
  //  "Laser 4",
  //  "Piercing Laser",
  //  "Extended Laser 1",
  //  "Extended Laser 2",
  //  "Wide Laser 1",
  //  "Wide Laser 2",
  //  "Bouncing Laser",
  //  "Tunneling Laser",
    
  //  "Missile 1",
  //  "Missile 2",
  //  "Missile 3",
  //  "Missile 4",
  //  "Multi-Launch 1",
  //  "Multi-Launch 2",
  //  "Missile Reload 1",
  //  "Missile Reload 2",
  //  "Blast Radius 1",
  //  "BLast Radius 2",
  //  "Bouncing Missile",
    
  //  "Razor Disc 1",
  //  "Razor Disc 2",
  //  "Razor Disc 3",
  //  "Razor Disc 4",
  //  "Multi-Disc 1",
  //  "Multi-Disc 2",
  //  "Multi-Disc 3",
  //  "Disc Bounce 1",
  //  "Disc Bounce 2",
  //  "Disc Bounce 3",
  //  "Fast Disc",
    
  //  "Electric Shock 1",
  //  "Electric Shock 2",
  //  "Electric Shock 3",
  //  "Electric Shock 4",
  //  "Shock Speed 1",
  //  "Shock Speed 2",
  //  "Long Arc 1",
  //  "Long Arc 2",
  //  "Long Arc 3",
  //  "Chain Shock"
  //};
  
  for(String s: upgradeImages.keySet())
  {
    r.upgrades.put(s,false);
  } 
  
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
}

public void keyReleased()
{
  manager.reactToRelease();
}
