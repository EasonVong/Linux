#!/bin/bash
#1、判断软件是否已安装，未安装就安装mariadb、mariadb-server软件。
rpm  -q  mariadb-server && echo '软件已存在'  ||  yum  install  -y  mariadb-server
rpm  -q  mariadb && echo '软件已存在'  ||  yum  install  -y  mariadb

#2、修改/etc/my.cnf配置文件，指定log-bin文件名和server_id的值。
grep 'log_bin'  /etc/my.cnf
if [ $? -eq 0 ];then
  echo  '配置已存在。'
else
  sed  -i  '1a log_bin=mysql-bin'  /etc/my.cnf
  sed  -i  '2a server_id=7'  /etc/my.cnf
fi

#3、启动mariadb服务，允许开机启动mariadb。
systemctl  restart  mariadb
systemctl  enable  mariadb

#4、创建replication  slave主从复制的账号rep和密码01。刷新权限表。
mysql -uroot  -e  "grant  replication slave on *.* to rep@'%' identified by '01';flush  privileges;"

#5、查master状态。记下二进制日志文件名和position的值。
mysql  -uroot  -e  "show  master  status;"
a=$(mysql -uroot -e "show master status;"|awk 'NR==2{print $1}')
b=$(mysql -uroot -e "show master status;"|awk 'NR==2{print $2}')
c=$(ifconfig | awk 'NR==2{print $2}')

#6、生成“从服务器”的配置脚本。
cat > b.sh <<EOF
rpm  -q  mariadb-server && echo '软件已存在'  ||  yum  install  -y  mariadb-server
rpm  -q  mariadb && echo '软件已存在'  ||  yum  install  -y  mariadb
grep 'log_bin'  /etc/my.cnf
if [ \$? -eq 0 ];then
  echo  '配置已存在。'
else
  sed  -i  '1a log_bin=slave8-bin'  /etc/my.cnf
  sed  -i  '2a server_id=8'  /etc/my.cnf
fi
systemctl  restart  mariadb
systemctl  enable  mariadb
mysql  -uroot  -e "change  master  to  master_host='$c',master_user='rep',master_password='01',master_log_file='$a',master_log_pos=$b;"
mysql  -uroot  -e  "start slave;show  slave  status\G"
EOF
sleep 5
cat  b.sh

#7、将b.sh脚本文件用scp上传到192.168.100.8的根目录下。
scp  b.sh   root@192.168.100.8:/
ssh  root@192.168.100.8  'sh  /b.sh'
sleep 3
ssh  root@192.168.100.8  'mysql -e "show slave status\G"'

