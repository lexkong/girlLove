#!/bin/sh

: << EOF
使用方法：
./girlLove.sh 女朋友名字
EOF

# 设置女朋友的名字，用来在终端展示
name="$1"

# 读入girlLove.txt文件中所设置的变量
. ./girlLove.txt

# 脚本结束语
declaration="$name 让我守护你一辈子！"

# pos_stdy：输出位置为 2/3 x 终端Y轴长度；pos_stdx：输出位置为 1/2 x 终端X轴长度
pos_stdy="$(($(stty size|cut -d' ' -f1) / 3 * 2))"
pos_stdx="$(($(stty size|cut -d' ' -f2) / 2))"

# total_stdx：终端X轴长度，total_stdy：终端Y轴长度
total_stdy="$(($(stty size|cut -d' ' -f1)))"
total_stdx="$(($(stty size|cut -d' ' -f2)))"

# 开始答题时，给出的提示信息（屏幕最底部的提示信息）
info="$name 这就是送你的礼物了 选择1－4并按下回车开始答题吧"

# 进度条前面显示的提示信息
head="$name 当前的答题进度: "

# 在终端输出declaration变量中设置的信息，通过while循环和for循环实现动画效果
function waiting()
{
    i=1

    # 通过while循环实现 ////// 转圈的动画效果
    while [ $i -gt 0 ]
    do
        for j in '-' '\\' '|' '/'
        do
            # 打印前面6个/符号 + declaration变量中的内容
            echo -ne "\033[1m\033[$(($(stty size|cut -d' ' -f1) / 3 * 2));$(($(stty size|cut -d' ' -f2) / 2 - ${#declaration} - 6))H$j$j$j$j$j$j\033[4m\033[32m${declaration}"

            # 打印后面六个/符号
            echo -ne "\033[24m\033[?25l$j$j$j$j$j$j"
            usleep 100000
        done
        ((i++))
    done
}

# 该函数用来控制字符串的打印位置
# 参数1：要打印的字符串；参数2：根据参数2来选择不同的位置计算公式，不同类型的字符串，位置计算公式不同；
# 参数3：用来控制字符在Y轴的打印位置；参数4：用来控制字符在X轴的打印位置；
function print_xy()
{
    if [ $# -eq 0 ]; then
        return 1
    fi

    len=`expr ${#1} / 2`
    if [ $# -lt 2 ]; then
        pos="\e[${pos_stdy};$((${pos_stdx} - ${len}))H"

    elif [ $2 = "-" ]; then
        pos="\e[$((${pos_stdy} - $3));$((${pos_stdx} - ${len}))H"

    elif [ $2 = "+" ]; then
        pos="\e[$((${pos_stdy} + $3));$((${pos_stdx} - ${len}))H"

    elif [ $2 = "lu" ]; then
        pos="\e[$((${pos_stdy} - $3));$((${pos_stdx} - $4))H"

    elif [ $2 = "ld" ]; then
        pos="\e[$((${pos_stdy} + $3));$((${pos_stdx} - $4))H"

    fi

    echo -ne "${pos}$1"
}

# 调用clear清屏
clear

# 在1/2 X轴，2/3 Y轴的位置处打印如下字符串（格式化界面）
print_xy "*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*"

# 在终端底部中间位置处打印$info信息
printf "\r\e[${total_stdy};$(((${total_stdx} - ${#info}*2)/2))H${info}"

offset=14
seq=0

# 循环18个问题，为求效果，问题数要比$poetry变量行数多1
while [ ${seq} -lt ${#poetry[@]} ]
do
    sleep 0
    isanswer=0

    # 打印问题
    print_xy "问: ${question[$seq]}" ld 2 $offset

    # 打印问题选项
    print_xy "${bakans[$seq]}" + 3

    # 打印回答栏
    print_xy "答: " ld 4 $offset

    # 读取终端输入到变量ans
    read ans

    # 光标上移3行，并清除从光标到行尾的内容（清除问题行字符）
    echo -e "\033[3A\r\033[K"

    # 清除问题选项行字符
    echo -e "\033[K"

    # 清除回答栏字符
    echo -e "\033[K"

    # 如果输入的值和预设的答案不同，则继续循环该问题
    if [ "$ans" != "${answer[$seq]}" ]; then

        # 打印 -----，格式化界面。----- 下面会显示该问题的tip
        print_xy "---------------------------------------" + 5

        # 显示该问题的tip
        print_xy "${tips[$seq]}" + 7

        # 等待1s
        sleep 1

        # 将光标移到行首，并清除光标到行尾的字符
        echo -e "\r\033[K"

        # 光标上移3行，并清除光标到行尾的字符
        echo -e "\033[3A\r\033[K"
        continue
    fi

    # 问题序号 + 1
    seq=`expr ${seq} + 1`

    # 获取poetry的倒数第seq + 1行
    curseq=`expr ${#poetry[@]} - ${seq}`

    # 打印poetry的倒数第seq + 1行
    print_xy "${poetry[${curseq}]}" lu $seq $offset

    # 打印进度条
    total=$[${total_stdx} - ${#head}*2]
    per=$[${seq}*${total}/${#poetry[@]}]
    shengyu=$[${total} - ${per}]
    printf "\r\e[${total_stdy};0H${head}\e[42m%${per}s\e[46m%${shengyu}s\e[00m" "" "";
done

# 设置红色背景
printf "\e[41m"

# 清屏
clear

# 输出declaration变量的信息
waiting
