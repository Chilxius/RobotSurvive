//PImage [] enemyPics = new PImage[10];
HashMap<String, PImage> enemyImages = new HashMap<String, PImage>();

class Enemy extends MovingThing
{
  int level;
  
  float health;
  boolean dead;
  float opacity; //for fading out once dead
  
  int nextShot;
  int nextTrail;
  
  EnemyBehavior behavior;
  
  Robot target;
  
  Enemy( EnemyBehavior b, Robot r, int l )
  {
    behavior = b;
    target = r;
    level = l;
    
    health = behavior.maxHealth;
    dead = false;
    opacity = 255;
    
    nextShot = int(random(behavior.shotDelay));
    nextTrail = behavior.trailDelay;
    
    //if(behavior.boss)
    //{
    //  size = data.bossBaseSize;
    //  loadEnemyImage(b, "1", data.bossBaseSize);
    //  loadEnemyImage(b, "2", data.bossBaseSize);
    //  loadEnemyImage(b, "x", data.bossBaseSize);
    //}
    //else
    //{
    //  size = data.enemyBaseSize;
    //  loadEnemyImage(b, "1", data.enemyBaseSize);
    //  loadEnemyImage(b, "2", data.enemyBaseSize);
    //  loadEnemyImage(b, "x", data.enemyBaseSize);
    //}
    
    if(behavior.boss) size = data.bossBaseSize;
    else              size = data.enemyBaseSize;
    loadEnemyImage(b, "1", size);
    loadEnemyImage(b, "2", size);
    loadEnemyImage(b, "x", size);
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
    
    //Wraith Motion
    if( behavior instanceof WraithBehavior )
    {
      if( millis() % 3000 < 1000 )
      {
        behavior.speedMultiplier = 0.05;
        behavior.friction = 0.95;
      }
      else
      {
        behavior.speedMultiplier = 0.00;
        behavior.friction = 0.99;
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
    
    drawEffect();
  }
  
  private void drawEffect()
  {
    if( behavior instanceof MummyBehavior )
    {
      push();
      translate(xPos+data.xOffset,yPos+data.yOffset);
      rotate(atan2(robot.yPos-yPos,robot.xPos-xPos));
      tint(255,255-timeToNextShot()/5);
      image(fireCharge,0,0);
      pop();
    }
  }
  
  public void countDownToShot()
  {
    if( behavior.ranged )
    {
      if( millis() > nextShot )
      {
        nextShot = millis() + behavior.shotDelay;
        
        if( behavior instanceof MummyBehavior )   new Fireball(this);
        if( behavior instanceof BansheeBehavior ) for( int i = 0; i < 8; i++ ) new Voice(this,i);
        if( behavior instanceof BrainBehavior )   new BrainBlast(this);
        if( behavior instanceof LichBehavior )    new Skull(this);
        if( behavior instanceof VampireBehavior ) new Bat(this);
      }
    }
  }
  
  private int timeToNextShot()
  {
    return nextShot - millis();
  }
  
  public void takeDamage( int amount )
  {
    health -= amount;
    if( health < 0 )
      dead = true;
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
  int shotDelay;
  int trailDelay;
  
  float speedMultiplier;
  float friction;
  
  int maxHealth;
  
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
    maxHealth = 3;
    
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
    maxHealth = 5;
  
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
    maxHealth = 5;
  
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
    maxHealth = 1;
  
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

class GhoulBehavior extends EnemyBehavior
{
  GhoulBehavior()
  {
    maxHealth = 20;
  
    corporeal = true;
    ranged = false;
    speedMultiplier = 0.020;
    friction = 0.95;
    sightRange = 7;
    
    step = 1;
    stepSpeed = 1000;
    stepOffset = int(random(stepSpeed));
    
    name = "Ghoul";
  }
}

class MummyBehavior extends EnemyBehavior
{
  MummyBehavior()
  {
    maxHealth = 15;
  
    corporeal = true;
    ranged = true;
    shotDelay = 5000;
    speedMultiplier = 0.020;
    friction = 0.95;
    sightRange = 7;
    
    step = 1;
    stepSpeed = 1000;
    stepOffset = int(random(stepSpeed));
    
    name = "Mummy";
  }
}

class VampireBehavior extends EnemyBehavior
{
  VampireBehavior()
  {
    maxHealth = 40;
  
    corporeal = true;
    ranged = true;
    shotDelay = 2000;
    speedMultiplier = 0.050;
    friction = 0.95;
    sightRange = 7;
    
    step = 1;
    stepSpeed = 1000;
    stepOffset = int(random(stepSpeed));
    trailDelay = 200;
    
    name = "Vampire";
  }
}

class WraithBehavior extends EnemyBehavior
{
  WraithBehavior()
  {
    maxHealth = 20;
  
    corporeal = false;
    ranged = false;
    speedMultiplier = 0.020;
    friction = 0.995;
    sightRange = 7;
    
    step = 1;
    stepSpeed = 1000;
    stepOffset = int(random(stepSpeed));
    
    name = "Wraith";
  }
}

class BansheeBehavior extends EnemyBehavior
{ 
  BansheeBehavior()
  {
    maxHealth = 50;
  
    boss = true;
    corporeal = false;
    ranged = true;
    shotDelay = 3000;
    speedMultiplier = 0.020;
    friction = 0.95;
    sightRange = 7;
    
    step = 1;
    stepSpeed = 2000;
    stepOffset = int(random(stepSpeed));
    
    name = "Banshee";
  }
}

class MonsterBehavior extends EnemyBehavior
{
  MonsterBehavior()
  {
    maxHealth = 200;
  
    boss = true;
    corporeal = true;
    ranged = false;
    speedMultiplier = 0.020;
    friction = 0.95;
    sightRange = 7;
    
    step = 1;
    stepSpeed = 2000;
    stepOffset = int(random(stepSpeed));
    
    name = "BoneMonster";
  }
}

class BrainBehavior extends EnemyBehavior
{
  BrainBehavior()
  {
    maxHealth = 300;
  
    boss = true;
    corporeal = true;
    ranged = true;
    shotDelay = 1000;
    speedMultiplier = 0.020;
    friction = 0.95;
    sightRange = 7;
    
    step = 1;
    stepSpeed = 2000;
    stepOffset = int(random(stepSpeed));
    
    name = "Brain";
  }
}

class LichBehavior extends EnemyBehavior
{
  LichBehavior()
  {
    maxHealth = 400;
  
    boss = true;
    corporeal = true;
    ranged = true;
    shotDelay = 2000;
    speedMultiplier = 0.020;
    friction = 0.95;
    sightRange = 7;
    
    step = 1;
    stepSpeed = 2000;
    stepOffset = int(random(stepSpeed));
    
    name = "Lich";
  }
}

class MageBehavior extends EnemyBehavior
{
  MageBehavior()
  {
    maxHealth = 600;
  
    boss = true;
    corporeal = true;
    ranged = false;
    speedMultiplier = 0.06;
    friction = 0.95;
    sightRange = 7;
    
    step = 1;
    stepSpeed = 2000;
    stepOffset = int(random(stepSpeed));
    trailDelay = 300;
    
    name = "Mage";
  }
}

/*
Ghost, Zombie, Skeleton, Rats, Mummy, Ghoul, Vampire, Wraith
Banshee, Dino Skeleton, Brain in a Jar, Lich, Vampire Mage
*/
