package ui;

enum WindowAlign {
  Start;
  End;
  Center;
  Fill;
}

class Window extends dn.Process {
  public var uiCtrl : UiGroupController;
  var fadeMask : h2d.Bitmap;

  public static var ALL : Array<Window> = [];
  public var fx(get,never) : Fx; inline function get_fx() return App.ME.fx;

  var uiWid(get,never) : Int; inline function get_uiWid() return M.ceil( stageWid/Const.UI_SCALE );
  var uiHei(get,never) : Int; inline function get_uiHei() return M.ceil( stageHei/Const.UI_SCALE );

  public var content: h2d.Flow;

  var ca : ControllerAccess<GameAction>;
  var mask : Null<h2d.Flow>;

  var owner: dn.Process;
  
  public var isModal(default, null) = false;
  public var canBeClosedManually = true;
  public var horizontalAlign(default,set) : WindowAlign = WindowAlign.Center;
  public var verticalAlign(default,set) : WindowAlign = WindowAlign.Center;


  public function new(modal:Bool, ?p:dn.Process) {
    var parentProc = p==null ? App.ME : p;
    super(parentProc);

    owner = parentProc;
    ALL.push(this);
    createRootInLayers(parentProc.root, Const.DP_UI);
    root.filter = new h2d.filter.Nothing(); // force pixel perfect rendering
    content = new h2d.Flow(root);
    content.backgroundTile = h2d.Tile.fromColor(0xffffff, 32,32);
    content.borderWidth = 7;
    content.borderHeight = 7;
    content.layout = Vertical;
    content.verticalSpacing = 2;
    content.onAfterReflow = onResize;
    content.enableInteractive = true;
    
    fadeMask = new h2d.Bitmap( h2d.Tile.fromColor(MidGray));

    //root.add(fadeMask, 99999);
    fadeMask.visible = false;

    ca = App.ME.controller.createAccess();
    ca.lockCondition = ()->App.ME.anyInputHasFocus() || !isActive();
    ca.lock(0.1);

    emitResizeAtEndOfFrame();
    if( modal )
      makeModal();
    
    uiCtrl = new UiGroupController(this);
    uiCtrl.customControllerLock = ()->!isActive();
  }

  function getModalIndex() {
    if( !isModal )
      return -1;

    var i = 0;
    for( w in ALL )
      if( w.isModal ) {
	if( w==this )
	  return i;
	i++;
      }
    Console.ME.error('$this has no valid modalIndex');
    return -1;
  }

  function set_horizontalAlign(v:WindowAlign) {
    if( v!=horizontalAlign ) {
      switch horizontalAlign {
	case Fill: content.minWidth = content.maxWidth = null; // clear previous constraint from onResize()
	case _:
      }
      horizontalAlign = v;
      emitResizeAtEndOfFrame();
    }
    return v;
  }

  function set_verticalAlign(v:WindowAlign) {
    if( v!=verticalAlign ) {
      switch verticalAlign {
	case Fill: content.minHeight = content.maxHeight = null; // clear previous constraint from onResize()
	case _:
      }
      verticalAlign = v;
      emitResizeAtEndOfFrame();
    }
    return v;
  }

  public function setAlign(h:WindowAlign, ?v:WindowAlign) {
    horizontalAlign = h;
    verticalAlign = v!=null ? v : h;
  }

  public function isActive() {
    return !destroyed &&  isLatestModal() ;
  }

  public function makeTransparent() {
    content.backgroundTile = null;
  }

  override function onDispose() {
    super.onDispose();

    ALL.remove(this);

    ca.dispose();
    ca = null;

    if(Game.ME != null && !hasAnyModal() )
      Game.ME.resume();

    emitResizeAtEndOfFrame();
  }

  @:keep override function toString():String {
    return isModal ? 'ModalWin${isActive()?"*":""}(${getModalIndex()})' : 'Win${isActive()?"*":""}';
  }

