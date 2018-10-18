#/bin/sh

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

for table in `find ./ -name 'xx*'`
do
  cat ${table} | grep -v '^$' |
  awk -v table=$table -v target_dir=$target_dir '
  # ここはテキストの1行目を読み込む前に実行される.
  BEGIN {
    #print table
    if("./xx00" != table){
    # BEGIN は特殊なパターンで初期化処理などを行いたい場合に使用する.
    }
  }

  # 1行目はテーブル処理
  NR == 1 {
    # 組み込み変数 NR には現在読み込んでいる行の行番号が設定されている.
    # print "1行目を読み込みました..."

    # 組み込み変数 $0 は現在読み込んでいる行の内容が設定されている.
    # また,文字列の結合はスペース区切りで並べるだけでよい.
    table_name=$1
    gsub(/#/,"",table_name)
    prifix = table_name

    # next を実行すると以下のパターンマッチングを中止し次の行を読み込む.
    next
  }

  # field処理
  $3 ~ /\[.*\]/{
    # パターンを省略すると直前にnextで飛ばされていない限り必ず実行される.
    # print $3
    match($3,/\[.*]/)
    t=substr($3,RSTART+1,RLENGTH-2)
    #print t
    num=split(t,tt,",")
    for(i=1;i<=num;i++){
      num2=split(tt[i],ttt,":")
      #print ttt[1] "\t" ttt[2]
      r[i] = join(ttt,1,2,"\t")
    }
      # ファイルの書き出し
      file_name = prifix "_" $1 ".tsv"
      #print num
      #print r[i]
      rr = join(r,1,num,"\n")
      #print rr
      print rr > target_dir "/" file_name

  }

  # ここはテキスト全行を読み込み終わった後に実行される.
  END {
    #print table
    if("./xx00" != table){
      # printf も使える.
      #printf("テキストは全%d行でした.\n", NR)
    }

  }
  
# join.awk -- 配列をつなげて文字列にする
# Arnold Robbins, arnold@gnu.org, Public Domain
# May 1993

function join(array, start, end, sep,    result, i)
{
    if (sep == "")
       sep = " "
    else if (sep == SUBSEP) # 魔法の値
       sep = ""
    result = array[start]
    for (i = start + 1; i <= end; i++)
        result = result sep array[i]
    return result
}

'

done

rm -rf xx*
