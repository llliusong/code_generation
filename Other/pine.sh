#########################################################################
# File Name: pine.sh
# Author: pine
# mail: xfhlp@sina.com  ./pine.sh -n 100 -c 10 -u http://www.ijieyb.com/
# Created Time: 2017-03-03 15:16:08
#########################################################################
#!/bin/bash

#压力测试脚本，需要及其安装Apache
echo '*==========================================================*'
echo '|  本脚本工具基于ab(Apache benchmark)，请先安装好ab, awk          |'
echo '|  注意：                                                    |'
echo '|     shell默认最大客户端数为1024                              |'
echo '|     如超出此限制，请使用管理员执行以下命令：                     |'
echo '|         ulimit -n 655350                                 |'
echo '*==========================================================*'


#暂未适配Windows
#$#	传递给脚本或函数的参数个数
#shift命令左移。比如shift 3表示原来的$4现在变成$1，原来的$5现在变成$2
#-eq 等于则为真。
#-ne 不等于则为真。
#-gt 大于则为真。
#-ge 大于等于则为真。
#-lt 小于则为真。
#-le 小于等于则为真
#read int 读取输入

#配置默认参数
# 总请求数
total_request=1000
# 并发数
concurrency=100
# 测试轮数
rounds=5
# 间隔时间
sleeptime=10
# 最小并发数
min=0
# 最大数发数
max=0
# 并发递增数
step=0
# 测试地址 http://www.ijieyb.com/
url='url'
# 测试限制时间
runtime=0
# 传输数据
postfile=''


cmd_idx=1
param_count=$#


#提示使用
function prompt_usage(){
    echo '|  命令格式：'
    echo '|  test.sh'
    echo '|      -n|--total request 总请求数，缺省 : 1000'
    echo '|      -c|--concurrency 并发数, 缺省 : 100'
    echo '|      -r|--rounds 测试次数, 缺省 : 5 次'
    echo '|      -s|-sleeptime 间隔时间(单位：秒）, 缺省 : 10 秒'
    echo '|      -i|--min 最小并发数,　缺省: 0'
    echo '|      -x|--max 最大并发数，缺省: 0'
    echo '|      -e|--step 次递增并发数'
    echo '|      -r|--runtime 总体运行时间,设置此项时最大请求数为5w'
    echo '|      -p|--postfile post数据文件路径'
    echo '|      -u|--url 测试地址'
    echo ''
    echo '  测试输出结果*.txt文件'

    exit;
}

#检查参数
function check_parameter(){
    #检查url
    if [ $url = 'url' ];then
        echo '  请输入测试url，并/以为结束'
        exit
    fi

    flag=0
    if [ $min != 0 -a $max != 0 ];then
        if [ $max -le $min ];then
            echo '最大并发数不能小于最小并发数'
            exit
        fi
        if [ $step -le 0 ];then
            echo '并发递增步长不能<=0'
            exit
        fi
        if [ $min -lt $max ];then
            flag=1
        fi
    fi
}

#接收传入参数
while [ $cmd_idx -lt $param_count ]
    do
        cmd=$1
        shift 1 #remove $1
        case $cmd in
            -n)
                total_request=$1
                shift 1;;
            -c)
                concurrency=$1
                shift 1;;
            -r)
                rounds=$1
                shift 1;;
            -i)
                min=$1
                shift 1;;
            -x)
                max=$1
                shift 1;;
            -s)
                sleeptime=$1
                shift 1;;
            -e)
                step=$1
                shift 1;;
            -p)
                postfile=$1
                shift 1;;
            -t)
                times=$1
                shift 1;;
            -u)
                url=$1
                shift 1;;
            *)
                prompt_usage;
        esac
        cmd_idx=`expr $cmd_idx + 2`
    done
#调用检查参数函数
check_parameter;

#生成ab命令串
cmd="ab -n $total_request -c $concurrency -t $sleeptime $url"

#############




echo '*======================================================*'
echo '*======================开始配置参数======================*'


