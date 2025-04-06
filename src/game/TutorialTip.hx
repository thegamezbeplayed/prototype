class TutorialTip extends dn.Process {
  static var CUR : TutorialTip;
  var sx : Float;
  var sy : Float;
  var win : ui.win.SimpleMenu;

  
  var isCompleted : Void->Bool;
  public var locking : Bool;
  static var pointer : h2d.Graphics;

  public function new(?x:Float,?y:Float, txt:dn.data.GetText.LocaleString,?delay:Int=3, ?toComplete:Void->Bool,?size:Int=5) {
    super(App.ME);

    CUR = this;

    isCompleted = toComplete;

    sx = x==null ? 0 : x;
    sy = y==null ? 0 : y;
    locking = true;
    delayer.addF('notif',()->{
      Game.ME.lockControls(900);

      createRootInLayers(Game.ME.root, Const.DP_TOP);

      win = new ui.win.TutorialMenu(txt,this,unlock);
      if(x!=0){
	pointer = new h2d.Graphics(win.root);
	pointer.lineStyle(1, 0xD7CA97);
	pointer.drawCircle(0,0,size*Const.GRID);
	pointer.setPosition(sx,sy);

//	tw.createS(pointer.alpha, 0>1, 0.2);
      }
    },delay);
  }

  function unlock(){
    locking = false;
  }

  public static inline function exists(){
    return CUR!=null && !CUR.destroyed;
  }

  public static inline function kill(){
    if(CUR!=null)
      CUR.destroy();
  }
  
  override function onDispose() {
    super.onDispose();
    if( CUR==this ) CUR = null;

    if(pointer!=null)
      pointer=null;
  }

  function close() {
    if( !cd.hasSetS("lock",M.POSITIVE_INFINITY())  &&pointer!=null) {
      //tw.createS(pointer.alpha, 0, TEaseIn, 0.3);
    }
  }

  override function update() {
    super.update();

    if(locking || delayer.hasId('notif'))
      return;
    else
    if( isCompleted() ){
      close();
    }
  }
}
