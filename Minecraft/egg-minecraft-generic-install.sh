#!/bin/sh -x

# 更换源和安装基础工具
function installBasicTools(){
    sed -i 's/dl-cdn.alpinelinux.org/mirrors.tuna.tsinghua.edu.cn/g' /etc/apk/repositories
    apk --no-cache add bash curl wget aria2 ca-certificates
    # 判断退出代码是否为 0
    if [ $? -eq 0 ]; then
        echo "基础工具安装成功"
    else
        echo "基础工具安装失败,但是仍然要以 0 退出脚本"
        echo "安装基础工具失败,可能是网络原因?"
        exit 0
    fi
}

# 按需清空服务器
function removeAllFiles(){
    # 判断是否存在清空服务器的变量
    # REMOVE_ALL_FILES=false
    # 如果没定义或者为 false 就不执行清空
    if [ "$REMOVE_ALL_FILES" == true ]; then
        echo "清空服务器文件"
        rm -rf /mnt/server/*
    fi
}

# 下载和安装
function downloadAndInstall(){
    # 判断包名字是否为空
    if [ ! -z "$PACKAGE_NAME" ]; then
        echo "包名字为空,跳过安装"
        exit 0
    fi
    echo "选择的包是 ${PACK_NAME}"


    # 下载部分
    # wget https://res.gameworldmc.cn/packs/${PACK_NAME}.tar.gz -O server.tar.gz
    # 你说先得删掉同名文件对不对
    rm -rf /mnt/server/server.tar.gz
    aria2c -x 16 -s 64 -c -o /mnt/server/server.tar.gz https://tres.misakacloud.app/api/raw/?path=/packs/${PACK_NAME}.tar.gz
    # echo $?
    # 判断退出代码是否为 0
    if [ $? -eq 0 ]; then
        echo "下载成功"
    else
        echo "下载失败,但是仍然要以 0 退出脚本"
        exit 0
    fi

    # 解压的时候要脱掉一层
    tar xvzf /mnt/server/server.tar.gz --strip-components=1 -C /mnt/server/
    # 判断解压退出代码是否为 0
    if [ $? -eq 0 ]; then
        echo "解压成功"
    else
        echo "解压失败,但是仍然要以 0 退出脚本"
        exit 0
    fi
    echo "安装完成,现在您可以删掉 server.tar.gz 文件"
}

# 删除肯定是放在最上面的
removeAllFiles
# 然后在这里要重置一下安装日志
touch /mnt/server/install.log && echo > /mnt/server/install.log
# exec 2>&1 | tee /mnt/server/install.log

(
# 剩下的事情就是老工作了
installBasicTools
downloadAndInstall
) 2>&1 | tee /mnt/server/install.log