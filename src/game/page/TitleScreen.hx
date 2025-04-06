package page;

import dn.heaps.HParticle;

class TitleScreen extends ui.Window {
  var bg : h2d.Bitmap;
  var box : h2d.Bitmap;
  var logo : h2d.Bitmap;

  public function new(?p:dn.Process) {
    //fadeIn();

    super(false,p);
  
    horizontalAlign = Fill;
    verticalAlign = Fill;
    content.horizontalAlign = Middle;
    content.verticalAlign = Middle;
    makeTransparent();
    var titleFlow = new h2d.Flow(content);
    var bodyFlow = new h2d.Flow(content);
    //App.ME.scene.over(content);
    bodyFlow.verticalSpacing = 12;
    titleFlow.padding = 36;


    addGraphic('title',titleFlow);
    addButton(null,"Settings",false,showMenu,0.575);
    #if hl
    addButton(null,"Exit",false,()->{
      App.ME.exit();
    });
    #end
    delayer.addF('run',run,4);
  }

  var ready = true;
  function run() {

    onResize();

  }

  function showMenu(){
    var menu = new ui.win.MainMenu();
  }

  override function skip() {
    fadeOut( 0.5, ()->{
      destroy();
      App.ME.startGame();
    });
  }
}
