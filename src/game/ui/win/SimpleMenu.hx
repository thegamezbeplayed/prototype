package ui.win;

class SimpleMenu extends ui.Window {

  var bgFlow : h2d.Flow;
  var titleFlow : h2d.Flow;
  var bodyFlow : h2d.Flow;
  var bgSpr : HSprite;
  var footerFlow : h2d.Flow;
  var topRightFlow : h2d.Flow;
  var headerFlow :h2d.Flow;

  var parentWin : ui.Window;

  public function new(?p:Window) {
    super(true);

    parentWin=p;

    content.padding = 1;
    content.horizontalSpacing = 4;
    content.verticalSpacing = 0;
    content.layout = Vertical;
    content.multiline = true;
    content.colWidth = 150;
   
    horizontalAlign = Center;
    verticalAlign = Center;
    makeTransparent();

    bgSpr = new HSprite(Assets.icons,content);
    bgSpr.setScale(0.65);

    bgFlow = new h2d.Flow(content);
    bgFlow.layout = Vertical;
    bgFlow.horizontalAlign = Middle;
    headerFlow = new h2d.Flow(bgFlow);
    headerFlow.layout = Horizontal;
    headerFlow.verticalAlign = Top;
    headerFlow.horizontalAlign = Right;
    //headerFlow.horizontalSpacing = 72;
    topRightFlow = new h2d.Flow(headerFlow);
    titleFlow = new h2d.Flow(headerFlow);
    topRightFlow.verticalAlign = Top;
    titleFlow.horizontalAlign = Middle;
    titleFlow.verticalAlign = Middle;
    bodyFlow = new h2d.Flow(bgFlow);
    footerFlow = new h2d.Flow(bgFlow);

    /*if(isModal)
      addButton(null,'X_blank',true,null,topRightFlow,.25);
 */
  }

  public function setColumnWidth(w:Int) {
    content.colWidth = w;
  }

  override function onResize() {
    super.onResize();
    switch verticalAlign {
      case Start,End: content.maxHeight = Std.int( 0.4 * stageHei/Const.UI_SCALE );
      case Center: content.maxHeight = Std.int( 0.8 * stageHei/Const.UI_SCALE );
      case Fill: content.maxHeight = Std.int( stageHei/Const.UI_SCALE );
    }
    
  }

  public function addCheckBox(label:String, getter:Void->Bool, setter:Bool->Void, autoClose=false) {
    var bt = new ui.component.CheckBox(label,getter,setter,content);
    bt.minWidth = content.colWidth;
    bt.onUseCb = ()->{
      if( autoClose )
      close();
    }

    uiCtrl.registerComponent(bt);
  }

}
