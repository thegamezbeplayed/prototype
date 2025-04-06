package filters;
class GlowOutline extends h2d.filter.Shader<InternalShader> {
  /** Outline color (0xRRGGBB) **/
  public var color(default, set) : Col;
  public var alpha(default, set) : Float;
  
  public var power(default, set) : Float;
  public var amount(default, set) : Float;

  /** Show left pixels of the outline (default is true) **/
  public var left(default,set) : Bool;
  /** Show right pixels of the outline (default is true) **/
  public var right(default,set) : Bool;
  /** Show top pixels of the outline (default is true) **/
  public var top(default,set) : Bool;
  /** Show bottom pixels of the outline (default is true) **/
  public var bottom(default,set) : Bool;

  /** Add a pixel-perfect outline around a h2d.Object using a shader filter **/
  public function new(color:Col=0x0, a=1.0,p=1.0,amnt=1.) {
    super( new InternalShader() );
    this.color = color;
    power = p;
    amount = amnt;
    alpha = a;
    smooth = false;
    left = true;
    right = true;
    top = false;
    bottom = true;
  }

  inline function set_color(v:Col) {
    color = v;
    shader.outlineColor = hxsl.Types.Vec4.fromColor(color);
    shader.outlineColor.a = alpha;
    return v;
  }

  inline function set_alpha(v:Float) {
    alpha = v;
    shader.outlineColor.a = v;
    return v;
  }


  inline function set_power(v:Float) {
    power = v;
    shader.power = v;
    return v;
  }


  inline function set_amount(v:Float) {
    amount = v;
    shader.amount = v;
    return v;
  }

  inline function set_left(v) {
    left = v;
    shader.leftMul = v ? 1 : 0;
    return v;
  }

  inline function set_right(v) {
    right = v;
    shader.rightMul = v ? 1 : 0;
    return v;
  }

  inline function set_top(v) {
    top = v;
    shader.topMul = v ? 1 : 0;
    return v;
  }

  inline function set_bottom(v) {
    bottom = v;
    shader.bottomMul = v ? 1 : 0;
    return v;
  }

  override function sync(ctx : h2d.RenderContext, s : h2d.Object) {
    super.sync(ctx, s);
    boundsExtend = 1;
  }

  override function draw(ctx : h2d.RenderContext, t : h2d.Tile) {
    shader.texelSize.set( 1/t.width, 1/t.height );
    return super.draw(ctx,t);
  }
}


// --- Shader -------------------------------------------------------------------------------
private class InternalShader extends h3d.shader.ScreenShader {
  static var SRC = {

    @param var texture : Sampler2D;
    @param var power : Float;
    @param var amount : Float;

    function fragment() {
      var c = texture.get(input.uv);
      var lum = c.rgb.dot(vec3(0.2126, 0.7152, 0.0722));
      output.color = vec4(c.rgb * lum.pow(power) * amount * c.a, c.a);

    }
  }
}
