interface Projectile
{
}

class Missile extends MovingThing implements Projectile
{
  Enemy target;
  
  int expiration;
  int damage;
  
  Missile( Robot r, int damage )
  {
    this.damage = damage;
    
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
  
  @Override
  public void bounce( Block b )
  {
    if( robot.upgrades.get("Bouncing Missile") )
      super.bounce(b);
    else
      expiration = 0;
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
  //int expiration;
  boolean step;
  int damage;
  
  Disc( Robot r, int damage )
  {
    this.damage = damage;
    
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
    
    //expiration = 2; //walls it can bounce off
    
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
  public void bounce(Block b) //Fast disc provides a 50% increase in bounces
  {
    super.bounce(b);
    float friction;
    if( robot.upgrades.get("Disc Bounce 3") )
    {
      friction = 0.90; //8
      if( robot.upgrades.get("Fast Disc") )
        friction = 0.87; //12
    }
    else if( robot.upgrades.get("Disc Bounce 2") )
    {
      friction = 0.85; //6
      if( robot.upgrades.get("Fast Disc") )
        friction = 0.82;//8
    }
    else if( robot.upgrades.get("Disc Bounce 1") )
    {
      friction = 0.80; //4
      if( robot.upgrades.get("Fast Disc") )
        friction = 0.74; //6
    }
    else
    {
      friction = 0.60; //2
      if( robot.upgrades.get("Fast Disc") )
        friction = 0.55; //3
    }
      
    xSpd *= friction;
    ySpd *= friction;
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
