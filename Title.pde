class Title
{
  float titleStartTimer;
  
  public Title()
  {
    titleStartTimer = 1000;
  }
  
  public void display()
  {
    drawTitle();
  }
  
  private void drawTitle()
  {
    push();
    tint(255,titleStartTimer);
    image(titlePic,width/2,height/2);
    pop();
    
    if( titleStartTimer > 0 )
      titleStartTimer-=4;
  }
  
  public void pressReact()
  {
    if(titleStartTimer <= 0)
      manager.goToSurvival();
  }
}
