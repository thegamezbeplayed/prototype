typedef LevelSave ={
  public var name: String;
  public var level: String;
  public var score: Int;
}
typedef ScoreSave = {

  public var saves: Array<LevelSave>;

}

class Storage{

  static var gameSave: LocalStorage;
  public static var scoreSave(get,null) : ScoreSave;
  static inline function get_scoreSave() return scoreSave;
  static var _initDone = false;
  public static function init(){
    if(_initDone)
      return;
    var baseName = "high_scores`";
    // String: default value
    #if hl
    gameSave = dn.data.LocalStorage.getJsonStorage(baseName);
    #end

    if(gameSave == null)
      return;

    if(!gameSave.exists()){
      var newSave = {
        name: null,
        level:null,
        score:null
      };
      var tempSaves = new Array<LevelSave>();
      tempSaves.push(newSave);
      var tempSave = {
        saves:tempSaves
      };
      //gameSave.radObject(newSave);
      gameSave.writeObject(tempSave);
    }


    scoreSave = gameSave.readObject();
  }

  public static function getScores(name:String){
  //  steam.SteamLeaderBoard.getLeaderboard(name);
  }
  public static function saveScore(n,l,s){
    if(!gameSave.exists())
      return;

    var newSave = {
      name :n,
      level: l,
      score:s
    };
    scoreSave.saves.push(newSave);

    sortSaves(l);
    gameSave.writeObject(scoreSave);
  }

  static function sortSaves(level:String){
    scoreSave.saves.sort(function(a, b) {
      if(a.level != level) return 0;
      else if(a.score < b.score) return 1;
      else if(a.score > b.score) return -1;
      else return 0;
    });
  }
}
