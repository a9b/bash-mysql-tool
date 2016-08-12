#!/usr/bin/env bash
MYSQL_HOST=localhost
MYSQL_PORT=3306
MYSQL_USER=""
MYSQL_PASS=""
MYSQL_DATABASE=""

if [ $MYSQL_PASS ]; then
connect=$(printf 'mysql --host=%s -P %s --user=%s -p%s %s -N' $MYSQL_HOST $MYSQL_PORT $MYSQL_USER $MYSQL_PASS $MYSQL_DATABASE);
else
connect=$(printf 'mysql --host=%s -P %s --user=%s %s -N' $MYSQL_HOST $MYSQL_PORT $MYSQL_USER $MYSQL_DATABASE);
fi

echo $connect;
#echo "host     : ${MYSQL_HOST}:${MYSQL_PORT}
#user     : ${MYSQL_USER}
#pass     : ${MYSQL_PASS}
#dababase : ${MYSQL_DATABASE}
#";

mysql_exec (){
local command=$*
local sql="${connect} -e \"${command}\""

eval $sql
}

str='# auto generated'
echo $str > $MYSQL_DATABASE
echo "[${MYSQL_DATABASE}]" >> $MYSQL_DATABASE;

tables=`mysql_exec "show tables;"`;
for table in ${tables}
do

echo "[${MYSQL_DATABASE}.${table}.scheme]" >> $MYSQL_DATABASE
desc=`mysql_exec "SELECT COLUMN_NAME,DATA_TYPE,COLUMN_COMMENT FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = '${table}'"`;
echo "${desc}" |awk -v OFS="" '{dq="\""; printf "  " $1 " = " dq $2 dq} $3!=""{$1=$2="";printf " # " $0} {print ""}' >> $MYSQL_DATABASE;

echo "[${MYSQL_DATABASE}.${table}.index]" >> $MYSQL_DATABASE
index=`mysql_exec "SELECT INDEX_NAME, SEQ_IN_INDEX, COLUMN_NAME FROM information_schema.statistics WHERE table_schema = '${MYSQL_DATABASE}' AND table_name = '${table}';"`;
echo "${index}" |awk -v OFS="" '{dq="\""; print "  " $1 "." $2 " = " dq $3 dq}' >> $MYSQL_DATABASE;

done