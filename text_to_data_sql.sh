#/bin/sh -x

if [ $# -lt 1 ];then
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

recode_num=1
if [ $# -eq 2 ];then
  recode_num=$2
fi

# [TODO] seki ファイルエンコードの確認 
csplit ${target_file} /^#/ {*} > /dev/null

tmp=${target_file##*/}
target_dir="./_"${tmp%.*}

mkdir ${target_dir} > /dev/null 2>&1
rm ${target_dir}"/data_sql.txt" > /dev/null 2>&1

for table in `find ./ -name 'xx*'`
do
  let seed=${seed}+1
  cat ${table} | grep -v '^$' |
  awk -v table=$table -v target_dir=$target_dir -v recode_num=$recode_num -v seed=$seed '
  # ここはテキストの1行目を読み込む前に実行される.
  BEGIN {
    $main=""
	  $insert_str=""
    $flg=0
	  $pk=1

    #print table
    if("./xx00" != table){
    # BEGIN は特殊なパターンで初期化処理などを行いたい場合に使用する.
    main=main "INSERT INTO"
    }
  }

  # 1行目はテーブル処理
  NR == 1 {
    # 組み込み変数 $0 は現在読み込んでいる行の内容が設定されている.
    # また,文字列の結合はスペース区切りで並べるだけでよい.
    table_name=$1
    table_comment=$2
    i=0

    gsub(/#/,"`",table_name)
    gsub(/$/,"`",table_name)
    main=main " " table_name "("

    # next を実行すると以下のパターンマッチングを中止し次の行を読み込む.
    next
  }

  $2 {
    main=main "" $1 ", "
  }

  # primary_key処理
  flg==0 {
    for(pk=1; pk<=recode_num; pk++){
      insert[pk]=insert[pk] " \"" pk "\", "
    }
    flg=1
    next
  }
  $1 ~ /version|delete_flg/{
    for(pk=1; pk<=recode_num; pk++){
      insert[pk]=insert[pk] " \"0\", "
    }
	next
  }
  $1 ~ /.*_time$/{
    for(pk=1; pk<=recode_num; pk++){
      insert[pk]=insert[pk] " \"" strftime("%Y-%m-%d %H:%M:%S") "\", "
    }
    next
  }
  $1 ~ /.*_id$|.*_value$|.*_num$|.*_type$|.*_bit$|.*_priority$/{
    for(pk=1; pk<=recode_num; pk++){
      srand(pk+seed+NR)
      num=roll(10)
      insert[pk]=insert[pk] " \"" num "\", "
    }
    next
  }
  $1 ~ /.*_message$/{
    for(pk=1; pk<=recode_num; pk++){
      insert[pk]=insert[pk] " \" これはメッセージです \", "
    }
    next
  }
  $1 ~ /.*_flg$/{
    for(pk=1; pk<=recode_num; pk++){
      insert[pk]=insert[pk] " \"" 0 "\", "
    }
    next
  }
  END {
    for(pk=1; pk<=recode_num; pk++){
      insert[pk]=insert[pk] " \"1\", "
      insert[pk]=insert[pk] " \"7184108\", "
      insert[pk]=insert[pk] " \"" strftime("%Y-%m-%d %H:%M:%S") "\", "
      insert[pk]=insert[pk] " \"7184108\", "
      insert[pk]=insert[pk] " \"" strftime("%Y-%m-%d %H:%M:%S") "\", "
      insert[pk]=insert[pk] " \"" 0 "\", "
    }
  }
  {
    for(pk=1; pk<=recode_num; pk++){
      insert[pk]=insert[pk] " \" ______ \", "
    }
    next
  }

  # ここはテキスト全行を読み込み終わった後に実行される.
  END {
    #main=insert[pk](main,1,length(main)-1)
    #print table
    if("./xx00" != table){
      # printf も使える.

      #printf("テキストは全%d行でした.\n", NR)

    for(pk=1; pk<=recode_num; pk++){
      gsub(/, $/,"",insert[pk])
      insert_str=insert_str "(" insert[pk] "),\n"
    }

	  gsub(/, $/,"",main)
	  gsub(/,\n$/,"",insert_str)

    main=main " ,version "
    main=main ",create_time "
    main=main ",create_user_id "
    main=main ",update_time "
    main=main ",update_user_id "
    main=main ",delete_flg "
	  main = main  ")" " VALUES \n" insert_str ";\n"
    print main >> target_dir "/data_sql.txt"
    }

  }

  # サイコロをシミュレートする関数
  function roll(n) { return 1 + int(rand() * n) }
  function randint(n) { return int(n * rand()) }
'
done

rm -rf xx*
