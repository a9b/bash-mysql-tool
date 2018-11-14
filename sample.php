<?php
/**
 * 
 */
class ChallengeActionLogger extends ActionLogger {

  public function addAction($Action) {
    parent::addAction($Action);
  }

  private function battleRaidNum($Action, $User) {
  }
}

class ActionLogger {
  public function __construct() {
  }

  public function addAction($Action) {
  }
}

class Action {
  const TYPE_GET_MONEY             = 1;
  const TYPE_GET_EXP               = 2;
  const TYPE_GET_CARD_NUM          = 3;
  const TYPE_BATTLE_TENKU_NUM      = 4;
  const TYPE_BATTLE_RAID_NUM       = 5;
  const TYPE_BATTLE_RAID_DAMAGE    = 5;
  const TYPE_BATTLE_RAID_CLEAR_NUM = 6;

  private $actionType;
  private $value;

  public function __construct($actionType, $value=0) {
    $this->actionType = $actionType;
    $this->value      = $value;
  }
}

class ChallengeUserAggregater {

  private $list = [];

  public function __construct() {
    $this->challengeParentList = $this->findChallengeParent();
    $this->challengeList = $this->findChallenge();
  }

  private function findChallengeParent() {
    //start_time
    //end_time
  }

  private function findChallenge() {
  }
}

class ChallengeUser {

  private $challengeId;

  private $actionType;

  private $value;

  private $needValue;

  private $name;

  private $description;

  private $display_priority;

  public function __construct() {
  }

  public function lastActionType($actionType) {
  }

  public function isFinishedParent($parentId) {
  }

  public function isFinished($challengeId) {
  }
}

class AchievementReward {

  private $item_id;

  private $item_value;

  private $item_num;

  private $prize_set_msg;

  public function __construct($item_id,  $item_value, $item_num, $prize_set_msg) {
    $this->item_id       = $item_id;
    $this->item_value    = $item_value;
    $this->item_num      = $item_num;
    $this->prize_set_msg = $prize_set_msg;
  }
}
