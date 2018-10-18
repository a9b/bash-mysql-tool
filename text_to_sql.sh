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

./text_to_create_sql.sh ${target_file}
./text_to_drop_sql.sh ${target_file}
./text_to_data_sql.sh ${target_file} 10
./text_to_tsv.sh ${target_file}

cat ${target_file}| grep '#'|sed 's/#//g' \
|awk '{text=$1; res=""; split(text, words, /[^a-zA-Z0-9]+/); \
for(i=1; i<=length(words); i++){\
  res = res toupper(substr(words[i],1,1)) tolower(substr(words[i],2));\
}\
sub(/M$|T$/, "", res);\
print "sh make_dao.sh " res " " $1 " " "\047" $2 "\047";\
}'
