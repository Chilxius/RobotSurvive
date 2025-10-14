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
    testWheel.show();
    testWheel.spin();
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
    manager.setState( new UpgradeState() );
  }
  void goToBreakdown(StateManager manager)
  {
    manager.setState( new BreakdownState() );
  }
  
  void display()
  {
    background(0);
    
    testMap.drawBlocks(testBot,0);
    testMap.drawBlocks(testBot,1);
    showAllMovers();
    testMap.drawBlocks(testBot,2);
    
    if(testMap.exiting)
      testMap.lowerExit();
    else
      moveAllMovers();
      
    if( testMap.fade >= 255 )
    {
      testMap = new Map(++testMapLevel);
    
      testBot.xPos = testMap.startingPoint('x');
      testBot.yPos = testMap.startingPoint('y');
    }
  }
  
  void reactToPress()
  {
    testBot.startTurning();
  }
  
  void reactToRelease()
  {
    testBot.stopTurning();
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
  }
  
  void reactToPress()
  {
  }
  
  void reactToRelease()
  {
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
    println("ERROR: Update switched to Update");
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
