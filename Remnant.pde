//After-images or explosions - the stuff that's left behind when another object is removed
class Remnant extends MovingThing
{
  int expiration;
  int opacity;
  int fadeSpeed;
  
  float angle;
  
  color tint;
  
  boolean grows;
  boolean flipped;
  
  PImage image;
  
  //Laser-specific stuff
  boolean laser;
  float originX, originY;
  color lazColor;
  
  //Explosion
  Remnant( float x1, float y1 )
  {
    xPos = x1;
    yPos = y1;
    
    size = laserWidth(robot)/2;
    fadeSpeed = 10;
    opacity = 255;
    image = explosionSmall;
    expiration = millis()+500;
    tint = 255;
    
    movers.add(this);
  }
  
  Remnant( Robot r )
  {
    xPos = r.xPos;
    yPos = r.yPos;
    size = r.size;
    
    angle = PI*int(random(2));
    
    image = shieldPic2;
    
    expiration = millis()+500;
    opacity = 120;
    fadeSpeed = 2;
    grows = false;
    
    tint = 255;
    
    movers.add(this);
  }
  
  Remnant( Enemy e )
  {
    xPos = e.xPos;
    yPos = e.yPos;
    size = e.size;
    if( e.target.xPos > e.xPos )
      flipped = true;
    
    image = e.behavior.pictureX;
    
    expiration = millis()+1000;
    opacity = 240;
    fadeSpeed = 2;
    grows = false;

    tint = color(255);
    
    if( e.behavior instanceof VampireBehavior || e.behavior instanceof MageBehavior )
    {
      if( !e.dead )
        tint = 0;
      else
      {
        fadeSpeed = 1;
        expiration = millis()+3000;
      }
    }
    
    trails.add(this);
  }
  
  Remnant( MovingThing m )
  {
    xPos = m.xPos;
    yPos = m.yPos;
    size = m.size;
      
    if( m instanceof Missile )
    {
      image = explosionSmall;
      expiration = millis()+1000;
      opacity = 240;
      fadeSpeed = 2;
      grows = true;
      tint = color(255);
      angle = random(TWO_PI);
    }
    if( m instanceof Disc )
    {
      image = explosionSmall;
      expiration = millis()+500;
      opacity = 240;
      fadeSpeed = 4;
      grows = false;
      tint = color(255);
    }
    
    movers.add(this);
  }
  
  //For lasers
  Remnant( MovingThing m, float oX, float oY)//, color c )
  {
    //lazColor = c;
    
    xPos = m.xPos;
    yPos = m.yPos;
    
    originX = oX;
    originY = oY;
    
    if( m instanceof Laser )
    {
      image = laserImage;
      expiration = millis()+500;
      opacity = 240;
      fadeSpeed = 4;
      grows = false;
      //xPos = (xPos + robot.xPos) / 2.0;
      //yPos = (yPos + robot.yPos) / 2.0;
      //tint = color( random(255), random(255), random(255) );
      //angle = robot.angle-HALF_PI;
      laser = true;
      //originX = robot.xPos + robot.xSpd*50; //Move laser away from robot
      //originY = robot.yPos + robot.ySpd*50;
    }
    
    movers.add(this);
  }
  
  public void show()
  {
    //println("SHOW!!!");
    
    if(finished) return;
    
    push();
    
    opacity -= fadeSpeed;
    if(grows) size += fadeSpeed/2;
    tint(tint,opacity);
    if(laser)
    {
      strokeWeight(laserWidth(robot)/9); //change with laser width
      if( robot.upgrades.get("Laser 4") )      stroke(200,25,25, opacity);
      else if( robot.upgrades.get("Laser 3") ) stroke(175,25,200,opacity);
      else if( robot.upgrades.get("Laser 2") ) stroke(25,100,200,opacity);
      else                                     stroke(25,200,200,opacity);
      line(xPos+data.xOffset,yPos+data.yOffset,originX+data.xOffset,originY+data.yOffset);
    }
    else
    {
      translate(xPos+data.xOffset,yPos+data.yOffset);
      rotate(angle);
      if( flipped )
        scale(-1, 1);
      image(image,0,0,size,size);
    }
    //if( millis() > expiration )
    //  finished = true;
    pop();
  }
  
  public void move()
  {
  }
  
  public boolean checkExpiration()
  {
    if( millis() > expiration )
    {
      finished = true;
      return true;
    }
    return false;
  }
}
