package ui.win;

class RecapMenu extends ui.win.SimpleMenu {

  var win:Bool;

  public function new(?spr:String,cleared=true) {
    super();

    win = cleared;
    
    if(spr!=null){
      makeTransparent();
      content.layout = Stack;
      content.horizontalAlign = Middle;
      content.minWidth = bgSpr.tile.iwidth;
      bgFlow.fillWidth = true;
      bgFlow.layout = Vertical;
      bgFlow.horizontalAlign = Middle;
      bgFlow.debug = content.debug;
      bgFlow.padding = 8;
      titleFlow.paddingTop = 8;
      titleFlow.paddingBottom = 24;

      bodyFlow.layout = Vertical;
      bodyFlow.padding = 32;
      bodyFlow.verticalSpacing = 16;
      //bgFlow.horizontalAlign = Left;
      bgSpr.set(spr);

      footerFlow.verticalAlign = Bottom;
      if(cleared)
        addButton(null,'Start',true,close,footerFlow); 
      
      addButton(null,"Exit",false,skip,footerFlow);
    }
  }

  public function addRow(text:String, score:Float,spacing:Int=8){
    var rowFlow = new h2d.Flow(bodyFlow);
    rowFlow.layout = Horizontal;
    rowFlow.debug = content.debug;
    rowFlow.horizontalSpacing = 4;
    rowFlow.horizontalAlign = Right;
    var itemFlow = new h2d.Flow(rowFlow);
    itemFlow.minWidth = 290;
    var scoreFlow = new h2d.Flow(rowFlow);

    addText('$text',White,itemFlow,4);
    addText(Game.ME.hud.scorify(score),White,scoreFlow,4);
    addSpacer(spacing);
  }

  override function addTitle(str:String,scale:Int = 4){
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

  override function skip(){
    Game.ME.finish();
    if(!destroyed)
      destroy();
  }

  override function onClose(){
    if(!win){
      Game.ME.finish();
      return;
    }

    if(!Game.ME.exitToLevel())
      Game.ME.finish();
  }
}
