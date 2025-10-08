interface GameState
{
  void goToMenu(StateManager manager);
  void goToSurvival(StateManager manager);
  void goToUpgrade(StateManager manager);
  void goToBreakdown(StateManager manager);
  
  void display();
  void reactToButton();
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
  }
  
  void reactToButton()
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
    manager.setState( new UpgradeState() );
  }
  void goToBreakdown(StateManager manager)
  {
    manager.setState( new BreakdownState() );
  }
  
  void display()
  {
  }
  
  void reactToButton()
  {
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
  
  void reactToButton()
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
  
  void reactToButton()
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
