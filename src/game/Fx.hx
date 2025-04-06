import h2d.Sprite;
import dn.heaps.HParticle;


class Fx extends GameChildProcess {
  var pool : ParticlePool;

  public var bg_add    : h2d.SpriteBatch;
  public var bg_normal    : h2d.SpriteBatch;
  public var main_add       : h2d.SpriteBatch;
  public var main_normal    : h2d.SpriteBatch;
  public var bgCol : h2d.Bitmap;

  var rootLayer : h2d.Layers;

  public function new(p:h2d.Layers) {
    super();

    pool = new ParticlePool(Assets.particles.tile, 2048, Const.FPS);

    rootLayer = p;
    bg_add = new h2d.SpriteBatch(Assets.particles.tile);
    bg_add.blendMode = Add;
    bg_add.hasRotationScale = true;
    rootLayer.add(bg_add, Const.DP_FX_BG);
    
    bg_normal = new h2d.SpriteBatch(Assets.particles.tile);
    rootLayer.add(bg_normal, Const.DP_FX_BG);
    bg_normal.blendMode = Screen;
    bg_normal.hasRotationScale = true;

    main_normal = new h2d.SpriteBatch(Assets.particles.tile);
    rootLayer.add(main_normal, Const.DP_FX_FRONT);


    main_normal.blendMode = Screen;
    main_normal.hasRotationScale = true;
    //main_normal.blendMode = Alpha;
    main_add = new h2d.SpriteBatch(Assets.particles.tile);
    rootLayer.add(main_add, Const.DP_FX_FRONT);
    main_add.blendMode = Add;
    main_add.hasRotationScale = true;
  }

  override public function onDispose() {
    super.onDispose();
    rootLayer.remove();
    pool.dispose();
    bg_add.remove();
    bg_normal.remove();
    main_add.remove();
    main_normal.remove();
    bgCol.remove();
  }

  override function onResize(){
    super.onResize();
    rootLayer.setScale(Const.UI_SCALE);
    if(bgCol==null)
      return;

  }
  /** Clear all particles **/
  public function clear() {
    rootLayer.filter = new h2d.filter.Nothing();
    bg_add.filter = new h2d.filter.Nothing();
    bg_normal.filter = new h2d.filter.Nothing();
    main_normal.filter = new h2d.filter.Nothing();
    main_add.filter = new h2d.filter.Nothing();
    if(bgCol!=null)
      bgCol.remove();
    if(pool==null)
      return;
    if(pool.allocated>=0)
      pool.clear();


  }

  /** Create a HParticle instance in the BG layer, using ADDITIVE blendmode **/
  public inline function allocBg_add(id,x,y) return pool.alloc(bg_add, Assets.particles.getTileRandom(id,tools.Tools.biasedRnd), x, y);

  /** Create a HParticle instance in the BG layer, using NORMAL blendmode **/
  public inline function allocBg_normal(id,x,y) return pool.alloc(bg_normal, Assets.particles.getTileRandom(id), x, y);

  /** Create a HParticle instance in the MAIN layer, using ADDITIVE blendmode **/
  public inline function allocMain_add(id,x,y) return pool.alloc( main_add, Assets.particles.getTileRandom(id), x, y );

  /** Create a HParticle instance in the MAIN layer, using NORMAL blendmode **/
  public inline function allocMain_normal(id,x,y) return pool.alloc(main_normal, Assets.particles.getTileRandom(id), x, y);


  public inline function markerEntity(e:Entity, c:Col=Pink, sec=3.0) {
    #if debug
    if( e!=null && e.isAlive() ) {
      var p = allocMain_add(D.tiles.fxCircle15, e.attachX, e.attachY);
      p.setCenterRatio(e.pivotX, e.pivotY);
      p.scaleTo(e.wid, e.hei);
      p.setFadeS(1, 0, 0.06);
      p.colorize(c);
      p.lifeS = sec;

      var p = allocMain_add(D.tiles.pixel, e.attachX, e.attachY);
      p.setFadeS(1, 0, 0.06);
      p.colorize(c);
      p.setScale(2);
      p.lifeS = sec;
    }
    #end
  }

