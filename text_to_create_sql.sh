#!/bin/bash

if [ $# -ne 1 ];then
  echo "引数が正しくありません"
  echo "./index.sh ./text.txt"
  echo "の形で実行して下さい"
  exit;
fi

target_file=$1

if [ ! -f ${target_file} ];then
  echo "${target_file}が正しくありません"
  exit;
fi

# [TODO] seki ファイルエンコードの確認 
gcsplit ${target_file} /^#/ {*} > /dev/null

tmp=${target_file##*/}
target_dir="./_"${tmp%.*}

mkdir ${target_dir} > /dev/null 2>&1
rm ${target_dir}"/create_sql.txt" > /dev/null 2>&1

for table in `find ./ -name 'xx*'`
do
  cat ${table} | grep -v '^$' |
  awk -v table=$table -v target_dir=$target_dir '
  # ここはテキストの1行目を読み込む前に実行される.
  BEGIN {
    $str=""
    flg=0
    #print table
    if("./xx00" != table){
    # BEGIN は特殊なパターンで初期化処理などを行いたい場合に使用する.
    str=str "CREATE TABLE IF NOT EXISTS"
    }
  }

  # 1行目はテーブル処理
  NR == 1 {
    # 組み込み変数 $0 は現在読み込んでいる行の内容が設定されている.
    # また,文字列の結合はスペース区切りで並べるだけでよい.
    table_name=$1
    table_comment=$2

    gsub(/#/,"`",table_name)
    gsub(/$/,"`",table_name)
    str=str " `dev_yhunter`." table_name "("

    # next を実行すると以下のパターンマッチングを中止し次の行を読み込む.
    next
  }

  # field処理
  flg==0 {
    str=str "\n`" $1 "` " $2 " NOT NULL AUTO_INCREMENT COMMENT \"" $3 "\","
    primary_key="\nPRIMARY KEY (`" $1 "`)"
    flg=1
    next
  }
  $2 ~ /.*int.*/{
    # intの場合はunsigned(整数値のみ許可)
    str=str "\n`" $1 "` " $2 " UNSIGNED NOT NULL COMMENT \"" $3 "\","
    next
  }
  {
    # パターンを省略すると直前にnextで飛ばされていない限り必ず実行される.
    str=str "\n`" $1 "` " $2 " NOT NULL COMMENT \"" $3 "\","
  }

  # ここはテキスト全行を読み込み終わった後に実行される.
  END {
    if(table_name ~ /_t`$|_history`$|_log`$/){
      str = str "\n`create_time` datetime NOT NULL COMMENT \"作成日時\","
      str = str "\n`create_user_id` int(11) UNSIGNED NOT NULL COMMENT \"作成ID(1:web,2:batch)\","
      str = str "\n`update_time` datetime NOT NULL COMMENT \"更新日時\","
      str = str "\n`update_user_id` int(11) UNSIGNED NOT NULL COMMENT \"更新者ID(1:web,2:batch)\","
      str = str "\n`delete_flg` tinyint(4) UNSIGNED NOT NULL COMMENT \"削除フラグ(0:正常データ,1:削除データ)\","
    }

    if(table_name ~ /_m`$/){
      str = str "\n`version` int(11) UNSIGNED NOT NULL COMMENT \"更新バージョン\","
      str = str "\n`create_time` datetime NOT NULL COMMENT \"作成日時\","
      str = str "\n`create_user_id` int(11) UNSIGNED NOT NULL COMMENT \"作成ID(1:web,2:batch)\","
      str = str "\n`update_time` datetime NOT NULL COMMENT \"更新日時\","
      str = str "\n`update_user_id` int(11) UNSIGNED NOT NULL COMMENT \"更新者ID(1:web,2:batch)\","
      str = str "\n`delete_flg` tinyint(4) UNSIGNED NOT NULL COMMENT \"削除フラグ(0:正常データ,1:削除データ)\","
    }

    str=str primary_key
    #str=substr(str,1,length(str)-1)
    #print table
    if("./xx00" != table){
      # printf も使える.
      #printf("テキストは全%d行でした.\n", NR)
      str = str "\n) ENGINE=InnoDB DEFAULT CHARSET=utf8;"
      str = str "\nALTER TABLE " table_name " CHANGE `delete_flg`  `delete_flg` TINYINT( 4 ) NOT NULL DEFAULT  '0' COMMENT  \"削除フラグ(0:正常データ,1:削除データ)\";"
      str = str "\nALTER TABLE " table_name " COMMENT \"" table_comment "\";"
      str = str "\n"
      print str >> target_dir "/create_sql.txt"
    }

  }
'
done

rm -rf "xx*"
