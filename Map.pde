//Minimum map size is 2x2 chunks. Size will increase for every two levels

class Map
{
  int level;
  int mapSize;
  Chunk [][] chunkGrid;// = new Chunk[mapSize][mapSize];
  
  //For how often rooms expand (0.0 to 1.0)
  //Should be kept to 0.45 or below to prevent long recursion
  float openness = 0.25;
  
  color wallColor = color( random(255), random(255), random(255) );
  
  //For exit
  float exitX, exitY;
  boolean exiting;
  float fade;
  
  Map( int l )
  {
    level = l;
    mapSize = level/2+2;
    chunkGrid = new Chunk[mapSize][mapSize];
    
    for( int i = 0; i < mapSize; i++ )
      for( int j = 0; j < mapSize; j++ )
        chunkGrid[i][j] = new Chunk(i,j);
        
    createRooms();
    createLegalPath();
    fillClosedRooms();
    addCaps();
    createExit();
  }
  
  private void createRooms()
  {
    for( int i = 0; i < mapSize; i++ )
      for( int j = 0; j < mapSize; j++ )
      {
        //Ignore already visited chunks
        if(chunkGrid[i][j].visited) continue;
        chunkGrid[i][j].visited = true;
        
        //Chance to spread
        if( random(1) < openness )
        {
          //Chance to create large room (spread to the S, SE, and E blocks)
          if( random(1) < openness )
          {
            addBigRoom(i,j);
          }
          //Regular spread (to one adjacent block)
          else
          {
            spread(i,j);
            addDoor(i,j);
          }
        }
      }
  }
  
  public void addCaps()
  {
    for( int i = 0; i < mapSize; i++ )
      for( int j = 0; j < mapSize; j++ )
        chunkGrid[i][j].addCaps();
  }
  
  private void createExit()
  {
    chunkGrid[mapSize-1][0].blockGrid[3][3].state = BlockState.EXIT;
    chunkGrid[mapSize-1][0].blockGrid[3][4].state = BlockState.EXIT;
    chunkGrid[mapSize-1][0].blockGrid[4][3].state = BlockState.EXIT;
    chunkGrid[mapSize-1][0].blockGrid[4][4].state = BlockState.EXIT;
    
    exitX = chunkGrid[mapSize-1][0].blockGrid[3][3].xPos+data.blockSize/2;
    exitY = chunkGrid[mapSize-1][0].blockGrid[3][3].yPos+data.blockSize/2;
    
    exiting = false;
    fade = 0;
  }
  
  private void spread(int x, int y)
  {
    int dir = -1;
    //Check all four directions until an option is found, starting with random direction
    for( int i = 0, next = int(random(4)); i < 4; i++, next=(next+1)%4 ) // 0-UP, 1-RIGHT, 2-DOWN, 3-LEFT
    {
      if(( next == 0 && y > 0         && !chunkGrid[x][y-1].visited )
      || ( next == 1 && x < mapSize-1 && !chunkGrid[x+1][y].visited )
      || ( next == 2 && y < mapSize-1 && !chunkGrid[x][y+1].visited )
      || ( next == 3 && x > 0         && !chunkGrid[x-1][y].visited ) )
      {
        dir = next;
        break;
      }
    }
    
    //No valid direction
    if( dir == -1 ) return;
    
    addDoor(x,y,directionString(dir),true);
    if( dir == 0 ) spreadToRoom( x, y-1 );
    if( dir == 1 ) spreadToRoom( x+1, y );
    if( dir == 2 ) spreadToRoom( x, y+1 );
    if( dir == 3 ) spreadToRoom( x-1, y );
  }
  
  private void spreadToRoom( int x, int y )
  {
    if(chunkGrid[x][y].visited) return;
    
    chunkGrid[x][y].visited = true;
    if( random(1) < openness*2 )
    {
      spread( x,y );
    }
    else
    {
      addDoor(x,y);
    }
  }
  
