class GhostWords
{
  float xPos, yPos;
  int timer;
  int size;
  String words;
  color col;
  
  GhostWords( String s, float x, float y )
  {
    words = s;
    xPos = x;
    yPos = y;
    size = 75;
    timer = millis()+2000;
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
    text( words, xPos+data.xOffset, yPos+data.yOffset );
    yPos-=0.1;
  }
}
