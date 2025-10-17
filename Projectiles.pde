interface Projectile
{
}

class Missile extends MovingThing implements Projectile
{
  Enemy target;
  
  int expiration;
  
  Missile( Robot r )
  {
    xPos = r.xPos-data.playerHitBox; //offset to left hand (where launcher is)
    yPos = r.yPos;
    
    xSpd = -3;
    
    xAcc = 0.08;
    yAcc = 0.08;
    
    size = data.missileSize;
    
    expiration = millis() + 5000;
    
    //projectiles.add(this);
    movers.add(this);
    
    //TESTING
    target = testEnemy;
  }
  
  public void show()
  {
    //TEMP
    push();
    translate(xPos+data.xOffset,yPos+data.yOffset);
    rotate(atan2(ySpd,xSpd));
    //rect(0,0,size,size/2);
    image(missilePic,0,0);
    pop();
  }
  
  public void move()
  {
    if( target != null )
    {
      if( target.xPos > xPos )
        xSpd += xAcc;
      else
        xSpd -= xAcc;
      if( target.yPos > yPos )
        ySpd += yAcc;
      else
        ySpd -= yAcc;
    }
    else
    {
      xSpd += xAcc;
      ySpd += yAcc;
    }
    
    xPos += xSpd;
    yPos += ySpd;
    
    xSpd *= 0.999;
    ySpd *= 0.999;
  }
  
  public boolean checkExpiration()
  {
    if(!finished && millis() > expiration)
    {
      finished = true;
      new Remnant(this);
      return true;
    }
    
    return false;
  }
}

class Disc extends MovingThing
{
  int expiration;
  boolean step;
  
  Disc( Robot r )
  {
    xPos = r.xPos;
    yPos = r.yPos;
    
    r.discAngle+=HALF_PI;
    int speed;
    if( r.upgrades.get("Fast Disc") )
      speed = 10;
    else
      speed = 5;
    
    xSpd = cos(r.discAngle) * speed;
    ySpd = sin(r.discAngle) * speed;
    
    size = data.missileSize;
    
    expiration = 2; //walls it can bounce off
    
    movers.add(this);
    
    move(); move();
  }
  
  public void show()
  {
    push();
    translate(xPos+data.xOffset,yPos+data.yOffset);
    if( step )
      scale(-1,1);
    image(disc,0,0);
    pop();
    step = !step;
  }
  
  public void move()
  {
    xPos += xSpd;
    yPos += ySpd;
  }
  
  @Override
  public void bounce(Block b)
  {
    super.bounce(b);
    xSpd *= .90;
    ySpd *= .90;
  }
  
  public boolean checkExpiration()
  {
    if( abs(xSpd)+abs(ySpd) < 3 )
    {
      finished = true;
      new Remnant(this);
      return true;
    }
    return false;
  }
}
