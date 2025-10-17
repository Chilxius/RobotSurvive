class Upgrade
{
  //TESTING
  color segmentColor;// = color( random(255), random(255), random(255) );
  
  String name = "";
  
  PImage image;// = chooseImage();
  
  //Upgrade nextUpgrade; //This should be handled by the tree
  boolean taken;
  
  UpgradeCategory category;

  Upgrade( String name )
  {
    this.name = name;
    image = upgradeImages.get(this.name);
    category = categoryByName(name);
    segmentColor = colorByCategory(category);
  }
}
  
public color colorByCategory(UpgradeCategory category)
{
  switch(category)
  {
    case MOVEMENT: return color(200,200,0);
    case DEFENSE:  return color(0,0,100);
    case LASER:    return color(0,100,0);
    case MISSILE:  return color(100,100,100);
    case DISC:     return color(100,0,0);
    case ELECTRIC: return color(200,200,0);
    
    default: return color(255);
  }
}



public UpgradeCategory categoryByName( String name )
{
  switch(name)
  {
    case "Movement Speed 1":
    case "Movement Speed 2":
    case "Movement Speed 3":
    case "Movement Speed 4":
    case "Knockback Resist":
    case "Pushback":
    case "Forceful Pushback":
    case "Rotation Speed 1":
    case "Rotation Speed 2":
    case "Rotation Speed 3":
    case "Turn-Slow":
    case "Turn-Stop":
      return UpgradeCategory.MOVEMENT;
    
    case "Armor Up 1":
    case "Armor Up 2":
    case "Armor Up 3":
    case "Armor Regeneration":
    case "Shield 1":
    case "Shield 2":
    case "Shield 3":
    case "Shield Regeneration":
    case "Magnet 1":
    case "Magnet 2":
      return UpgradeCategory.DEFENSE;
    
    case "Laser 1":
    case "Laser 2":
    case "Laser 3":
    case "Laser 4":
    case "Piercing Laser":
    case "Extended Laser 1":
    case "Extended Laser 2":
    case "Wide Laser 1":
    case "Wide Laser 2":
    case "Bouncing Laser":
    case "Tunneling Laser":
      return UpgradeCategory.LASER;
    
    case "Missile 1":
    case "Missile 2":
    case "Missile 3":
    case "Missile 4":
    case "Multi-Launch 1":
    case "Multi-Launch 2":
    case "Missile Reload 1":
    case "Missile Reload 2":
    case "Blast Radius 1":
    case "BLast Radius 2":
    case "Bouncing Missile":
      return UpgradeCategory.MISSILE;
    
    case "Razor Disc 1":
    case "Razor Disc 2":
    case "Razor Disc 3":
    case "Razor Disc 4":
    case "Multi-Disc 1":
    case "Multi-Disc 2":
    case "Multi-Disc 3":
    case "Disc Bounce 1":
    case "Disc Bounce 2":
    case "Disc Bounce 3":
    case "Fast Disc":
      return UpgradeCategory.DISC;
    
    case "Electric Shock 1":
    case "Electric Shock 2":
    case "Electric Shock 3":
    case "Electric Shock 4":
    case "Shock Speed 1":
    case "Shock Speed 2":
    case "Long Arc 1":
    case "Long Arc 2":
    case "Long Arc 3":
    case "Chain Shock":
      return UpgradeCategory.ELECTRIC;
    
    default:
      return UpgradeCategory.BASE;
  }
}

class RootUpgrade
{
  
}

public enum UpgradeCategory
{
  BASE,
  MOVEMENT, DEFENSE, LASER, MISSILE, DISC, ELECTRIC
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
