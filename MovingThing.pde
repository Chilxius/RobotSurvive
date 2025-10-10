public abstract class MovingThing
{
  float xPos, yPos;
  float xSpd, ySpd;
  float xAcc, yAcc;
  float size;
  
  abstract public void move();
  abstract public void show();
  
  public void bounce( Block b )
  {
    //Go back a step to avoid phasing through the block partially before
    //  determining direction of bounce
    xPos -= xSpd;
    yPos -= ySpd;
    
    if(abs(xPos - b.xPos) > abs(yPos - b.yPos)) //horizontal
      xSpd = -xSpd;
    else if(abs(xPos - b.xPos) < abs(yPos - b.yPos)) //vertical
      ySpd = -ySpd;
    else
    {
      xSpd = -xSpd;
      ySpd = -ySpd;
    }
    
 
  }
}

class TestBall extends MovingThing
{
  public void move()
  {
    xPos += xSpd;
    yPos += ySpd;
  }
  
  public void show()
  {
    circle(xPos, yPos, size);
  }
}
