//PImage [] enemyPics = new PImage[10];
HashMap<String, PImage> enemyImages = new HashMap<String, PImage>();

class Enemy extends MovingThing
{
  int level;
  
  float health;
  boolean dead;
  float opacity; //for fading out once dead
  
  EnemyBehavior behavior;
  
  Robot target;
  
  Enemy( EnemyBehavior b, Robot r, int l )
  {
    behavior = b;
    target = r;
    level = l;
    
    //health = behavior.maxHealth;
    dead = false;
    opacity = 255;
    
    if(behavior.boss)
    {
      size = data.bossBaseSize;
      loadEnemyImage(b, "1", data.bossBaseSize);
      loadEnemyImage(b, "2", data.bossBaseSize);
      loadEnemyImage(b, "x", data.bossBaseSize);
    }
    else
    {
      size = data.enemyBaseSize;
      loadEnemyImage(b, "1", data.enemyBaseSize);
      loadEnemyImage(b, "2", data.enemyBaseSize);
      loadEnemyImage(b, "x", data.enemyBaseSize);
    }
  }
  
  //Load by name, only the first time it's needed
  private void loadEnemyImage(EnemyBehavior b, String keySuffix, float resizeSize)
  {
    String key = b.name + keySuffix;
    if (!enemyImages.containsKey(key))
    {
      PImage img = loadImage(key.toLowerCase() + ".png");
      img.resize((int)resizeSize, 0);
      enemyImages.put(key, img);
    }
  
    PImage img = enemyImages.get(key);
    if      (keySuffix.equals("1")) b.picture1 = img;
    else if (keySuffix.equals("2")) b.picture2 = img;
    else if (keySuffix.equals("x")) b.pictureX = img;
  }
  
  public void move()
  {
    if( dist( target.xPos, target.yPos, xPos, yPos ) < data.blockSize * behavior.sightRange )
    {
      //Shooters stop when they get close, all enemies stop accelerating when dead
      if( !(behavior.ranged && dist( target.xPos, target.yPos, xPos, yPos ) < data.blockSize * behavior.minRange ) && !dead )
      {
        if( target.xPos < xPos ) xSpd -= behavior.speedMultiplier*level;
        else                     xSpd += behavior.speedMultiplier*level;
        if( target.yPos < yPos ) ySpd -= behavior.speedMultiplier*level;
        else                     ySpd += behavior.speedMultiplier*level;
      }
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

    image((behavior.step == 1) ? behavior.picture1 : behavior.picture2, 0, 0);
    
    pop();
  }
  
  public boolean checkExpiration()
  {
    if(dead)
    {
      finished = true;
      new Remnant(this);
      return true;
    }
    return false;
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
  int minRange; //for shooters
  
  String name;
  
  int step;
  int stepSpeed;
  int stepOffset;
  
  PImage picture1;
  PImage picture2;
  PImage pictureX;
  
  boolean boss;
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

class SkeletonBehavior extends EnemyBehavior
{
  SkeletonBehavior()
  {
    corporeal = true;
    ranged = false;
    speedMultiplier = 0.010;
    friction = 0.90;
    sightRange = 7;
    
    step = 1;
    stepSpeed = 1000;
    stepOffset = int(random(stepSpeed));
    
    name = "Skeleton";
  }
}

class RatBehavior extends EnemyBehavior
{
  RatBehavior()
  {
    corporeal = true;
    ranged = false;
    speedMultiplier = 0.020;
    friction = 0.95;
    sightRange = 7;
    
    step = 1;
    stepSpeed = 1000;
    stepOffset = int(random(stepSpeed));
    
    name = "Rat";
  }
}

class BansheeBehavior extends EnemyBehavior
{
  BansheeBehavior()
  {
    boss = true;
    corporeal = true;
    ranged = false;
    speedMultiplier = 0.020;
    friction = 0.95;
    sightRange = 7;
    
    step = 1;
    stepSpeed = 2000;
    stepOffset = int(random(stepSpeed));
    
    name = "Banshee";
  }
}

/*
Ghost, Zombie, Skeleton, Rats, Mummy, Ghoul, Vampire, Wraith
Banshee, Dino Skeleton, Brain in a Jar, Lich, Vampire Mage
*/
