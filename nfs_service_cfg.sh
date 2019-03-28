#!/bin/bash
#这是一个nfs自动配置的脚本。

#1、检测软件是否已安装
rpm  -q  nfs-utils && echo  'nfs已安装' || yum  install -y  nfs-utils

#2、检测服务状态,systemctl  status nfs-server > /dev/null是将命令的结果写到null空文件中，屏幕不显示提示。
systemctl  status  nfs-server >/dev/null  && echo 'nfs已启动' || systemctl  restart  nfs-server 

#3、设置服务开机启动
systemctl  enable  nfs-server

#4、配置共享,提示用户输入共享路径，
read  -p  '请输入共享目录路径，例如:/var：'  x
grep  "$x"  /etc/exports
if [ $? -ne 0 ];then
  if [ -d $x ];then
    echo  "$x  *(ro,sync)" >> /etc/exports
  else
    echo  "$x目录不存在。"
  fi
fi
exportfs  -arv

#5、在服务器本地查看共享资源。
showmount  -e  127.0.0.1

