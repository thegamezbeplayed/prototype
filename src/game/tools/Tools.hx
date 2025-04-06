package tools;

class Tools{

  inline public static function biasToEnds():Float {
    var r = Math.random(); // Uniform random [0, 1)
    return if (r < 0.5) Math.pow(r, 0.5) else 1.0 - Math.pow(1.0 - r, 0.5);
  }

  public static function biasedRnd(max:Int):Int {
    var choice = Std.random(max);

    // Assuming spark 10 is at index 9, re-roll with 5% chance
    if (choice == 9 && Std.random(100) < 95) {

      return Std.random(max - 1); // Force a different tile
    }

    return choice;
  }

  public static inline function biasedMinRnd(min:Float, max:Float, bias:Float = 2): Float {
    var t = Math.pow(R.rnd(0, 1), bias); // Apply bias (higher values make it skew more toward min)
    return min + t * (max - min);
}
  public static function choose<T>(choices:Array<{value:T, weight:Int}>):T {
    var totalWeight = 0;
    for (choice in choices) {
      totalWeight += choice.weight;
    }

    var rand = R.irnd(0,totalWeight);
    var cumulativeWeight = 0;

    for (choice in choices) {
      cumulativeWeight += choice.weight;
      if (rand <= cumulativeWeight) {
	return choice.value;
      }
    }

    return choices[choices.length - 1].value; // Fallback in case of precision issues
  }
}
