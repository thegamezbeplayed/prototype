package assets;

import dn.heaps.slib.*;

/**
	This class centralizes all assets management (ie. art, sounds, fonts etc.)
 **/
class Assets {
  public static var SLIB = dn.heaps.assets.SfxDirectory.load("sfx",true);
  // Fonts
  public static var fontPixel : h2d.Font;
  public static var fontPixelMono : h2d.Font;

  /** Main atlas **/
  public static var tiles : SpriteLib;
  public static var icons : SpriteLib;
  public static var characters : SpriteLib;
  public static var particles : SpriteLib;

  public static var palette : h3d.mat.Texture;//SpriteLib;//Map<String,h3d.mat.Texture> = new Map();
  /** LDtk world data **/
  public static var worldData : World;


  static var texturesLoaded = false;
  static var particlesLoaded = false;

  static var _initDone = false;

  static var groups : Map<Int,Map<String,Dynamic>> = new Map();

  static var uiSfx : Map<String,Dynamic> = new Map();
  static var music : Map<String,dn.heaps.Sfx> = new Map();
  static var actionSfx1 : Map<String,Dynamic> = new Map();
  static var actionSfx0 : Map<String,Dynamic> = new Map();
  static var actionSfx2 : Map<String,Dynamic> = new Map();
  static var actionSfx3 : Map<String,Dynamic> = new Map();
  static var clickIter = 1;
  static var musicIter = 0;

  static var curSong: String;

  public static function init() {
    if( _initDone )
      return;
    _initDone = true;
    
    dn.heaps.Sfx.setGroupVolume(Const.SG_FX0, Const.FX_VOL);
    dn.heaps.Sfx.setGroupVolume(Const.SG_FX1, Const.FX_VOL);
    dn.heaps.Sfx.setGroupVolume(Const.SG_FX2, Const.FX_VOL);

    dn.heaps.Sfx.setGroupVolume(Const.SG_FX3, Const.FX_VOL);
    dn.heaps.Sfx.setGroupVolume(Const.SG_UI, 1);
    dn.heaps.Sfx.setGroupVolume(Const.SG_MUSIC, Const.MUSIC_VOL);

        // Fonts
    fontPixel = new hxd.res.BitmapFont( hxd.Res.fonts.pixel_unicode_regular_12_xml.entry ).toFont();
    fontPixelMono = new hxd.res.BitmapFont( hxd.Res.fonts.pixica_mono_regular_16_xml.entry ).toFont();

    // build sprite atlas directly from Aseprite file
    tiles = dn.heaps.assets.Aseprite.convertToSLib(Const.FPS, hxd.Res.atlas.tiles.toAseprite());
    icons = dn.heaps.assets.Aseprite.convertToSLib(Const.FPS, hxd.Res.atlas.icons.toAseprite());
    particles = dn.heaps.assets.Atlas.load('atlas/particles.atlas');

    palette = dn.heaps.assets.Atlas.load('atlas/palette.atlas').tile.getTexture();
    /*for (group in palette.getGroups()){
      var tex = palette.getTile(group.id).getTexture();
      palettes.set(group.id,tex);
    }
    */
    CastleDb.load( hxd.Res.data.entry.getText() );
    // Hot-reloading of CastleDB
    #if debug
    hxd.Res.data.watch(function() {
      // Only reload actual updated file from disk after a short delay, to avoid reading a file being written
      App.ME.delayer.cancelById("cdb");
      App.ME.delayer.addS("cdb", function() {
	CastleDb.load( hxd.Res.data.entry.getBytes().toString() );
	Const.db.reload_data_cdb( hxd.Res.data.entry.getText() );
      }, 0.2);
    });
    #end


    // Hot-reloading of `const.json`
    hxd.Res.const.watch(function() {
      // Only reload actual updated file from disk after a short delay, to avoid reading a file being written
      App.ME.delayer.cancelById("constJson");
      App.ME.delayer.addS("constJson", function() {
	Const.db.reload_const_json( hxd.Res.const.entry.getBytes().toString() );
      }, 0.2);
    });

    // LDtk init & parsing
    worldData = new World();
   // LDtk file hot-reloading
    #if debug
    var res = try hxd.Res.load(worldData.projectFilePath.substr(4)) catch(_) null; // assume the LDtk file is in "res/" subfolder
    if( res!=null )
      res.watch( ()->{
	// Only reload actual updated file from disk after a short delay, to avoid reading a file being written
	App.ME.delayer.cancelById("ldtk");
	App.ME.delayer.addS("ldtk", function() {
	  worldData.parseJson( res.entry.getText() );
	  if( Game.exists() )
	    Game.ME.onLdtkReload();
	}, 0.2);
      });
    #end
  }