  public inline function markerCase(cx:Int, cy:Int, sec=3.0, c:Col=Pink) {
    #if debug
    var p = allocMain_add(D.tiles.fxCircle15, (cx+0.5)*Const.GRID, (cy+0.5)*Const.GRID);
    p.setFadeS(1, 0, 0.06);
    p.colorize(c);
    p.lifeS = sec;

    var p = allocMain_add(D.tiles.pixel, (cx+0.5)*Const.GRID, (cy+0.5)*Const.GRID);
    p.setFadeS(1, 0, 0.06);
    p.colorize(c);
    p.setScale(2);
    p.lifeS = sec;
    #end
  }

  public inline function markerFree(x:Float, y:Float, sec=3.0, c:Col=Pink) {
    #if debug
    var p = allocMain_add(D.tiles.fxDot, x,y);
    p.setCenterRatio(0.5,0.5);
    p.setFadeS(1, 0, 0.06);
    p.colorize(c);
    p.setScale(3);
    p.lifeS = sec;
    #end
  }

  public inline function markerText(cx:Int, cy:Int, txt:String, t=1.0) {
    #if debug
    var tf = new h2d.Text(Assets.fontPixel, main_normal);
    tf.text = txt;

    var p = allocMain_add(D.tiles.fxCircle15, (cx+0.5)*Const.GRID, (cy+0.5)*Const.GRID);
    p.colorize(0x0080FF);
    p.alpha = 0.6;
    p.lifeS = 0.3;
    p.fadeOutSpeed = 0.4;
    p.onKill = tf.remove;

    tf.setPosition(p.x-tf.textWidth*0.5, p.y-tf.textHeight*0.5);
    #end
  }


  public inline function markerLine(fx:Float, fy:Float, tx:Float, ty:Float, c:Col, sec=3.) {
    #if debug
    var p = allocMain_add(D.tiles.fxLine, fx,fy);
    p.setFadeS(1, 0, 0);
    p.colorize(c);
    p.setCenterRatio(0,0.5);
    p.scaleX = M.dist(fx,fy,tx,ty) / p.t.width;
    p.rotation = Math.atan2(ty-fy, tx-fx);
    p.lifeS = sec;
    #end
  }

  function _followAng(p:HParticle) {
    p.rotation = p.getMoveAng();
  }

  public inline function checkEntityCollision(p:HParticle,cb:Dynamic->Bool,len:Float=0.,kill=true){
  }

  inline function fastDistPx(p:HParticle,e:Entity) : Float {
    return M.fabs(p.x-e.screenX) + M.fabs(p.y-e.screenY);
  }

  inline function collides(p:HParticle, offX=0., offY=0.) {
    return level.hasCollision( Std.int((p.x+offX)/Const.GRID), Std.int((p.y+offY)/Const.GRID) );
  }

  public inline function flashBangS(c:Col, a:Float, t=0.1) {
    var e = new h2d.Bitmap(h2d.Tile.fromColor(c,1,1,a));
    //game.root.add(e, Const.DP_FX_FRONT);
    e.scaleX = game.w();
    e.scaleY = game.h();
    e.blendMode = Add;
    game.tw.createS(e.alpha, 0, t).end( function() {
      e.remove();
    });
  }

  public inline function dotsExplosionExample(x:Float, y:Float, color:Col) {
    for(i in 0...80) {
      var p = allocMain_add( D.tiles.fxDot, x+rnd(0,3,true), y+rnd(0,3,true) );
      p.alpha = rnd(0.4,1);
      p.colorAnimS(color, 0x762087, rnd(0.6, 3)); // fade particle color from given color to some purple
      p.moveAwayFrom(x,y, rnd(1,3)); // move away from source
      p.frict = rnd(0.8, 0.9); // friction applied to velocities
      p.gy = rnd(0, 0.02); // gravity Y (added on each frame)
      p.lifeS = rnd(2,3); // life time in seconds
    }
  }
  