  private void addBigRoom(int x, int y)
  {
    //Don't build off the map
    if( x == mapSize-1 || y == mapSize-1 ) return;
    
    addDoor(x,y,"RIGHT",true);
    addDoor(x+1,y,"DOWN",true);
    addDoor(x+1,y+1,"LEFT",true);
    addDoor(x,y+1,"UP",true);
    chunkGrid[x][y].blockGrid[7][7].state = BlockState.DOOR;
    chunkGrid[x+1][y].blockGrid[0][7].state = BlockState.DOOR;
    chunkGrid[x][y+1].blockGrid[7][0].state = BlockState.DOOR;
    chunkGrid[x+1][y+1].blockGrid[0][0].state = BlockState.DOOR;
  }
  
  //Creates a legal path from the bottom left to the top right
  private void createLegalPath()
  {
    //Number of steps required to cross grid
    int steps = mapSize*2-2;
    
    //Divide steps into right and up steps
    int ups = steps/2;
    int overs = steps/2;
    
    int currentX = 0, currentY = mapSize-1;
    
    while( ups > 0 || overs > 0 )
    {
      int choice = int(random(10));
      if( choice < 4 && overs > 0 && currentX < mapSize-1 )
      {
        if(addDoor(currentX,currentY,"Right",false))
        {
          overs--;
          currentX++;
        }
      }
      else if( choice > 3 && choice < 8 && ups > 0 && currentY > 0 )
      {
        if( addDoor(currentX,currentY,"UP",false) )
        {
          ups--;
          currentY--;
        }
      }
      else if( choice == 8 && currentX > 0 )
      {
        if( addDoor(currentX,currentY,"LEFT",false) )
        {
          overs++;
          currentX--;
        }
      }
      else if( choice == 9 && currentY < mapSize-1 )
      {
        if( addDoor(currentX,currentY,"DOWN",false) )
        {
          ups++;
          currentY++;
        }
      }
    }
  }
  
  private void addDoor(int x, int y)
  {
    int dir = -1;
    if (x < 0 || y < 0 || x >= mapSize || y >= mapSize) return;
    
    //Check all four directions until an option is found, starting with random direction
    for( int i = 0, next = int(random(4)); i < 4; i++, next++ ) // 0-UP, 1-RIGHT, 2-DOWN, 3-LEFT
    {
      if( ( next%4 == 0 && y > 0         && chunkGrid[x][y-1].blockGrid[3][7].state != BlockState.DOOR )
        ||( next%4 == 1 && x < mapSize-1 && chunkGrid[x+1][y].blockGrid[0][3].state != BlockState.DOOR )
        ||( next%4 == 2 && y < mapSize-1 && chunkGrid[x][y+1].blockGrid[3][0].state != BlockState.DOOR )
        ||( next%4 == 3 && x > 0         && chunkGrid[x-1][y].blockGrid[7][3].state != BlockState.DOOR ) )
      {
        dir = next%4;
        break;
      }
    }
    
    //Add door in given direction
    switch(dir)
    {
      case -1:return; //No available options
      
      case 0:
        chunkGrid[x][y].blockGrid[3][0].state = BlockState.DOOR;
        chunkGrid[x][y].blockGrid[4][0].state = BlockState.DOOR;
        chunkGrid[x][y-1].blockGrid[3][7].state = BlockState.DOOR;
        chunkGrid[x][y-1].blockGrid[4][7].state = BlockState.DOOR;
        break;
        
      case 1:
        chunkGrid[x][y].blockGrid[7][3].state = BlockState.DOOR;
        chunkGrid[x][y].blockGrid[7][4].state = BlockState.DOOR;
        chunkGrid[x+1][y].blockGrid[0][3].state = BlockState.DOOR;
        chunkGrid[x+1][y].blockGrid[0][4].state = BlockState.DOOR;
        break;
      
      case 2:
        chunkGrid[x][y].blockGrid[3][7].state = BlockState.DOOR;
        chunkGrid[x][y].blockGrid[4][7].state = BlockState.DOOR;
        chunkGrid[x][y+1].blockGrid[3][0].state = BlockState.DOOR;
        chunkGrid[x][y+1].blockGrid[4][0].state = BlockState.DOOR;
        break;
      
      case 3:
        chunkGrid[x][y].blockGrid[0][3].state = BlockState.DOOR;
        chunkGrid[x][y].blockGrid[0][4].state = BlockState.DOOR;
        chunkGrid[x-1][y].blockGrid[7][3].state = BlockState.DOOR;
        chunkGrid[x-1][y].blockGrid[7][4].state = BlockState.DOOR;
        break;
    }
  }
  
