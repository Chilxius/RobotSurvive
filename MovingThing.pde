public abstract class MovingThing
{
  float xPos, yPos;
  float xSpd, ySpd;
  float xAcc, yAcc;
  float size;
  
  boolean finished;
  
  abstract public void move();
  abstract public void show();
  abstract public boolean checkExpiration(); //May not need to be boolean anymore
  
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
  
  public boolean intersects( MovingThing m )
  {
    return ( dist(xPos,yPos,m.xPos,m.yPos) < (size+m.size)/4 );
  }
  
  public float laserWidth( Robot r )
  {
    if( r.upgrades.get("Wide Laser 2") ) return data.enemyBaseSize*4;
    if( r.upgrades.get("Wide Laser 1") ) return data.enemyBaseSize*2;
    else return data.enemyBaseSize;
  }
  
}