  function makeModal() {
    if( isModal )
      return;

    isModal = true;

    if( Game.ME != null && getModalIndex()==0 )
      Game.ME.pause();

    mask = new h2d.Flow(root);
    mask.backgroundTile = h2d.Tile.fromColor(0x0, 1, 1, 0.5);
    mask.enableInteractive = true;
    mask.interactive.onClick = _->{
      if( canBeClosedManually )
      close();
    }
    mask.interactive.enableRightButton = true;
    root.under(mask);
  }

  function isLatestModal() {
    var idx = ALL.length-1;
    while( idx>=0 ) {
      var w = ALL[idx];
      if( !w.destroyed ) {
	if( w!=this && w.isModal )
	  return false;
	if( w==this )
	  return true;
      }
      idx--;
    }
    return false;
  }

  public static function hasAnyModal() {
    for(e in ALL)
      if( !e.destroyed && e.isModal )
	return true;
    return false;
  }

  public function clearContent() {
    content.removeChildren();
  }


  override function onResize() {
    super.onResize();
    root.setScale(Const.UI_SCALE);

    // Horizontal
    if( horizontalAlign==Fill )
      content.minWidth = content.maxWidth = uiWid;

    switch horizontalAlign {
      case Start: content.x = 0;
      case End: content.x = uiWid-content.outerWidth;
      case Center: content.x = Std.int( uiWid*0.5 - content.outerWidth*0.5 + getModalIndex()*8 );
      case Fill: content.x = 0; content.minWidth = content.maxWidth = uiWid;
    }

    // Vertical
    if( verticalAlign==Fill )
      content.minHeight = content.maxHeight = uiHei;

    switch verticalAlign {
      case Start: content.y = 0;
      case End: content.y = uiHei-content.outerHeight;
      case Center: content.y = Std.int( uiHei*0.5 - content.outerHeight*0.5 + getModalIndex()*4 );
      case Fill: content.y = 0; content.minHeight = content.maxHeight = uiHei;
    }

    // Mask
    if( mask!=null ) {
      mask.minWidth = uiWid;
      mask.minHeight = uiHei;
    }
  }

  public dynamic function onClose() {}

  public function close() {
    if( !destroyed ) {
      destroy();
      onClose();
    }
  }

  public function addTextArea(label:String,onSubmit,scale:Float=1,color:Col=Black){
    new ui.component.TextArea(label,onSubmit,content);
  }

  public function addSpacer(pixels=4,?flow:h2d.Flow) {
    if(flow==null)
      flow = content;
    var f = new h2d.Flow(flow);
    f.minWidth = f.minHeight = pixels;
  }

  public function addTitle(str:String,scale:Int = 4) {
    new ui.component.Text( str.toUpperCase(), Col.coldGray(0.5), content,scale );
    addSpacer();
  }

  public function addText(str:String, col:Col=Black,?flow:h2d.Flow,scale:Float=1) {
    if(flow==null)
      flow = content;

    return new ui.component.Text( str, col, flow,scale );
  }

  public function addGraphic(graphic:String,?flow:h2d.Flow,scale:Float=0.5){
    if(flow==null)
      flow = content;

    var gr = new ui.component.Graphic(graphic,flow,scale);
  }

  public function addButton(label:String, ?tile:String, autoClose=true, cb:Void->Void,?flow:h2d.Flow,scale:Float=0.5,col:Col=Black,textSize:Int=8) {
    if(flow==null)
      flow = content;
    var bt = new ui.component.Button(label, tile,col,flow,scale,textSize);
    bt.minWidth = flow.colWidth;
    bt.onUseCb = ()->{
      if( autoClose )
      close();
      cb();
    }
    uiCtrl.registerComponent(bt);
  }

  function fadeIn(t=1.5, ?then:Void->Void) {
    root.over(fadeMask);
    fadeMask.visible = true;
    tw.createS(fadeMask.alpha, 1>0, t).end( ()->{
      fadeMask.visible = false;
      if( then!=null )
      then();
    });
  }
  function fadeOut(t=0.5, ?then:Void->Void) {
    root.over(fadeMask);
    fadeMask.visible = true;
    tw.createS(fadeMask.alpha, 0>1, t).end( then );
  }

  function skip(){}

  override function update() {
    super.update();
    if( canBeClosedManually && isModal && ca.isPressed(MenuCancel) )
      close();
  }
}
