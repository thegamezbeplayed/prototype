package ui.component;

class TextArea extends ui.component.Button{
  var input: h2d.TextInput;

  var area : h2d.Flow;

  public function new(label:String,onSubmit,?p:h2d.Object,scale:Float=0.5,col:Int=0xAAAAAA){
    super(label,col,p,scale);
    horizontalSpacing = 4;
    input = new h2d.TextInput(Assets.fontPixel, this);
    input.backgroundColor = 0x80808080;
    input.textColor = col;
    input.inputWidth = 32;
    this.onSubmit = onSubmit;

    input.setScale(scale);
    input.onFocus = function(_) {
      input.textColor = 0xFFFFFF;
    }
    input.onFocusLost = function(_) {
      input.textColor = 0xAAAAAA;
    }

    input.onKeyDown = function(e){
      if(e.keyCode == K.ENTER)
      {
        onSubmit(input.text);
      }
    }
  }

  dynamic function onSubmit(text:String){

  }
}
