package ui.win;

class HighScoreMenu extends ui.win.SimpleMenu {

  public function new(?spr:String,?p:Window) {
    super(p);

    //content.debug = true;
   
    if(spr!=null){
      makeTransparent();
      content.layout = Stack;
      content.horizontalAlign = Middle;
      content.minWidth = bgSpr.tile.iwidth;
      bgFlow.fillWidth = true;
      bgFlow.horizontalAlign = Middle;
      bgFlow.debug = content.debug;
      bgFlow.padding = 8;
      titleFlow.paddingTop = 8;
      titleFlow.paddingBottom = 8;

      bodyFlow.layout = Vertical;
      bodyFlow.padding = 16;
      bodyFlow.paddingTop = 24;
      bodyFlow.verticalSpacing = 6;
      //bgFlow.horizontalAlign = Left;
      bgSpr.set(spr);

      footerFlow.verticalAlign = Bottom;
      addButton(null,"Exit",false,parentWin.skip,footerFlow);
    }
  }

  public function addRow(text:String, score:Float,spacing:Int=8){
    var rowFlow = new h2d.Flow(bodyFlow);
    rowFlow.layout = Horizontal;
    rowFlow.debug = content.debug;
    rowFlow.horizontalSpacing = 1;
    rowFlow.horizontalAlign = Right;
    var itemFlow = new h2d.Flow(rowFlow);
    var scoreFlow = new h2d.Flow(rowFlow);
    addText(dn.Lib.padRight(text,32),White,itemFlow,2);
    addText(Game.ME.hud.scorify(score),White,scoreFlow,2);
    addSpacer(spacing);
  }

  override function addTitle(str:String,scale:Float = 4){
    var flow = content;
    if(bgFlow!=null)
      flow = titleFlow;

    new ui.component.Text( str.toUpperCase(),White, flow,scale );
    addSpacer();
  }

  override function addTextArea(label:String,onSubmit,scale:Float=1,color:Col=Black){
    var flow = content;
    if(bgFlow!=null)
      flow=bodyFlow;

    new ui.component.TextArea(label,onSubmit,flow,scale,color);
  }

  override function onClose(){
    App.ME.startTitle();
  }
}
