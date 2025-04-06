package ui.win;

class TutorialMenu extends ui.win.SimpleMenu{

  var onCloseCb: Void->Void;

  public function new(message:String,?p:dn.Process,?closeCb:Void->Void){
    super();
    content.backgroundTile = Assets.icons.getTile("tutorial_menu");
    content.padding = 16;
    content.layout = Stack;
    content.horizontalAlign = Middle;
    content.verticalAlign = Middle;
    content.minHeight = 172;
    onClose = closeCb;
    bgFlow.verticalAlign = Middle;
    bodyFlow.layout = Vertical;
    bodyFlow.verticalSpacing = 6;
    //bodyFlow.paddingVertical = 36;
    bodyFlow.paddingRight = 9;
    
    bodyFlow.paddingLeft = 9;
    bodyFlow.paddingVertical = 16;
    bodyFlow.horizontalAlign = Middle;
    bodyFlow.verticalAlign = Middle;

    bodyFlow.maxWidth = 248;
    owner=p;
    var t = addText(message,Black,bodyFlow,2.25);
  }
  
  override function onDispose(){
    Game.ME.lockControls(1);
    //cd.dispose();
    //cd = null;
   
    super.onDispose();
  }

}

