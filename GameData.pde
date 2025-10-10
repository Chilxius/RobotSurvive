PImage tile,wall,cap,grid,decor[],exit,girder,g_back,g_front;

class GameData
{
  float blockSize = 100;
  float playerSize = 100;
  float playerHitBox = 50;
  
  float xOffset = 0;
  float yOffset = 0;
  
  float scrollXDist = width/3;
  float scrollYDist = height/3;
  
  float enemyBaseSize = 75;
  float bossBaseSize = 150;

  public void loadImages()
  {
    //Map
    tile = loadImage("tile3.png");
    tile.resize(0,int(data.blockSize));
    wall = loadImage("wallLong9.png");
    wall.resize(0,int(data.blockSize*1.25));
    cap = loadImage("wallCap4.png");
    cap.resize(int(data.blockSize),0);
    grid = loadImage("doorGrid3.png");
    grid.resize(int(data.blockSize),0);
    exit = loadImage("exit.png");
    exit.resize(int(data.blockSize),0);
    girder = loadImage("girder2.png");
    girder.resize(int(data.blockSize),0);
    g_back = loadImage("girder_back.png");
    g_back.resize(int(data.blockSize),0);
    g_front = loadImage("girder_back.png");
    g_front.resize(int(data.blockSize)*2,0);
    
    //Decoration
    decor = new PImage[4];
    decor[0] = loadImage("decor0.png");
    decor[0].resize(int(data.blockSize),0);
    decor[1] = loadImage("decor1.png");
    decor[1].resize(int(data.blockSize),0);
    decor[2] = loadImage("decor2_2.png");
    decor[2].resize(int(data.blockSize),0);
    decor[3] = loadImage("decor3.png");
    decor[3].resize(int(data.blockSize),0);
    
  }
}
