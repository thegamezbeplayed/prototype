package ui.component;

class Text extends ui.UiComponent {

  public var text(get,default):h2d.Text;
  inline function get_text() return text;

  public function new(label:String, col:dn.Col=Black, ?p,scale:Float=1) {
    super(p);
    paddingTop = 4;
    paddingBottom = 4;
    text = new h2d.Text(Assets.fontPixelMono, this);
    text.setScale(scale);
    
    text.textColor = col;
    text.text = label;
  }
}
