using tools.script.Script;

class Entity implements StateMachine{
  public static var ALL : FixedArray<Entity> = new FixedArray(1024);
  public static var GC : FixedArray<Entity> = new FixedArray(ALL.maxSize);

  // Various getters to access all important stuff easily
  public var app(get,never) : App; inline function get_app() return App.ME;
  public var game(get,never) : Game; inline function get_game() return Game.ME;
  public var fx(get,never) : Fx; inline function get_fx() return App.ME.fx;
  public var level(get,never) : Level; inline function get_level() return Game.ME.level;
  public var destroyed(default,null) = false;
  public var ftime(get,never) : Float; inline function get_ftime() return game.ftime;
  public var lftime(get,never) : Float; inline function get_lftime() return game.lftime;
  public var stime(get,never) : Float; inline function get_stime() return game.stime;
  public var camera(get,never) : Camera; inline function get_camera() return game.camera;

  var tmod(get,never) : Float; inline function get_tmod() return Game.ME.tmod;
  var utmod(get,never) : Float; inline function get_utmod() return Game.ME.utmod;
  public var hud(get,never) : ui.Hud; inline function get_hud() return Game.ME.hud;

  /** Cooldowns **/
  public var cd : dn.Cooldown;

  /** Cooldowns, unaffected by slowmo (ie. always in realtime) **/
  public var ucd : dn.Cooldown;

  /** Temporary gameplay affects **/
  var affects : Map<Affect,Float> = new Map();

  /** State machine. Value should only be changed using `startState(v)` **/
  public var state(default,null) : State;

  /** Unique identifier **/
  public var uid(default,null) : Int;

  /** Grid X coordinate **/
  public var cx = 0;
  /** Grid Y coordinate **/
  public var cy = 0;
  /** Sub-grid X coordinate (from 0.0 to 1.0) **/
  public var xr = 0.5;
  /** Sub-grid Y coordinate (from 0.0 to 1.0) **/
  public var yr = 1.0;
  public var xx:Float = 0.5;
  public var yy:Float = 1;

  public var screenX(get,never): Float;
  inline function get_screenX() return position.screenX;

  public var screenY(get,never): Float;
  inline function get_screenY() return position.screenY;

  var allVelocities : VelocityArray;

  public var speed(get,never):Float;
inline function get_speed() return Math.sqrt(M.pow(dxTotal,2)+M.pow(dyTotal,2));

  var position (get,default):LPoint;
  inline function get_position(){
    position.setLevelCase(cx,cy,xr,yr);
    return position;
  }

  /** Base X/Y velocity of the Entity **/
  public var vBase : Velocity;
  /** "External bump" velocity. It is used to push the Entity in some direction, independently of the "user-controlled" base velocity. **/
  public var vBump : Velocity;

  /** Last known X position of the attach point (in pixels), at the beginning of the latest fixedUpdate **/
  var lastFixedUpdateX = 0.;
  /** Last known Y position of the attach point (in pixels), at the beginning of the latest fixedUpdate **/
  var lastFixedUpdateY = 0.;

  /** If TRUE, the sprite display coordinates will be an interpolation between the last known position and the current one. This is useful if the gameplay happens in the `fixedUpdate()` (so at 30 FPS), but you still want the sprite position to move smoothly at 60 FPS or more. **/
  var interpolateSprPos = true;

  /** Total of all X velocities **/
  public var dxTotal(get,never) : Float; inline function get_dxTotal() return allVelocities.getSumX();
  /** Total of all Y velocities **/
  public var dyTotal(get,never) : Float; inline function get_dyTotal() return allVelocities.getSumY();

  /** Pixel width of entity **/
  public var wid(default,set) : Float = Const.GRID;
  inline function set_wid(v) { invalidateDebugBounds=true;  return wid=v; }
  public var iwid(get,set) : Int;
  inline function get_iwid() return M.round(wid);
  inline function set_iwid(v:Int) { invalidateDebugBounds=true; wid=v; return iwid; }

  /** Pixel height of entity **/
  public var hei(default,set) : Float = Const.GRID;
  inline function set_hei(v) { invalidateDebugBounds=true;  return hei=v; }
  public var ihei(get,set) : Int;
  inline function get_ihei() return M.round(hei);
  inline function set_ihei(v:Int) { invalidateDebugBounds=true; hei=v; return ihei; }

  public var radius (get,never):Float;

  function get_radius() return innerRadius/Const.GRID;
  
  var hitBox: {x:Float,y:Float,radius:Float};
  
  //grid based radius for collisions
  public var colRadius(get,never):Float;
  inline function get_colRadius() return largeRadius/Const.GRID;
  /** Inner radius in pixels (ie. smallest value between width/height, then divided by 2) **/
  public var innerRadius(get,never) : Float;
  inline function get_innerRadius() return M.fmin(wid,hei)*0.5;

