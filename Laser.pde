//class Laser
//{
//  Leader lead;
  
//  Laser(Robot r)
//  {
//    lead = new Leader(r);

//  }
//}

class Laser extends MovingThing
{
  int steps;
  color lazColor;
  
  Laser( Robot r )
  {
    //Range changes with upgrades
    steps = stepCount(r);
    
    lazColor = color(random(255),random(255),random(255));
    
    xPos = r.xPos;
    yPos = r.yPos;
      
    xSpd = cos(r.angle);// * data.enemyBaseSize/2;
    ySpd = sin(r.angle);// * data.enemyBaseSize/2;
    
    size = laserWidth(r);
    
    measure();
    
    movers.add(this);
  }
  
  private int stepCount( Robot r )
  {
    if( r.upgrades.get("Extended Laser 2") ) return int(data.blockSize)*20;
    if( r.upgrades.get("Extended Laser 1") ) return int(data.blockSize)*10;
    else return int(data.blockSize)*5;
  }
  
  public void measure()
  {
    int i = 0;
    float oX = robot.xPos + robot.xSpd*50;
    float oY = robot.yPos + robot.ySpd*50;;
    
    for(; i < steps; i++)
    {
      xPos += xSpd;
      yPos += ySpd;
      
      //TODO: check for hit
      if( intersects(testEnemy) )
      {
        new Remnant(xPos,yPos); //Creates impact explosion
        break;
      }
      if( testMap.intersectingBlock(this)!= null )
      {
        if( robot.upgrades.get("Bouncing Laser") )
        {
          new Remnant(this,oX,oY);//,lazColor);
          oX = xPos;
          oY = yPos;
          bounce( testMap.intersectingBlock(this) );
        }
        else
        {
          new Remnant(xPos,yPos);
          break;
        }
      }
    }
    
    //create remnant
    finished = true;
    new Remnant(this,oX,oY);//,lazColor); //creates beam
  }
  
  public void move(){/*Does not move*/}
  
  public void show(){/*Not visible*/}
  
  public boolean checkExpiration()
  {
    
    return false;
  }
}
