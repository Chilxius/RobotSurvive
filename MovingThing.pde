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
    
    //Expell
    //while( inBlock(b) )
    //{
    //  println("EXPELL");
    //  xPos += xSpd;
    //  yPos += ySpd;
    //}
    if (inBlock(b)) //Used to be a while, seems to work better this way
    {
      if (abs(xPos - b.xPos) > abs(yPos - b.yPos))
        xPos += Math.signum(xSpd);
      else
        yPos += Math.signum(ySpd);
    }
  }
  
  //Taken from ChatGPT
  public void shove(MovingThing m)
  {
    // Compute difference in position
    double dx = m.xPos - xPos;
    double dy = m.yPos - yPos;
    
    // Compute distance between the two centers
    double distance = Math.sqrt(dx * dx + dy * dy);
    
    // Avoid division by zero (in case objects overlap)
    if (distance == 0)
        return;
    
    // Normalize the direction vector (unit vector away from this)
    double nx = dx / distance;
    double ny = dy / distance;
    
    // Apply push along that direction
    double pushStrength = 1.0;  // tweak this constant for effect
    m.xSpd += nx * pushStrength;
    m.ySpd += ny * pushStrength;
  }
  
  public boolean inBlock(Block b)
  {
    double half = data.blockSize / 2.0;
    double myHalf = size / 2.0;
    
    boolean overlapX = !(xPos + myHalf < b.xPos - half || xPos - myHalf > b.xPos + half);
    boolean overlapY = !(yPos + myHalf < b.yPos - half || yPos - myHalf > b.yPos + half);
    
    return overlapX && overlapY;
  }
  
  //Y-coordinant
  public float hitBox()
  {
    if( this instanceof Enemy )
      return yPos+size/3;
    else
      return yPos;
  }
  
  //public boolean inBlock( Block b )
  //{
  //  return ( xPos >= b.xPos-data.blockSize/1.9 && xPos <= b.xPos+data.blockSize/1.9 && yPos >= b.yPos-data.blockSize/1.9 && yPos <= b.yPos+data.blockSize/1.9 );
  //}
  
  public boolean intersects( MovingThing m )
  {
    return ( dist(xPos,hitBox(),m.xPos,m.hitBox()) < (size+m.size)/4 );
  }
  
  public float laserWidth( Robot r )
  {
    if( r.upgrades.get("Wide Laser 2") ) return data.enemyBaseSize*4;
    if( r.upgrades.get("Wide Laser 1") ) return data.enemyBaseSize*2;
    else return data.enemyBaseSize;
  }
  
}
