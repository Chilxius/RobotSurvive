//Game Jam Challenge: One Button
//Robots vs Vampires

//Issues:
  // forceful pushback can knock enemies out of bounds
  // laser explosions in wrong place
  // fully upgraded missiles OP

//Get the robot and map un-coupled for end-of-level operations
//De-couple pointer's draw from its move

//Stretch Goals:
//Curse attack
//Fix covering over exit
//Replace explosion - this image was downloaded
//Fancy level start (elevator, tube, etc.)
//Sound
//Final cinematic
//Keep robot from getting stuck on walls when bumped
//Little longer wait before banking discs
//Visit upgrade wheel when continuing after deaths
//PANIC: release super-attack when at low health once per map/game

import processing.sound.*;
import java.util.Collections;
import java.util.Comparator;

Robot robot;
RootNode<Upgrade> upgradeTree;

HUD hud;

Map map;
//int mapLevel = 1;

Title title;

StateManager manager = new StateManager();
GameData data;

ArrayList<MovingThing> movers = new ArrayList<MovingThing>();
ArrayList<MovingThing> trails = new ArrayList<MovingThing>();
ArrayList<GhostWords> ghostWords = new ArrayList<GhostWords>();

color dangerColor = color(0,0,200);

ChoiceWheel wheel;

GameOver gameOver;
int continues = 3;

//Hold to turn, direction changes, press to spin wheel, press to slow wheel, hold to grab wheel
boolean [] helpMessageShown = {false,false,false,false,false};

//For final cutscene
boolean speech = true;
int speechOver;
boolean gameFinished = false;
int frame1, frame2, frame3;

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
  
  upgradeTree = new RootNode<>( new Upgrade("Root") );
  buildTree();
  
  manager.setState( new MenuState() );

  map = new Map(1);
  
  robot = new Robot("test", this);
  createUpgradeTree(robot);
  
  hud = new HUD();
  
  title = new Title();
  
  setupTestingStuff();
}

void draw()
{
  background(0);
  
  if( gameFinished )
  {
    if( millis() > frame3 )
      image( end3, width/2, height/2 );
    else if( millis() > frame2 )
      image( end2, width/2, height/2 );
    else if( millis() > frame1 )
      image( end1, width/2, height/2 );
    return;
  }
  
  manager.display();
  
  //fill(255);
  //textSize(50);
  //text((map.totalEnemies + " \\ " + map.requiredEnemies), 100, 200);
  //text((map.totalBosses + " \\ " + map.requiredBosses), 100, 250);
  //text((map.totalDiscs + " \\ " + map.requiredDiscs), 100, 300);
  //text(robot.discActive+"",100,200);
  //reportOnMovers();
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
      ghostWords.get(i).checkForFollowup();
      ghostWords.remove(i);
      i--;
    }
  }
}

//Got help from ChatGPT - this shoud work unless there are thousands of objects
public void showAllMovers()
{
  //Vampire trails
  for( MovingThing m: trails )
    if( m.onScreen() )
      m.show();
    
  ArrayList<MovingThing> sorted = new ArrayList<MovingThing>(movers);
  
  // Make sure we're calling the method on the list itself
  Collections.sort(sorted, new Comparator<MovingThing>() {
    public int compare(MovingThing a, MovingThing b) {
      return Float.compare(a.yPos, b.yPos);
    }
  });
  
  for (MovingThing o : sorted)
    if( o.onScreen() )
      o.show();
}

public void moveAllMovers()
{
  //Vampire trails
  for( MovingThing m: trails )
    m.move();
    
  for( MovingThing m: movers )
  {
    m.move();
    
    //Handle incorporeal enemies
    if( m instanceof Enemy )
    {
      Enemy e = (Enemy) m;
      if( !e.behavior.corporeal ) continue;
    }
    
    //Enemies push each other around
    for( int i = 0; i < movers.size(); i++ )
    {
      if( m instanceof Enemy && movers.get(i) != m && movers.get(i) instanceof Enemy && dist( m.xPos, m.yPos, movers.get(i).xPos, movers.get(i).yPos ) < (movers.get(i).size+m.size)/2 )
      {
        m.shove( movers.get(i) );
        break;
      }
    }
    
    Block b = map.intersectingBlock( m );
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
      if( (e.behavior instanceof VampireBehavior || e.behavior instanceof MageBehavior) && e.nextTrail < millis() )
      {
        e.nextTrail = millis() + e.behavior.trailDelay;
        new Remnant(e);
      }
    }
    if( movers.get(i) instanceof Robot )
    {
      Robot r = (Robot) movers.get(i);
      r.activate();
    }
  }
}

//Interactions not handled elsewhere (REFACTOR: handle all interactions here or elsewhere, not both)
public void checkAllMoversForHits()
{
  //Robot, pickups, projectiles, enemies, dangers(bad projectiles)
  for( int i = 0; i < movers.size(); i++ )
  {
    for( int j = 0; j < movers.size(); j++ )
    {
      if( i == j ) continue;
      
      //*********************
      // Robot interactions
      if( movers.get(i) instanceof Robot )
      {
        //Grab diskette
        if( movers.get(j) instanceof Pickup && movers.get(i).intersects(movers.get(j)) )
        {
          robot.cash++;
          map.totalDiscs++;
          map.checkMapRequirements();
          movers.get(j).finished=true;
        }
        //Hit by enemy
        else if( movers.get(j) instanceof Enemy && movers.get(i).intersects(movers.get(j)) )
        {
          movers.get(j).getPushed(10-robot.bumpSpeed());
          if( robot.upgrades.get("Forceful Pushback") )
            movers.get(j).takeDamage(int(robot.adjustedSpeed()*3));
          robot.getHitBy( (Enemy) movers.get(j) );
        }
        //Hit by danger
        else if( movers.get(j) instanceof Danger && movers.get(i).intersects(movers.get(j)) )
        {
          if( robot.getHitBy( movers.get(j) ) )
            movers.remove(j);
        }
      }
      
      //*********************
      // Enemy interactions
      if(movers.get(i) instanceof Enemy && movers.get(j) instanceof Projectile && !movers.get(j).finished && movers.get(i).intersects(movers.get(j)) )
      {
        if( !checkForBlast( (Projectile)movers.get(j) ) )
        {
          movers.get(i).takeDamage( movers.get(j).damage );
        }
        movers.get(j).destroy();
      }
    }
  }
}