  public static function reset(){
    musicIter = 0;
    curSong = null;
    for(s in groups.get(Const.SG_MUSIC))
      if(s.isPlaying())
	s.stop();
  }

  public static function loadTextures(){
    if(texturesLoaded)
      return;

    characters = dn.heaps.assets.Aseprite.convertToSLib(Const.FPS, hxd.Res.atlas.characters.toAseprite());
    texturesLoaded = true;
  } 


  public static function loadParticles(){
    if(particlesLoaded)
      return;
    particlesLoaded = true;
  } 

  /**
		Pass `tmod` value from the game to atlases, to allow them to play animations at the same speed as the Game.
		For example, if the game has some slow-mo running, all atlas anims should also play in slow-mo
   **/
  public static function update(tmod:Float) {
    if( Game.exists() && Game.ME.isPaused() )
      tmod = 0;
    
    tiles.tmod = tmod;
    icons.tmod = tmod;

    if(texturesLoaded)
      characters.tmod = tmod;

    if(particlesLoaded)
      particles.tmod = tmod;
  }

  public static function setVolume(group:Int, vol:Float){
    dn.heaps.Sfx.setGroupVolume(group,vol);
  }

  public static function playMusic(name:String,vol:Float = 1.0,bipass=false){
    var g = groups.get(Const.SG_MUSIC);
    if(g==null)
      return;

    if(!bipass && (curSong == null || curSong != '$name')){
      var song = g.get('$curSong'); 
      musicIter = 0;
      if(song!=null && song.isPlaying()){
	song.stopWithFadeOut(1);
	Game.ME.delayer.addF(function(){
	  curSong = null;
	  playMusic(name,true);
	},25);
	return;
      }
      else
	curSong = '$name$musicIter';
    }

    var s = g.get('$name$musicIter');
    if(s!=null){
      curSong = '$name$musicIter';
      s.play(false,vol*Const.ALL_VOL);
      s.onEnd(()->{
	playMusic(name,true);
      });

      musicIter=1;
    }
  }

  public static function playSoundOnTempGroup(name:String,group:Int = 1, vol:Float=1.,?overIter:Int,tmpIter=1){
    var g = groups.get(group);

    var iter = overIter!=null?overIter:clickIter;
    if(g==null)
      return;

    var s = g.get('$name$iter');
    if(s!=null)
      if(!s.togglePlayStop(false,vol*Const.ALL_VOL))
	s.playOnGroup(group+tmpIter,false,vol);
    clickIter++;
    if(clickIter>4)
      clickIter = 1;

  }
  
    public static function playSound(name:String,group:Int = 1,vol:Float = 1.,?overIter:Int){
    var g = groups.get(group);

    var iter = overIter!=null?overIter:clickIter;
    if(g==null)
      return;

    var s = g.get('$name$iter');
    if(s!=null)
      if(!s.togglePlayStop(false,vol*Const.ALL_VOL))
      s.play(false,vol*Const.ALL_VOL);
    clickIter++;
    if(clickIter>4)
      clickIter = 1;

  }
}
