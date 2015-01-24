#!/bin/bash

###port forwarding support obfuscated ssh handshak using ssh as socks proxy server for fast access intranet web sites behind firewall from anywhere.
###by lai

###备选服务器列表
ssh_servers=(vip01.tttt.cn
vip02.tttt.cn
vip03.tttt.cn
vip04.tttt.cn
vip05.tttt.cn
vip06.tttt.cn
)
###备选端口列表
ssh_server_ports=(80 110 11231 10813)
###password
sshpass_cmd="/bin/sshpass -p123456 "
ssh_obf_cmd="/usr/local/newssh/bin/ssh -o StrictHostKeyChecking=no -p 110 -fCND 127.0.0.1:7070 -Z keyworks "
ssh_user_name=sshuser1@

###detect which ssh server is the fastest according round-trip-time using ping and traceroute(for further support)
min_atime=10000
for i in `seq 0 $((${#ssh_servers[@]} - 1))` ;do
	ip=${ssh_servers[$i]}
	#echo $i $ip
	###get the average round-trip-time
	###mac系统开启，二选一
	rtt=`ping -c 5 -i 0.1 $ip |grep round-trip|awk -F/ '{print $5}'`
	###linux系统开启，二选一
	#rtt=`ping -c 2 -i 0.1 $ip |grep rtt|awk -F/ '{print $5}'`
	atime[$i]=$rtt
	###如果当前rtt比则min_atime还小，则min_atime=$rtt
	#echo min_atime:$min_atime rtt:$rtt
	if  [[ $(echo "$rtt < $min_atime" |bc) = 1 ]];then
		min_atime=$rtt
		min_ip=$ip
		#echo min_atime:$min_atime
	fi
	echo [$i] average round-trip-time of $ip is: ${atime[$i]},current  fastest response time is $min_atime of $min_ip
done

###kill the ssh session if it's pid is exist.
#ps aux|grep $ssh_user_name
ps aux|awk '/[s]shuser1/ {system("kill -9 "$2)}'
echo ------------------------------
echo the fastest response time is $min_atime of $min_ip ,to connect this fastest server,plese wait a moment......
###make connection to the fastest server
$sshpass_cmd$ssh_obf_cmd$ssh_user_name$min_ip
#echo ------------------------------
#ps aux|grep $ssh_user_name


