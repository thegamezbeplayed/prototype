interface StateMachine{
    /** State machine. Value should only be changed using `startState(v)` **/
  public var state(default,null) : State;
  
  public function startState(s:State) : Bool;
  
  private function onStateChange(old:State, newState:State) : Void;

  private function canChangeStateTo(from:State, to:State): Bool;

}