  private boolean addDoor( int x, int y, String direction, boolean big )
  {
    //This appears to have been an issue - stopped having issues once this was added
    if (x < 0 || y < 0 || x >= mapSize || y >= mapSize) return false;
    
    switch(direction.toUpperCase())
    {
      case "UP":
        if(y==0) return false;
        chunkGrid[x][y].blockGrid[3][0].state = BlockState.DOOR;
        chunkGrid[x][y].blockGrid[4][0].state = BlockState.DOOR;
        chunkGrid[x][y-1].blockGrid[3][7].state = BlockState.DOOR;
        chunkGrid[x][y-1].blockGrid[4][7].state = BlockState.DOOR;
        if(big)
        {
          chunkGrid[x][y].blockGrid[1][0].state = BlockState.DOOR;
          chunkGrid[x][y].blockGrid[2][0].state = BlockState.DOOR;
          chunkGrid[x][y].blockGrid[5][0].state = BlockState.DOOR;
          chunkGrid[x][y].blockGrid[6][0].state = BlockState.DOOR;
          chunkGrid[x][y-1].blockGrid[1][7].state = BlockState.DOOR;
          chunkGrid[x][y-1].blockGrid[2][7].state = BlockState.DOOR;
          chunkGrid[x][y-1].blockGrid[5][7].state = BlockState.DOOR;
          chunkGrid[x][y-1].blockGrid[6][7].state = BlockState.DOOR;
        }
        break;
        
      case "RIGHT":
        if(x==mapSize-1) return false;
        chunkGrid[x][y].blockGrid[7][3].state = BlockState.DOOR;
        chunkGrid[x][y].blockGrid[7][4].state = BlockState.DOOR;
        chunkGrid[x+1][y].blockGrid[0][3].state = BlockState.DOOR;
        chunkGrid[x+1][y].blockGrid[0][4].state = BlockState.DOOR;
        if(big)
        {
          chunkGrid[x][y].blockGrid[7][1].state = BlockState.DOOR;
          chunkGrid[x][y].blockGrid[7][2].state = BlockState.DOOR;
          chunkGrid[x][y].blockGrid[7][5].state = BlockState.DOOR;
          chunkGrid[x][y].blockGrid[7][6].state = BlockState.DOOR;
          chunkGrid[x+1][y].blockGrid[0][1].state = BlockState.DOOR;
          chunkGrid[x+1][y].blockGrid[0][2].state = BlockState.DOOR;
          chunkGrid[x+1][y].blockGrid[0][5].state = BlockState.DOOR;
          chunkGrid[x+1][y].blockGrid[0][6].state = BlockState.DOOR;
        }
        break;
      
      case "DOWN":
        if( y == mapSize-1 ) return false;
        chunkGrid[x][y].blockGrid[3][7].state = BlockState.DOOR;
        chunkGrid[x][y].blockGrid[4][7].state = BlockState.DOOR;
        chunkGrid[x][y+1].blockGrid[3][0].state = BlockState.DOOR;
        chunkGrid[x][y+1].blockGrid[4][0].state = BlockState.DOOR;
        if(big)
        {
          chunkGrid[x][y].blockGrid[1][7].state = BlockState.DOOR;
          chunkGrid[x][y].blockGrid[2][7].state = BlockState.DOOR;
          chunkGrid[x][y].blockGrid[5][7].state = BlockState.DOOR;
          chunkGrid[x][y].blockGrid[6][7].state = BlockState.DOOR;
          chunkGrid[x][y+1].blockGrid[1][0].state = BlockState.DOOR;
          chunkGrid[x][y+1].blockGrid[2][0].state = BlockState.DOOR;
          chunkGrid[x][y+1].blockGrid[5][0].state = BlockState.DOOR;
          chunkGrid[x][y+1].blockGrid[6][0].state = BlockState.DOOR;
        }
        break;
      
      case "LEFT":
        if(x==0) return false;
        chunkGrid[x][y].blockGrid[0][3].state = BlockState.DOOR;
        chunkGrid[x][y].blockGrid[0][4].state = BlockState.DOOR;
        chunkGrid[x-1][y].blockGrid[7][3].state = BlockState.DOOR;
        chunkGrid[x-1][y].blockGrid[7][4].state = BlockState.DOOR;
        if(big)
        {
          chunkGrid[x][y].blockGrid[0][1].state = BlockState.DOOR;
          chunkGrid[x][y].blockGrid[0][2].state = BlockState.DOOR;
          chunkGrid[x][y].blockGrid[0][5].state = BlockState.DOOR;
          chunkGrid[x][y].blockGrid[0][6].state = BlockState.DOOR;
          chunkGrid[x-1][y].blockGrid[7][1].state = BlockState.DOOR;
          chunkGrid[x-1][y].blockGrid[7][2].state = BlockState.DOOR;
          chunkGrid[x-1][y].blockGrid[7][5].state = BlockState.DOOR;
          chunkGrid[x-1][y].blockGrid[7][6].state = BlockState.DOOR;
        }
        break;
    }
    return true;
  }
  
