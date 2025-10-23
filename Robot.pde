//Tried acceleration with Robot, caused it to glitch into walls

class Robot extends MovingThing
{
  CosmeticKit cosmetics;
  //TurnGuide guide;
  
  HashMap<String,Boolean> upgrades = new HashMap<>();
  
  String fullName;
  String shortName;
  
  float angle;
  //float angleSpeed;
  float discAngle = QUARTER_PI; //for alternating disc directions
  
  float speed;
  
  boolean turning;
  boolean turningClockwise;
  
  int cash = 1500;
  
  ArrayList<Pointer> pointer = new ArrayList<Pointer>();
  
  int armor; //health
  int nextArmorRegen;
  
  int shield;
  int nextShieldRegen;
  
  int iFrames;
  
  boolean discActive;
  int nextDisc;
  boolean laserActive;
  int nextLaser;
  boolean missileActive;
  int nextMissile;
  
  public Robot( String name, PApplet parent )
  {
    cosmetics = new CosmeticKit( name, parent );
    size = data.playerSize;
    
    speed = 2;
    xSpd = 1;
    ySpd = 0;
    angle = QUARTER_PI;
    
    xPos = map.startingPoint('x');
    yPos = map.startingPoint('y');
    
    shortName = generateName(1);
    fullName = shortName + generateName(2);
    
    armor = 20;
    
    movers.add(this);
  }
  
  public void show()
  {
    if(map.exiting) return;
    
    //showDirectionDisplay();
    //if(!map.exiting)
    recordAndDrawPointers();
    
    cosmetics.display(xPos+data.xOffset,yPos+data.yOffset,iFrames>millis());
    //circle(xPos+data.xOffset,yPos+data.yOffset,data.playerHitBox);
    if( shield > 0 )
      drawShield();
  }
  
  public void move()
  {
    recordAndDrawPointers();
    
    adjustToAngle();
    
    //xSpd += xAcc;
    //ySpd += yAcc;
    
    if( turning && upgrades.get("Turn-Stop") )
    {
      xPos += bumpX;
      yPos += bumpY;
    }
    else if( turning && upgrades.get("Turn-Slow") )
    {
      xPos += xSpd/2+bumpX;
      yPos += ySpd/2+bumpY;
    }
    else
    {
      xPos += xSpd+bumpX;
      yPos += ySpd+bumpY;
    }
    
    bumpX *= 0.95;
    bumpY *= 0.95;
    
    checkForScroll();
    
    checkForExit();
  }
  
  //Weapons and abilities
  public void activate()
  {
    //Armor Regen
    if( upgrades.get("Armor Regeneration") && nextArmorRegen < millis() )
    {
      restoreArmor(1);
      nextArmorRegen = millis() + 5000;
    }
    
    //Shield
    if( shield < getMaxShield() )
    {
      if( upgrades.get("Shield Regeneration") && nextShieldRegen < millis() )
      {
        restoreShield(1);
        nextShieldRegen = millis() + 5000;
      } 
      else if( nextShieldRegen < millis() )
      {
        restoreShield(1);
        nextShieldRegen = millis() + 10000;
      } 
    }
    
    if( discActive && millis() > nextDisc )
    {
      nextDisc = millis()+800;
      
      new Disc(this,discDamage());
      
      if( upgrades.get("Multi-Disc 1") )
        new Disc(this,discDamage());
        
      if( upgrades.get("Multi-Disc 2") )
      {
        new Disc(this,discDamage());
        new Disc(this,discDamage());
      }
      
      if( upgrades.get("Multi-Disc 3") )
      {
        new Disc(this,discDamage());
        new Disc(this,discDamage());
        new Disc(this,discDamage());
      }
    }
    
    if( laserActive && millis() > nextLaser )
    {
      nextLaser = millis()+1000;
      new Laser(this,laserDamage());
    }
    
    if( missileActive && millis() > nextMissile )
    {
      nextMissile = millis() + missileDelay();
      
      new Missile(this,missileDamage());
      
      if( upgrades.get("Multi-Launch 1") )
        new Missile(this,missileDamage());
      
      if( upgrades.get("Multi-Launch 2") )
      {
        new Missile(this,missileDamage());
        new Missile(this,missileDamage());
        new Missile(this,missileDamage());
      }
    }
  }
  
