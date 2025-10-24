interface Projectile
{
}

class Missile extends MovingThing implements Projectile
{
  Enemy target;
  
  int expiration;
  //int damage;
  
  Missile( Robot r, int damage )
  {
    this.damage = damage;
    
    xPos = r.xPos-data.playerHitBox; //offset to left hand (where launcher is)
    yPos = r.yPos;
    
    xSpd = random(-3,3);
    ySpd = random(-3,3);
    
    xAcc = 0.1;
    yAcc = 0.1;
    
    size = data.missileSize;
    
    expiration = millis() + 5000;
    
    //projectiles.add(this);
    movers.add(this);
    
    //TESTING
    //target = testEnemy;
    target = closeTarget();
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
    
    xSpd *= 0.99;
    ySpd *= 0.99;
  }
  
  @Override
  public void bounce( Block b )
  {
    if( robot.upgrades.get("Bouncing Missile") )
      super.bounce(b);
    else if( robot.upgrades.get("Demolition Missile") )
    {
      b.demolish();
      expiration = 0;
    }
    else
      expiration = 0;
  }
  
  @Override
  public void destroy()
  {
    expiration = 0;
  }
  
  public boolean checkExpiration()
  {
    if(!finished && millis() > expiration)
    {
      finished = true;
      if( robot.upgrades.get("Blast Radius 1") ) size*=2;
      if( robot.upgrades.get("Blast Radius 2") ) size*=4;
      new Remnant(this);
      return true;
    }
    
    return false;
  }
  
  private Enemy closeTarget()
  {
    ArrayList<Enemy> sorted = new ArrayList<Enemy>();
    for( MovingThing m: movers )
      if( m instanceof Enemy )
      {
        Enemy e = (Enemy) m;
        
        //Only include targets close to target
        float dx = e.xPos - xPos;
        float dy = e.yPos - yPos;
        float distSq = dx*dx + dy*dy;

        if (distSq > (data.blockSize*12)*(data.blockSize*12)) continue;
        
        sorted.add((Enemy)m);
      }
      
    if (sorted.size() <= 1) return sorted.isEmpty() ? null : sorted.get(0);
  
    Collections.sort(sorted, new Comparator<Enemy>() {
      public int compare(Enemy a, Enemy b) {
        return Float.compare(
          sq(a.xPos - xPos) + sq(a.yPos - yPos),
          sq(b.xPos - xPos) + sq(b.yPos - yPos)
        );
      }
    });
    
    int roll1 = int(random(sorted.size()));
    int roll2 = int(random(sorted.size()));
    int roll3 = int(random(sorted.size()));
    int roll4 = int(random(sorted.size()));
    int chosenIndex = min(min(roll1, roll2), min(roll3, roll4));
    return sorted.get( chosenIndex );
  }
}

class Disc extends MovingThing implements Projectile
{
  //int expiration;
  boolean step;
  //int damage;
  
  Disc( Robot r, int damage )
  {
    this.damage = damage;
    
    xPos = r.xPos;
    yPos = r.yPos;
    
    r.discAngle+=robot.discAngleShift();
    
    int speed;
    if( r.upgrades.get("Fast Disc") )
      speed = 10;
    else
      speed = 5;
    
    xSpd = cos(r.discAngle) * speed;
    ySpd = sin(r.discAngle) * speed;
    
    size = data.missileSize*1.2;
    
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
