class TurnGuide
{
  float xPos, yPos;
  float angle;
  Robot r;
  
  TurnGuide( float x, float y, Robot r )
  {
    xPos = x;
    yPos = y;
    this.r = r;
  }
  
  public void display()
  {
    push();
    
    translate(xPos,yPos);
    fill(150);
    stroke(100);
    strokeWeight(5);
    circle(0,0,160);
    rotate(angle);
    if( robot.turningClockwise )
    {
      fill(200,0,0);
      angle += robot.adjustedAngleSpeed();
    }
    else
    {
      fill(0,0,200);
      angle -= robot.adjustedAngleSpeed();
    }
    
    noStroke();
    for(int i = 0; i < 13; i++)
    {
      if( robot.turningClockwise )
        rotate( -0.015*7 );
      else
        rotate( 0.015*7 );
        
      circle(50+i,0,30-i*2);
      circle(-50-i,0,30-i*2);
    }
    
    pop();
  }
}