  private int missileDelay()
  {
    if( upgrades.get("Missile Reload 2") ) return 900;
    if( upgrades.get("Missile Reload 1") ) return 1200;
    return 1500;
  }
  
  public float discAngleShift()
  {
    if( upgrades.get("Multi-Disc 3") ) return TWO_PI/5;
    if( upgrades.get("Multi-Disc 2") ) return TWO_PI/4;
    if( upgrades.get("Multi-Disc 1") ) return PI*.75;
    return HALF_PI;
  }
  
  private void drawShield()
  {
    push();
    tint(255,50);
    image( shieldPic, xPos+data.xOffset, yPos+data.yOffset );
    pop();
  }
  
  public float blastRange()
  {
    if( upgrades.get("Blast Radius 2") ) return data.blockSize*2;
    if( upgrades.get("Blast Radius 1") ) return data.blockSize;
    return 0;
  }
  
  public boolean checkExpiration()
  {
    return false;
  }
  
  //Override
  public void bounce( Block b )
  {
    //Go back a step to avoid phasing through the block partially before
    //  determining direction of bounce
    xPos -= (xSpd+bumpX)*2;
    yPos -= (ySpd+bumpY)*2;
    
    if(abs(xPos - b.xPos) > abs(yPos - b.yPos)) //horizontal
    {
      xSpd = -xSpd;
      angle = PI-angle;
    }
    else if(abs(xPos - b.xPos) < abs(yPos - b.yPos)) //vertical
    {
      ySpd = -ySpd;
      angle = -angle;
    }
    else //corner hit
    {
      xSpd = -xSpd;
      ySpd = -ySpd;
      angle += PI;
    }
  }
  
  public void getHitBy( Enemy e )
  {
    if( iFrames > millis() ) return;
    
    //Get pushed
    float pushAngle = atan2(yPos-e.yPos,xPos-e.xPos);
    bumpX = cos(pushAngle) * bumpSpeed();
    bumpY = sin(pushAngle) * bumpSpeed();
    
    //Take damage
    takeDamage( e.damage );
    
    iFrames = millis() + 500;
  }
  
  public boolean getHitBy( MovingThing m )
  {
    if( iFrames > millis() ) return false;
    
    takeDamage( m.damage );
    
    iFrames = millis() + 500;
    
    return true;
  }
  
  public void takeDamage( int d )
  {
    if( shield > 0 )
    {
      shield--;
      new Remnant(this);
    }
    else
    {
      armor -= d;
      new GhostWords(d,xPos,yPos);
      if( armor <= 0 )
      {
        //DEAD - go to BREAKDOWN
      }
    }
  }
  
  private int bumpSpeed()
  {
    if( upgrades.get("Pushback") || upgrades.get("Forceful Pushback") )
      return 1;
    else if( upgrades.get("Knockback Resist") )
      return 5;
    else
      return 10;
  }
  
  public int missileDamage()
  {
    if( upgrades.get("Missile 4") ) return 6;
    if( upgrades.get("Missile 3") ) return 4;
    if( upgrades.get("Missile 2") ) return 2;
    if( upgrades.get("Missile 1") ) return 1;
    return 0;
  }
  
  public int discDamage()
  {
    if( upgrades.get("Razor Disc 4") ) return 8;
    if( upgrades.get("Razor Disc 3") ) return 6;
    if( upgrades.get("Razor Disc 2") ) return 4;
    if( upgrades.get("Razor Disc 1") ) return 2;
    return 0;
  }
  
  public int laserDamage()
  {
    if( upgrades.get("Laser 4") ) return 12;
    if( upgrades.get("Laser 3") ) return 9;
    if( upgrades.get("Laser 2") ) return 6;
    if( upgrades.get("Laser 1") ) return 3;
    return 0;
  }
  
  public void checkForScroll()
  {
    if( yPos+data.yOffset < data.scrollYDist ) //screen up
      data.yOffset -= yPos+data.yOffset - data.scrollYDist;
   
    if( xPos+data.xOffset < data.scrollXDist ) //screen left
      data.xOffset -= xPos+data.xOffset -data.scrollXDist;
     
    if( yPos+data.yOffset > height-data.scrollYDist ) //screen down
      data.yOffset -= yPos+data.yOffset - (height-data.scrollYDist);
     
    if( xPos+data.xOffset > width-data.scrollXDist) //screen right
      data.xOffset -= xPos+data.xOffset - (width-data.scrollXDist);
  }
  
