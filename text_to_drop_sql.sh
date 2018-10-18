#/bin/sh -x

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
csplit ${target_file} /^#/ {*} > /dev/null

tmp=${target_file##*/}
target_dir="./_"${tmp%.*}

mkdir ${target_dir} > /dev/null 2>&1
rm ${target_dir}"/drop_sql.txt" > /dev/null 2>&1

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
    str=str "DROP TABLE IF EXISTS"
    }
  }

  # 1行目はテーブル処理
  NR == 1 {
    # 組み込み変数 $0 は現在読み込んでいる行の内容が設定されている.
    # また,文字列の結合はスペース区切りで並べるだけでよい.
    table_name=$1

    gsub(/#/,"`",table_name)
    gsub(/$/,"`",table_name)
    str=str " `shoplist`." table_name ";"

    # next を実行すると以下のパターンマッチングを中止し次の行を読み込む.
    next
  }


  # ここはテキスト全行を読み込み終わった後に実行される.
  END {
    str=str primary_key
    #str=substr(str,1,length(str)-1)
    #print table
    if("./xx00" != table){
      # printf も使える.
      #printf("テキストは全%d行でした.\n", NR)
      print str >> target_dir "/drop_sql.txt"
    }

  }
'
done

rm -rf 'xx*'