  /** "Large" radius in pixels (ie. biggest value between width/height, then divided by 2) **/
  public var largeRadius(get,never) : Float;
  inline function get_largeRadius() return M.fmax(wid,hei)*0.5;

  /** Horizontal direction, can only be -1 or 1 **/
  public var dir(default,set) = 1;
  
  public var facing(default,set):Float = 0.0;
  inline function get_facing() return facing;
  inline function set_facing(v:Float){facing=v; return facing;}

  public var isReady:Bool = false;
  var isMoving (get,never):Bool;
  inline function get_isMoving() return vBase.len > 0;
  /** Current sprite X **/
  public var sprX(get,never) : Float;
  inline function get_sprX() {
    return interpolateSprPos
      ? M.lerp( lastFixedUpdateX, (cx+xr)*Const.GRID, game.getFixedUpdateAccuRatio() )
      : (cx+xr)*Const.GRID;
  }

  /** Current sprite Y **/
  public var sprY(get,never) : Float;
  inline function get_sprY() {
    return interpolateSprPos
      ? M.lerp( lastFixedUpdateY, (cy+yr)*Const.GRID, game.getFixedUpdateAccuRatio() )
      : (cy+yr)*Const.GRID;
  }

  /** Sprite X scaling **/
  public var sprScaleX = 1.0;
  /** Sprite Y scaling **/
  public var sprScaleY = 1.0;

  /** Sprite X squash & stretch scaling, which automatically comes back to 1 after a few frames **/
  var sprSquashX = 1.0;
  /** Sprite Y squash & stretch scaling, which automatically comes back to 1 after a few frames **/
  var sprSquashY = 1.0;

  /** Entity visibility **/
  public var entityVisible = true;

  /** Current hit points **/
  public var life(default,null) : dn.struct.Stat<Int>;
  /** Last source of damage if it was an Entity **/
  public var lastDmgSource(default,null) : Null<Entity>;

  /** Horizontal direction (left=-1 or right=1): from "last source of damage" to "this" **/
  public var lastHitDirFromSource(get,never) : Int;
  inline function get_lastHitDirFromSource() return lastDmgSource==null ? -dir : -dirTo(lastDmgSource);

  /** Horizontal direction (left=-1 or right=1): from "this" to "last source of damage" **/
  public var lastHitDirToSource(get,never) : Int;
  inline function get_lastHitDirToSource() return lastDmgSource==null ? dir : dirTo(lastDmgSource);

  /** Main entity HSprite instance **/
  public var spr : HSprite;
  public var filter:h2d.filter.Filter;
  var flashFltr:h2d.filter.Filter;
  var bloomFltr:h2d.filter.Filter;
  /** Color vector transformation applied to sprite **/
  public var baseColor : h3d.Vector;

  /** Color matrix transformation applied to sprite **/
  public var colorMatrix : h3d.Matrix;

  // Animated blink color on damage hit
  var blinkColor : h3d.Vector;

  /** Sprite X shake power **/
  var shakePowX = 0.;
  /** Sprite Y shake power **/
  var shakePowY = 0.;

  // Debug stuff
  var debugLabel : Null<h2d.Text>;
  var debugBounds : Null<h2d.Graphics>;
  var invalidateDebugBounds = false;

  var infoLabel : Null<h2d.Text>;

  /** Defines X alignment of entity at its attach point (0 to 1.0) **/
  public var pivotX(default,set) : Float = 0.5;
  /** Defines Y alignment of entity at its attach point (0 to 1.0) **/
  public var pivotY(default,set) : Float = 0.5;

  /** Entity attach X pixel coordinate **/
  public var attachX(get,never) : Float; inline function get_attachX() return (cx+xr)*Const.GRID;
  /** Entity attach Y pixel coordinate **/
  public var attachY(get,never) : Float; inline function get_attachY() return (cy+yr)*Const.GRID;

  // Various coordinates getters, for easier gameplay coding

  /** Left pixel coordinate of the bounding box **/
  public var left(get,never) : Float; inline function get_left() return attachX + (0-pivotX) * wid;
  /** Right pixel coordinate of the bounding box **/
  public var right(get,never) : Float; inline function get_right() return attachX + (1-pivotX) * wid;
  /** Top pixel coordinate of the bounding box **/
  public var top(get,never) : Float; inline function get_top() return attachY + (0-pivotY) * hei;
  /** Bottom pixel coordinate of the bounding box **/
  public var bottom(get,never) : Float; inline function get_bottom() return attachY + (1-pivotY) * hei;

  /** Center X pixel coordinate of the bounding box **/
  public var centerX(get,never) : Float; inline function get_centerX() return attachX + (0.5-pivotX) * wid;
  /** Center Y pixel coordinate of the bounding box **/
  public var centerY(get,never) : Float; inline function get_centerY() return attachY + (0.5-pivotY) * hei;