  private void checkForExit()
  {
    if( dist( xPos, yPos, map.exitX, map.exitY-data.blockSize/3 ) < data.blockSize/2+data.playerHitBox/2 )
      map.exiting = true;
  }
  
  public void setPosition( float x, float y )
  {
    xPos = x;
    yPos = y;
  }
  
  public void restoreArmor( int amount )
  {
    armor += amount;
    if( armor > getMaxArmor() )
      armor = getMaxArmor();
  }
  
  public void restoreShield( int amount )
  {
    shield += amount;
    if( shield > 3 )
      shield = 3;
  }
  
  public int getMaxArmor()
  {
    if( upgrades.get("Armor Up 3") ) return 100;
    if( upgrades.get("Armor Up 2") ) return 70;
    if( upgrades.get("Armor Up 1") ) return 40;
    return 20;
  }
  
  private int getMaxShield()
  {
    if( upgrades.get("Shield 3") ) return 3;
    if( upgrades.get("Shield 2") ) return 2;
    if( upgrades.get("Shield 1") ) return 1;
    return 0;
  }
  
  private float adjustedSpeed()
  {
    if(upgrades.get("Movement Speed 4")) return 3.75;
    if(upgrades.get("Movement Speed 3")) return 3;
    if(upgrades.get("Movement Speed 2")) return 2.5;
    if(upgrades.get("Movement Speed 1")) return 2;
    return 1.5;
  }
  
  private float adjustedAngleSpeed()
  {
    if(upgrades.get("Rotation Speed 3")) return 0.04;
    if(upgrades.get("Rotation Speed 2")) return 0.03;
    if(upgrades.get("Rotation Speed 1")) return 0.02;
    return 0.015;
  }
  
  private void adjustToAngle()
  {
    if(!turning) return;
    
    if(turningClockwise) angle+=adjustedAngleSpeed();
    else                 angle-=adjustedAngleSpeed();
    
    xSpd = cos(angle) * adjustedSpeed();
    ySpd = sin(angle) * adjustedSpeed();
  }
  
  public void startTurning()
  {
    if(turning)return;
    
    turning = true;
  }
  
  public void stopTurning()
  {
    turning = false;
    turningClockwise = !turningClockwise;
  }
  
  private void recordAndDrawPointers()
  {
    float xRecovered = xPos + cos(angle) * 75;
    float yRecovered = yPos + sin(angle) * 75;
    
    pointer.add( new Pointer( xRecovered, yRecovered, turningClockwise ) );
    
    for(int i = 0; i < pointer.size(); i++)
    {
      pointer.get(i).life--;
      pointer.get(i).drawPointer();
      if(pointer.get(i).life<=20)
      {
        pointer.remove(i);
        i--;
      }
    }
    
    //robot.drawLaserCrosshair();
  }
  
  //private void drawLaserCrosshair()
  //{
  //  if( !(upgrades.get("Laser 1") || upgrades.get("Laser 2") || upgrades.get("Laser 3") || upgrades.get("Laser 4") ) ) return;
    
  //  push();
  //  translate(xPos+data.xOffset,yPos+data.yOffset);
  //  rotate(angle);
  //  noStroke();
  //  fill(25,200,200);
  //  circle(300,0,10);
  //  pop();
  //}
  
  private String generateName( int part )
  {
    String result = "";

    if( part == 1 )
    {
      if( int(random(100)) == 13 ) return "Mango";
      
      
      String [] firstHalf = {"Robo","Auto","Laser","Metal","Proto","Mega","Super","Heavy","Gizmo","Cyber","Alpha","Omega","Techno","Max","Ultra","Alloy","Kilo","Artifice","Mighty","Astro","Micro","Power","Armor","Virus"};
      String [] secondHalf = {"Matic","Tron","Bot","Machine","Type","Device","Gadget","Droid","Mech","Storm","-Kun","-Chan","Enforcer","Gear","Tool","Byte","Shock","Thing","Rex","bit"};
      
      result += firstHalf[int(random(firstHalf.length))];
      result += secondHalf[int(random(secondHalf.length))];
      return result;
    }
    else
    {
      if( random(2) > 1 && !shortName.equals("Mango") )
        result += ""+ numericPart();
  
      return result;
    }
  }
  