  private void fillClosedRooms()
  {
    for( int i = 0; i < mapSize; i++ )
      for( int j = 0; j < mapSize; j++ )
      {
        if( chunkGrid[i][j].blockGrid[0][3].state == BlockState.SOLID
        &&  chunkGrid[i][j].blockGrid[7][3].state == BlockState.SOLID
        &&  chunkGrid[i][j].blockGrid[3][0].state == BlockState.SOLID
        &&  chunkGrid[i][j].blockGrid[3][7].state == BlockState.SOLID )
        {
          for( int k = 0; k < 8; k++ )
            for( int l = 0; l < 8; l++ )
              chunkGrid[i][j].blockGrid[k][l].state = BlockState.NONE;
        }
      }
  }
  
  private String directionString( int d )
  {
    switch(d)
    {
      case 0:  return "UP";
      case 1:  return "RIGHT";
      case 2:  return "DOWN";
      default: return "LEFT";
    }
  }
  
  public void drawBlocks( MovingThing m, boolean overlay )
  {
    if(!overlay)
      drawBackgroundBlocks();
    
    for( int i = 0; i < mapSize; i++ )
      for( int j = 0; j < mapSize; j++ )
        chunkGrid[i][j].drawBlocks(m,wallColor,overlay);
    //circle(exitX+data.xOffset,exitY+data.yOffset,data.blockSize);
  }
  
  private void drawBackgroundBlocks()
  {
    image(girder,exitX-data.blockSize/2+data.xOffset,exitY-data.blockSize/2+data.yOffset);
    image(girder,exitX+data.blockSize/2+data.xOffset,exitY-data.blockSize/2+data.yOffset);
  }
  
  public Block intersectingBlock( MovingThing m )
  {       
    for( int i = 0; i < chunkGrid.length; i++ )
      for( int j = 0; j < chunkGrid[0].length; j++ )
        for( int k = 0; k < 8; k++ )
          for( int l = 0; l < 8; l++ )
            if( chunkGrid[i][j].blockGrid[k][l].state == BlockState.SOLID && chunkGrid[i][j].blockGrid[k][l].intersects(m) )
              return chunkGrid[i][j].blockGrid[k][l];
    
    return null;
  }
  
  public float startingPoint( char dimension )
  {
    if( dimension == 'x' )
      return chunkGrid[0][mapSize-1].blockGrid[3][4].xPos;
    if( dimension == 'y' )
      return chunkGrid[0][mapSize-1].blockGrid[3][4].yPos;
    return 0;
  }
  