  public var icx(get,never): Int;
  inline function get_icx() return M.round(centerX);

  public var icy(get,never): Int;
  inline function get_icy() return M.round(centerY);

  /** Current X position on screen (ie. absolute)**/
  public var screenAttachX(get,never) : Float;
  inline function get_screenAttachX() return game!=null && !game.destroyed ? sprX*Const.SCALE + game.scroller.x : sprX*Const.SCALE;

  /** Current Y position on screen (ie. absolute)**/
  public var screenAttachY(get,never) : Float;
  inline function get_screenAttachY() return game!=null && !game.destroyed ? sprY*Const.SCALE + game.scroller.y : sprY*Const.SCALE;

  /** attachX value during last frame **/
  public var prevFrameAttachX(default,null) : Float = M.NEGATIVE_INFINITY();
  /** attachY value during last frame **/
  public var prevFrameAttachY(default,null) : Float = M.NEGATIVE_INFINITY();

  var actions : RecyclablePool<tools.ChargedAction>;

  public var owner(default,null): Entity;
  public var team: Int = 0;

  public var moveSpeed(get,default): Float = 1;
  public inline function get_moveSpeed() return moveSpeed;
  
  var finalSpeed(get,never): Float;
  inline function get_finalSpeed() return moveSpeed/1000;

   var moveTarget: LPoint;
  
  /**
		Constructor
   **/
  public function new(x:Int, y:Int) {
    uid = Const.makeUniqueId();
    ALL.push(this);

    cd = new dn.Cooldown(Const.FPS);
    ucd = new dn.Cooldown(Const.FPS);
    life = new Stat();

    initLife(1);
    state = Spawn;
    actions = new RecyclablePool(15, ()->new tools.ChargedAction());

    allVelocities = new VelocityArray(15);
    vBase = registerNewVelocity(VEL_Base,0.91);
    vBump = registerNewVelocity(VEL_Bump,0.9);
    vBump.immutable = true;
    spr = new HSprite(A.characters);

    setPosCase(x,y);
    Game.ME.scroller.add(spr, Const.DP_MAIN);
    
    spr.colorAdd = new h3d.Vector();
    baseColor = new h3d.Vector();
    blinkColor = new h3d.Vector();
    spr.colorMatrix = colorMatrix = h3d.Matrix.I();
    spr.setCenterRatio(pivotX, pivotY);

    flashFltr = new h2d.filter.Nothing();

    if( ui.Console.ME.hasFlag(F_Bounds) )
      enableDebugBounds();

    moveTarget = LPoint.createBoth(-1);

    setAffectS(Spawn,1,true);
  }

  function onReady(){
    isReady =true;
  }

  function setVelocityAng(id:VelocityId,ang:Float,v:Float){
    var x = Math.cos(ang)*v;
    var y = Math.sin(ang)*v;

    setVelocityXY(id,x,y);
  }

  function setVelocityXY(id:VelocityId,x:Float,y:Float){
    if( !isAlive() )
      return;

    if(allVelocities.hasVel(id) )
      allVelocities.setVel(id,x,y);

  }

  function setVelocity(id:VelocityId,vel:Velocity){
    setVelocityXY(id,vel.x,vel.y);
  }

  public function registerNewVelocity(id:VelocityId,frict:Float) : Velocity {

    var v = Velocity.createFrict(frict);
    v.id = id;
    allVelocities.push(v);
    return v;
  }

  /** Remove sprite from display context. Only do that if you're 100% sure your entity won't need the `spr` instance itself. **/
  function noSprite() {
    spr.setEmptyTexture();
    spr.remove();
  }

  public function gotoPx(x,y) {
    moveTarget.setLevelPixel(x,y);
  }

  public function gotoCase(x,y,?spd:Float) {
    moveTarget.setLevelCase(x,y, 0.5, 0.5);
  }

  function arrive(tar:LPoint):Velocity{
  //  var desired_velocity = normalize(position - target) * max_velocity

 //   steering = desired_velocity - velocity

    return Velocity.createFrict(1);
  }

  function rotate(rad:Float){
    spr.rotate(rad);
    facing+=rad;
  }

  public function rotateTowardTarget(t:LPoint) {
    facing = angTo(t);
  }

  public inline function cancelMove(reached:Bool = false) {
    moveTarget.setBoth(-1);
    if(reached)
      onTargetReached();
  }

  function onTargetReached() {}
 
  function onFragTouch(e:Entity){
    return false;
  }

  function set_pivotX(v) {
    pivotX = M.fclamp(v,0,1);
    if( spr!=null )
      spr.setCenterRatio(pivotX, pivotY);
    return pivotX;
  }

