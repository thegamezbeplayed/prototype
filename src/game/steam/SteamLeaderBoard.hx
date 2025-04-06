package steam;

/**
 * Steam platform support
 */
class SteamLeaderBoard {


  public function init() {}

  public static function getLeaderboard(score:steam.Api.LeaderboardScore){
    steam.Api.downloadLeaderboardScore(score.leaderboardId);
  }

  public static function uploadScore(score:Int,map:String,retrieve=true){
    var lScore = new steam.Api.LeaderboardScore(map,score,0);

    if(retrieve)
      steam.Api.whenLeaderboardScoreUploaded = getLeaderboard;

    steam.Api.uploadLeaderboardScore(lScore);

  }

  public static function setOnDownloaded(cb:steam.Api.LeaderboardScore->Void){
    steam.Api.whenLeaderboardScoreUploaded = cb;
  }

  public static function testAch(){
    steam.Api.setStatInt('TEST_STAT',1);
    var achs = ['TEST_ACH'];

    if (achs != null && achs.length > 0)
    {
      for (ach in achs) steam.Api.clearAchievement(ach);
      for (ach in achs) steam.Api.setAchievement(ach);
    }
  }

  public static function testScores(score:steam.Api.LeaderboardScore){
  }
}
