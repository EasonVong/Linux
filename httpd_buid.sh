#!bin/bash
#httpd.sh 是httpd的菜单脚本
#HTTPD_PORT 表示httpd监听的端口号
#HTTPD_SERVER 表示服务程序的安装路径
#HTTPD_CONF 表示http的配置文件路径
httpd(){
clear
cat <<EOF
=================
1.START
2.STOP
3.RESTART
4.STATUS
5.CONFIGTEST
Q.EXIT
=================
EOF
}
while :
do
httpd
read -p "请输入选项：" x
case $x in
4)
  find /etc -name httpd
   if [ $? -eq 0 ]
    then
      HTTPD_CONF=`find /etc/httpd -name httpd.conf|tail -1`
      HTTPD_SERVER=`grep ^ServerRoot $HTTPD_CONF|awk -F '"' '{print $2}'`
     if [ "$HTTPD_SERVER" = "/usr/local/httpd" ]
       then 
       echo "http已经编译安装"
       HTTPD_PORT=`grep ^"Listen" $HTTPD_CONF|awk '{print $2}'`
       lsof -i :$HTTPD_PORT
         if [ $? -eq 0 ]
         then
           echo "httpd服务已启动，端口已监听"
         else
           echo "httpd服务尚未启动"
         fi
       else
         echo "http已经通过本地yum源安装"
         lsof -i :$HTTPD_PORT
          if [ $? -eq 0 ]
          then
            echo "服务已启动，端口已监听"
          else
           echo "服务尚未启动"
          fi
     fi  
   else
     echo "http尚未安装"
  fi
;;
1)
 find /etc -name httpd
   if [ $? -eq 0 ]
    then
      HTTPD_CONF=`find /etc/httpd -name httpd.conf|tail -1`
      HTTPD_SERVER=`grep ^ServerRoot $HTTPD_CONF|awk -F '"' '{print $2}'`
      HTTPD_PORT=`grep ^"Listen" $HTTPD_CONF|awk '{print $2}'`
     if [ "$HTTPD_SERVER" = "/usr/local/httpd" ]
       then
        echo "http已经编译安装，即将启动"
        ${HTTPD_SERVER}/bin/httpd -f ${HTTPD_CONF} && lsof -i :$HTTPD_PORT && echo "httpd服务已启动"
       else
        echo "http已经通过本地yum源安装"
        systemctl start httpd && lsof -i :$HTTPD_PORT && echo "httpd服务已启动"
     fi
    else
     echo "http尚未安装"
   fi
;;
2)
  find /etc -name httpd
   if [ $? -eq 0 ]
    then
      HTTPD_CONF=`find /etc/httpd -name httpd.conf|tail -1`
      HTTPD_SERVER=`grep ^ServerRoot $HTTPD_CONF|awk -F '"' '{print $2}'`
      HTTPD_PORT=`grep ^Listen $HTTPD_CONF|awk '{print $2}'`
    if [ "$HTTPD_SERVER" = "/usr/local/httpd" ]
      then
       lsof -i :$HTTPD_PORT && ${HTTPD_SERVER}/bin/httpd -k stop && echo "httpd服务已停止" || echo "httpd服务尚未启动"
      else
       lsof -i :$HTTPD_PORT && systemctl stop httpd && echo "httpd服务已停止"
       lsof -i :$HTTPD_PORT || echo "httpd服务尚未启动"
     fi
    else
     echo "http尚未安装"
   fi
;;
3)
   find /etc -name httpd
   if [ $? -eq 0 ]
    then
      HTTPD_CONF=`find /etc/httpd -name httpd.conf|tail -1`
      HTTPD_SERVER=`grep ^ServerRoot $HTTPD_CONF|awk -F '"' '{print $2}'`
      HTTPD_PORT=`grep ^Listen $HTTPD_CONF|awk '{print $2}'`
     if [ "$HTTPD_SERVER" = "/usr/local/httpd" ]
       then
        lsof -i :$HTTPD_PORT && ${HTTPD_SERVER}/bin/httpd -k restart && echo "httpd服务已重启"
       else
        lsof -i :$HTTPD_PORT && systemctl restart httpd && echo "httpd服务已重启"
     fi
    else
     echo "http尚未安装"
   fi
;;
5)
  find /etc -name httpd
   if [ $? -eq 0 ]
    then
      HTTPD_CONF=`find /etc/httpd -name httpd.conf|tail -1`
      HTTPD_SERVER=`grep ^ServerRoot $HTTPD_CONF|awk -F '"' '{print $2}'`
      HTTPD_PORT=`grep Listen $HTTPD_CONF|awk '{print $2}'`
     if [ "$HTTPD_SERVER" = "/usr/local/httpd" ]
       then
       ${HTTPD_SERVER}/bin/httpd -t && echo "语法检测OK"
       else
       httpd -t && echo "语法检测OK"  
     fi
    else
     echo "http尚未安装"
   fi
;;
q)
  echo "退出菜单选项"
  break
;;
*)
  continue
;;
esac
read -p '按回车键继续...'
done 