  function set_pivotY(v) {
    pivotY = M.fclamp(v,0,1);
    if( spr!=null )
      spr.setCenterRatio(pivotX, pivotY);
    return pivotY;
  }

  /** Initialize current and max hit points **/
  public function initLife(v) {
    life.initMaxOnMax(v);
  }

  public function heal(amnt:Int, from:Null<Entity>){
    if( !isAlive())
      return false;

    life.v +=amnt;

    return true;
  }

  /** Inflict damage **/
  public function hit(dmg:Int, from:Null<Entity>) :Bool{
    if( !isAlive() || dmg<=0 )
      return false;

    life.v -= dmg;
    lastDmgSource = from;
    onDamage(dmg, from);
    if( life.v<=0 )
      onDie();

    return true;
  }

  /** Kill instantly **/
  public function kill(by:Null<Entity>) {
    if( isAlive() )
      destroy();
  }

  function onTouchEntity(e:Entity):Bool{
    return true;
  }

  function onDamage(dmg:Int, from:Entity) {
    if(life.v <= 0)
      return;

    var pAng = angTo(from);
    fx.explosion(screenX,screenY,Red,pAng,irnd(dmg,dmg*3));

  }

  function onDie() {
    destroy();
  }

  public function onMouseMove(){
  }

  inline function set_dir(v) {
    return dir = v>0 ? 1 : v<0 ? -1 : dir;
  }

  /** Return TRUE if current entity wasn't destroyed or killed **/
  public inline function isAlive() {
    return !destroyed && life.v>0;
  }

  public function obstacleDistY(range:Int = 1)
  {
    for(p in -range...range)
      if(level.hasCollision(cx,cy+p))
	return p;

    return 0;
  }

  public function obstacleDistX(range:Int = 1)
  {
    for(p in -range...range)
      if(level.hasCollision(cx+p,cy))
	return p;

    return 0;
  }

  /*Move entity to grid coordinates that is not within wall or obstacle*/
  public function setSafeCase(x:Int,y:Int,padding:Int = 1){
    setPosCase(x,y);
   
    cx -= obstacleDistX(padding+M.ceil(colRadius));
    cy -= obstacleDistY(padding+M.ceil(colRadius));
  }

  public function setPosCasePt(pt:LPoint){
    cx = pt.cx;
    cy = pt.cy;
    xr = pt.xr;
    yr = pt.yr;
    onPosManuallyChangedBoth();
  }

  /** Move entity to grid coordinates **/
  public function setPosCase(x:Int, y:Int) {
    cx = x;
    cy = y;
    xr = 0.5;
    yr = 1;
    onPosManuallyChangedBoth();
  }

  /** Move entity to pixel coordinates **/
  public function setPosPixel(x:Float, y:Float) {
    cx = Std.int(x/Const.GRID);
    cy = Std.int(y/Const.GRID);
    xr = (x-cx*Const.GRID)/Const.GRID;
    yr = (y-cy*Const.GRID)/Const.GRID;
    onPosManuallyChangedBoth();
  }

  /** Should be called when you manually (ie. ignoring physics) modify both X & Y entity coordinates **/
  function onPosManuallyChangedBoth() {
    if( M.dist(attachX,attachY,prevFrameAttachX,prevFrameAttachY) > Const.GRID*2 ) {
      prevFrameAttachX = attachX;
      prevFrameAttachY = attachY;
    }
    updateLastFixedUpdatePos();

    position = LPoint.fromCase(xx,yy);
  }

  /** Should be called when you manually (ie. ignoring physics) modify entity X coordinate **/
  function onPosManuallyChangedX() {
    if( M.fabs(attachX-prevFrameAttachX) > Const.GRID*2 )
      prevFrameAttachX = attachX;
    lastFixedUpdateX = attachX;
  }

  /** Should be called when you manually (ie. ignoring physics) modify entity Y coordinate **/
  function onPosManuallyChangedY() {
    if( M.fabs(attachY-prevFrameAttachY) > Const.GRID*2 )
      prevFrameAttachY = attachY;
    lastFixedUpdateY = attachY;
  }


  /** Quickly set X/Y pivots. If Y is omitted, it will be equal to X. **/
  public function setPivots(x:Float, ?y:Float) {
    pivotX = x;
    pivotY = y!=null ? y : x;
  }

  public inline function isOnLevel(){
    return game.level.isValid(cx,cy);
  }

  /** Return TRUE if the Entity *center point* is in screen bounds (default padding is +32px) **/
  public inline function isOnScreenCenter(padding=32) {
    return camera.isOnScreen( centerX, centerY, padding + M.fmax(wid*0.5, hei*0.5) );
  }

