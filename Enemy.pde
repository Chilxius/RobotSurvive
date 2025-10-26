//PImage [] enemyPics = new PImage[10];
HashMap<String, PImage> enemyImages = new HashMap<String, PImage>();

class Enemy extends MovingThing
{
  //int projectileDamage;
  int health;
  boolean dead;
  float opacity; //for fading out once dead
  
  int nextShot;
  int nextTrail;
  
  EnemyBehavior behavior;
  
  Robot target;
  
  // methods follow
  
  Enemy( EnemyBehavior b, Robot r )
  {
    behavior = b;
    target = r;
    //level = l;
    
    health = behavior.maxHealth;
    dead = false;
    opacity = 255;
    
    nextShot = int(random(behavior.shotDelay));
    nextTrail = behavior.trailDelay;
    
    damage = behavior.damage;
    
    if(behavior.boss) size = data.bossBaseSize;
    else              size = data.enemyBaseSize;
    loadEnemyImage(b, "1", size);
    loadEnemyImage(b, "2", size);
    loadEnemyImage(b, "x", size);
    
    movers.add(this);
    move();
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
        if( target.xPos < xPos ) xSpd -= behavior.speedMultiplier;
        else                     xSpd += behavior.speedMultiplier;
        if( target.yPos < yPos ) ySpd -= behavior.speedMultiplier;
        else                     ySpd += behavior.speedMultiplier;
      }
    }
    
    //Wraith Motion
    if( behavior instanceof WraithBehavior )
    {
      if( millis() % 4000 < 2000 )
      {
        behavior.speedMultiplier = 0.05;
        behavior.friction = 0.96;
      }
      else
      {
        behavior.speedMultiplier = 0.00;
        behavior.friction = 0.999;
      }
    }
    
    xPos += xSpd+bumpX;
    yPos += ySpd+bumpY;
  
    xSpd *= behavior.friction;
    ySpd *= behavior.friction;
    
    if( (millis()+behavior.stepOffset) % behavior.stepSpeed < behavior.stepSpeed/2 )
      behavior.step = 1;
    else behavior.step = 2;
    
    bumpX *=.8;
    bumpY *=.8;
  }
  
  public void show()
  {
    push();
    
    translate(xPos+data.xOffset,yPos+data.yOffset);
    if( target.xPos > xPos )
      scale(-1, 1);

    if( speech && behavior instanceof ScientistBehavior )
      image( scientist, 0, 0 );
    image((behavior.step == 1) ? behavior.picture1 : behavior.picture2, 0, 0);
    
    pop();
    
    drawEffect();
    
    //circle(xPos+data.xOffset,hitBox()+data.yOffset,size);
    text(health+"/"+behavior.maxHealth,xPos+data.xOffset,yPos+data.yOffset-40);
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
      if( millis() > nextShot && dist(robot.xPos,robot.yPos,xPos,yPos) < (data.blockSize * behavior.sightRange)/2 )
      {
        nextShot = millis() + behavior.shotDelay;
        
        if( behavior instanceof MummyBehavior )     new Fireball(this,behavior.projectileDamage);
        if( behavior instanceof BansheeBehavior )   for( int i = 0; i < 8; i++ ) new Voice(this,behavior.projectileDamage,i);
        if( behavior instanceof BrainBehavior )     new BrainBlast(this,behavior.projectileDamage);
        if( behavior instanceof LichBehavior )      new Skull(this,behavior.projectileDamage);
        if( behavior instanceof VampireBehavior )   new Bat(this,behavior.projectileDamage);
        if( behavior instanceof MageBehavior )      for(int i=0;i<4;i++) new Bat(this,behavior.projectileDamage);
        if( behavior instanceof ScientistBehavior ) new Bat(this,behavior.projectileDamage);
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
    behavior.sightRange += 8; //Notice when hit
    new GhostWords( amount, xPos, yPos );
    if( health <= 0 )
    {
      dead = true;
    }
    else //minor slow
    {
      xSpd *= 0.5;
      ySpd *= 0.5;
    }

    //summon(); //Having concurrant modification issues
  }
  
  public void summon()
  {
    //Summons on hit
    if( behavior instanceof MonsterBehavior )
    {
      switch( behavior.summonType )
      {
        case 0:
        case 1:
        case 2: new Enemy( new RatBehavior(), this, robot );
          break;
          
        case 3:
        case 4: new Enemy( new SkeletonBehavior(), this, robot );
          break;
        
        default: new Enemy( new RatBehavior(), this, robot );
      }
      behavior.summonType = (behavior.summonType+1)%5;
    }
    
    if( behavior instanceof MageBehavior )
    {
      if( behavior.summonType == 9 )
        new Enemy( new VampireBehavior(), this, robot );
        
      behavior.summonType = (behavior.summonType+1)%10;
    }
  }
  
  public boolean checkExpiration()
  {
    if(dead)
    {
      finished = true;
      new Remnant(this);
      dropPickups();
      if(behavior.boss)
        map.totalBosses++;
      else
        map.totalEnemies++;
      map.checkMapRequirements();
      
      if( behavior instanceof ScientistBehavior )
        endGame();
      
      return true;
    }
    return false;
  }
  
  private void dropPickups()
  {
    for( int i = 0; i < behavior.drops; i++ )
      new Pickup(this);
  }
  
  //private void summon( EnemyBehavior b )
  //{
  //  new Enemy( b, target );
  //}
  
  //For summoned enemies
  Enemy( EnemyBehavior b, Enemy e, Robot t )
  {
    this(b,t);
    behavior.drops = 0;
    bumpX = random(-20,20);
    bumpY = random(-20,20);
    xPos = e.xPos;
    yPos = e.yPos;
  }
  
  public void endGame()
  {
    gameFinished = true;
    frame1 = millis();
    frame2 = millis() + 4000;
    frame3 = millis() + 8000;
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
  
  int damage;
  int projectileDamage;
  
  int drops;
  
  boolean boss;
  
  
  int attackType; //for mage and maybe scientist
  int summonType = 0;
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
    sightRange = 16;
    
    damage = 1;
    
    step = 1;
    stepSpeed = 2000;
    
    drops = 1;
    
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
    sightRange = 8;
    
    step = 1;
    stepSpeed = 2000;
    stepOffset = int(random(stepSpeed));
    
    damage = 1;
    
    drops = 1;
    
    name = "Zombie";
  }
}

