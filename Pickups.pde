class Pickup extends MovingThing
{
  float angle;
  
  Pickup( Enemy e )
  {
    xPos = e.xPos;
    yPos = e.yPos;
    xSpd = e.xSpd+random(-4,4);
    ySpd = e.ySpd+random(-4,4);
    angle = random(TWO_PI);
    size = data.playerHitBox/2;
    
    movers.add(this);
  }
  
  //public void move()
  //{
  //  float direction = atan2( robot.yPos-yPos, robot.xPos-xPos );
    
  //  if( robot.upgrades.get("Magnet 2") && dist( robot.xPos, robot.yPos, xPos, yPos ) < 500 )
  //  {
  //    xAcc += cos(direction) * .008;
  //    yAcc += sin(direction) * .008;
  //  }
  //  else if( robot.upgrades.get("Magnet 1") && dist( robot.xPos, robot.yPos, xPos, yPos ) < 300 )
  //  {
  //    xAcc += cos(direction) * .005;
  //    yAcc += sin(direction) * .005;
  //  }
  //  else if( dist( robot.xPos, robot.yPos, xPos, yPos ) < 150 )
  //  {
  //    xAcc += cos(direction) * .003;
  //    yAcc += sin(direction) * .003;
  //  }
    
  //  xSpd += xAcc;
  //  ySpd += yAcc;
    
  //  xPos += xSpd;
  //  yPos += ySpd;
    
  //  xAcc *= 0.95;
  //  yAcc *= 0.95;
  //  xSpd *= 0.85;
  //  ySpd *= 0.85;
  //}
  
  //Edited AI solution - short on time
  float magnetTimer;
  public void move()
  {
    float direction = atan2(robot.yPos - yPos, robot.xPos - xPos);
    float distance = dist(robot.xPos, robot.yPos, xPos, yPos);

    boolean inRange = false;
    float baseAccel = 0;

    if (robot.upgrades.get("Magnet 2") && distance < 800)
    {
        inRange = true;
        //baseAccel = 0.004;
        baseAccel = (850-distance)/40000;
    }
    else if (robot.upgrades.get("Magnet 1") && distance < 400)
    {
        inRange = true;
        //baseAccel = 0.003;
        baseAccel = (550-distance)/40000;
    }
    else if (distance < 150)
    {
        inRange = true;
        //baseAccel = 0.002;
        baseAccel = (350-distance)/40000;
    }

    // Gradual buildup while in range
    if (inRange)
    {
        magnetTimer = min(magnetTimer + 1, 120);  // cap to ~2 seconds at 60 fps
    }
    else
    {
        magnetTimer = max(magnetTimer - 2, 0);    // decay faster when out of range
    }

    // Scale the pull strength using the timer (smooth acceleration curve)
    float speedMultiplier = 1 + (magnetTimer / 120.0);  // 1× to 2× pull over 2 s
    float accel = baseAccel * speedMultiplier;

    xAcc += cos(direction) * accel;
    yAcc += sin(direction) * accel;

    xSpd += xAcc;
    ySpd += yAcc;

    xPos += xSpd;
    yPos += ySpd;

    xAcc *= 0.95;
    yAcc *= 0.95;
    xSpd *= 0.85;
    ySpd *= 0.85;
  }

  @Override
  public void bounce(Block b)
  {
    /*Ignore Walls*/
  }
  
  public void show()
  {
    push();
    translate(xPos+data.xOffset,yPos+data.yOffset);
    rotate(angle);
    image(floppy,0,0);
    pop();
  }
  
  public boolean checkExpiration()
  {
    return finished;
  }
}
