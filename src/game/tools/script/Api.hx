package tools.script;

/**
	Everything in this class will be available in HScript execution context.
 **/
@:keep
class Api {
  public var app(get,never):App;
  inline function get_app() return App.ME;

  public var levelWid(get,never) : Int; inline function get_levelWid() return Game.ME.level.pxWid;
  public var levelHei(get,never) : Int; inline function get_levelHei() return Game.ME.level.pxHei;
  public function either<T>(a:T,b:T,chance=0.5):T{
    return R.either(a,b,chance);
  }

  public function addCooldownF(proc:dn.Process,name:String,frames:Int){
    if(proc!=null && proc.cd!=null)
      proc.cd.setF('$name',frames);
  }

 
  public function hasCooldown(proc:dn.Process,name:String){
    if(proc!=null && proc.cd!=null)
      return proc.cd.has('$name');

    return false;
  }

 
  public function getLevel(){
    return Game.ME.level;
  }

  public function new() {}
}
