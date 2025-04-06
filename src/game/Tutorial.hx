using tools.script.Script;

class Tutorial extends dn.Process {
  static var DONES : Map<ObjectivesKind,Bool> = new Map();
  public static var ME : Tutorial;

  public var game(get,never) : Game; inline function get_game() return Game.ME;
  public var kidMode(get,never) : Bool; inline function get_kidMode() return Game.ME.cd.has("kid");
  public var hero(get,never) : en.Hero; inline function get_hero() return Game.ME.hero;

  public var level(get,never) : Level; inline function get_level() return Game.ME.level;

  public var cur : Objectives;

  var disable = false;


  var objectives : FixedArray<Objectives>;

  public function new() {
    super(Game.ME);

    ME = this;
    game.lockControls(900);
    objectives = FixedArray.fromArray(CastleDb.Objectives.all.toArrayCopy());
    objectives.preserveOrder = true;
  }

  public function tryToStart(k:Objectives) {
    if( disable || game.hero.destroyed )
      return false;

    if( DONES.exists(k.name) || cur!=null )
      return false;

    if(!checkPrereq(k))
      return false;

    cur = k;
    if(k.task!=null)
      for(script in k.task.order){
	Script.runAs(script.text,ME);
      }

    return true;
  }

  public function completeCurrent() {
    if( cur!=null )
      tryToComplete(cur);
  }
  
  public function tryToComplete(k:Objectives) {
    if(cur!=k || game.hero.destroyed )
      return false;


    if(k.completion!=null)
      if (!Script.runAs(k.completion.order[0].text,this))
      return false;

    objectives.remove(k);

    DONES.set(k.name,true);
    cur = null;
    //TutorialTip.clear();
    onComplete(k);
    return true;
  }

  public inline function isDoingOrDone(k:Objectives) {
    return k.name==cur.name || hasDone(k) || kidMode;
  }

  public inline function hasDone(k:Objectives) {
    if( disable || kidMode )
      return true;
    if(k==null)
      return false;

    return DONES.exists(k.name);
  }

  public inline function checkPrereq(k:Objectives){
    if(k.prequisite ==null)
      return true;

    if( hasDone(k.prequisite))
      return true;

    return false;

  }

  override function onDispose(){
    game.levelCleared();
    super.onDispose();
    if(TutorialTip.exists())
      TutorialTip.kill();
    
    DONES.clear();
    if( ME==this )
      ME = null;
  }

  function onComplete(t : Objectives):Bool{
    if(!hasDone(t))
      return false;

    if(t.on_complete!=null)
      return Script.runAs(t.on_complete.order[0].text,this);
    else
      return true;
  }

  override function update() {
    super.update();

    if( game.hero.destroyed || kidMode ) {
      destroy();
      return;
    }

    if(!hasDone(cur))
      if(cur!=null && cur.tip==null){
	tryToComplete(cur);
	return;
      }

    var o = objectives.first();
    
    if(level.ftime > o.frame && !hasDone(o))
      if(tryToStart(o)){
	if(o.tip!=null){
	  new TutorialTip(o.location_x, o.location_y, Lang.untranslated(o.tip),o.notify_frame, ()->tryToComplete(o),o.pointer_size);
	}
	return;
      }

  }
}
