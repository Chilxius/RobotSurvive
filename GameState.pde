interface GameState
{
  void goToMenu(StateManager manager);
  void goToSurvival(StateManager manager);
  void goToUpgrade(StateManager manager);
  void goToBreakdown(StateManager manager);
  
  void display();
  
  void reactToPress();
  void reactToRelease();
}

class MenuState implements GameState
{
  void goToMenu(StateManager manager)
  {
    println("ERROR: Menu switched to Menu");
  }
  void goToSurvival(StateManager manager)
  {
    clearMovers();
    manager.setState( new SurvivalState() );
  }
  void goToUpgrade(StateManager manager)
  {
    println("ERROR: Menu switched to Upgrade");
  }
  void goToBreakdown(StateManager manager)
  {
    println("ERROR: Menu switched to Breakdown");
  }
  
  void display()
  {
    title.display();
  }
  
  void reactToPress()
  {
    title.pressReact();
  }
  
  void reactToRelease()
  {
    
  }
}

class SurvivalState implements GameState
{
  void goToMenu(StateManager manager)
  {
    println("ERROR: Survival switched to Menu");
  }
  void goToSurvival(StateManager manager)
  {
    println("ERROR: Survival switched to Survival");
  }
  void goToUpgrade(StateManager manager)
  {
    ghostWords.clear();
    hud.commsBoxOffset = -height;
    hud.commsBoxOpening = true;
    manager.setState( new UpgradeState() );
    data.xOffset = data.yOffset = 0;
    //testWheel.buildWheel(4);
    testWheel = new ChoiceWheel( robot, width*2/3, height/2, height*0.7 );
  }
  void goToBreakdown(StateManager manager)
  {
    manager.setState( new BreakdownState() );
  }
  
  void display()
  {
    background(0);
    
    map.drawBlocks(robot,0);
    map.drawBlocks(robot,1);
    showAllMovers();
    map.drawBlocks(robot,2);
    checkAllMoversForHits();
    
    if(map.exiting)
      map.lowerExit();
    else
    {
      moveAllMovers();
      checkMoversForRemoval();
      checkAllShooters();
      //robot.guide.display();
      //robot.activate();
    }
    
    if( map.fade >= 255 )
    {
      map = new Map(++mapLevel);
      
      manager.goToUpgrade();
    
      robot.xPos = map.startingPoint('x');
      robot.yPos = map.startingPoint('y');
    }
    
    hud.display(false);
    
    handleGhostWords();
  }
  
  void reactToPress()
  {
    robot.startTurning();
  }
  
  void reactToRelease()
  {
    robot.stopTurning();
  }
}

class UpgradeState implements GameState
{
  void goToMenu(StateManager manager)
  {
    println("ERROR: Update switched to Menu");
  }
  void goToSurvival(StateManager manager)
  {
    clearMovers();
    manager.setState( new SurvivalState() );
  }
  void goToUpgrade(StateManager manager)
  {
    println("ERROR: Update switched to Update");
  }
  void goToBreakdown(StateManager manager)
  {
    println("ERROR: Update switched to Breakdown");
  }
  
  void display()
  {
    testWheel.show();
    testWheel.spin();
    hud.display(true);
    if( robot.armor < robot.getMaxArmor() )
      robot.armor++;
    handleGhostWords();
  }
  
  void reactToPress()
  {
    testWheel.pressReact(true);
  }
  
  void reactToRelease()
  {
    testWheel.pressReact(false);
  }
}

class BreakdownState implements GameState
{
  void goToMenu(StateManager manager) //new game
  {
    manager.setState( new MenuState() );
  }
  void goToSurvival(StateManager manager) //restart
  {
    manager.setState( new SurvivalState() );
  }
  void goToUpgrade(StateManager manager)
  {
    println("ERROR: Breakdown switched to Update");
  }
  void goToBreakdown(StateManager manager)
  {
    println("ERROR: Breakdown switched to Breakdown");
  }
  
  void display()
  {
  }
  
  void reactToPress()
  {
  }
  
  void reactToRelease()
  {
  }
}

class StateManager
{
  private GameState state;
  
  public StateManager()
  {
    this.state = new MenuState();
  }
  
  public void setState(GameState state)
  {
    this.state = state;
  }
  
  public void display()
  {
    state.display();
  }
  
  public void reactToPress()
  {
    state.reactToPress();
  }
  
  public void reactToRelease()
  {
    state.reactToRelease();
  }
  
  void goToMenu()
  {
    state.goToMenu(this);
  }
  void goToSurvival()
  {
    state.goToSurvival(this);
  }
  void goToUpgrade()
  {
    state.goToUpgrade(this);
  }
  void goToBreakdown()
  {
    state.goToBreakdown(this);
  }
}