  public inline function starShine(x:Float, y:Float){
    var lifeA = rnd(23,69);
    var alphaA = (100-lifeA)/100;
    var scale = M.fmin(lifeA/200,0.15);
    var color = Blue;
    var color2 = Cyan;

    var p = allocBg_add('star',x,y);
    var p1 = allocMain_add('star',x,y);
    p1.colorAnimS(White,color, rnd(0.1,0.15));
    p1.fadeIn(alphaA,2);
    p1.lifeF = rnd(13,26);
    p1.setScale(scale);
    p.alpha = alphaA;
    p.lifeF = rnd(14,25);
    p.setScale(scale);

    p1.onKill = ()->{
      var p2 = allocMain_add('star',x,y);
      p2.setScale(scale);
      p2.colorAnimS(color,color2, rnd(0.1,0.15));
      p2.lifeF = rnd(15,45);
      p2.alpha = p1.alpha + 0.1;
    }
  }

  public inline function star(x:Float, y:Float,time=150){
    var color = Blue;
    var color2 = Cyan;

    var scale = Tools.biasedMinRnd(0.05,0.1,5);
    var p = allocMain_add('star',x,y);
    p.setScale(scale);
    p.lifeF = time;

    var flicker = (b:HParticle)->{
      if(irnd(-1000,10000)==100){
	var f = allocMain_add('flicker',x,y);
	f.setScale(scale);
	f.lifeF = irnd(3,6);
      }
    };

    p.onUpdate = flicker;
  }

  public inline function heroDeath(x:Float, y:Float, color:Col, color2:Col){
    var p = allocBg_add('star',x,y);
    var p1 = allocMain_add('star',x,y);
    p1.colorAnimS(White,color, rnd(0.1,0.15));
    p1.fadeIn(0.7,1);
    p1.lifeF = rnd(3,4);
    p1.setScale(0.65);
    p.alpha = rnd(0.5,0.7);
    p.lifeF = rnd(4,5);
    p.setScale(0.5);

    p1.onKill = ()->{
      var p2 = allocMain_add('star',x,y);
      p2.setScale(0.65);
      p2.colorAnimS(color,color2, rnd(0.1,0.15));
      p2.lifeF = rnd(3,4);
      p2.alpha = p1.alpha + 0.1;
    }
  }

  public inline function twinkle(amnt:Int,x:Float,y: Float, color:Col,?cb){
    for (i in 0...amnt){
      var f = allocMain_add('fxDot',x+rnd(1,7,true),y+rnd(0,9,true));
      f.colorAnimS(White,color,rnd(0.1,0.15));
      f.alpha = rnd(0.69,1);
      f.alphaFlicker = rnd(0.4,0.69);
      f.lifeF = rnd(30,45);
      f.gy = rnd(0.,-0.025);
      if(cb==null)
	continue;

      f.onUpdate = cb;
    }
  }

  public inline function frag(amnt:Int,spd:Int,x:Float, y: Float,color:Col, ang=M.PI,?cb){
    for (i in 0...amnt){
      var f = allocMain_add('fxDot', x+rnd(0,4,true), y+rnd(0,4,true));
      f.alpha = rnd(0.75,1);
      f.colorAnimS(White,color,rnd(0.1,0.15));
      f.moveAng(ang,spd/1000);
      f.frict = 1;
      f.lifeF = rnd(25,40);
      ang+=rnd(M.PI/amnt,M.PIHALF/amnt);
      color = color.incRGB(0.01);
      if(cb!=null)
	f.onUpdate = cb;
    }
  }
 
  public inline function fragCone(amnt:Int,spd:Int,x:Float, y: Float,color:Col, origAng=M.PI,?cb){
    var ang = origAng;
    for (i in 0...amnt){
      var f = allocMain_add('fxDot', x+rnd(0,4,true), y+rnd(0,4,true));
      f.alpha = rnd(0.75,1);
      f.colorAnimS(White,color,rnd(0.1,0.15));
      f.moveAng(ang,spd/(1000-3*i));
      f.frict = 1;
      f.lifeF = rnd(30,45);
      ang=M.frandRange(origAng-M.PI/amnt,origAng+M.PI/amnt,tools.Tools.biasToEnds);
      color = color.incRGB(0.01);
      if(cb!=null)
        f.onUpdate = cb;
    }
  }

