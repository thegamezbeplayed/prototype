package tools;

/**
	A generic X/Y velocity utility class
 **/
class Velocity {
  /** Custom identifier **/
  public var id = -1;

  public var x : Float;
  public var y : Float;
  public var frictX : Float;
  public var frictY : Float;

  public var immutable:Bool = false;
  public var committed:Bool = false; //must reach 0 before being settable
  /** `v` is a convenience alias for `x` when you just need a 1D velocity **/
  public var v(get,set) : Float;
  inline function get_v() return x;
  inline function set_v(v:Float) return setBoth(v);

  /** `x` alias **/
  public var dx(get,set) : Float;
  inline function set_dx(v) return x = v;
  inline function get_dx() return x;

  /** `y` alias **/
  public var dy(get,set) : Float;
  inline function set_dy(v) return y = v;
  inline function get_dy() return y;

  /** If absolute `x` or `y` goes below this value, instead, it is set to zero during next update. **/
  public var clearThreshold = 0.0005;

  public var frict(never,set) : Float;
  inline function set_frict(v) return frictX = frictY = v;

  /** Angle in radians of the vector represented by x/y **/
  public var ang(get,never) : Float; inline function get_ang() return Math.atan2(y,x);

  /** Length of the vector represented by x/y **/
  public var len(get,never) : Float; inline function get_len() return Math.sqrt(x*x + y*y);

  /** Sign of X (-1 or 1) **/
  public var dirX(get,never) : Int; inline function get_dirX() return M.sign(x);

  /** Sign of Y (-1 or 1) **/
  public var dirY(get,never) : Int; inline function get_dirY() return M.sign(y);


  public inline function new() {
    x = y = 0;
    frict = 1;
  }

  /** Create a Velocity instance with X and Y values **/
  public static inline function createXY(x:Float, y:Float, frict=1.) {
    var v = new Velocity();
    v.set(x,y);
    v.frict = frict;
    return v;
  }
  @:deprecated("Use createXY(f)") @:noCompletion public inline function createInit(x,y,?f) createXY(x,y,f);

  /** Create a Velocity instance with an angle and a length **/
  public static inline function createAng(ang:Float, len:Float, frict=1.) {
    var v = new Velocity();
    v.setAng(ang,len);
    v.frict = frict;
    return v;
  }

  /** Create a Velocity instance with just an initial friction **/
  public static inline function createFrict(frict:Float) {
    var v = new Velocity();
    v.frict = frict;
    return v;
  }

  @:keep public function toString() {
    return 'Velocity${ id<0?"":"#"+id }(${ shortString() })';
  }

  public inline function shortString() {
    return '${ M.pretty(x,2) },${ M.pretty(y,2) }';
  }

  /** Set individual frictions **/
  public inline function setFricts(fx:Float, fy:Float) {
    frictX = fx;
    frictY = fy;
  }

  /* Multiply X/Y values by individual factors */
  public inline function mulXY(fx:Float, fy:Float) {
    x*=fx;
    y*=fy;
  }

  /** Multiply both X/Y values by a factor **/
  public inline function mul(f:Float) {
    x*=f;
    y*=f;
  }
  @:deprecated("Use mul(f)") @:noCompletion public inline function mulBoth(f:Float) mul(f);

  public inline function clear() {
    x = y = 0;
  }

  public inline function truncate(v:Float){
    if(len > v)
      setLen(v);
  }
  
  /** Add individual values to X/Y **/
  public inline function addXY(vx:Float, vy:Float) {
    x += vx;
    y += vy;
  }

  public inline function addLen(v:Float) {
    var l = len;
    var a = ang;
    x = Math.cos(a)*(l+v);
    y = Math.sin(a)*(l+v);
  }
  @:deprecated("This method is no longer implemented.") @:noCompletion public inline function addBoth(v:Float) {}

  /** Set X and Y to specific values **/
  public inline function set(x:Float, y:Float) {
    if(committed && len !=0)
      return;

    this.x = x;
    this.y = y;
  }

  /** Set both X and Y to the same value **/
  public inline function setBoth(v:Float) {
    return x = y = v;
  }

  public inline function setLen(l:Float){
    /*if(committed && len !=0)
      return;
*/
    x = Math.cos(ang)*l;
    y = Math.sin(ang)*l;

  }
  
  /** Add a vector to this one **/
  public inline function addAng(ang:Float, v:Float) {
    x += Math.cos(ang)*v;
    y += Math.sin(ang)*v;
  }