class SkeletonBehavior extends EnemyBehavior
{
  SkeletonBehavior()
  {
    maxHealth = 10;
  
    corporeal = true;
    ranged = false;
    speedMultiplier = 0.020;
    friction = 0.90;
    sightRange = 8;
    
    step = 1;
    stepSpeed = 1000;
    stepOffset = int(random(stepSpeed));
    
    damage = 2;
    
    drops = int(random(2))+1;
    
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
    sightRange = 8;
    
    step = 1;
    stepSpeed = 1000;
    stepOffset = int(random(stepSpeed));
    
    damage = 1;
    
    drops = 1;
    
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
    sightRange = 10;
    
    step = 1;
    stepSpeed = 1000;
    stepOffset = int(random(stepSpeed));
    
    damage = 3;
    
    drops = int(random(2))+3;
    
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
    speedMultiplier = 0.015;
    friction = 0.95;
    sightRange = 16;
    
    step = 1;
    stepSpeed = 1000;
    stepOffset = int(random(stepSpeed));
    
    damage = 1;
    projectileDamage = 2;
    minRange = 2;
    
    drops = int(random(2))+2;
    
    name = "Mummy";
  }
}

class VampireBehavior extends EnemyBehavior
{
  VampireBehavior()
  {
    maxHealth = 40;
    
    damage = 2;
  
    corporeal = true;
    ranged = true;
    shotDelay = 2000;
    speedMultiplier = 0.050;
    friction = 0.95;
    sightRange = 20;
    
    step = 1;
    stepSpeed = 1000;
    stepOffset = int(random(stepSpeed));
    trailDelay = 200;
    
    damage = 5;
    projectileDamage = 3;
    
    drops = int(random(6))+5;
    
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
    sightRange = 20;
    
    step = 1;
    stepSpeed = 1000;
    stepOffset = int(random(stepSpeed));
    
    damage = 4;
    
    drops = int(random(5))+2;
    
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
    speedMultiplier = 0.02;
    friction = 0.95;
    sightRange = 24;
    
    step = 1;
    stepSpeed = 1000;
    stepOffset = int(random(stepSpeed));
    
    damage = 5;
    projectileDamage = 5;
    
    minRange = 2;
    
    drops = int(random(26))+25;
    
    name = "Banshee";
  }
}

class MonsterBehavior extends EnemyBehavior
{
  MonsterBehavior()
  {
    maxHealth = 150;
  
    boss = true;
    corporeal = true;
    ranged = false;
    speedMultiplier = 0.035;
    friction = 0.95;
    sightRange = 16;
    
    step = 1;
    stepSpeed = 2000;
    stepOffset = int(random(stepSpeed));
    
    damage = 5;
    
    drops = 50;
    
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
    speedMultiplier = 0;
    friction = 1;
    sightRange = 1000;
    
    step = 1;
    stepSpeed = 2000;
    stepOffset = int(random(stepSpeed));
    
    damage = 1;
    projectileDamage = 5;
    
    drops = int(random(51))+50;
    
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
    shotDelay = 3000;
    speedMultiplier = 0.030;
    friction = 0.95;
    sightRange = 32;
    
    step = 1;
    stepSpeed = 1500;
    stepOffset = int(random(stepSpeed));
    
    damage = 10;
    projectileDamage = 10;
    
    minRange = 5;
    
    drops = int(random(101))+100;
    
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
    ranged = true;
    shotDelay = 2000;
    speedMultiplier = 0.05;
    friction = 0.95;
    sightRange = 20;
    
    step = 1;
    stepSpeed = 1000;
    stepOffset = int(random(stepSpeed));
    trailDelay = 300;
    
    damage = 7;
    projectileDamage = 5;
    
    minRange = 3;
    
    drops = int(random(201))+100;
    
    name = "Mage";
  }
}

class ScientistBehavior extends EnemyBehavior
{
  ScientistBehavior()
  {
    maxHealth = 450;
  
    boss = true;
    corporeal = false;
    ranged = true;
    shotDelay = 300;
    speedMultiplier = 0.03;
    friction = 0.995;
    sightRange = 20;
    
    step = 1;
    stepSpeed = 1000;
    stepOffset = int(random(stepSpeed));
    trailDelay = 300;
    
    damage = 7;
    projectileDamage = 5;
    
    minRange = 3;
    
    drops = 0;
    
    name = "Boss";
    
    //Big coupling issue here
    speech = true;
    speechOver = millis() + 4000;
  }
}

/*
Ghost, Zombie, Skeleton, Rats, Mummy, Ghoul, Vampire, Wraith
Banshee, Dino Skeleton, Brain in a Jar, Lich, Vampire Mage
*/
