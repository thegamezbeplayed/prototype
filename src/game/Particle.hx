class Particle extends h2d.Object{
  var spr : HSprite;
  public function new(t:h2d.Tile,x:Float,y:Float,?p){
    super(p);
    setPosition(x,y);
    spr = HSprite.fromTile(t,this);
  }
}
