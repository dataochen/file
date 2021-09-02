#!/bin/bash
#搜索的key 
key=""
log="/export/log/th_token_requester/th_token_requester_detail.log"
#选中的行数
selectdRowNum=1
#上下文默认查询行数
contextRowNum=100
#命中搜索的日志的线程名 用于筛选统一线程的日志
threadName="";
#选择的日志的日志时间 用于高亮选择的日志
seletedTime="";
#选择的日志的内容
seletedContent=""
#当前查询的内容（未处理的）
logContentLocal="";
#service cdt_search list key page selectdRowNum
list(){
clear
key=$1
page=1
if [ $2 ];then page=$2;fi
if [ $3 ];then selectdRowNum=$3;fi
num=`expr $page \* 10`
Cnum=`expr $num \* $contextRowNum \* 2 + $num`
Tnum=`expr 10 \* $contextRowNum  \* 2 + $num`
#查询命中搜索key的上下文contextRowNum行的日志（按时间倒叙） 并赋值给logContentLocal
logContentLocal=$(grep -C $contextRowNum   $key $log|sort -t " " -k 1 -rn|head -n $Cnum|tail -n $Tnum )
#echo $contextRowNum $logContentLocal
#命中搜索key的日志列表 输出并高亮搜索key 
#result=$(echo -e "$logContentLocal"|grep $key|head -n 1)
#head 10默认
result=$(echo -e "$logContentLocal"|awk "/"$key"/"|head -n $num|tail -n 10|awk -F  $key 'BEGIN {print "===cdt_log start====\n"} {print  NR" row",$1"\033[1;32m""'$key'""\033[0m"$2,"\n"}END{print "===cdt_log end====\n"}')
if [ $3 ];then detail;else echo -e "$result";fi

}

detail(){
#list
#echo $key $num $selectdRowNum
#echo $result
threadName=$(echo -e  "$result"|awk -F "[ ]" '{if($1=='$selectdRowNum')print $3 }'|awk -F "[][]" '{print $2}')
seletedTime=$(echo -e  "$result"|awk -F "[ ]" '{if($1=='$selectdRowNum')print $3 }')
#seletedContent=$(echo -e  "$result"|awk -F " row " '{if($1=='$selectdRowNum')print $2}')
#seletedContent=$(echo -e "$seletedContent")
#echo $threadName "|||"$seletedTime
#echo -e "$logContentLocal"
#resultDetail=$(echo -e "$logContentLocal"|awk "/"$threadName"/"|awk -F "[ ]+" '{print $0}')
seletedNR=$(echo -e "$logContentLocal"|awk "/"$threadName"/"|awk -F "[ ]+" '{if($1=="'$seletedTime'"){print NR}}')
seletedNRmin=$(echo -e $seletedNR|awk -F "[ ]" '{print $1}')
seletedNRmax=$(echo -e $seletedNR|awk -F "[ ]" '{print $NF}')
#echo $seletedNRmin $seletedNRmax
resultDetail=$(echo -e "$logContentLocal"|awk "/"$threadName"/"|awk -F "[ ]+" '{if(NR<='$seletedNRmax+$contextRowNum'&&NR>='$seletedNRmin-$contextRowNum'){if(NR>='$seletedNRmin'&&NR<='$seletedNRmax')print "\033[1;31m"$0 "\033[0m ";else print $0;}}')
echo -e "$resultDetail"
}
#清楚变量值 上次查询的数据
clear(){
#搜索的key 
key=""
#选中的行数
selectdRowNum=1
#上下文默认查询行数
contextRowNum=100
#命中搜索的日志的线程名 用于筛选统一线程的日志
threadName="";
#选择的日志的日志时间 用于高亮选择的日志
seletedTime="";
#当前查询的内容（未处理的）
logContentLocal="";
}
get(){
echo $log
}
# See how we were called
case "$1" in
  list)
        list $2 $3 $4
        ;;
  clear)
        clear
        ;;
  get)
	get
	;;
  *)
        echo "Usage: $0 {config|list|detail|clear}"
esac
exit 0
