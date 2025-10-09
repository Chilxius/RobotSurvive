//PImage [] enemyPics = new PImage[10];
HashMap<String, PImage> enemyImages = new HashMap<String, PImage>();

class Enemy extends MovingThing
{
  int level;
  
  EnemyBehavior behavior;
  
  Robot target;
  
  Enemy( EnemyBehavior b, Robot r, int l )
  {
    behavior = b;
    target = r;
    level = l;
  }
  
  public void move()
  {
    if( dist( target.xPos, target.yPos, xPos, yPos ) < data.blockSize * behavior.sightRange )
    {
      if( target.xPos < xPos ) xSpd -= behavior.speedMultiplier*level;
      else                     xSpd += behavior.speedMultiplier*level;
      if( target.yPos < yPos ) ySpd -= behavior.speedMultiplier*level;
      else                     ySpd += behavior.speedMultiplier*level;
    }
    
    xPos += xSpd;
    yPos += ySpd;
    
    xSpd *= behavior.friction;
    ySpd *= behavior.friction;
    
    if( (millis()+behavior.stepOffset) % behavior.stepSpeed < behavior.stepSpeed/2 )
      behavior.step = 1;
    else behavior.step = 2;
  }
  
  public void show()
  {
    push();
    translate(xPos+data.xOffset,yPos+data.yOffset);
    if( target.xPos > xPos )
      scale(-1, 1);
    image( enemyImages.get(behavior.name+behavior.step), 0, 0 );
    pop();
  }
}

abstract class EnemyBehavior
{
  //Can move through walls
  boolean corporeal;
  //Shoots (and keeps distance)
  boolean ranged;
  
  //This * level
  float speedMultiplier;
  float friction;
  
  //In blockSizes
  int sightRange;
  
  String name;
  
  int step;
  int stepSpeed;
  int stepOffset;
}

class GhostBehavior extends EnemyBehavior
{
  GhostBehavior()
  {
    corporeal = false;
    ranged = false;
    speedMultiplier = 0.005;
    friction = 0.99;
    sightRange = 10;
    
    step = 1;
    stepSpeed = 2000;
    
    name = "Ghost";
  }
}

class ZombieBehavior extends EnemyBehavior
{
  ZombieBehavior()
  {
    corporeal = true;
    ranged = false;
    speedMultiplier = 0.005;
    friction = 0.90;
    sightRange = 10;
    
    step = 1;
    stepSpeed = 2000;
    stepOffset = int(random(stepSpeed));
    
    name = "Zombie";
  }
}
