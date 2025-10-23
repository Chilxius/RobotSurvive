PImage titlePic,tile,wall,cap,grid,decor[],exit,girder,g_back,g_front,floppy,staticPic,shieldPic,shieldPic2,bigFacePic;

PImage missilePic, disc, bolt, laserImage, explosionSmall, explosionBig;
PImage fireball, fireCharge, voice, brainBlast, skull, bat[];

HashMap<String, PImage> upgradeImages = new HashMap<>();

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
  
  int missileSize = 30;
  
  float upgradeWheelSize = 200;
  float upgradeBarSize = 45;

  public void loadImages()
  {
    //Title Page
    titlePic = loadImage("title.png");
    titlePic.resize(width,0);
    
    //Floppy Disc
    floppy = loadImage("floppy.png");
    floppy.resize(30,0);
    
    //Static/Face
    staticPic = loadImage("static.png");
    staticPic.resize(370,0);
    bigFacePic = loadImage("scientist.png");
    bigFacePic.resize(366,0);
    
    //Shield
    shieldPic = loadImage("shield.png");
    shieldPic.resize(int(data.playerSize),0);
    shieldPic2 = loadImage("shieldRemnant.png");
    shieldPic2.resize(int(data.playerSize),0);
    
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
    
    //Upgrades
    //Movement
    upgradeImages.put("Movement Speed 1", loadImage("greenArrow.png") );
    upgradeImages.put("Movement Speed 2", loadImage("twoArrows.png") );
    upgradeImages.put("Movement Speed 3", loadImage("threeArrows.png") );
    upgradeImages.put("Movement Speed 4", loadImage("fourArrows.png") );
    upgradeImages.put("Knockback Resist",loadImage("purpleFoot.png") );
    upgradeImages.put("Pushback",loadImage("fushaFoot.png") );
    upgradeImages.put("Forceful Pushback",loadImage("redFoot.png") );
    upgradeImages.put("Rotation Speed 1",loadImage("rotate.png") );
    upgradeImages.put("Rotation Speed 2",loadImage("rotate2.png") );
    upgradeImages.put("Rotation Speed 3",loadImage("rotate3.png") );
    upgradeImages.put("Turn-Slow",loadImage("turnSlow.png") );
    upgradeImages.put("Turn-Stop",loadImage("turnStop.png") );
    //Defense
    upgradeImages.put("Armor Up 1", loadImage("tool.png") );
    upgradeImages.put("Armor Up 2", loadImage("tools2.png") );
    upgradeImages.put("Armor Up 3", loadImage("tools3.png") );
    upgradeImages.put("Armor Regeneration", loadImage("regen.png") );
    upgradeImages.put("Shield 1", loadImage("shield.png") );
    upgradeImages.put("Shield 2", loadImage("shield2.png") );
    upgradeImages.put("Shield 3", loadImage("shield3.png") );
    upgradeImages.put("Shield Regeneration", loadImage("shieldRegen.png") );
    upgradeImages.put("Magnet 1", loadImage("magnet.png") );
    upgradeImages.put("Magnet 2", loadImage("magnet2.png") );
    //Laser
    upgradeImages.put("Laser 1",loadImage("laser1.png") );
    upgradeImages.put("Laser 2",loadImage("laser2.png") );
    upgradeImages.put("Laser 3",loadImage("laser3.png") );
    upgradeImages.put("Laser 4",loadImage("laser4.png") );
    upgradeImages.put("Piercing Laser",loadImage("pierce.png") );
    upgradeImages.put("Extended Laser 1",loadImage("laserRange.png") );
    upgradeImages.put("Extended Laser 2",loadImage("laserRange2.png") );
    upgradeImages.put("Wide Laser 1",loadImage("laserWidth.png") );
    upgradeImages.put("Wide Laser 2",loadImage("laserWidth2.png") );
    upgradeImages.put("Bouncing Laser",loadImage("laserBounce.png") );
    upgradeImages.put("Tunneling Laser",loadImage("tunnel.png") );
    //Missiles
    upgradeImages.put("Missile 1",loadImage("missile 1.png") );
    upgradeImages.put("Missile 2",loadImage("missile 2.png") );
    upgradeImages.put("Missile 3",loadImage("missile 3.png") );
    upgradeImages.put("Missile 4",loadImage("missile 4.png") );
    upgradeImages.put("Multi-Launch 1",loadImage("multiMissile 1.png") );
    upgradeImages.put("Multi-Launch 2",loadImage("multiMissile 2.png") );
    upgradeImages.put("Missile Reload 1",loadImage("missileReload 1.png") );
    upgradeImages.put("Missile Reload 2",loadImage("missileReload 2.png") );
    upgradeImages.put("Blast Radius 1",loadImage("boom.png") );
    upgradeImages.put("Blast Radius 2",loadImage("bigBoom.png") );
    upgradeImages.put("Bouncing Missile",loadImage("missileBounce.png") );
    //Discs
    upgradeImages.put("Razor Disc 1",loadImage("disc 1.png") );
    upgradeImages.put("Razor Disc 2",loadImage("disc 2.png") );
    upgradeImages.put("Razor Disc 3",loadImage("disc 3.png") );
    upgradeImages.put("Razor Disc 4",loadImage("disc 4.png") );
    upgradeImages.put("Multi-Disc 1",loadImage("multiDisc 1.png") );
    upgradeImages.put("Multi-Disc 2",loadImage("multiDisc 2.png") );
    upgradeImages.put("Multi-Disc 3",loadImage("multiDisc 3.png") );
    upgradeImages.put("Disc Bounce 1",loadImage("discBounce 1.png") );
    upgradeImages.put("Disc Bounce 2",loadImage("discBounce 2.png") );
    upgradeImages.put("Disc Bounce 3",loadImage("discBounce 3.png") );
    upgradeImages.put("Fast Disc",loadImage("fastDisc.png") );
    //Shock
    upgradeImages.put("Electric Shock 1",loadImage("decor1.png") );
    upgradeImages.put("Electric Shock 2",loadImage("decor1.png") );
    upgradeImages.put("Electric Shock 3",loadImage("decor1.png") );
    upgradeImages.put("Electric Shock 4",loadImage("decor1.png") );
    upgradeImages.put("Shock Speed 1",loadImage("decor1.png") );
    upgradeImages.put("Shock Speed 2",loadImage("decor1.png") );
    upgradeImages.put("Long Arc 1",loadImage("decor1.png") );
    upgradeImages.put("Long Arc 2",loadImage("decor1.png") );
    upgradeImages.put("Long Arc 3",loadImage("decor1.png") );
    upgradeImages.put("Chain Shock",loadImage("decor1.png") );
    
    //Projectiles
    missilePic = loadImage("missile.png"); missilePic.resize(missileSize,0);
    disc = loadImage("disc.png"); disc.resize(missileSize,0);
    bolt = loadImage("bolt.png"); bolt.resize(missileSize,0);
    laserImage = loadImage("laser.png"); laserImage.resize(missileSize,0);
    explosionSmall = loadImage("boom.png"); explosionSmall.resize(missileSize,0);
    skull = loadImage("skull.png"); skull.resize(missileSize*2,0);
    
    fireball = loadImage("FireBall.png"); fireball.resize(missileSize,0);
    fireCharge = loadImage("fireCharge.png"); fireCharge.resize(missileSize,0);
    voice = loadImage("voice.png"); voice.resize(missileSize*2,0);
    brainBlast = loadImage("brainBlast.png"); brainBlast.resize(missileSize*2,0);
    bat = new PImage[] { loadImage("bat1.png"), loadImage("bat2.png") };
    bat[0].resize(int(missileSize*1.5),0); bat[1].resize(int(missileSize*1.5),0);
  }
}
