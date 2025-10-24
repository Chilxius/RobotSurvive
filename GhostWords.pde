class GhostWords
{
  float xPos, yPos;
  int timer;
  int size;
  String words;
  color col;
  boolean isText;
  
  GhostWords( String s, float x, float y )
  {
    isText = true;
    words = s;
    xPos = x;
    yPos = y;
    size = 75;
    timer = millis()+2500;
    col = color(255);
    
    ghostWords.add(this);
  }
  
  GhostWords( int i, float x, float y )
  {
    words = ""+i;
    xPos = x + random(-data.enemyBaseSize/3,data.enemyBaseSize/3);
    yPos = y + random(-data.enemyBaseSize/3,data.enemyBaseSize/3);
    size = 50;
    timer = millis()+1000;
    col = color(255);
    
    ghostWords.add(this);
  }
  
  public void show()
  {
    fill(col);
    textSize(size);
    textAlign(CENTER);
    if(isText)
      text( words, xPos, yPos );
    else
      text( words, xPos+data.xOffset, yPos+data.yOffset );
    yPos-=0.1;
  }
  
  public void checkForFollowup()
  {
    if( words.equals("Hold to Turn") )
      ghostWords.add( new GhostWords("Direction Changes With Each Turn",width/2,height-100) );
    if( words.equals("Press to Slow Wheel") )
      ghostWords.add( new GhostWords("Hold to Grab Wheel", width*2/3,height-100) );
  }
}
