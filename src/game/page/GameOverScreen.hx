package page;

import dn.heaps.HParticle;

class GameOverScreen extends ui.Window {

  var menu: ui.win.HighScoreMenu;
  var score: Int;
  
  public function new() {
    super(false);

    menu = new ui.win.HighScoreMenu('menu_panel',this);
    menu.canBeClosedManually = false;
    ca.lockCondition = ()->return false;
    run();
  }

  var ready = true;
  function run() {
    score = M.round(Game.ME.hud.score);
    menu.addTitle('You scored ${Game.ME.hud.score} points!');
    saveScore(Game.ME.levelName,score);

    onResize();
  }

  function saveScore(mName:String,score:Int):Bool{
    if(Const.STEAM_API_LOADED){
      steam.Api.whenLeaderboardScoreDownloaded= addScoreRow;
      steam.SteamLeaderBoard.uploadScore(score,mName);
      return true;
    }

    return false;
  }

  public function addScoreRow(score:steam.Api.LeaderboardScore){
    menu.addRow( score.rank+": "+score.user,score.score,1);

  }

  function shake(t) {
    cd.setS("shake",t);
  }

  override function skip() {
    shake(0.1);
    fadeOut( 0.5, ()->{
      App.ME.startTitle();
      Assets.reset();
      destroy();
    });
  }

  override function onDispose() {
    menu.destroy();
    super.onDispose();
  }

  override function update() {
    super.update();

    if( ca.isKeyboardPressed(K.ESCAPE) ) {
      ca.lock();
      skip();
    }
  }
}