  private String numericPart()
  {
    switch(int(random(4)))
    {
      //Just a number
      case 0:
        return " " + int(random(1,10));
      
      //Number with abbreviation
      case 1:
        String suffix[] = {"mk.","No.","#","ver."};
        return " " + suffix[int(random(suffix.length))]+int(random(1,10));
      
      //Extra Word (not numeric, I know)
      case 2:
        String suffix2[] = {" Special"," Advanced","Pro"," [Experimental]"," [Unstable]"," MAX","Plus","-X"};
        return "" + suffix2[int(random(suffix2.length))];
      
      //Big number (100 to 9000)
      default:
       return " " + int( int(random(1,10)) * pow(10, int(random(2,4))) );
    }
  }
  
  public void activateUpgrade( String name )
  {
    if( upgrades.get(name) )
    {
      println("Tried to activate " + name + " when it was already active.");
      return;
    }
    
    //Deactivate previous tiers
    switch(name)
    {
      case "Movement Speed 4": upgrades.put("Movement Speed 3",false);
      case "Movement Speed 3": upgrades.put("Movement Speed 2",false);
      case "Movement Speed 2": upgrades.put("Movement Speed 1",false);
      break;
      case "Forceful Pushback":upgrades.put("Pushback",false);
      case "Pushback":         upgrades.put("Knockback Resist",false);
      break;
      case "Rotation Speed 3": upgrades.put("Rotation Speed 2",false);
      case "Rotation Speed 2": upgrades.put("Rotation Speed 1",false);
      break;
      case "Turn-Stop": upgrades.put("Turn-Slow",false);
      break;
      case "Armor Up 3": upgrades.put("Armor Up 2",false);
      case "Armor Up 2": upgrades.put("Armor Up 1",false);
      break;
      case "Shield 3": upgrades.put("Shield 2",false);
      case "Shield 2": upgrades.put("Shield 1",false);
      break;
      case "Magnet 2": upgrades.put("Magnet 1",false);
      break;
      case "Laser 4": upgrades.put("Laser 3",false);
      case "Laser 3": upgrades.put("Laser 2",false);
      case "Laser 2": upgrades.put("Laser 1",false);
      case "Laser 1": laserActive = true;
      break;
      case "Extended Laser 2": upgrades.put("Extended Laser 1",false);
      break;
      case "Wide Laser 2": upgrades.put("Wide Laser 1",false);
      break;
      case "Missile 4": upgrades.put("Missile 3",false);
      case "Missile 3": upgrades.put("Missile 2",false);
      case "Missile 2": upgrades.put("Missile 1",false);
      case "Missile 1": missileActive = true;
      break;
      case "Missile Reload 2": upgrades.put("Missile Reload 1",false);
      break;
      case "Multi-Launch 2": upgrades.put("Multi-Launch 1",false);
      break;
      case "Blast Radius 2": upgrades.put("Blast Radius 1",false);
      break;
      case "Razor Disc 4": upgrades.put("Razor Disc 3",false);
      case "Razor Disc 3": upgrades.put("Razor Disc 2",false);
      case "Razor Disc 2": upgrades.put("Razor Disc 1",false);
      case "Razor Disc 1": discActive = true;
      break;
      case "Multi-Disc 3": upgrades.put("Multi-Disc 2",false);
      case "Multi-Disc 2": upgrades.put("Multi-Disc 1",false);
      break;
      case "Disc Bounce 3": upgrades.put("Disc Bounce 2",false);
      case "Disc Bounce 2": upgrades.put("Disc Bounce 1",false);
      break;
      case "Electric Shock 4": upgrades.put("Electric Shock 3",false);
      case "Electric Shock 3": upgrades.put("Electric Shock 2",false);
      case "Electric Shock 2": upgrades.put("Electric Shock 1",false);
      break;
      case "Shock Speed 2": upgrades.put("Shock Speed 1",false);
      break;
      case "Long Arc 3": upgrades.put("Long Arc 2",false);
      case "Long Arc 2": upgrades.put("Long Arc 1",false);
      break;
    }
    
    //Activated upgrade
    upgrades.put(name,true);
  }
}

