class GameOver
{
  PImage endPic;
  boolean over;
  
  int fadeIn;
  
  GameOver()
  {
    save("gameOver.png");
    endPic = loadImage("gameOver.png");
    over = true;
    fadeIn = -255;
    manager.goToBreakdown();
  }
  
  public void show()
  {
    push();
    background(255);
    tint(150,250,150,200);
    image(endPic,width/2,height/2);
    noTint();
    fill(50,200,50,fadeIn);
    textSize(200);
    textAlign(CENTER);
    text("BREAKDOWN", width/2, height/3);
    if( continues > 0 && fadeIn >= 250 )
    {
      textSize(100);
      text("Spare Chassis:",width/2,height*2/3);
      for(int i = 0; i < continues; i++)
        image(token,(width/6)*(i+2),height*2/3+100);
    }
    pop();
    
    if(fadeIn < 250)
      fadeIn++;
  }
  
  public void tryAgain()
  {
    if( continues <= 0 || fadeIn < 250 ) return;
    
    continues--;
    
    over = false;
    clearMovers();
    map = new Map(map.level);
    robot.xPos = map.startingPoint('x');
    robot.yPos = map.startingPoint('y');
    robot.armor = robot.getMaxArmor();
    robot.bumpX = robot.bumpY = 0;
    map.initialSpawn();
    manager.goToSurvival();
  }
}
