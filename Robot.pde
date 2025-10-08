class Robot extends MovingThing
{
  CosmeticKit cosmetics;
  
  float angle;
  float angleSpeed;
  
  float speed;
  
  boolean turning;
  boolean turningClockwise;
  
  ArrayList<Pointer> pointer = new ArrayList<Pointer>();
  
  public Robot( String name, PApplet parent )
  {
    cosmetics = new CosmeticKit( name, parent );
    size = data.playerSize;
  }
  
  public void show()
  {
    //showDirectionDisplay();
    recordAndDrawPointers();
    cosmetics.display(xPos+data.xOffset,yPos+data.yOffset);
    //circle(xPos+data.xOffset,yPos+data.yOffset,data.playerHitBox);
  }
  
  public void move()
  {
    recordAndDrawPointers();
    
    adjustToAngle();
    
    xPos += xSpd;
    yPos += ySpd;
    
    checkForScroll();
    
    checkForExit();
  }
  
  //Override
  public void bounce( Block b )
  {
    //Go back a step to avoid phasing through the block partially before
    //  determining direction of bounce
    xPos -= xSpd;
    yPos -= ySpd;
    
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
    if( dist( xPos, yPos, testMap.exitX, testMap.exitY-data.blockSize/3 ) < data.blockSize/2+data.playerHitBox/2 )
      testMap.exiting = true;
  }
  
  public void setPosition( float x, float y )
  {
    xPos = x;
    yPos = y;
  }
  
  private void adjustToAngle()
  {
    if(!turning) return;
    
    if(turningClockwise) angle+=angleSpeed;
    else                 angle-=angleSpeed;
    
    xSpd = cos(angle) * speed;
    ySpd = sin(angle) * speed;

  }
  
  //Make this an ellipse
  private void showDirectionDisplay()
  {
    push();
    translate(xPos+data.xOffset, yPos+data.yOffset+data.playerHitBox*.75);
    rotate(angle);
    //strokeWeight(5);
    //line(0,0,75,0);
    //if(turningClockwise)
    //  triangle(75,0, 65,0, 70,10);
    //else
    //  triangle(75,0, 65,0, 70,-10);
    noStroke();
    color lightColor;
    if(turningClockwise) lightColor = color(200,0,0);
    else lightColor = color(0,0,200);
    fill(lightColor);
    circle(75,0,10);
    if(turning)
    {
      fill(lightColor,75);
      for(int i = 0; i < 10; i++)
      {
        if(turningClockwise) rotate(-0.05);
        if(!turningClockwise)rotate(0.05);
        circle(75,0,10-i);
      }
    }
    pop();
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
    
    pointer.add( new Pointer( xRecovered, yRecovered ) );
    
    for(int i = 0; i < pointer.size(); i++)
    {
      pointer.get(i).life--;
      pointer.get(i).drawPointer(turningClockwise);
      if(pointer.get(i).life<=20)
      {
        pointer.remove(i);
        i--;
      }
    }
    
    for(Pointer p: pointer)
      println(p.xPos + " " + p.yPos);
  }
}

//*****************************************
// Laser Pointer for directing robot
class Pointer
{
  float xPos, yPos;
  int life;
  
  Pointer(float x, float y)
  {
    xPos = x;
    yPos = y;
    life = 50;
  }
  
  public void drawPointer( boolean turningRight )
  {
    push();
    noStroke();
    //float opacity = life/4;
    //if( life == 49 )
    //  opacity = 255;
    color pointColor;
    if(turningRight) pointColor = color(200,0,0);
    else             pointColor = color(0,0,200);
    
    fill(pointColor);
    circle(xPos+data.xOffset,yPos+data.yOffset,life/7);
    
    ////Diagetic Player
    //if( life == 49 )
    //{
    //  stroke(pointColor,20);
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
  
  void display( float x, float y )
  {
    push();
  
    translate( x, y );
    if( millis() % 1000 < 500 )
      scale(-1,1);//flip on X axis
      
    image(basePic,0,0);
    
    //if(keyPressed) image(facePic2,0,0);
    //else           image(facePic,0,0);
    
    image(facePic,0,0);
    
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
  
  void display( float x, float y )
  {
    kit.display(x,y);
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
