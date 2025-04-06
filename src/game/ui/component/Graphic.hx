package ui.component;

class Graphic extends ui.UiComponent{

  public function new(gr:String,?p,scale:Float=0.5){
    super(p);

    spr = new HSprite(Assets.icons,this);
    spr.set(gr);
    spr.setScale(scale);
  }
}

