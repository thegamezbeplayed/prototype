using tools.script.Script;

class Level extends GameChildProcess implements StateMachine {
  public var uid: Int;
  /** Level grid-based width**/
  public var cWid(default,null): Int;
  /** Level grid-based height **/
  public var cHei(default,null): Int;

  public var cMidY(default,null):Float;
  public var cMidX(default,null):Float;
  
  /** Level pixel width**/
  public var pxWid(default,null) : Int;
  /** Level pixel height**/
  public var pxHei(default,null) : Int;

  public var pxMidY(default,null):Float;
  public var pxMidX(default,null):Float;

  var data : World_Level;
  var tilesetSource : h2d.Tile;

  public var marks : dn.MarkerMap<LevelMark>;
  var invalidated = true;
  public var state(default,null) : State;

  var playerStart:Entity_PlayerStart;


  public function new(ldtkLevel:World.World_Level,index:Int) {
    super();
    createRootInLayers(Game.ME.scroller, Const.DP_BG);
    Game.ME.scroller.under(root);
    data = ldtkLevel; 
    uid = data.uid;

    cWid = data.l_Collisions.cWid;
    cHei = data.l_Collisions.cHei;
    cMidY = cHei/2;
    cMidX = cWid/2;
    pxWid = cWid * Const.GRID;
    pxHei = cHei * Const.GRID;
    pxMidY = pxHei/2;
    pxMidX = pxWid/2;
    tilesetSource = hxd.Res.levels.sampleWorldTiles.toAseprite().toTile();

    marks = new dn.MarkerMap(cWid, cHei);
    for(cy in 0...cHei)
      for(cx in 0...cWid) {
        if( data.l_Collisions.getInt(cx,cy)==1 )
          marks.set(M_Coll_Wall, cx,cy);
      }

    playerStart = data.l_Entities.all_PlayerStart[0];
    
   }

  public function getLevel(id:String){
    return Assets.worldData.all_worlds.SampleWorld.getLevel(id);
  }

  override function initOnceBeforeUpdate(){
    startState(Start);
  }

  function canChangeStateTo(from:State, to:State) {

    return true;
  }
  
  function onStateChange(old:State, newState:State) {
  }

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

  public function heroStart():en.Hero{
    if(playerStart ==null)
      return null;

    var hx = playerStart.cx;
    var hy = playerStart.cy;
    return new en.Hero(hx,hy);
  }

  override function onDispose() {
    super.onDispose();
    data = null;
    tilesetSource = null;
    marks.dispose();
    marks = null;
  }

  /** TRUE if given coords are in level bounds **/
  public inline function isValid(cx,cy) return cx>=0 && cx<cWid && cy>=0 && cy<cHei;

  /** Gets the integer ID of a given level grid coord **/
  public inline function coordId(cx,cy) return cx + cy*cWid;

  /** Ask for a level render that will only happen at the end of the current frame. **/
  public inline function invalidate() {
    invalidated = true;
  }

  /** Return TRUE if "Collisions" layer contains a collision value **/
  public inline function hasCollision(cx,cy) : Bool {
    return !isValid(cx,cy) ? true : marks.has(M_Coll_Wall, cx,cy);
  }

  /** Render current level**/
  function render() {
    // Placeholder level render
    root.removeChildren();
    
    var bgCol = new h2d.Bitmap(h2d.Tile.fromColor(Black,level.pxWid-1,level.pxHei-1,1));

    root.add(bgCol,Const.DP_BG);
    var tg = new h2d.TileGroup(tilesetSource, root);

    var rtg = data.l_Collisions.render(tg);


  }

  override function postUpdate() {
    super.postUpdate();

    if( invalidated ) {
      invalidated = false;
      render();

    }
  }
}
