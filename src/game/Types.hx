/**	This abstract enum is used by the Controller class to bind general game actions to actual keyboard keys or gamepad buttons. **/
enum abstract GameAction(Int) to Int {
  var MoveLeft;
  var MoveRight;
  var MoveUp;
  var MoveDown;
  var Atk;

  var Jump;
  var Restart;

  var MenuLeft;
  var MenuRight;
  var MenuUp;
  var MenuDown;
  var MenuOk;
  var MenuCancel;
  var Pause;

  var skipLevel;
  var OpenConsoleFlags;
  var ToggleDebugDrone;
  var DebugDroneZoomIn;
  var DebugDroneZoomOut;
  var DebugTurbo;
  var DebugSlowMo;
  var ScreenshotMode;
}

/** Entity state machine. Each entity can only have 1 active State at a time. **/
enum State{
  Spawn;
  Start;
  Normal;
  Attack;
  Seek(d:Int);
  End;
}

enum MobUpgrade{
  All;
  Leader;
  End;
}
/** Entity Affects have a limited duration in time and you can stack different affects. **/
enum abstract Affect(Int) {
  var Spawn;
  var Stun;
  var Invul;
}

enum abstract LevelMark(Int) to Int {
  var M_Coll_Wall; // 0
}

enum abstract LevelSubMark(Int) to Int {
  var SM_None; // 0
}

enum abstract SlowMoId(Int) to Int {
  var S_Default; // 0
}

enum abstract ChargedActionId(Int) to Int {
  var CA_Unknown;
  var CA_Attack;
  var CA_Move;
  var CA_Die;
  var CA_Destroy;
  var CA_Script;
}

enum abstract VelocityId(Int) to Int {
  var VEL_Base;
  var VEL_Bump;
  var VEL_Desired;
  var VEL_Avoidance;
  var VEL_Pattern;
}

typedef ScriptInfo = {script:String, delayF:Int};

typedef AttachInfo = {pt:Velocity, og:Velocity,type:String,ang:Float}//top left px and bottom right px