  /** Return TRUE if the Entity rectangle is in screen bounds (default padding is +32px) **/
  public inline function isOnScreenBounds(padding=32) {
    return camera.isOnScreenRect( left,top, wid, hei, padding );
  }

  public function newOwner(o:Entity) : Bool{
    if(o==owner)
      return true;

    var old = owner;
    owner = o;
    onOwnerChange(old,owner);
    return true;
  }

  function onOwnerChange(old:Entity,newOwner:Entity){}
  /**
		Changed the current entity state.
		Return TRUE if the state is `s` after the call.
   **/
  public function startState(s:State) : Bool {
    if( s==state )
      return false;

    if( !canChangeStateTo(state, s) )
      return false;

    var old = state;
    state = s;
    onStateChange(old,state);
    return true;
  }


  /** Return TRUE to allow a change of the state value **/
  function canChangeStateTo(from:State, to:State) {
    if(to==Spawn)
      return false;

    return true;
  }

  /** Called when state is changed to a new value **/
  function onStateChange(old:State, newState:State) {
    switch(old){
      case Spawn:
	clearAffect(Spawn,false);
	onReady();
      default:
    }
  }

  /** Apply a bump/kick force to entity **/
  public function bump(x:Float,y:Float) {
    vBump.addXY(x,y);
  }

  public function redirect(x:Float,y:Float){
    vBase.addXY(x,y);
  }
  
  /** Reset velocities to zero **/
  public function cancelVelocities() {
    allVelocities.clearAll();
  }

  public function is<T:Entity>(c:Class<T>) return Std.isOfType(this, c);
  public function as<T:Entity>(c:Class<T>) : T return Std.downcast(this, c);

  /** Return a random Float value in range [min,max]. If `sign` is TRUE, returned value might be multiplied by -1 randomly. **/
  public inline function rnd(min,max,?sign) return Lib.rnd(min,max,sign);
  /** Return a random Integer value in range [min,max]. If `sign` is TRUE, returned value might be multiplied by -1 randomly. **/
  public inline function irnd(min,max,?sign) return Lib.irnd(min,max,sign);

  /** Truncate a float value using given `precision` **/
  public inline function pretty(value:Float,?precision=1) return M.pretty(value,precision);

  public inline function dirTo(e:Entity) return e.centerX<centerX ? -1 : 1;
  public inline function dirToX(?e:LPoint,x:Int=0){
    if(e!=null)
      return e.levelX<centerX ? -1 : 1;
    else
      return x<xx? -1:1;
  }

  public inline function dirToY(?e:LPoint,y:Int=0){
    if(e!=null)
      return e.levelY<centerY ? -1 : 1;
    else
      return y<yy ? -1:1;
  }

  public inline function dirToAng() return dir==1 ? 0. : M.PI;
  public inline function getMoveAng() return Math.atan2(dyTotal,dxTotal);

  public inline function getFacingRads(){
    return Math.atan2(-vBase.dy,vBase.dx);
  }

  public inline function angTo(?e:Entity,?pt:LPoint, tx=0.,ty=0.)
  {
    if( e!=null )
      return Math.atan2((e.cy+e.yr)-yy, (e.cx+e.xr)-xx );
    else if( pt!=null )
      return Math.atan2(pt.cyf-yy, pt.cxf-xx);
    else
      return Math.atan2(ty-yy, tx-xx);

  }
  /** Return a distance (in grid cells) from this to something **/
  public inline function distCase(?e:Entity, ?tcx:Int, ?tcy:Int, txr=0.5, tyr=0.5) {
    if( e!=null )
      return M.dist(cx+xr, cy+yr, e.cx+e.xr, e.cy+e.yr);
    else
      return M.dist(cx+xr, cy+yr, tcx+txr, tcy+tyr);
  }

  public inline function fastDistPx(e:Entity) : Float {
    return M.fabs(attachX-e.attachX) + M.fabs(attachY-e.attachY);
  }
 
  public inline function fastDistCase(e:Entity){
    return M.fabs(cx-e.cx)+M.fabs(cy-e.cy);
  }

  /** Return a distance (in pixels) from this to something **/
  public inline function distPx(?e:Entity, ?x:Float, ?y:Float) {
    if( e!=null )
      return M.dist(attachX, attachY, e.attachX, e.attachY);
    else
      return return M.dist(attachX, attachY, x, y);
  }

  function getDistClosestPoint(p1:LPoint, p2:LPoint,e:Entity){
// Find the closest point on the rectangle to the center of the circle
    final closestX = M.fclamp(e.xx, p1.cxf, p2.cxf);
    final closestY = M.fclamp(e.yy, p1.cyf, p2.cyf);

    // Calculate the distance between the closest point and the center of the circle
    var dx = closestX - e.xx;
    var dy = closestY - e.yy;
    return Math.sqrt( dx*dx + dy*dy );
  }
  function canSeeThrough(cx:Int, cy:Int) {
    return !level.hasCollision(cx,cy) || this.cx==cx && this.cy==cy;
  }