  public inline function explosion(x:Float, y:Float, color:Col, ang=M.PI, amnt:Int=80) {
    for(i in 0...amnt) {
      var p = allocMain_add( 'fxDot', x+rnd(0,3,true), y+rnd(0,3,true) );
      p.alpha = rnd(0.5,1);
      p.colorAnimS(White, color, rnd(0.3, .45)); // fade particle color from given color to some purple
      p.moveAwayFrom(x,y, rnd(3,4)); // move away from source
      p.frict = rnd(0.9, 0.975); // friction applied to velocities
      p.gy = Math.sin(ang);
      p.gx = Math.cos(ang);
      p.lifeF = rnd(9,18); // life time in Frames
      if (i%9 == 0)
	envDust(irnd(1,2),p.x,p.y,irnd(i+999,9999));
    }

  }

  public inline function bigExplosion(amnt:Int,spd:Int,x,y,color:Col,ang:Float,?cb){
    for (i in 0...amnt){
      var f = allocMain_add('fxDot', x+rnd(0,5,true), y+rnd(0,5,true));
      f.alpha = rnd(0.75,1);
      f.colorAnimS(White,color,rnd(0.1,0.15));
      f.moveAng(ang,spd/1000);
      f.frict = 0.999;
      f.lifeF = rnd(29,rnd(36,90));
      ang+=M.PI2/amnt;
      color = color.incRGB(0.01);
      if(cb!=null)
        f.onUpdate = cb;
    }
  }
  
  public inline function bullet(x:Float, y:Float, scale:Float,?cb):dn.heaps.HParticle{
    var p = allocMain_add('trace',x,y);
    p.setScale(scale);
    p.fadeIn(1,0.1);
    if(cb!=null)
      p.onUpdate = cb;

    return p;
  }
  
  public function envSmoke(n:Int) {
    for(i in 0...n) {
      var xr = rnd(0,1);
      var p = allocBg_add('fxDot', xr*Game.ME.level.pxWid, Game.ME.level.pxHei*xr);
      var c:Col = 0x236CC7;
      p.colorize(c.interpolate(0xBC2E38,xr) );
      p.setFadeS(rnd(0.05,0.08), rnd(0.6,1), rnd(2,3));
      p.setScale(rnd(0.9,1.7));
      p.rotation = rnd(0,6.28);
      p.scaleMul = rnd(0.995,0.998);
      p.dy = rnd(-1,2);
      p.frict = rnd(0.94,0.97);
      p.dr = rnd(0,0.003,true);
      p.gx = rnd(0.01,0.02);
      p.gy = rnd(0.003,0.004);
      p.lifeS = rnd(2,3);
    }
  }

  public function envDust(n:Int,?x:Float,?y:Float,?time:Int) {
    for(i in 0...n) {
      var lifeF = time==null?irnd(55,85):time;
      var lx = x==null?rnd(4,Game.ME.level.pxWid):x+rnd(0,2,true);
      var ly = y==null?rnd(4,Game.ME.level.pxHei):y+rnd(0,2,true);

      var p = allocMain_add('fxDot', lx, ly);

      p.setFadeS(rnd(0.33,0.5), rnd(0.6,1),0);//rnd(1.5,2.4));
      p.scaleX = rnd(1,3);
      p.scaleY = rnd(1,3);
      p.colorAnimS(White,Blue,rnd(0.75,1.75));

      p.scaleXMul = rnd(0.97,0.99);
      p.dx = rnd(0,2);
      p.dy = rnd(-1,2);
      p.frict = rnd(0.94,0.97);
      p.gx = rnd(0.01,0.03);
      p.gy = rnd(0.01,0.02);
      p.lifeF = lifeF;
      p.onUpdate = _followAng;
    }
  }

