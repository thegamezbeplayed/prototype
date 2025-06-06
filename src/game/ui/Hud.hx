package ui;

class Hud extends GameChildProcess {
  var flow : h2d.Flow;
  var invalidated = true;
  var topP : ui.win.SimplePanel;
  var notifications : Array<h2d.Flow> = [];
  var notifTw : dn.Tweenie;
  public var healthBar: ui.Bar;
  public var score : Float;

  var debugText : h2d.Text;

  public function new() {
    super();

    notifTw = new Tweenie(Const.FPS);

    createRootInLayers(game.root, Const.DP_UI);
    root.filter = new h2d.filter.Nothing(); // force pixel perfect rendering

    flow = new h2d.Flow(root);
    flow.debug=true;
    notifications = [];

    debugText = new h2d.Text(Assets.fontPixel, root);
    debugText.filter = new dn.heaps.filter.PixelOutline();
    clearDebug();

    // Bg
  }

  override function onResize() {
    super.onResize();
    root.setScale(Const.UI_SCALE);
  }

  /** Clear debug printing **/
  public inline function clearDebug() {
    debugText.text = "";
    debugText.visible = false;
  }

  /** Display a debug string **/
  public inline function debug(v:Dynamic, clear=true) {
    if( clear )
      debugText.text = Std.string(v);
    else
      debugText.text += "\n"+v;
    debugText.visible = true;
    debugText.x = Std.int( stageWid/Const.UI_SCALE - 4 - debugText.textWidth );
  }

  public function scorify(score:Float,lead:Int=6):String{
    return Std.string(dn.Lib.leadingZeros(M.pretty(score,0),lead));

  }

  public function alert(str:String, color:Col=0x0){
    var tf = new h2d.Text(Assets.fontPixel);
    game.scroller.add(tf, Const.DP_UI);
    tf.text = str;
    tf.setPosition(250, 200);
    tw.createMs(tf.alpha, 500|0, TEaseIn, 400).end( tf.remove );

  }

  /** Pop a quick s in the corner **/
  public function notify(str:String, color:Col=0x0) {
    // Bg
    var t = Assets.tiles.getTile( D.tiles.uiNotification );
    var f = new dn.heaps.FlowBg(t, 5, root);
    f.colorizeBg(color);
    f.paddingHorizontal = 6;
    f.paddingBottom = 4;
    f.paddingTop = 0;
    f.paddingLeft = 9;
    f.y = 4;

    // Text
    var tf = new h2d.Text(Assets.fontPixel, f);
    tf.text = str;
    tf.maxWidth = 0.6 * stageWid/Const.UI_SCALE;
    tf.textColor = 0xffffff;
    tf.filter = new dn.heaps.filter.PixelOutline( color.toBlack(0.2) );

    // Notification lifetime
    var durationS = 2 + str.length*0.04;
    var p = createChildProcess();
    notifications.insert(0,f);
    p.tw.createS(f.x, -f.outerWidth>-2, TEaseOut, 0.1);
    p.onUpdateCb = ()->{
      if( p.stime>=durationS && !p.cd.hasSetS("done",M.POSITIVE_INFINITY()) )
      p.tw.createS(f.x, -f.outerWidth, 0.2).end( p.destroy );
    }
    p.onDisposeCb = ()->{
      notifications.remove(f);
      f.remove();
    }

    // Move existing notifications
    var y = 4;
    for(f in notifications) {
      notifTw.terminateWithoutCallbacks(f.y);
      notifTw.createS(f.y, y, TEaseOut, 0.2);
      y+=f.outerHeight+1;
    }

  }

  public inline function invalidate() invalidated = true;

  function render() {}

  override function preUpdate() {
    super.preUpdate();
    notifTw.update(tmod);
  }

  override function postUpdate() {
    super.postUpdate();

    if( invalidated ) {
      invalidated = false;
      render();
    }
  }
}
