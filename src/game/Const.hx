/**
	The Const class is a place for you to store various values that should be available everywhere in your code. Example: `Const.FPS`
 **/
class Const {
  #if !macro

  /** Default engine framerate (60) **/
  public static var FPS(get,never) : Int;
  static inline function get_FPS() return Std.int( hxd.System.getDefaultFrameRate() );

  /**
		"Fixed" updates framerate. 30fps is a good value here, as it's almost guaranteed to work on any decent setup, and it's more than enough to run any gameplay related physics.
   **/
  public static final FIXED_UPDATE_FPS = 30;

  /** Grid size in pixels **/
  public static final GRID = 16;

  static var _nextUniqueId = 0;
  /** Unique value generator **/
  public static inline function makeUniqueId() {
    return _nextUniqueId++;
  }

  /** Viewport scaling **/
  public static var SCALE(get,never) : Int;
  static inline function get_SCALE() {
    // can be replaced with another way to determine the game scaling
    var s = dn.heaps.Scaler.bestFit_i(1280);
    return s;
  }

  /** Specific scaling for top UI elements **/
  public static var UI_SCALE(get,never) : Float;
  static inline function get_UI_SCALE() {
    // can be replaced with another way to determine the UI scaling
    return dn.heaps.Scaler.bestFit_i(1280);
  }


  /** Current build information, including date, time, language & various other things **/
  public static var BUILD_INFO(get,never) : String;
  static function get_BUILD_INFO() return dn.MacroTools.getBuildInfo();


  public static var STEAM_API_LOADED=false;

  /** Game layers indexes **/
  static var _inc = 0;
  public static var DP_BG = _inc++;
  public static var DP_FX_BG = _inc++;
  public static var DP_MAIN = _inc++;
  public static var DP_HERO = _inc++;
  public static var DP_FRONT = _inc++;
  public static var DP_FX_FRONT = _inc++;
  public static var DP_TOP = _inc++;
  public static var DP_UI = _inc++;


  /** Game sound group ids */

  static var _group = 0;
  public static var SG_MUSIC = _group++;
  public static var SG_FX0 = _group++;
  public static var SG_FX1 = _group++;
  public static var SG_FX2 = _group++;
  public static var SG_FX3 = _group++;
  public static var SG_UI = _group++;

  public static var ALL_VOL = 1.0;
  public static var FX_VOL = 1.0;
  public static var UI_VOL = 1.0;
  public static var MUSIC_VOL = 1.0;

  public static var db = ConstDbBuilder.buildVar(["data.cdb", "const.json"]);

  #end
}