echo '-----------------------------';
echo '测试参数';
echo "  总请求数：$total_request";
echo "  并发数：$concurrency";
echo "  重复次数：$rounds 次";
echo "  间隔时间：$sleeptime 秒";
echo "  测试地址：$url";
if [ $min != 0 ];then
    echo "  最小并发数：$min";
fi
if [ $max != 0 ];then
    echo "  最大并发数：$max";
fi
if [ $step != 0 ];then
    echo " 每轮并发递增：$step"
fi


echo '*======================正在进行测试======================*'



#判断有无logs这个文件夹，如果没有则创建
if [ ! -d "logs" ]; then
    mkdir logs
fi
# 指定输出文件名
datestr=`date +%Y%m%d%H%I%S`
outfile="logs/$datestr.txt";


# runtest $cmd $outfile $rounds $sleeptime
function runtest() {
    # 输出命令
    echo "";
    echo '  当前执行命令：'
    echo "  $cmd"
    echo '------------------------------'


    # 开始执行测试
    cnt=1
    while [ $cnt -le $rounds ];
    do
        echo "第 $cnt 轮 开始"
        $cmd >> $outfile
        echo "\n\n" >> $outfile
        echo "第 $cnt 轮 结束"
        echo '----------------------------'


        cnt=$(($cnt+1))


        if [ $cnt -le $rounds ]; then
            echo "等待 $sleeptime 秒"
        fi
    done
}

# 分析结果
function result(){
    runtest $cmd $outfile $rounds $sleeptime
    echo '本次测试结果如下：'
    echo '+------+----------+----------+---------------+-------------------+---------------+--------------------+--------------------+----------+----------+----------+--------------------+'
    echo '| 序号 | 总请求数 |  并发数  |   失败请求数  | 每秒事务数[#/sec] |  平均事务(ms) | 并发平均事务数(ms) |　  总体传输字节数  |  90%     |  95%     |     99%  |  测试持续时间      |'
    echo '+------+----------+----------+---------------+-------------------+---------------+--------------------+--------------------+----------+----------+----------+--------------------+'


    comp=(`awk '/Complete requests/{print $NF}' $outfile`)
    concur=(`awk '/Concurrency Level:/{print $NF}' $outfile`)
    fail=(`awk '/Failed requests/{print $NF}' $outfile`)
    qps=(`awk '/Requests per second/{print $4F}' $outfile`)
    tpr=(`awk '/^Time per request:(.*)mean$/{print $4F}' $outfile`)
    tpr_c=(`awk '/Time per request(.*)(mean, across all concurrent requests)/{print $4F}' $outfile`)
    trate=(`awk '/Transfer rate/{print $3F}' $outfile`)
    pjcssl=(`awk '/90%/{print $2F}' $outfile`)
    pjcss95=(`awk '/95%/{print $2F}' $outfile`)
    pjcss99=(`awk '/99%/{print $2F}' $outfile`)
    cxsj=(`awk '/Time taken for tests/{print $5F}' $outfile`)


    for ((i=0; i<${#comp[@]}; i++))
    do
        echo   "|"
        printf '%6s' $(($i+1))
        printf " |"


        printf '%10s' ${comp[i]}
        printf '|'

        printf '%10s' ${concur[i]}
        printf '|'


        printf '%15s' ${fail[i]}
        printf '|'


        printf '%19s' ${qps[i]}
        printf '|'


        printf '%15s' ${tpr[i]}
        printf '|'


        printf '%20s' ${tpr_c[i]}
        printf '|'


        printf '%20s' ${trate[i]}
        printf '|'

        printf '%10s' ${pjcssl[i]}
        printf '|'
        printf '%10s' ${pjcss95[i]}
        printf '|'
        printf '%10s' ${pjcss99[i]}
        printf '|'

        printf '%15s' ${cxsj[i]}
        printf '|'


        echo '';
        echo '+------+----------+----------+---------------+-------------------+---------------+--------------------+--------------------+----------+----------+----------+---------------+'
    done

    echo '*======================压测完毕======================*'
    echo ''
}

result;

