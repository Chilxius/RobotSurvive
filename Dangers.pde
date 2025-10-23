interface Danger //(enemy projectiles)
{
  
}

//Mummy: fireball
//Vampire: seeker
//Banshee: sound wave
//Brain: squigly brain blast
//Lich: skulls (curse?)
//Mage: bullet-hell
//Final Boss: 

class Fireball extends MovingThing implements Danger
{
  float angle;
  //int damage;
  
  Fireball( Enemy e, int d )
  {
    damage = d;
    xPos = e.xPos;
    yPos = e.yPos;
    xSpd = e.xSpd;
    ySpd = e.ySpd;
    
    angle = atan2(robot.yPos-yPos, robot.xPos-xPos);
    
    int speed = 2;
    
    xAcc = cos(angle) * speed / 100;
    yAcc = sin(angle) * speed / 100;
    
    size = data.missileSize;
    
    //expiration = 2; //walls it can bounce off
    
    movers.add(this);
  }
  
  public void move()
  {
    xSpd += xAcc;
    ySpd += yAcc;
    
    xPos += xSpd;
    yPos += ySpd;
  }
  
  public void show()
  {
    push();
    translate(xPos+data.xOffset,yPos+data.yOffset);
    rotate(angle-HALF_PI);
    image(fireball,0,0);
    pop();
  }
  
  @Override
  public void bounce(Block b)
  {
    finished = true;
  }
  
  public boolean checkExpiration()
  {
    if( finished )
    {
      new Remnant(xPos,yPos);
      return true;
    }
    return false;
  }
}

class Voice extends MovingThing implements Danger
{
  float angle;
  //int damage;
  
  Voice( Enemy e, int d, int i )
  {
    damage = d;
    
    xPos = e.xPos;
    yPos = e.yPos;
    
    angle = atan2(robot.yPos-yPos,robot.xPos-xPos) + (QUARTER_PI*i);
    
    xSpd = cos(angle) * 2;
    ySpd = sin(angle) * 2;
    
    size = data.missileSize*2;
    
    for(int j = 0; j < 20; j++) move();
    
    movers.add(this);
  }
  
  public void move()
  {
    xPos += xSpd;
    yPos += ySpd;
  }
  public void show()
  {
    push();
    translate(xPos+data.xOffset,yPos+data.yOffset);
    rotate(angle-HALF_PI);
    image(voice,0,0);
    pop();
  }
  
  @Override
  public void bounce(Block b)
  {
    finished = true;
  }
  
  public boolean checkExpiration()
  {
    return finished;
  }
}

class BrainBlast extends MovingThing implements Danger
{
  float angle;
  int duration;
  //int damage;
  
  BrainBlast( Enemy e, int d )
  {
    damage = d;
    
    xPos = e.xPos;
    yPos = e.yPos;
    
    angle = atan2(robot.yPos-yPos,robot.xPos-xPos)+random(-0.2,0.2);
    
    xSpd = cos(angle) * 2.5;
    ySpd = sin(angle) * 2.5;
    
    size = data.missileSize*2;
    
    duration = millis() + 10000;
    
    for(int j = 0; j < 10; j++) move();
    
    movers.add(this);
  }
  
  public void move()
  {
    xPos += xSpd;
    yPos += ySpd;
  }
  
  public void show()
  {
    push();
    translate(xPos+data.xOffset,yPos+data.yOffset);
    rotate(angle-HALF_PI);
    if( millis()% 400 < 200 )
      scale(-1,1);
    image(brainBlast,0,0);
    pop();
  }
  
  @Override
  public void bounce(Block b)
  {
    if( millis() > duration )
      finished = true;
  }
  
  public boolean checkExpiration()
  {
    return finished;
  }
}

class Skull extends MovingThing implements Danger
{
  //float angle;
  int duration;
  //int damage;
  
  Skull( Enemy e, int d )
  {
    damage = d;
    
    xPos = e.xPos;
    yPos = e.yPos;
    
    float angle = atan2(robot.yPos-yPos,robot.xPos-xPos)+random(-0.1,0.1);
    
    xSpd = cos(angle) * 2;
    ySpd = sin(angle) * 2;
    
    size = data.missileSize*2;
    
    duration = millis() + 10000;
    
    for(int j = 0; j < 10; j++) move();
    
    movers.add(this);
  }
  
  public void move()
  {
    xPos += xSpd;
    yPos += ySpd;
  }
  
  public void show()
  {
    push();
    translate(xPos+data.xOffset,yPos+data.yOffset);
    //rotate(angle-HALF_PI);
    //if( millis()% 400 < 200 )
    //  scale(-1,1);
    image(skull,0,0);
    pop();
  }
  
  @Override
  public void bounce(Block b)
  {
    if( millis() > duration )
      finished = true;
  }
  
  public boolean checkExpiration()
  {
    return finished;
  }
}

class Bat extends MovingThing implements Danger
{ 
  int seekTimer;
  //int damage;
  
  Bat( Enemy e, int d )
  {
    damage = d;
    
    xPos = e.xPos;
    yPos = e.yPos;
    
    float angle = atan2(robot.yPos-yPos,robot.xPos-xPos)+random(-0.1,0.1);
    
    xSpd = cos(angle) * 2;
    ySpd = sin(angle) * 2;
    
    size = data.missileSize*2;
    
    seekTimer = millis() + 2000;
    
    movers.add(this);
  }
  
  public void move()
  {
    if( seekTimer > millis() )
    {
      float angle = atan2(robot.yPos-yPos,robot.xPos-xPos)+random(-0.1,0.1);
      
      xSpd = cos(angle) * 2;
      ySpd = sin(angle) * 2;
    }
    
    xPos += xSpd;
    yPos += ySpd;
  }
  
  public void show()
  {
    push();
    translate(xPos+data.xOffset,yPos+data.yOffset);
    //rotate(angle-HALF_PI);
    //if( millis()% 400 < 200 )
    //  scale(-1,1);
    image(bat[int(millis()%200/100)],0,0);
    pop();
  }
  
  @Override
  public void bounce(Block b)
  {
    finished = true;
  }
  
  public boolean checkExpiration()
  {
    return finished;
  }
}
