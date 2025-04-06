package ui.component;

class Button extends ui.UiComponent {
  var tf : h2d.Text;
  var btnFlow:h2d.Flow;

  public function new(?label:String, ?icon:String, col:dn.Col=Black, ?p:h2d.Object,scale:Float=1,textSize:Int=8) {
    super(p);
    layout = Stack;
    verticalAlign = Top;
    horizontalAlign = Middle;
    padding = 2;
    //paddingBottom = 4;

   if(icon!=null){
      spr = new HSprite(Assets.icons,this);
      spr.set('Btn_'+icon);
      spr.setScale(scale);
    }
    btnFlow = new h2d.Flow(this);
    btnFlow.layout = Stack;
    btnFlow.verticalAlign = Top;
    btnFlow.horizontalAlign = Middle;
    btnFlow.paddingTop = -8;
 
    tf = new h2d.Text(Assets.fontPixelMono, btnFlow);
    if( label!=null )
      setLabel(label, col,textSize);
  }

  public function setLabel(str:String, col:dn.Col=Black,?scale:Float=1) {
    var fontSize = scale/16;
    tf.text = str;
    tf.textColor = col;
    tf.setScale(fontSize);
  }


  override function onUse(){
    Assets.playSound('click',Const.SG_UI);
  }

  override function onFocus(){
    Assets.playSound('options',Const.SG_UI);
    super.onFocus();
  }
}