 /** Create a LPoint instance from current coordinates **/
  public inline function createPoint() return LPoint.fromCase(cx+xr,cy+yr);

  /** Create a LRect instance from current entity bounds **/
  public inline function createRect() return tools.LRect.fromPixels( Std.int(left), Std.int(top), Std.int(wid), Std.int(hei) );

  function fade(amnt:Float=.1){
    spr.alpha -= amnt;
  }

  public final function destroy() {
    if( !destroyed ) {
      destroyed = true;
      GC.push(this);
    }
  }

  function checkEntityCollision(cb:Dynamic->Void,len:Float=0.){
    var d = 0.;

    for(e in ALL) {
      if( e==this && e.team == team)
	continue;

      if( fastDistPx(e)>len+Const.GRID*2 )
	continue;

      d = M.dist(xx, yy, e.xx, e.yy);
      if( d>len+radius+e.radius )
	continue;

      cb(e);
    }
  }
  //TODO Every once in a while this code throws a null access error 
  public function dispose() {
    try{
      ALL.remove(this);

      allVelocities.dispose();
      allVelocities = null;
      baseColor = null;
      blinkColor = null;
      colorMatrix = null;
      filter = null;

      spr.remove();
      spr = null;

      if( debugLabel!=null ) {
	debugLabel.remove();
	debugLabel = null;
      }

      if( infoLabel!=null){
	infoLabel.remove();
	infoLabel = null;
      }

      if( debugBounds!=null ) {
	debugBounds.remove();
	debugBounds = null;
      }

      cd.dispose();
      cd = null;

      ucd.dispose();
      ucd = null;
      onDispose();
    }
    catch(e){
      App.ME.onError(e);
    }
  }

  function onDispose(){}

  /** Print some numeric value below entity **/
  public inline function debugFloat(v:Float, c:Col=0xffffff) {
    debug( pretty(v), c );
  }


  /** Print some value below entity **/
  public inline function debug(?v:Dynamic, c:Col=0xffffff) {
    #if debug
    if( v==null && debugLabel!=null ) {
      debugLabel.remove();
      debugLabel = null;
    }
    if( v!=null && !cd.hasSetF('debugText',10)) {
      if( debugLabel==null ) {
	debugLabel = new h2d.Text(Assets.fontPixel, Game.ME.scroller);
	debugLabel.filter = new dn.heaps.filter.PixelOutline();
      }
      debugLabel.text = Std.string(v);
      debugLabel.textColor = c;
    }
    #end
  }

  public inline function info(?text:String, c:Col=White,offsetX:Int, offsetY:Int, frames:Int){
    if(infoLabel == null){
      infoLabel = new h2d.Text(Assets.fontPixel, Game.ME.scroller);
      infoLabel.filter = new dn.heaps.filter.PixelOutline();
    }
    infoLabel.text = text;
    infoLabel.textColor = c;

  }

  /** Hide entity info bounds **/
  public function disableDebugBounds() {
    if( debugBounds!=null ) {
      debugBounds.remove();
      debugBounds = null;
      entityVisible = true;
    }
  }


  /** Show entity debug bounds (position and width/height). Use the `/bounds` command in Console to enable them. **/
  public function enableDebugBounds() {
    if( debugBounds==null ) {
      //entityVisible = false;
      debugBounds = new h2d.Graphics();
      game.scroller.add(debugBounds, Const.DP_TOP);
    }
    invalidateDebugBounds = true;
  }

  function renderDebugBounds() {
    var c = Col.fromHsl((uid%20)/20, 1, 1);
    debugBounds.clear();

    // Bounds rect
    debugBounds.lineStyle(1, c, 0.5);
    debugBounds.drawRect(left-attachX, top-attachY, wid, hei);
  }
  
  function chargeActionF(id:ChargedActionId, frames:Int, onComplete:ChargedAction->Void, ?onProgress:ChargedAction->Void) {
    var sec = frames/Const.FPS;
    chargeAction(id,sec,onComplete,onProgress);
  }
  
  /** Wait for `sec` seconds, then runs provided callback. **/
  function chargeAction(id:ChargedActionId, sec:Float, onComplete:ChargedAction->Void, ?onProgress:ChargedAction->Void) {
    if( !isAlive() )
      return;

    if( isChargingAction(id) )
      cancelAction(id);

    var a = actions.alloc();
    a.id = id;
    a.onComplete = onComplete;
    a.durationS = sec;
    if( onProgress!=null )
      a.onProgress = onProgress;
  }

