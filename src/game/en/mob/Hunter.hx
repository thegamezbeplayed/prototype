package en.mob;

class Hunter extends en.Mob{
  public function new(x,y) {
    super(x,y);
    initLife(2);
    // Placeholder display
    var b = new h2d.Bitmap( h2d.Tile.fromColor(Red, iwid, ihei), spr );
    b.tile.setCenterRatio(0.5,1);

  }

  override function generatePlan() {
    var rlist = new dn.struct.RandList( wave.makeRand().random );
    rlist.add("D4 _3 RD2/1 _2 LD2/1 _3 RD2/2 _2 D1",1);
    rlist.add("D3 _2 RD4/3 _3 LD3/1 _2 RD2/2 _2 D1",1);
    return rlist.draw();
  }

  override function shoot(){
    var e = en.bul.MobBullet.linear(this, 1.57, 8);
    e.setPosPixel(centerX+side*5, centerY);
    side *= -1;
    shots++;
    if( shots>=5 ) {
      shots = 0;
      cd.setS("shoot",1);
    }
    else
      cd.setS("shoot",0.15);
  }

  override public function fixedUpdate(){
    super.fixedUpdate();

    if(M.fabs(vBase.dx)+M.fabs(vBase.dy)<=0.01 &&
      !cd.has("shoot") ) {
      shoot();
    }
  }
}