//*****************************************
// Laser Pointer for directing robot
class Pointer
{
  float xPos, yPos;
  int life;
  color col;
  
  Pointer(float x, float y, boolean turningRight)
  {
    xPos = x;
    yPos = y;
    life = 50;
    if(turningRight) col = color(200,0,0);
    else             col = color(0,0,200);
  }
  
  public void drawPointer()
  {
    push();
    noStroke();
    //float opacity = life/4;
    //if( life == 49 )
    //  opacity = 255;
    
    fill(col);
    circle(xPos+data.xOffset,yPos+data.yOffset,life/7);
    
    ////Diagetic Player
    //if( life == 49 )
    //{
    //  stroke(col,20);
    //  strokeWeight(0.75);
    //  //line(testBot.xPos+data.xOffset,testBot.yPos+data.yOffset-data.playerHitBox/2,xPos+data.xOffset,yPos+data.yOffset);
    //  line(width/2,0,xPos+data.xOffset,yPos+data.yOffset);
    //}
    pop();
  }
}

//*****************************************
// Cosmetic Kit for robot visuals and sound
class CosmeticKit
{
  String name; //for Decorator
  PImage basePic;
  PImage facePic;
  PImage facePic2;
  
  PApplet parent;
  
  CosmeticKit( String name, PApplet parent )
  {
    this.name = name;
    this.parent = parent;
    basePic  = loadImage(name+"Base.png");  basePic.resize(int(data.playerSize),0);
    facePic  = loadImage(name+"Face.png");  facePic.resize(int(data.playerSize),0);
    facePic2 = loadImage(name+"Face2.png"); facePic2.resize(int(data.playerSize),0);
    sounds = matchingSoundPack( name, this.parent );
  }
  
  void display( float x, float y, boolean sad )
  {
    push();
  
    translate( x, y );
    if( millis() % 1000 < 500 )
      scale(-1,1);//flip on X axis
      
    image(basePic,0,0);
    
    //if(keyPressed) image(facePic2,0,0);
    //else           image(facePic,0,0);
    
    if( sad ) image(facePic2,0,0);
    else      image(facePic,0,0);
    
    pop();
  }
  
  SoundPack sounds;
  
  private SoundPack matchingSoundPack( String name, PApplet parent )
  {
    switch( name )
    {
      case "test": return new ChirpPack(parent);
      default:     return new SoftPack(parent);
    }
  }
}

//*********************************
// Decorators for Cosmetic Kit
abstract class CosmeticDecorator extends CosmeticKit
{
  protected final CosmeticKit kit;
  protected PImage upgradePic;
  
  public CosmeticDecorator( CosmeticKit kit )
  {
    super(kit.name,kit.parent);
    this.kit = kit;
  }
}

class TestDecorator extends CosmeticDecorator
{
  public TestDecorator( CosmeticKit kit )
  {
    super(kit);
    upgradePic = loadImage("testArmUpgrade.png"); upgradePic.resize(int(data.playerSize),0);
  }
  
  void display( float x, float y, boolean s )
  {
    kit.display(x,y,s);
    image(upgradePic,x,y);
  }
}

//*********************************
// Sound Packs
class SoundPack
{
  protected SoundFile move;
  protected SoundFile hurt;
  protected SoundFile levelUp;
  
  protected PApplet parent;
  
  public SoundPack(PApplet parent)
  {
    this.parent = parent;
  }
  
  public void move()
  {
    move.play();
  }
  public void hurt()
  {
    hurt.play();
  }
  public void levelUp()
  {
    levelUp.play();
  }
}

class ChirpPack extends SoundPack
{
  public ChirpPack(PApplet parent)
  {
    super(parent);
    move = new SoundFile(parent, "beep.wav" );
    hurt = new SoundFile(parent, "hurt_chirp.wav" );
    levelUp = new SoundFile(parent, "power_zap.wav" );
  }
}

class SoftPack extends SoundPack
{
  public SoftPack(PApplet parent)
  {
    super(parent);
    move = new SoundFile(parent, "blip.wav" );
    hurt = new SoundFile(parent, "hit_bump.wav" );
    levelUp = new SoundFile(parent, "power_bubble.wav" );
  }
}
