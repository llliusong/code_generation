#########################################################################
# File Name: code_generation.sh
# Author: pine
# mail: xfhlp@sina.com
# Created Time: 2017-05-10 09:40:07
#########################################################################
#!/bin/bash

# 此脚本自动生成.java文件，包含Controller及其测试类，适用于本司自己代码
# 自动生成代码，需约定代码生成模板
#在这里配置生成的文件名，生成多个文件以空格分割 example:file_array=('CouponsUser' 'User')

file_array=('CouponsUser')

bathPath=$(cd `dirname $0`; pwd)

function controller_generate(){
    controllerTemplateFilePath="$bathPath/Controller$2Template"
    #controllerFilePath="${bathPath%%code_generation*}src/$1/java/com/jy/dingding/controller/${fileName}Controller$2.java"
    controllerFilePath="$bathPath/${fileName}Controller$2.java"
    if [ ! -f  $controllerFilePath ]; then
       touch $controllerFilePath
    fi

    cat $controllerTemplateFilePath > $controllerFilePath

    sed -i '' 's/#pine#/'$fileName'/g' $controllerFilePath

    ls="`echo ${fileName:0:1} | tr "[:upper:]" "[:lower:]"`""${fileName:1}"
    sed -i '' 's/*pine/'$ls'/g' $controllerFilePath
}

for pine in ${file_array[*]}
do
    fileName=$pine
    controller_generate "main";
    controller_generate "test" "Test";
done





