package ui.win;

class MainMenu extends ui.win.SimpleMenu {

  public function new(){
    super();
    
    content.layout = Stack;
    content.horizontalAlign = Middle;
    bgSpr.set('menu_main');
    bgFlow.padding = 16;
    bgFlow.verticalSpacing = 8;
    bgFlow.horizontalAlign = Middle;
    titleFlow.paddingTop = 8;
    titleFlow.paddingBottom = 112;
    addGraphic('settings',titleFlow,0.65);

    bodyFlow.layout = Vertical;
    bodyFlow.verticalSpacing = 128;
    bodyFlow.paddingBottom =128;
    var musicSlider = addSoundBar('Music',Const.MUSIC_VOL);
    musicSlider.onUseCb = ()->{
      Const.MUSIC_VOL = musicSlider.pct;
      Assets.setVolume(Const.SG_MUSIC,musicSlider.pct);
    };

    var fxSlider = addSoundBar('FX',Const.FX_VOL);
    fxSlider.onUseCb = ()->{
      Const.FX_VOL = fxSlider.pct;
      Assets.setVolume(Const.SG_FX0,fxSlider.pct);
      Assets.setVolume(Const.SG_FX1,fxSlider.pct);
      Assets.setVolume(Const.SG_FX2,fxSlider.pct);
      Assets.setVolume(Const.SG_FX3,fxSlider.pct);
    };

    var uiSlider = addSoundBar('UI',Const.UI_VOL);
    uiSlider.onUseCb = ()->{
      Const.UI_VOL = uiSlider.pct;
      Assets.setVolume(Const.SG_UI,uiSlider.pct);
    };
    
    footerFlow.verticalAlign = Bottom;

    addButton(null,"Exit",true,close,footerFlow);


  }

  function addSoundBar(name:String,vol:Float){
    var soundF = new h2d.Flow(bodyFlow);
    soundF.horizontalSpacing = 8;
    soundF.layout = Horizontal;
    soundF.verticalAlign = Middle;
    addText('$name Volume',White,soundF,3);
    var soundSlider = new ui.component.Slider('grn',vol,soundF,0.75);
    return soundSlider;
  }
}
