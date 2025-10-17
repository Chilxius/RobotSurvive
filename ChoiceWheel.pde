//Icons still wrong on wheel with differnet numbers of wedges

class ChoiceWheel
{
  ArrayList<Upgrade> segments = new ArrayList<Upgrade>();
  
  float xPos, yPos;
  float wheelSize;
  
  float angle;
  float spinSpeed;
  
  boolean touched;
  
  WheelState state;
  
  Clicker clicker;
  
  ChoiceWheel( Robot r, float x, float y, float size )
  {
    xPos = x;
    yPos = y;
    wheelSize = size;
    state = WheelState.START;
    clicker = new Clicker(this);
  }
  
  public void addUpgrade( Upgrade u )
  {
    segments.add(u);
  }
  
  public void show()
  {
    push();
    translate(xPos,yPos);
    rotate(angle);
    
    float chunks = segments.size();
    float size = TWO_PI/chunks;
    
    //Math for finding index by angle (clockwise and counterclockwise)
    //int index = int(((angle % TWO_PI) / size) % segments.size());
    //int index = int(((TWO_PI - (angle % TWO_PI)) / size) % segments.size());
    
    //background( segments.get( int(((TWO_PI - (angle % TWO_PI)) / size) % segments.size()) ).segmentColor );
      
    for(int i = 0; i < chunks; i++)
    {
      fill(segments.get(i).segmentColor);
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
      
      image(segments.get(i).image,0,0);
      
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
      state = WheelState.STOPPED;
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
