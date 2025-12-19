interface TreeNode<T>
{
    T getValue();
}

//n-ary root node
class RootNode<T> implements TreeNode<T>
{
    T value;
    ArrayList<Node<T>> children = new ArrayList<Node<T>>();
    
    RootNode( T value )
    {
      this.value = value;
    }
    
    public T getValue() { return value; }
}

//Binary nodes
class Node<T> implements TreeNode<T>
{
    T value;
    Node<T> left, right;
    
    Node( T value )
    {
      this.value = value;
    }
    
    public T getValue() { return value; }
}

//Brittle and bad - works for the time I have
public void buildTree()
{
  //Movement
  upgradeTree.children.add( new Node( new Upgrade("Movement Speed 1") ) );// upgradeTree.children.get(0).value.taken = true;
    upgradeTree.children.get(0).left = new Node( new Upgrade("Movement Speed 2") );//upgradeTree.children.get(0).left.value.taken=true;
      upgradeTree.children.get(0).left.left = new Node( new Upgrade("Movement Speed 3") );
        upgradeTree.children.get(0).left.left.left = new Node( new Upgrade("Movement Speed 4") );
      upgradeTree.children.get(0).left.right = new Node( new Upgrade("Knockback Resist") );
        upgradeTree.children.get(0).left.right.left = new Node( new Upgrade("Pushback") );
          upgradeTree.children.get(0).left.right.left.left = new Node( new Upgrade("Forceful Pushback") );
    upgradeTree.children.get(0).right = new Node( new Upgrade("Rotation Speed 1") );//upgradeTree.children.get(0).right.value.taken=true;
      upgradeTree.children.get(0).right.left = new Node( new Upgrade("Rotation Speed 2") );
        upgradeTree.children.get(0).right.left.left = new Node( new Upgrade("Rotation Speed 3") );
      upgradeTree.children.get(0).right.right = new Node( new Upgrade("Turn-Slow") );
        upgradeTree.children.get(0).right.right.right = new Node( new Upgrade("Turn-Stop") );
  //Defense
  upgradeTree.children.add( new Node( new Upgrade("Armor Up 1") ) );
    upgradeTree.children.get(1).left = new Node( new Upgrade("Shield 1") );
      upgradeTree.children.get(1).left.left = new Node( new Upgrade("Shield 2") );
        upgradeTree.children.get(1).left.left.left = new Node( new Upgrade("Shield 3") );
        upgradeTree.children.get(1).left.left.right = new Node( new Upgrade("Shield Regeneration") );
      upgradeTree.children.get(1).left.right = new Node( new Upgrade("Armor Up 2") );
        upgradeTree.children.get(1).left.right.left = new Node( new Upgrade("Armor Up 3") );
        upgradeTree.children.get(1).left.right.right = new Node( new Upgrade("Armor Regeneration") );
    upgradeTree.children.get(1).right = new Node( new Upgrade("Magnet 1") );
      upgradeTree.children.get(1).right.left = new Node( new Upgrade("Magnet 2") );
  //Lasers
  upgradeTree.children.add( new Node( new Upgrade("Laser 1") ) );
    upgradeTree.children.get(2).left = new Node( new Upgrade("Laser 2") );
      upgradeTree.children.get(2).left.left = new Node( new Upgrade("Laser 3") );
        upgradeTree.children.get(2).left.left.left = new Node( new Upgrade("Laser 4") );
      upgradeTree.children.get(2).left.right = new Node( new Upgrade("Piercing Laser") );
    upgradeTree.children.get(2).right = new Node( new Upgrade("Extended Laser 1") );
      upgradeTree.children.get(2).right.left = new Node( new Upgrade("Extended Laser 2") );
        upgradeTree.children.get(2).right.left.left = new Node( new Upgrade("Tunneling Laser") );
        upgradeTree.children.get(2).right.left.right = new Node( new Upgrade("Bouncing Laser") );
      upgradeTree.children.get(2).right.right = new Node( new Upgrade("Wide Laser 1") );
        upgradeTree.children.get(2).right.right.left = new Node( new Upgrade("Wide Laser 2") );
  //Missiles
  upgradeTree.children.add( new Node( new Upgrade("Missile 1") ) );
    upgradeTree.children.get(3).left = new Node( new Upgrade("Missile 2") );
      upgradeTree.children.get(3).left.left = new Node( new Upgrade("Missile 3") );
        upgradeTree.children.get(3).left.left.left = new Node( new Upgrade("Missile 4") );
      upgradeTree.children.get(3).left.right = new Node( new Upgrade("Multi-Launch 1") );
        upgradeTree.children.get(3).left.right.left = new Node( new Upgrade("Multi-Launch 2") );
    upgradeTree.children.get(3).right = new Node( new Upgrade("Missile Reload 1") );
      upgradeTree.children.get(3).right.right = new Node( new Upgrade("Missile Reload 2") );
        upgradeTree.children.get(3).right.right.left = new Node( new Upgrade("Bouncing Missile") );
        upgradeTree.children.get(3).right.right.right = new Node( new Upgrade("Demolition Missile") );
      upgradeTree.children.get(3).right.left = new Node( new Upgrade("Blast Radius 1") );
        upgradeTree.children.get(3).right.left.left = new Node( new Upgrade("Blast Radius 2") );
  //Razor Discs
  upgradeTree.children.add( new Node( new Upgrade("Razor Disc 1") ) );
    upgradeTree.children.get(4).left = new Node( new Upgrade("Razor Disc 2") );
      upgradeTree.children.get(4).left.left = new Node( new Upgrade("Razor Disc 3") );
        upgradeTree.children.get(4).left.left.left = new Node( new Upgrade("Razor Disc 4") );
      upgradeTree.children.get(4).left.right = new Node( new Upgrade("Multi-Disc 1") );
        upgradeTree.children.get(4).left.right.left = new Node( new Upgrade("Multi-Disc 2") );
          upgradeTree.children.get(4).left.right.left.left = new Node( new Upgrade("Multi-Disc 3") );
    upgradeTree.children.get(4).right = new Node( new Upgrade("Disc Bounce 1") );
      upgradeTree.children.get(4).right.right = new Node( new Upgrade("Disc Bounce 2") );
        upgradeTree.children.get(4).right.right.right = new Node( new Upgrade("Disc Bounce 3") );
      upgradeTree.children.get(4).right.left = new Node( new Upgrade("Fast Disc") );
}