public void checkMoversForRemoval()
{
  for( int i = 0; i < trails.size(); i++ )
    trails.get(i).checkExpiration();
    
  for( int i = 0; i < movers.size(); i++ )
    movers.get(i).checkExpiration();
    
  for( int i = 0; i < trails.size(); i++ )
    if( trails.get(i).finished )
    {
      trails.remove(i);  
      i--;
    }
    
  for( int i = 0; i < movers.size(); i++ )
    if( movers.get(i).finished )
    {
      movers.remove(i);
      i--;
    }
}

public void createUpgradeTree( Robot r )
{ 
  for(String s: upgradeImages.keySet())
    r.upgrades.put(s,false);
}

public boolean checkForBlast( Projectile p )
{
  if( !(p instanceof Missile) || !( robot.upgrades.get("Blast Radius 1") || robot.upgrades.get("Blast Radius 2") ) ) return false;
  
  float range = robot.blastRange();
  
  for( MovingThing m: movers )
  {
    Missile x = (Missile) p;
    if( m instanceof Enemy ) 
    {
      Enemy e = (Enemy) m;
      if( dist(m.xPos, m.yPos, x.xPos, x.yPos) < range )
        e.takeDamage(x.damage);
    }
  }
  
  ((Missile)p).expiration = 0;
  
  return true;
}

//public void reportOnMovers()
//{
//  ArrayList<MovingThing> moversOnScreen = new ArrayList<MovingThing>();
//  for(MovingThing m: movers)
//    if( m.onScreen() )
//      moversOnScreen.add(m);
//  textAlign(LEFT);
//  text("Movers: " + movers.size() + " / On Screen: " + moversOnScreen.size(), 100, 100 );
//}

public void clearMovers()
{
  movers.clear();
  movers.add(robot);
}

public void addHelpMessage( int index )
{
  if( helpMessageShown[index] ) return;
  
  helpMessageShown[index] = true;
  
  if( index == 0 ) ghostWords.add( new GhostWords("Hold to Turn",                    width/2,  height-150) );
  if( index == 1 ) ghostWords.add( new GhostWords("Direction Changes With Each Turn",width/2,  height-100) );
  if( index == 2 ) ghostWords.add( new GhostWords("Press to Spin Wheel",             width*2/3,height-150) );
  if( index == 3 ) ghostWords.add( new GhostWords("Press to Slow Wheel",             width*2/3,height-125) );
  if( index == 4 ) ghostWords.add( new GhostWords("Hold to Grab Wheel",              width*2/3,height-100) );
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

public void setupTestingStuff()
{  
  //robot.activateUpgrade("Movement Speed 4");
  //robot.activateUpgrade("Rotation Speed 3");
  //robot.activateUpgrade("Fast Disc");
  //robot.activateUpgrade("Disc Bounce 3");
  //robot.activateUpgrade("Extended Laser 1");
  //robot.activateUpgrade("Wide Laser 2");
  //robot.activateUpgrade("Bouncing Laser");
  //robot.activateUpgrade("Tunneling Laser");
  //robot.activateUpgrade("Magnet 2");
  //robot.activateUpgrade("Knockback Resist");
  //robot.activateUpgrade("Forceful Pushback");
  //robot.activateUpgrade("Missile Reload 2");
  //robot.activateUpgrade("Multi-Launch 2");
  //robot.activateUpgrade("Laser 1");
  //robot.activateUpgrade("Razor Disc 1");
  //robot.activateUpgrade("Missile 1");
  //robot.activateUpgrade("Demolition Missile");
  
  
  //movers.add(robot);
  
  //testEnemy = new Enemy( new ZombieBehavior(), robot, 1 );
  //testEnemy.xPos = 500;
  //testEnemy.yPos = 1300;
  
  //movers.add(testEnemy);
  
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
  
  //movers.add( new Enemy( new BansheeBehavior(), robot, 1 ) );
  //movers.get( movers.size()-1 ).xPos = 400;
  //movers.get( movers.size()-1 ).yPos = 900;
  
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


//public void showTitle( int opacity )
//{
//  push();
//  noStroke();
//  fill(200);
//  rectMode(CENTER);
//  rect(width/2,height/2,width,height);
  
//  fill(50,100,50);
//  textFont( createFont("TechnoBoard-519Ej.ttf", 128) ); //Title - ROBOT
//  textSize(180);
//  text("ROBOTS",width/2,height/3+50);
  
//  fill(0);
//  textFont( createFont("Javanese Text", 128) );
//  textSize(75);
//  text("vs",width/2,height/2-30);
  
//  fill(100,0,0);
//  textFont( createFont("October Crow.ttf", 128) ); //Title - VAMPIRE
//  textSize(175);
//  translate(width/2+25,height*2.0/3-25);
//  rotate(-0.2);
//  text("VAMPIRES",0,0);
//  pop();
//}
