class Upgrade
{
  //TESTING
  color segmentColor = color( random(255), random(255), random(255) );
  
  String name = "";
  
  PImage image;// = chooseImage();
  
  Upgrade nextUpgrade;
  boolean taken;

  Upgrade()
  {
    image = chooseImage();
    image.resize(150,0);
  }

  //FOR TESTING
  private PImage chooseImage()
  {
    switch( int( random( 34 ) ) )
    {
      case 0:  return loadImage("greenFoot.png");
      case 1:  return loadImage("yellowFoot.png");
      case 2:  return loadImage("redFoot.png");
      case 3:  return loadImage("purpleFoot.png");
      case 4:  return loadImage("greenArrow.png");
      case 5:  return loadImage("turnStop.png");
      case 6:  return loadImage("rotate.png");
      case 7:  return loadImage("turnSlow.png");
      case 8:  return loadImage("twoArrows.png");
      case 9:  return loadImage("threeArrows.png");
      case 10: return loadImage("fourArrows.png");
      case 11: return loadImage("fushaFoot.png");
      case 12: return loadImage("rotate2.png");
      case 13: return loadImage("rotate3.png");
      case 14: return loadImage("tool.png");
      case 15: return loadImage("tools2.png");
      case 16: return loadImage("tools3.png");
      case 17: return loadImage("regen.png");
      case 18: return loadImage("magnet.png");
      case 19: return loadImage("magnet.png");
      case 20: return loadImage("shieldRegen.png");
      case 21: return loadImage("shield2.png");
      case 22: return loadImage("shield3.png");
      case 23: return loadImage("laser1.png");
      case 24: return loadImage("laser2.png");
      case 25: return loadImage("laser3.png");
      case 26: return loadImage("laser4.png");
      case 27: return loadImage("laserBounce.png");
      case 28: return loadImage("tunnel.png");
      case 29: return loadImage("pierce.png");
      case 30: return loadImage("laserWidth.png");
      case 31: return loadImage("laserWidth2.png");
      case 32: return loadImage("laserRange.png");
      case 33: return loadImage("laserRange2.png");
      default: return loadImage("shield.png");
    }
  }
}

class RootUpgrade
{
  
}

//Enough extra cash will earn an extra upgrade

//Upgrade trees:
/*
Lasers (shoot forward)
  Damage
    ?
  Range
    Width

Missiles (seek)
  Damage
    Number
  Cooldown
    Accuracy

Discs (bounce)
  Damage
    More Discs
  Bounces
    Speed

Electricity (short-range auto, charges)
  Damage
    Mini-shocks
  Range
    Bounce

Defense
  Shields
    Regen
  Health
    Regen
  
Movement Speed
  Speed
    Pushback - Pushback2 - DamagePush
  Rotation
    Turnslow - turnstop


Vampire survivors weapons:
Whip: horizontal attacks
Wand: targets nearest enemy
Knife: rapid forward attack
Cross: boomerang
Axe: ?
Bible: orbit
Fire wand: random target
Holy water: damage zone
Runetracer: bounce around
Lightning ring: strike random enemies


Blookit:
Boomerang Pizza
Bubbles (grows with distance)
Bouncing Slime
Bee (wiggles)
Acorns (rapid at nearest)
Curving banana (rotate)
Dark Energy
Feathers (orbiting birds that shoot)
Peacock feathers (go and return)
Eggs (rapid forward)
Lasers (rapid forward)
Shells (bounce)
Horseshoes (orbit)
Cards (cardinal direcitons)
Arrows (shotgun forward)
Syrup (random pools)
*/
