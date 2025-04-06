package filters;


class NoiseMap extends h2d.filter.Shader<InternalShader> {
  /** Color replacement intensity for pixels closer to the center of the texture (0-1) **/
  public var innerIntensity(default,set): Float;

  /** Color replacement intensity for pixels further from the center of the texture (0-1) **/
  public var outerIntensity(default,set): Float;

  /** Threshold when switching from inner to outer intensities (defaults to 0.5) **/
  public var threshold(default,set): Float;


  public function new(noiseMap:h3d.mat.Texture, alpha=0., inner=0., outer=0.) {
    super( new InternalShader() );
    threshold = 0.5;
    shader.noiseMap=noiseMap;
    innerIntensity = inner;
    outerIntensity = outer;
  }

  inline function set_innerIntensity(v:Float) return innerIntensity = shader.innerIntensity = M.fclamp(v,0,1);
  inline function set_outerIntensity(v:Float) return outerIntensity = shader.outerIntensity = M.fclamp(v,0,1);
  inline function set_threshold(v:Float) {
    threshold = v;
    shader.threshold = M.fmax(v, 0.001);
    return v;
  }
}


// --- Shader -------------------------------------------------------------------------------
private class InternalShader extends h3d.shader.ScreenShader {
  static var SRC = {
    @param var texture : Sampler2D;
    @param var noiseMap : Sampler2D;
    @param var innerIntensity : Float;
    @param var outerIntensity : Float;
    @param var threshold : Float;


    function fragment() {
      var uv = input.uv;

      var src : Vec4  = texture.get(uv);
      var rep = noiseMap.get(vec2(distance(vec2(0.75),uv),0));
      output.color = mix(
	mix( src, rep, innerIntensity ),
	mix( src, rep, outerIntensity ),
	clamp( distance(vec2(0.5),uv) / threshold, 0, 1 )
      );
    }
  };
}
