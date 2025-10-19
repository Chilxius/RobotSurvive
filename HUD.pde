class HUD
{
  TurnGuide guide = new TurnGuide(80,height-80,robot);
  
  String upgradeString;
  
  int installBoxOffset = -55;
  boolean installBoxOpening = false;
  
  int commsBoxOffset = -height;
  boolean commsBoxOpening = false;
  String [] commsBoxText;
  String currentText = ""; //For displaying text
  int currentIndex;        //one character at a time.
  int nextLetterTime;
  
  HUD()
  {
    commsBoxText = createConversations();
  }
  
  public void display( boolean commsBox )
  {
    //Show commsBox
    if(commsBox)
      drawCommsBox();
    
    //Show turning guide
    if(!commsBox)
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
    
    //Install Box
    drawInstallBox();
  }
  
  private void drawInstallBox()
  {
    if( installBoxOpening )
    {
      if( installBoxOffset >= 0 )
        installBoxOpening = false;
      else
        installBoxOffset++;
    }
    
    String installString = upgradeString + ": INSTALLED";
    float textLength = 10+18.75*installString.length();
    push();
    
    rectMode(CENTER);
    stroke(100);
    fill(170);
    strokeWeight(3);
    beginShape();
    vertex( width*2/3 - textLength/2 - 50, -10+installBoxOffset );
    vertex( width*2/3 - textLength/2,       50+installBoxOffset );
    vertex( width*2/3 + textLength/2,       50+installBoxOffset );
    vertex( width*2/3 + textLength/2 + 50, -10+installBoxOffset );
    endShape();
    
    textAlign(CENTER);
    fill(0);
    textSize(30);
    text( installString, width*2/3, 30+installBoxOffset );
    
    pop();
  }
  
  private void drawCommsBox()
  {
    if( commsBoxOpening )
    {
      if( commsBoxOffset >= 0 )
        commsBoxOpening = false;
      else
        commsBoxOffset+=5;
    }
    
    push();
    
    stroke(100);
    fill(130);
    strokeWeight(5);
    rectMode(CORNER);
    
    //Background
    rect(-10,-10+commsBoxOffset,810,height+10);
    
    //Video Screen decoration
    fill(170);
    strokeWeight(3);
    beginShape();
    vertex(0,  500+commsBoxOffset);
    vertex(430,500+commsBoxOffset);
    vertex(430,120+commsBoxOffset);
    vertex(550,0+commsBoxOffset);
    vertex(0, 0);
    endShape();
    
    //Video Screen
    strokeWeight(5);
    fill(0);
    rect(30,100+commsBoxOffset,370,370);
    if(!commsBoxOpening)
    {
      push();
      translate(215,(100+commsBoxOffset)+370/2);
      rotate(millis()%4*HALF_PI);
      image(staticPic,0,0);
      pop();
    }
    
    //Text Box decoration
    strokeWeight(3);
    fill(170);
    beginShape();
    vertex(-10, 530+commsBoxOffset);
    vertex(750, 530+commsBoxOffset);
    vertex(800, 480+commsBoxOffset);
    vertex(800, height+commsBoxOffset);
    vertex(-10, height+commsBoxOffset);

    endShape();
    
    //Text Box
    strokeWeight(5);
    fill(0,20,0);
    rect(0,550+commsBoxOffset,770,height-550);
    pop();
    
    //Display text
    push();
    textSize(50);
    fill(50,200,50,200);
    textAlign(LEFT);
    rectMode(CORNER);
    if(!commsBoxOpening)
    {
      if( currentIndex < commsBoxText[0].length() && millis() > nextLetterTime )
      {
        nextLetterTime = millis() + 50; //Time between letters
        currentText += commsBoxText[0].charAt(currentIndex++);
      }
      text(currentText, 20, 570+commsBoxOffset, 750,1000);
    }
    pop();
  }
  
  private void drawPickupCounter()
  {
    push();
    stroke(100);
    fill(170);
    strokeWeight(5);
    rectMode(CORNER);
    rect(width+20,0,-193,50,20);
    image(floppy,width-25,25);
    textAlign(RIGHT);
    textSize(30);
    fill(0);
    //text(robot.cash + " :",width-53,33);
    text(8888 + " :",width-53,33);
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
  
  private String[] createConversations()
  {
    return new String[]
    {
      "This is the first test output string. These words should fill up the box until the string is finished. Buy Robots vs Vampires from your local Blockbuster today!",
      "Second string"
    };
  }
}
