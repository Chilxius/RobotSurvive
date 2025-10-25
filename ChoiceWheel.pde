//Icons still wrong on wheel with differnet numbers of wedges

class ChoiceWheel
{
  //ArrayList<Upgrade> segments = new ArrayList<Upgrade>();
  ArrayList<Node<Upgrade>> segments = new ArrayList<Node<Upgrade>>();
  
  float xPos, yPos;
  float wheelSize;
  
  float angle;
  float spinSpeed;
  
  boolean touched;
  boolean upgradeInstalled;
  
  WheelState state;
  
  Clicker clicker;
  
  ChoiceWheel( Robot r, float x, float y, float size )
  {
    xPos = x;
    yPos = y;
    wheelSize = size;
    state = WheelState.START;
    clicker = new Clicker(this);
    
    buildWheel(4);
  }
  
  //public void addUpgrade( Upgrade u )
  //{
  //  segments.add(u);
  //}
  
  public void addSegment( Node n )
  {
    segments.add(n);
  }
  
  public void show()
  {
    addHelpMessage(2);
    
    push();
    translate(xPos,yPos);
    
    float chunks = segments.size();
    float size = TWO_PI/chunks;
    
    //Math for finding index by angle (clockwise and counterclockwise)
    //int index = int(((angle % TWO_PI) / size) % segments.size());
    //int index = int(((TWO_PI - (angle % TWO_PI)) / size) % segments.size());
    
    //background( segments.get( int(((TWO_PI - (angle % TWO_PI)) / size) % segments.size()) ).segmentColor );
    
    fill(100);
    noStroke();
    circle(0,0,wheelSize+30);
    rectMode(CENTER);
    rect(0,0,100,height);
    rect(500,0,1000,100);
    
    rotate(angle);
    for(int i = 0; i < chunks; i++)
    {
      fill(segments.get(i).value.segmentColor);
      stroke(150,150,150); strokeWeight(5);
      arc( 0, 0, wheelSize, wheelSize, 0, size+0, PIE );
      
      //Rotate back to get image in place
      push();
      
      rotate(-size/2);
      
      //Re-orient image
      push();
      
      translate(0,wheelSize/3.5);
      
      //Un-roatate so image is upright
      rotate(-angle-size*i+QUARTER_PI);
      
      image(segments.get(i).value.image,0,0,data.upgradeWheelSize,data.upgradeWheelSize);
      
      pop(); //un-twist
      pop(); //return to wheel chunks
      
      rotate(size);
    }
    
    pop();
    
    clicker.handleClicker();
  }
  
  public void spin()
  {
    switch( state )
    {
      //Player hasn't touched it since it started spinning
      case SPINNING:
        angle += spinSpeed;
        break;
        
      //Wheel is slowing down
      case SLOWING:
        angle += spinSpeed;
        spinSpeed *= 0.995;
        break;
        
      //Wheel is being "grabbed", slowing it faster
      case GRABBED:
        angle += spinSpeed;
        spinSpeed *= 0.97;
        break;
    }
    
    //Wheel has effectively stopped
    if( state != WheelState.START && spinSpeed <= 0.002 )
    {
      state = WheelState.STOPPED;
      
      //TEST - installing upgrade and marking the tree node
      //  also triggers some animation stuff
      if( !upgradeInstalled )
      {
        Node<Upgrade> choice = segments.get( int(((TWO_PI - (angle % TWO_PI)) / (TWO_PI/segments.size())) % segments.size()) );
        hud.upgradeString = choice.value.name;
        hud.installBoxOpening = true;
        robot.activateUpgrade(hud.upgradeString);
        choice.value.taken = true;
        upgradeInstalled = true;
      }
    }
  }
  
  public void pressReact( boolean pressed )
  {
    //Wheel was newly touched, or touched wheel was released
    if( touched != pressed )
      touched = !touched;

    switch(state)
    {  
      //Wheel is ready to spin
      case START:
        addHelpMessage(3);
        if(pressed)
        {
          touched = true;
          spinSpeed = 0.1;
          state = WheelState.SPINNING;
        }
        break;
      
      //Wheel is spinning and ready to be grabbed
      case SPINNING:
        if(touched)
          state = WheelState.GRABBED;
        break;
      
      //Wheel is slowing by its own friction
      case SLOWING:
        //addHelpMessage(4);
        if(touched)
          state = WheelState.GRABBED;
        break;
      
      //Wheel has been "grabbed"
      case GRABBED:
        if(!touched)
          state = WheelState.SLOWING;
        break;
    }
  }
  
  //Select upgrades for the wheel
  //SAFE UNDER CURRENT GAME CONDITONS, but should be made infinite-loop safe for endless mode
  //Edited to record nodes rather than upgrades, but the old logic is still part of it - needs refactoring
  public void buildWheel( int items )
  {
    Upgrade chunks[] = {null,null,null,null};
    Node nodeRefs[] =  {null,null,null,null};
    for( int i = 0; i < items; i++ )
    {
      boolean keepLooking = true;
      int searches = 0; //after 100 searches, will allow duplicates
      
      while( chunks[i] == null || keepLooking ) //Keep trying until a legitimate upgrade is found
      {
        searches++;
        
        Node<Upgrade> current;
        
        if( map.level == 1 )
          current = upgradeTree.children.get( int(random(3))+2 );
        else
          current = upgradeTree.children.get( int(random(upgradeTree.children.size())));
        
        while( true ) //Iterate down random tree path
        {
          //Assign value if leaf node
          if( current == null || !current.value.taken )
          {
            if( current != null )
            {
              chunks[i] = current.value;
              nodeRefs[i] = current;
            }
            break;
          }
          
          //Choose random direction
          int direction = int(random(2));
          
          if( direction == 1 && current.left != null )
            current = current.left;
          else
            current = current.right;
        }
      
        //Avoid duplicates
        
        if( searches < 100 )
        {
          boolean duplicateFound = false;
          for (int j = 0; j < chunks.length; j++)
          {
              if (i != j && chunks[i] != null && chunks[j] != null &&
                  chunks[i].name.equals(chunks[j].name))
              {
                  duplicateFound = true;
                  break;
              }
          }
          keepLooking = duplicateFound;
        }
        else
          keepLooking = false;
      }
    }
    
    for( Node n: nodeRefs )
    {
      segments.add( n );
    }
  }
}

//Part on the wheel that slows it - this is apparently the correct term
class Clicker
{
  ChoiceWheel wheel;
  float nextClick;
  float offset;
  
  //Causes tight coupling, but ChoiceWheel and Clicker will never exist apart
  //  from each other and will always exist together.
  Clicker( ChoiceWheel wheel )
  {
    this.wheel = wheel;
  }
  
  public void handleClicker()
  {
    click( wheel.wheelSize, wheel.angle, TWO_PI/wheel.segments.size() );
    show( wheel.xPos, wheel.yPos, wheel.wheelSize );
  }
  
  public void click( float size, float angle, float chunkSize )
  {
    if( angle > nextClick )
    {
      //make sound
      nextClick += chunkSize;
      offset = size*0.03;
    }
  }
  
  public void show( float x, float y, float size )
  {
    push();
    
    fill(255);
    noStroke();

    circle(x+size*0.58,y,size*0.065);
    triangle(x+size*0.48, y+offset,  x+size*0.58,y+size*0.03,  x+size*0.58,y-size*0.03);
    
    pop();
    
    offset *= 0.95;
  }
}
  
public enum WheelState
{
  START, SPINNING, SLOWING, GRABBED, STOPPED
}
