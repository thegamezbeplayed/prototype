package ui.component;

import hxd.Event;

class Slider extends ui.UiComponent {

  var bar: HSprite;
  var slider: HSprite;

  public var pct: Float = 1.0;
  var int : h2d.Interactive;
  var startX : Float;
  var sliderX : dn.struct.Stat<Float>;

  public function new(col:String,pct:Float,?p:h2d.Object,scale:Float){
    super(p);
    
   
    layout=Stack;
    verticalAlign = Middle;
    paddingTop = 12;
    bar = new HSprite(Assets.icons, this);
    bar.set('Bar_slider_$col');

    slider = new HSprite(Assets.icons,bar);
    slider.set('Icon_slider_$col');
    slider.y -= 8;
    sliderX = new Stat();
    sliderX.initMaxOnMax(bar.tile.width-slider.tile.width/2);
    int = new h2d.Interactive(slider.tile.width, slider.tile.height, slider);
    //int.onCheck = function(_) check();
    //int.onOut = function(_) unCheck();
    int.onPush = captureEvents;
    setScale(scale);
    setSlider(pct);
  }

  function setSlider(pct:Float){
    this.pct = pct;
    slider.x = (bar.tile.width * pct)-slider.tile.width/2;
  }

  function drag(e:Event){

    var distX = startX - e.relX;
    if(distX > bar.tile.width/8)
      distX*=0.125;

    sliderX.v-=distX;
    slider.x = sliderX.v;

  }
  
  function captureEvents(e:Event){
    e.propagate = false;

    startX = e.relX;
    Assets.playSound('click',Const.SG_UI);

    int.startCapture((e)->{
      switch(e.kind){
	case EMove:
	  drag(e);
	case ERelease:
	  int.stopCapture();
	default:
      }
    },use);
  }

  override public function onUse(){
    pct = slider.x / (bar.tile.width-slider.tile.width/2);
  }

}