  /** If id is null, return TRUE if any action is charging. If id is provided, return TRUE if this specific action is charging nokw. **/
  public function isChargingAction(?id:ChargedActionId) {
    if( !isAlive() )
      return false;

    if( id==null )
      return actions.allocated>0;

    for(a in actions)
      if( a.id==id )
	return true;

    return false;
  }

  public function cancelAction(?onlyId:ChargedActionId) {
    if( !isAlive() )
      return;

    if( onlyId==null )
      actions.freeAll();
    else {
      var i = 0;
      while( i<actions.allocated ) {
	if( actions.get(i).id==onlyId )
	  actions.freeIndex(i);
	else
	  i++;
      }
    }
  }

  /** Action management loop **/
  function updateActions() {
    if( !isAlive() )
      return;

    var i = 0;
    while( i<actions.allocated ) {
      if( actions.get(i).update(tmod) )
	actions.freeIndex(i);
      else
	i++;
    }
  }


  public inline function hasAffect(k:Affect) {
    return isAlive() && affects.exists(k) && affects.get(k)>0;
  }

  public inline function getAffectDurationS(k:Affect) {
    return hasAffect(k) ? affects.get(k) : 0.;
  }

  /** Add an Affect. If `allowLower` is TRUE, it is possible to override an existing Affect with a shorter duration. **/
  public function setAffectS(k:Affect, t:Float, allowLower=false) {
    if( !isAlive() || affects.exists(k) && affects.get(k)>t && !allowLower )
      return;

    if( t<=0 )
      clearAffect(k);
    else {
      var isNew = !hasAffect(k);
      affects.set(k,t);
      if( isNew )
	onAffectStart(k);
    }
  }

  /** Multiply an Affect duration by a factor `f` **/
  public function mulAffectS(k:Affect, f:Float) {
    if( hasAffect(k) )
      setAffectS(k, getAffectDurationS(k)*f, true);
  }

  public function clearAffect(k:Affect,onEnd=true) {
    if( hasAffect(k) ) {
      affects.remove(k);
      if(onEnd)
	onAffectEnd(k);
    }
  }

  /** Affects update loop **/
  function updateAffects() {
    if( !isAlive() )
      return;

    for(k in affects.keys()) {
      var t = affects.get(k);
      t-=1/Const.FPS * tmod;
      if( t<=0 )
	clearAffect(k);
      else
	affects.set(k,t);
    }
  }

  function onAffectStart(k:Affect) {}
  function onAffectEnd(k:Affect) {
    switch(k){
      case Spawn:
	startState(Normal);
      default:
    }
  }

  /** Return TRUE if the entity is active and has no status affect that prevents actions. **/
  public function isConscious() {
    return !hasAffect(Stun) && isAlive();
  }

  /** Blink `spr` briefly (eg. when damaged by something) **/
  public function blink(c:Col) {
    blinkColor.setColor(c);
    cd.setF("keepBlink",15);
  }

  public function flash(col:Col=White,rad:Int=1){
    flashFltr = new h2d.filter.Displacement(Assets.particles.getTileRandom('dirt'));
    cd.setF("keepFlash",12);
  }
  public function shakeS(xPow:Float, yPow:Float, t:Float) {
    cd.setS("shaking", t, true);
    shakePowX = xPow;
    shakePowY = yPow;
  }

  /** Briefly squash sprite on X (Y changes accordingly). "1.0" means no distorsion. **/
  public function setSquashX(scaleX:Float) {
    sprSquashX = scaleX;
    sprSquashY = 2-scaleX;
  }

  /** Briefly squash sprite on Y (X changes accordingly). "1.0" means no distorsion. **/
  public function setSquashY(scaleY:Float) {
    sprSquashX = 2-scaleY;
    sprSquashY = scaleY;
  }

  function onHitWall(){
  }
  
    /**
		"Beginning of the frame" loop, called before any other Entity update loop
   **/
  public function preUpdate() {
    ucd.update(utmod);
    cd.update(tmod);
    updateAffects();
    updateActions();


    #if debug
    // Display the list of active "affects" (with `/set affect` in console)
    if( ui.Console.ME.hasFlag(F_Affects) ) {
      var all = [state.getName()];
      for(k in affects.keys())
	all.push( k+"=>"+M.pretty( getAffectDurationS(k) , 1) );
      debug(all);
    }

    // Show bounds (with `/bounds` in console)
    if( ui.Console.ME.hasFlag(F_Bounds) && debugBounds==null )
      enableDebugBounds();

    // Hide bounds
    if( !ui.Console.ME.hasFlag(F_Bounds) && debugBounds!=null )
      disableDebugBounds();
    #end

  }

