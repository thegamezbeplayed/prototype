package ui.win;

class PauseMenu extends ui.win.SimpleMenu {

  public function new(){
    super();

    addButton(null,"Start",true,close,0.5);
    addButton(null,"Settings",false,showMenu,0.575);
    addButton(null,"Exit",true,()->{
      Game.ME.restart();
    });

  }

  function showMenu(){
    var menu = new ui.win.MainMenu();
  }

}
