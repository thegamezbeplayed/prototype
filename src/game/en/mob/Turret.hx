package en.mob;

class Turret extends en.Mob{
  public function new(x,y) {
    super(x,y);
    initLife(5);
    moveSpeed = 0;
    
    var b = new h2d.Bitmap( h2d.Tile.fromColor(Red, iwid, ihei), spr );
    b.tile.setCenterRatio(0.5,1);

    cd.setS("shoot", rnd(0,1));
  }
  
  override function shoot(){
    en.bul.MobBullet.autoAim(this);
    shots++;
    if( shots>=5 ) {
      shots = 0;
      cd.setS("shoot",0.5);
    }
    else
      cd.setS("shoot",0.1);

  }

  override public function fixedUpdate(){
    super.fixedUpdate();
    if(!cd.has("shoot"))
      shoot();
  }
}
