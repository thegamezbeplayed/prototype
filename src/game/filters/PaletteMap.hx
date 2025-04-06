package filters;

private enum AffectedLuminanceRange {
	Full; // Default
	OnlyLights;
	OnlyShadows;
  	OnlySolid;
}

class PaletteMap extends h2d.filter.Shader<InternalShader> {
  var paletteY (default,set): Float = 0;
  inline function set_paletteY(v) return shader.paletteY = M.fclamp( v * 1/shader.gradientMap.height, 0, 1 );

  /** Gradient map intensity (0-1) **/
  public var intensity(default,set) : Float;
  inline function set_intensity(v) return shader.intensity = M.fclamp(v,0,1);

  public function new(gradientMap:h3d.mat.Texture, y:Int=0,intensity=1.0, mode:AffectedLuminanceRange = Full) {
    super( new InternalShader() );
    shader.gradientMap = gradientMap;
    this.intensity = intensity;
    shader.mode = mode.getIndex();
    paletteY = y;
  }

  override function draw(ctx:h2d.RenderContext, t:h2d.Tile):h2d.Tile {
    return super.draw(ctx, t);
  }

  public static function createGradientMapTexture(darkest:Col, brightest:Col) : h3d.mat.Texture {
    var p = hxd.Pixels.alloc(256,1, RGBA);
    for(x in 0...p.width)
      p.setPixel( x, 0, paletteInterpolation(x/(p.width-1), darkest, brightest) );
    return h3d.mat.Texture.fromPixels(p);
  }


  static inline function paletteInterpolation(ratio:Float, darkest:Col, brightest:Col, white:Col=0xffffff) : Int {
    final lightLimit = 0.78;
    if( ratio<=lightLimit )
      return darkest.interpolate(brightest, ratio/lightLimit).withAlpha(1);
    else
      return brightest.interpolate(white, (ratio-lightLimit)/(1-lightLimit)).withAlpha(1);
  }

}


// --- Shader -------------------------------------------------------------------------------
private class InternalShader extends h3d.shader.ScreenShader {
  static var SRC = {
    @param var texture : Sampler2D;
    @param var gradientMap : Sampler2D;
    @const var mode : Int;
    @param var intensity : Float;
    @param var paletteY: Float = 0;

    inline function getLum(col:Vec3) : Float {
      return col.rgb.dot( vec3(0.2126, 0.7152, 0.0722) );
    }

    function fragment() {
      var pixel : Vec4 = texture.get(calculatedUV);

      if( intensity>0 ) {
	var lum = getLum(pixel.rgb);
	var rep = gradientMap.get( vec2(lum, paletteY) );
	switch (mode){
	  case 0: // Full gradient map
	  pixelColor = vec4( mix(pixel.rgb, rep.rgb, intensity ), pixel.a);
	  case 1: // Only lights
	  pixelColor = vec4( mix(pixel.rgb, rep.rgb, intensity*lum ), pixel.a);
	  case 2: // Only shadows
	  pixelColor = vec4( mix(pixel.rgb, rep.rgb, intensity*(1-lum) ), pixel.a);
	  case 3:
	    var alpha = pixel.a;
	    if(alpha < 0.7)
	      alpha = 0.;

	    pixelColor = vec4( mix(pixel.rgb, rep.rgb, intensity*(1-lum) ), alpha);

	}
      }
      else
	pixelColor = pixel;

    }
  };
}
