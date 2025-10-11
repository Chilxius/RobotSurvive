class UpgradeWheel
{
  ArrayList<Upgrade> segments = new ArrayList<Upgrade>();
  
  float angle;
  
  boolean stopping;
  
  UpgradeWheel( Robot r )
  {
    
  }
}

class Upgrade
{
  color segmentColor = color( random(255), random(255), random(255) );
  
  String name = "";
  
  PImage image = loadImage("testFace.png");
  
  Upgrade nextUpgrade;
  boolean taken;
}

class RootUpgrade
{
  
}

//More money = better upgrades
//If not enough cash, will include more copies of cheeper upgrades
//If can't aford anything, will put empty slot on wheel or skip wheel
//Cash will only be "spent" on selected upgrade
