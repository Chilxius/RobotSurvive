class Title
{
  float titleStartTimer;
  int textIndex = 0;
  int textTimer;
  boolean flashPrompt;
  
  String grnText;
  String redText;
  
  public Title()
  {
    titleStartTimer = 1000;
    buildStrings();
  }
  
  public void display()
  {
    background(0,20,0);
    if(titleStartTimer>0)
      drawTitle();
    else
      drawText();
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
  
  private void drawText()
  {
    drawLeftText();
    drawRightText();
    advanceText();
    
    if(flashPrompt)
      drawPromptText();
  }
  
  private void advanceText()
  {
    if(textIndex < grnText.length() && textTimer < millis() )
    {
      textTimer = millis() + 50;
      textIndex++;
    }
    
    if( !flashPrompt && textIndex >= grnText.length() )
      flashPrompt = true;
  }
  
  private void drawLeftText()
  {
    push();
    textSize(75);
    fill(50,200,50,200);
    textAlign(LEFT);
    rectMode(CORNER);
    text(grnText.substring(0,textIndex),50,100);
    pop();
  }
  
  private void drawRightText()
  {
    push();
    textSize(75);
    fill(200,50,50,200);
    textAlign(LEFT);
    rectMode(CORNER);
    text(redText.substring(0,textIndex),350,100);
    pop();
  }
  
  private void drawPromptText()
  {
    push();
    textSize(100);
    fill(50,200,50,200);
    textAlign(CENTER);
    
    if( millis()%1000 < 500 )
      text("PRESS TO BRING ONLINE", width/2, height-50);
    
    pop();
  }
  
  public void pressReact()
  {
    if(titleStartTimer <= 0)
      manager.goToSurvival();
  }
  
  private void buildStrings()
  {
    grnText = "Device Identifier: "+robot.getLongName() + "\n"+
              "Bringing Online . . . \n"+
              "> Advanced AI:              \n"+
              "> Disintegrator:            \n"+
              "> Plasma Cannon:            \n"+
              "> Targeting System:         \n"+
              "> Modular Equip:        <ACTIVE> \n"+
              "> Advanced Motility:        \n"+
              "> Navigation:             <ACTIVE> \n"+
              "> Brakes:                   \n            ";
    redText = "                   ";
    for(int i = 0; i < robot.getLongName().length();i++) redText+=" ";
    redText +="\n"+
              "                      \n"+
              "                         <ERROR>\n"+
              "                         <ERROR>\n"+
              "                         <ERROR>\n"+
              "                         <ERROR>\n"+
              "                            \n"+
              "                         <ERROR>\n"+
              "                            \n"+
              "                         <ERROR> ";
  }
}