  /**
		Post-update loop, which is guaranteed to happen AFTER any preUpdate/update. This is usually where render and display is updated
   **/
  public function postUpdate() {
    spr.x = sprX;
    spr.y = sprY;
    spr.scaleX = dir*sprScaleX * sprSquashX;
    spr.scaleY = sprScaleY * sprSquashY;
    spr.visible = entityVisible;

    if(!cd.has("keepFlash"))
      flashFltr = new h2d.filter.Nothing();

    spr.filter = filter;
    sprSquashX += (1-sprSquashX) * M.fmin(1, 0.2*tmod);
    sprSquashY += (1-sprSquashY) * M.fmin(1, 0.2*tmod);

    if( cd.has("shaking") ) {
      spr.x += Math.cos(ftime*1.1)*shakePowX * cd.getRatio("shaking");
      spr.y += Math.sin(0.3+ftime*1.7)*shakePowY * cd.getRatio("shaking");
    }

    // Blink
    if( !cd.has("keepBlink") ) {
      blinkColor.r*=Math.pow(0.60, tmod);
      blinkColor.g*=Math.pow(0.55, tmod);
      blinkColor.b*=Math.pow(0.50, tmod);
    }

    // Color adds
    spr.colorAdd.load(baseColor);
    spr.colorAdd.r += blinkColor.r;
    spr.colorAdd.g += blinkColor.g;
    spr.colorAdd.b += blinkColor.b;

    setDebugPos();
    setInfoPos();
    
  }

  /**
		Loop that runs at the absolute end of the frame
   **/
  function setDebugPos(){
    // Debug label
    if( debugLabel!=null ) {
      debugLabel.x = Std.int(attachX - debugLabel.textWidth*0.5);
      debugLabel.y = Std.int(attachY+1);
    }

    // Debug bounds
    if( debugBounds!=null ) {
      if( invalidateDebugBounds ) {
	invalidateDebugBounds = false;
	renderDebugBounds();
      }
      debugBounds.x = Std.int(attachX);
      debugBounds.y = Std.int(attachY);
    }
  }
  
  function setInfoPos(){
    // Info label
    if( infoLabel!=null ) {
      infoLabel.x = Std.int(attachX - infoLabel.textWidth*0.5);
      infoLabel.y = Std.int(attachY+1);
    }
  }
  
  public function finalUpdate() {
    prevFrameAttachX = attachX;
    prevFrameAttachY = attachY;
    invalidateDebugBounds = true;
  }


  final function updateLastFixedUpdatePos() {
    lastFixedUpdateX = attachX;
    lastFixedUpdateY = attachY;
  }



  /** Called at the beginning of each X movement step **/
  function onPreStepX() {
  }

  /** Called at the beginning of each Y movement step **/
  function onPreStepY() {
  }

  function onStep(){
    //facing = getFacingRads();
  }

  /**
		Main loop, but it only runs at a "guaranteed" 30 fps (so it might not be called during some frames, if the app runs at 60fps). This is usually where most gameplay elements affecting physics should occur, to ensure these will not depend on FPS at all.
   **/
  public function fixedUpdate() {
    updateLastFixedUpdatePos();
    
    checkEntityCollision(onTouchEntity);
/**
			Stepping: any movement greater than 33% of grid size (ie. 0.33) will increase the number of `steps` here. These steps will break down the full movement into smaller iterations to avoid jumping over grid collisions.
			*/

    var baseX = allVelocities.getCappedX();
    var baseY = allVelocities.getCappedY();

    var bumpX = allVelocities.getImpulseX();
    var bumpY = allVelocities.getImpulseY();

    var tempVel = Velocity.createXY(baseX,baseY);
    if(baseX != 0 || baseY !=0)
      tempVel.truncate(finalSpeed);

    tempVel.addXY(bumpX,bumpY);
    
    var steps = M.ceil(tempVel.len / 0.33 );
    if( steps>0 ) {
      var n = 0;
      while ( n<steps ) {
	// X movement
	xr += tempVel.x / steps;

	if( tempVel.x!=0 )
	  onPreStepX(); // <---- Add X collisions checks and physics in here

	while( xr>1 ) { xr--; cx++; }
	while( xr<0 ) { xr++; cx--; }


	// Y movement
	yr += tempVel.y / steps;

	if( tempVel.y!=0 )
	  onPreStepY(); // <---- Add Y collisions checks and physics in here

	while( yr>1 ) { yr--; cy++; }
	while( yr<0 ) { yr++; cy--; }

	n++;
      }
    }

    if(isMoving)
      onStep();

    xx = cx+xr;
    yy = cy+yr;

    //position.setLevelCase(cx,cy,xr,yr);
    // Update velocities
    for(v in allVelocities){
      
      v.fixedUpdate();
    }

    tempVel = null;
  }


  /**
		Main loop running at full FPS (ie. always happen once on every frames, after preUpdate and before postUpdate)
   **/
  public function frameUpdate() {
    spr.rotation = facing+M.PIHALF;
  }
}