  /** Set X and Y to specific values based on given angle and current length **/
  public inline function setAng(ang:Float, v:Float) {
    x = Math.cos(ang)*v;
    y = Math.sin(ang)*v;
  }

  public inline function rotate(angInc:Float) {
    var oldAng = ang;
    var d = len;
    dx = Math.cos(oldAng+angInc) * d;
    dy = Math.sin(oldAng+angInc) * d;
  }


  /** Return true if X and Y are both below the `clearThreshold` value **/
  public inline function isZero() return M.fabs(x)<=clearThreshold  &&  M.fabs(y)<=clearThreshold;

  /** Call this method to update Velocity at fixed/constant FPS **/
  public inline function fixedUpdate(frictOverride=-1.) {
    frameUpdate(1, frictOverride);
  }

  /** Call this method to update Velocity at variable FPS **/
  public inline function frameUpdate(tmod:Float, frictOverride=-1.) {
    if( frictOverride>=0 ) {
      x *= Math.pow(frictOverride,tmod);
      y *= Math.pow(frictOverride,tmod);
    }
    else {
      x *= Math.pow(frictX,tmod);
      y *= Math.pow(frictY,tmod);
    }

    if( M.fabs(x)<clearThreshold )
      x = 0;

    if( M.fabs(y)<clearThreshold )
      y = 0;
  }

}



/**
	Array of Velocity instances, with extra helper methods.
 **/
class VelocityArray {
  var all : dn.struct.FixedArray<Velocity>;
  var _sum = 0.;

  public inline function new(size:Int) {
    all = new dn.struct.FixedArray(size);
    for(i in 0...all.allocated)
      all.set(i,new tools.Velocity());
  }

  @:keep public function toString() {
    return all.toString();
  }

  public inline function push(v:Velocity) {
    all.push(v);
  }

  public inline function remove(v:Velocity) : Bool {
    return all.remove(v);
  }

  public inline function empty() {
    all.empty();
  }

  public function dispose() {
    all.dispose();
    all = null;
  }

  /** Get the sum of all X values **/
  public inline function getSumX() {
    _sum = 0.;
    for(v in all)
      _sum+=v.x;
    return _sum;
  }

  /** Get the sum of all Y values **/
  public inline function getSumY() {
    _sum = 0.;
    for(v in all)
      _sum+=v.y;
    return _sum;
  }

  /** Get the overall "total" length of all vectors **/
  public inline function getOverallLen() {
    return Math.sqrt( getSumX()*getSumX() + getSumY()*getSumY() );
  }

  public inline function getCappedX(){
    _sum = 0.;
    for (m in all.filter(v->!v.immutable))
      _sum+=m.x;

    return _sum;
  }

  public inline function getCappedY(){
    _sum = 0.;
    for (m in all.filter(v->!v.immutable))
      _sum+=m.y;

    return _sum;
  }

  public inline function getImpulseX(){
    _sum = 0.;
    for (m in all.filter(v->v.immutable))
      _sum+=m.x;

    return _sum;
  }
  
  public inline function getImpulseY(){
    _sum = 0.;
    for (m in all.filter(v->v.immutable))
      _sum+=m.y;

    return _sum;
  }
   
  public inline function mulAll(f:Float) {
    for(v in all)
      v.mul(f);
  }

  public inline function mulAllX(f:Float) {
    for(v in all)
      v.mulXY(f,1);
  }

  public inline function mulAllY(f:Float) {
    for(v in all)
      v.mulXY(1,f);
  }

  public inline function truncate(f:Float){
    var totLen = getOverallLen();
    if(totLen > f)
      for(v in all)
      {
	if(v.immutable)
	  continue;

	var vf = (v.len/totLen)*f;
	v.setLen(vf);
      }
  }
  
  public inline function clearAll() {
    for(v in all)
      v.clear();
  }

  public inline function setVel(id:VelocityId,x:Float,y:Float){
    for(v in all)
      if(v.id == id)
	v.set(x,y);
  }

  public inline function cancelVel(id:VelocityId){
    for(v in all)
      if(v.id == id){
	v.clear();
	all.remove(v);
      }
  }
  /** Remove "zero" velocities from array **/
  public function removeZeros() {
    var i = 0;
    while( i<all.allocated ) {
      if( all.get(i).isZero() )
	all.removeIndex(i);
      else
	i++;
    }
  }

  public function hasVel(id:VelocityId){
    for(v in all)
      if(v.id == id)
	return true;

    return false;
  }
  public inline function iterator() {
    return all.iterator();
  }
}