  public inline function nebula(x:Float, y:Float, pal:h3d.mat.Texture, time:Int = 150,wid=1920,hei=1080) {
    var centerX= x;
    var centerY= y;//rnd(y-10,y+10);
    var plots = tools.LPoint.getEllipsePoints(irnd(16,18),rnd(29,30),rnd(16,17),centerX,centerY);
    var count = 0;
    var bgCol = new h2d.Bitmap(h2d.Tile.fromColor(Black,wid,hei,1));
    var nm = new filters.NoiseMap(pal,rnd(0.4,0.7),1,0.5);
    bg_add.filter = new filters.PaletteMap(pal,irnd(0,7));
    var pm = new filters.AlphaMap(pal,irnd(0,7),1,OnlyLights);
    var ig = new h2d.filter.InnerGlow();
    var pmd = new filters.PaletteMap(pal,irnd(0,7));

    bgCol.filter = new h2d.filter.Group([nm,pmd]);
    rootLayer.add(bgCol,Const.DP_BG);
    main_add.filter = new h2d.filter.Group([pm,ig]);
    for (pt in plots){
      var angC = pt.angTo(centerX,centerY);
      if(count%4==0 && count <10){
	var l = allocMain_add('spark',pt.levelX,pt.levelY);
	l.scale=rnd(0.7,0.775);
	l.rotation = rnd(0,M.PI2);
	l.lifeF=time;
	l.setGravityAng(angC+M.PI,0.0001);
      }
      else{
	var b = allocBg_add('smoke',pt.levelX,pt.levelY);
	b.rotation = rnd(0,M.PI2);
	b.scaleX=rnd(1.65,1.75);
	b.scaleY=rnd(1,1.09);

	b.setGravityAng(angC+M.PI,0.0001);
	b.lifeF = time;
      }
      var stPts = tools.LPoint.getClusterPoints(irnd(count,7),rnd(49,65),pt.levelX,pt.levelY);
      for(stPt in stPts){
	star(stPt.levelX,stPt.levelY,time);
	star(stPt.levelX+rnd(250,-250),stPt.levelY+rnd(200,-200),time);
      }
      count++;
    }


  }

  public function halo(x:Float, y:Float, c:UInt, ?scale=1.0) {
    var p = allocMain_add("dirt", x,y);
    p.colorAnimS(c, 0x4E1672, 0.3);
    p.scale = 0.3*scale;
    p.ds = 0.1*scale;
    p.dsFrict = 0.8;
    p.lifeS = 0.2;
  }

  public function damage(x:Float,y:Float,col:Col, ?scale=1.0,?cb){
    var time = M.floor(scale*10);
    var p = allocMain_add("light", x,y);
    p.colorAnimS(Red,White,0.25);
    p.scale = M.fclamp(0.05,0.075,scale);
    p.ds = scale/2;
    p.dsFrict = 0.8;
    p.lifeF = scale;

    if(cb==null)
      return;

    p.onUpdate = cb;
  }

  public function lazer(x:Float,y:Float,col:Col,ang:Float,?scale=1,?time:Int=1,?cb){
    var noTouchy = true;
    var count = 0;
    while(noTouchy){
      var tName = count==0?"lazer_base":"lazer";
      var p = allocMain_add(tName,x,y);
      p.rotation = ang+M.PIHALF;
      p.resizeXTo(irnd(3,4));
      p.resizeYTo(irnd(9,16));
      p.alpha = rnd(0.35,0.5);
      //p.scaleX = 0.125;
      //p.scaleY = 0.15;
      p.lifeF=time;
      var hei = p.t.height;
      x += Math.cos(ang) * hei; 
      y += Math.sin(ang) * hei;
      p.delayCallback((p)->{
	p.alpha=1;
	p.scale=1;
	if(cb!=null)
	p.onUpdate = cb;
      },(time/Const.FPS)/4);
      count++;
      noTouchy = !collides(p);
    }
  }
  
  override function update() {
    super.update();
    pool.update(tmod);
  }
}
