package en;

class Hero extends Entity {
  var ca : ControllerAccess<GameAction>;


  public function new(x,y) {
    super(x,y);
    moveSpeed = 999;

    vBase.setFricts(0.83,0.83);
    // Misc inits
    vBase.clearThreshold = 0.075;
    // Camera tracks this
    camera.trackEntity(this, true);
    camera.clampToLevelBounds = true;

    // Init controller
    ca = App.ME.controller.createAccess();
    ca.lockCondition = Game.isGameControllerLocked;

    // Placeholder display
    spr.set('Hero');
    startState(Normal);
  }

  override function dispose() {
    ca.dispose(); // don't forget to dispose controller accesses
    super.dispose();
  }

   /** X collisions **/
  override function onPreStepX() {
    super.onPreStepX();

    // Right collision
    if( xr>0.8 && level.hasCollision(cx+1,cy) )
      xr = 0.8;

    // Left collision
    if( xr<0.2 && level.hasCollision(cx-1,cy) )
      xr = 0.2;
  }


  /** Y collisions **/
  override function onPreStepY() {
    super.onPreStepY();

    // Land on ground
    if( yr>1 && level.hasCollision(cx,cy+1) ) {
      yr = 1;
    }

    // Ceiling collision
    if( yr<0.8 && level.hasCollision(cx,cy-1) )
      yr = 0.8;
  }

  override function preUpdate() {
    super.preUpdate();
    var stickDist = ca.getAnalogDist4(MoveLeft,MoveRight,MoveUp,MoveDown);
    var stickAng = ca.getAnalogAngle4(MoveLeft,MoveRight,MoveUp,MoveDown);

    if( stickDist>0 ) {
      setVelocityAng(VEL_Base,stickAng,finalSpeed);
      dir = ca.isDown(MoveLeft) ? -1 : ca.isDown(MoveRight) ? 1 : dir;

      facing = vBase.ang;
    }
  }
  
}
