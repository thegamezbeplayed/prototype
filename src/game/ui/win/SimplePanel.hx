package ui.win;

class SimplePanel extends ui.Window {

  var panels : Map<String,h2d.Flow> = new Map();
  
  public function new(bg:String,col:Int=3,?p:dn.Process){
    super(false,p);
//    content.debug = true;
    content.layout = Horizontal;

    makeTransparent();
    var left = bg+'_panel_left';
    var center = bg+'_panel_mid';
    var right = bg+'_panel_right';
    
    addPanel("Left",left);

    switch(col){
      case 3:
        addPanel("Center",center);
      case 4:
        addPanel("CenterLeft",center);
        addPanel("CenterRight",center);
    }

    addPanel("Right",right);

    for(s in panels)
      s.setScale(0.7);
    
    setAlign(Center,Start);
  }

  public function addColumn(child: h2d.Object, col:String,scale:Float = 4.){
    var colFlow = panels.get(col);

    child.setScale(scale);
    colFlow.addChild(child);
  }

  function addPanel(name:String, spr:String){

    var pFlow = new h2d.Flow(content);
    pFlow.layout = Stack;
    pFlow.horizontalAlign = Middle;
    pFlow.verticalAlign = Middle;
    pFlow.paddingBottom = 4;
    var pSpr = new HSprite(Assets.icons,pFlow);

    pSpr.set(spr);

    panels.set(name,pFlow);
  }
  
  override function onResize(){
    super.onResize();
  }
}

