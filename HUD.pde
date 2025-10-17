class HUD
{
  TurnGuide guide = new TurnGuide(80,height-80,robot);
  
  public void display( boolean commsBox )
  {
    //Show commsBox
    if(commsBox)
      drawCommsBox();
      
    guide.display();
    //Draw Upgrades
    drawUpgradeBar(UpgradeCategory.MOVEMENT,0);
    drawUpgradeBar(UpgradeCategory.DEFENSE, 1);
    drawUpgradeBar(UpgradeCategory.LASER,   2);
    drawUpgradeBar(UpgradeCategory.MISSILE, 3);
    drawUpgradeBar(UpgradeCategory.DISC,    4);
    
    //Draw health
    drawArmorBar();
    
    //Show name
    drawNameBar();
    
    //Show pickups
    drawPickupCounter();
  }
  
  private void drawCommsBox()
  {
    push();
    
    stroke(100);
    fill(170);
    strokeWeight(5);
    rectMode(CORNER);
    
    rect(-10,0,700,850);
    
    pop();
  }
  
  private void drawPickupCounter()
  {
    push();
    stroke(100);
    fill(170);
    strokeWeight(5);
    rectMode(CORNER);
    rect(width+20,0,-190,50,20);
    image(floppy,width-25,25);
    textAlign(RIGHT);
    textSize(30);
    fill(0);
    text(robot.cash + " :",width-50,33);
    pop();
  }
  
  private void drawNameBar()
  {
    push();
    float nameLength = 10+18.75*robot.fullName.length();
    strokeWeight(3);
    stroke(100);
    fill(170);
    beginShape();
    vertex(width+10,height-50);
    vertex(width-10-nameLength,height-50);
    vertex(width-90-nameLength,height+10);
    vertex(width+10,height+10);
    endShape();
    
    textAlign(RIGHT);
    textSize(30);
    fill(0);
    text(robot.fullName,width-20,height-17);
    pop();
  }
  
  private void drawArmorBar()
  {
    push();
    
    stroke(100);
    rectMode(CORNER);
    
    strokeWeight(3);
    fill(170);
    beginShape();
    vertex(-10,70);
    vertex(620,70);
    vertex(700,-10);
    vertex(-10,-10);
    endShape();
    
    float barWidth = 600.0/robot.getMaxArmor();
    strokeWeight(2);
    fill(0);
    rect(10,10,600,50);
    fill(150);
    for( int i = 0; i < robot.armor; i++ )
    {
      rect(10+i*barWidth,10,barWidth,50);
    }
    
    pop();
  }
  
  private void drawUpgradeBar( UpgradeCategory type, int level )
  {
    //First part of this would be better permanently stored - will do if I need to improve efficientcy
    ArrayList<PImage> icons = new ArrayList<PImage>();
    
    for( String str: robot.upgrades.keySet() )
      if( robot.upgrades.get(str) && type == categoryByName(str) )
        icons.add( upgradeImages.get(str) );
    
    push();
    stroke(100);
    strokeWeight(5);
    fill(colorByCategory(type));
    rectMode(CORNER);
    rect(width+20,50+50*level,-25-50*icons.size(),50,20);
    for( int i = 0; i < icons.size(); i++ )
      image( icons.get(i), width-25-50*i, 75+50*level, 45,45);
    pop();
  }
}
