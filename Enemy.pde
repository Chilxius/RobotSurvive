class Enemy extends MovingThing
{
  int level;
  EnemyBehavior behavior;
  
  public void move()
  {
  }
  
  public void show()
  {
    
  }
}

class EnemyBehavior
{
  //Can move through walls
  boolean corporeal;
  //Shoots (and keeps distance)
  boolean ranged;
  
  //This * level
  float speedMultiplier;
  
  //In blockSizes
  int sightRange;
}
