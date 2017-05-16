#########################################################################
# File Name: code_generation.sh
# Author: pine
# mail: xfhlp@sina.com
# Created Time: 2017-05-10 09:40:07
#########################################################################
#!/bin/bash

#此为配置java数组，批量生成多个
# java代码
# String arr[] = {"CouponsUser", "Coupons", "User"};
# for (String s : arr) {
# String cmds = "sh /Users/lius/IdeaProjects/MyProject/springMVCTest/src/main/resources/code_generation.sh " + s;
# try {
# Runtime.getRuntime().exec(cmds).waitFor();
# } catch (Exception e) {
# e.printStackTrace();
# }
# }

#实用对象，实体类名 XxxEntity，Service层 XxxService


fileName=$1

#得到当前文件所在路径
bathPath=$(cd `dirname $0`; pwd)
#echo $bathPath

#从src开始截取前面的路径
#echo ${bathPath%%src*}


function code_generation(){
    templateFilePath="$bathPath/code_generation_template"
    generateFilePath="$bathPath/${fileName}Controller.txt"

    #判断目标文件是否存在，如果不存在，则创建
    if [ ! -f  $generateFilePath ]; then
       touch $generateFilePath
    fi

    #echo $templateFilePath
    echo 生成文件路径: $generateFilePath

    #读取shell 模板 并重定向到指定位置
    cat $templateFilePath > $generateFilePath
    #读取配置文件，根据文件进行替换  service变量名先截取第一个字符转换成小写，在截取后面的字符，在拼接

    #echo $fileName
    sed -i '' 's/#pine#/'$fileName'/g' $generateFilePath

    ls="`echo ${fileName:0:1} | tr "[:upper:]" "[:lower:]"`""${fileName:1}"
    sed -i '' 's/*pine/'$ls'/g' $generateFilePath

}

code_generation;