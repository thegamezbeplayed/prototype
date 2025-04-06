class Game extends AppChildProcess {
  var levelIndex:Int = 0;
  public static var ME : Game;

  /** Game controller (pad or keyboard) **/
  public var ca : ControllerAccess<GameAction>;

  public var fx(get,never) : Fx; inline function get_fx() return App.ME.fx;

  /** Basic viewport control **/
  public var camera : Camera;

  /** Container of all visual game objects. Ths wrapper is moved around by Camera. **/
  public var scroller : h2d.Layers;

  /** Level data **/
  static var levels: FixedArray<World.World_Level> = new FixedArray(8);
  public var level : Level;
  public var levelName:String;
  /** UI **/
  public var hud : ui.Hud;
 
  public var hero : en.Hero;
  /** Slow mo internal values**/
  var curGameSpeed = 1.0;
  var slowMos : Map<SlowMoId, { id:SlowMoId, t:Float, f:Float }> = new Map();
  
  var interactive : h2d.Interactive;
  public var mouse: LPoint;

  public var lastMouse:	LPoint;

  public var lftime (get,never):Float;
  inline function get_lftime() if (level !=null) return level.ftime; else return ftime;
  public function new(lName = 'Intro') {
    super();
    ME = this;
    ca = App.ME.controller.createAccess();
    ca.lockCondition = isGameControllerLocked;
    createRootInLayers(App.ME.root, Const.DP_BG);
    dn.Gc.runNow();

    scroller = new h2d.Layers();
    root.add(scroller, Const.DP_BG);
    scroller.filter = new h2d.filter.Nothing(); // force rendering for pixel perfect

    camera = new Camera();
    hud = new ui.Hud();
    interactive = new h2d.Interactive(stageWid,stageHei,root);
    interactive.propagateEvents = true;
    interactive.onMove = onMouseMove;

    mouse = LPoint.fromScreen(0,0);
    lastMouse = LPoint.fromScreen(0,0);
    levels = FixedArray.fromArray(Assets.worldData.all_worlds.SampleWorld.levels.filter(l->l.f_name==levelName));

    var level = getLevel(lName);
    startLevel(level);
  }

  public function getLevel(id:String){
    return Assets.worldData.all_worlds.SampleWorld.getLevel(id);
  }

  public static function isGameControllerLocked() {
    return !exists() || ME.isPaused() || App.ME.anyInputHasFocus() || ME.cd.has('lockControls');
  }

  public function restart(){
    finish(true);
  }

  public static inline function exists() {
    return ME!=null && !ME.destroyed;
  }

  public function lockControls(frames:Int=45){
    return ME.cd.setF('lockControls',frames,true);
  }
  
  /** Load a level **/
  function startLevel(l:World.World_Level) {
    if( level!=null )
      level.destroy();

    fx.clear();

    for(e in Entity.ALL) // <---- Replace this with more adapted entity destruction (eg. keep the player alive)
      if(e.team==0)
        e.destroy();
    garbageCollectEntities();

    // <---- Here: instanciate your level entities
    if(levelIndex == 0)
      Assets.playMusic('level${l.f_name}');
    level = new Level(l,levelIndex);
    
    levelName = l.f_name;
    if(hero == null)
      hero = level.heroStart();

    camera.centerOnTarget();
    dn.Process.resizeAll();
    dn.Gc.runNow();
  }

  /** Called when either CastleDB or `const.json` changes on disk **/
  @:allow(App)
  function onDbReload() {
    hud.notify("DB reloaded");
  }

  /** Called when LDtk file changes on disk **/
  @:allow(assets.Assets)
  function onLdtkReload() {
    hud.notify("LDtk reloaded");
    if( level!=null )
      startLevel(Assets.worldData.all_worlds.SampleWorld.getLevel(level.uid) );
  }

  /** Window/app resize event **/
  override function onResize() {
    super.onResize();
  }


  /** Garbage collect any Entity marked for destruction. This is normally done at the end of the frame, but you can call it manually if you want to make sure marked entities are disposed right away, and removed from lists. **/
  public function garbageCollectEntities() {
    if( Entity.GC==null || Entity.GC.allocated==0 )
      return;

    for(e in Entity.GC)
      e.dispose();
    Entity.GC.empty();
  }

  /** Called if game is destroyed, but only at the end of the frame **/
  override function onDispose() {
    super.onDispose();
    level.destroy();
    for(e in Entity.ALL)
      e.destroy();
    garbageCollectEntities();

    if( ME==this )
      ME = null;
  }
  
  inline function updateMouse(ev:hxd.Event) {
    lastMouse.usePoint(mouse);
    mouse.setScreen(ev.relX, ev.relY);
  }

  function onMouseMove(ev:hxd.Event) {
    updateMouse(ev);
    for(e in Entity.ALL.filter(en->en.team==1)) e.onMouseMove();
  }
	
    //TODO shield still spins with mouse
  public function finish(skip=false){
    if(!skip){
      App.ME.startGameOver();
      fadeOut(0.5, ()->{
	Assets.reset();
	if(exists())
	destroy();
      });
    }
    else
      App.ME.startTitle();

  }

  public function playSound(name:String,groupId:Int=1,?iter:Int,freqCap:Int = 3){
    if( !cd.hasSetF("playSfx$groupId",freqCap) )
      Assets.playSound(name,groupId,1,iter);
  }
  
  public function exitToLevel() {
    return true;
  }

  /**
		Start a cumulative slow-motion effect that will affect `tmod` value in this Process
		and all its children.

		@param sec Realtime second duration of this slowmo
		@param speedFactor Cumulative multiplier to the Process `tmod`
   **/
  public function addSlowMo(id:SlowMoId, sec:Float, speedFactor=0.3) {
    if( slowMos.exists(id) ) {
      var s = slowMos.get(id);
      s.f = speedFactor;
      s.t = M.fmax(s.t, sec);
    }
    else
      slowMos.set(id, { id:id, t:sec, f:speedFactor });
  }


  /** The loop that updates slow-mos **/
  final function updateSlowMos() {
    // Timeout active slow-mos
    for(s in slowMos) {
      s.t -= utmod * 1/Const.FPS;
      if( s.t<=0 )
	slowMos.remove(s.id);
    }

    // Update game speed
    var targetGameSpeed = 1.0;
    for(s in slowMos)
      targetGameSpeed*=s.f;
    curGameSpeed += (targetGameSpeed-curGameSpeed) * (targetGameSpeed>curGameSpeed ? 0.2 : 0.6);

    if( M.fabs(curGameSpeed-targetGameSpeed)<=0.001 )
      curGameSpeed = targetGameSpeed;
  }


  /**
		Pause briefly the game for 1 frame: very useful for impactful moments,
		like when hitting an opponent in Street Fighter ;)
   **/
  public inline function stopFrame() {
    ucd.setS("stopFrame", 4/Const.FPS);
  }


  /** Loop that happens at the beginning of the frame **/
  override function preUpdate() {
    super.preUpdate();

    for(e in Entity.ALL) if( !e.destroyed) e.preUpdate();
  }

  /** Loop that happens at the end of the frame **/
  override function postUpdate() {
    super.postUpdate();

    // Update slow-motions
    updateSlowMos();
    baseTimeMul = ( 0.2 + 0.8*curGameSpeed ) * ( ucd.has("stopFrame") ? 0.1 : 1 );
    Assets.tiles.tmod = tmod;

    // Entities post-updates
    for(e in Entity.ALL) if( !e.destroyed) e.postUpdate();

    // Entities final updates
    for(e in Entity.ALL) if( !e.destroyed && e.isReady) e.finalUpdate();

    // Dispose entities marked as "destroyed"
    garbageCollectEntities();
  }


  /** Main loop but limited to 30 fps (so it might not be called during some frames) **/
  override function fixedUpdate() {
    try{
    super.fixedUpdate();

    // Entities "30 fps" loop
    for(e in Entity.ALL) if( !e.destroyed && e.isReady) e.fixedUpdate();
    }
    catch(e)
    App.ME.onError(e);
  }

  /** Main loop **/
  override function update() {
    try{
    super.update();

    // Entities main loop
    for(e in Entity.ALL) if( !e.destroyed && e.isReady ) e.frameUpdate();
    }
    catch(e){
      App.ME.onError(e);
    }

    // Global key shortcuts
    if( !App.ME.anyInputHasFocus() && !ui.Window.hasAnyModal() && !Console.ME.isActive() ) {
      // Attach debug drone (CTRL-SHIFT-D)
      #if debug
      if(ca.isPressed(skipLevel))
	levelCleared();
      if( ca.isPressed(ToggleDebugDrone) )
	new DebugDrone(); // <-- HERE: provide an Entity as argument to attach Drone near it
      if( ca.isPressed(Restart) )
	App.ME.startGame();

      #end

      // Restart whole game
    }
  }
}