  public void lowerExit()
  {
    chunkGrid[mapSize-1][0].blockGrid[3][3].yPos++;
    chunkGrid[mapSize-1][0].blockGrid[3][4].yPos++;
    chunkGrid[mapSize-1][0].blockGrid[4][3].yPos++;
    chunkGrid[mapSize-1][0].blockGrid[4][4].yPos++;
    
    image(tile,chunkGrid[mapSize-1][0].blockGrid[3][5].xPos+data.xOffset,chunkGrid[mapSize-1][0].blockGrid[3][5].yPos+data.yOffset);
    image(tile,chunkGrid[mapSize-1][0].blockGrid[4][5].xPos+data.xOffset,chunkGrid[mapSize-1][0].blockGrid[4][5].yPos+data.yOffset);
    
    testBot.yPos++;
    
    fade+= 255/data.blockSize;
    
    push();
    fill(0,fade);
    rect(width/2,height/2,width,height);
    pop();
  }
}

//**********************
//Collection of Blocks
class Chunk
{
  Block [][] blockGrid = new Block[8][8];
  boolean visited; //for creating rooms
  
  Chunk( int x, int y )
  {
    for( int i = 0; i < 8; i++ )
      for( int j = 0; j < 8; j++ )
        blockGrid[i][j] = new Block( i==0 || j==0 || i == 7 || j == 7, x*data.blockSize*8+i*data.blockSize, y*data.blockSize*8+j*data.blockSize );
  }
  
  public void drawBlocks(MovingThing m, color c, boolean overlay)// int x, int y )
  {
    for( int i = 0; i < 8; i++ )
      for( int j = 0; j < 8; j++ )
        blockGrid[i][j].drawBlock(m,c,overlay);//x,y,i,j);
  }
  
  private void addCaps()
  {
    for( int i = 0; i < 8; i++ )
      for( int j = 1; j < 8; j++ )
        if( hasCap(i,j) )
          blockGrid[i][j].addCap();// = new Block( i==0 || j==0 || i == 7 || j == 7, x*data.blockSize*8+i*data.blockSize, y*data.blockSize*8+j*data.blockSize );
  }
  
  private boolean hasCap(int i, int j)
  {
    if( blockGrid[i][j].state == BlockState.SOLID && blockGrid[i][j-1].state != BlockState.SOLID )
      return true;
    return false; 
  }
}

//**********************
//Individual wall pieces
class Block
{
  BlockState state;
  
  float xPos, yPos;
  
  int decoration = -1;
  boolean hasCap;
  
  public Block( boolean wall, float x, float y )
  {
    if( wall ) state = BlockState.SOLID;
    else state = BlockState.OPEN;
    
    xPos = x;
    yPos = y;
    hasCap = false;
    
    if(random(100)>98) decoration = int(random(3));
  }
  
  public void addCap()
  {
    hasCap = true;
  }
  
  void drawBlock(MovingThing m, color c, boolean overlay)// float cX, float cY, float bX, float bY )
  {
    if( dist(m.xPos,m.yPos, xPos,yPos) > width*.80 ) return;
    
    if(!overlay)
    {
      if( state == BlockState.OPEN || state == BlockState.DOOR )
        image(tile,xPos+data.xOffset,yPos+data.yOffset);
      if( state == BlockState.SOLID )
      {
        push();
        tint(c);
        image(wall,xPos+data.xOffset,yPos+data.yOffset);
        pop();
      }
      if( state == BlockState.DOOR )
      {
        push();
        tint(dangerColor,150);
        image(grid,xPos+data.xOffset,yPos+data.yOffset);
        pop();
      }
      if( state == BlockState.EXIT )
      {
        image(exit,xPos+data.xOffset,yPos+data.yOffset);
      }
      if( state == BlockState.OPEN && decoration != -1 )
        image(decor[decoration],xPos+data.xOffset,yPos+data.yOffset);
    }
    else
    {
      push();
      tint(c);
      if( hasCap )
        image(cap,xPos+data.xOffset,yPos+data.yOffset);
      pop();
    }
  }
  
  public boolean intersects( MovingThing m )
  {
    if( m.xPos+data.playerHitBox/2 > xPos-data.blockSize/2
    &&  m.xPos-data.playerHitBox/2 < xPos+data.blockSize/2
    &&  m.yPos+data.playerHitBox/2 > yPos-data.blockSize/2
    &&  m.yPos-data.playerHitBox/2 < yPos+data.blockSize/2 )
      return true;
    return false;
  }
}

public enum BlockState
{
  SOLID, OPEN, DOOR, EXIT, NONE
}
