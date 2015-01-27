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

###ssh相关参数定义
ssh_user_name=sshuser1
ssh_user_pass=123456
sshpass_path=/bin/sshpass
ssh_obf_path=/usr/local/newssh/bin/ssh
###自动添加hostkey、keepalive选项
ssh_obf_options="-o StrictHostKeyChecking=no -o ServerAliveInterval=30 -p 110 -fCND 127.0.0.1:7070"
ssh_obf_keyword=keyworks
sshpass_cmd="$sshpass_path -p$ssh_user_pass "
ssh_obf_cmd="$ssh_obf_path $ssh_obf_options -Z $ssh_obf_keyword "

###定义运行此脚本所在os的ping返回结果格式
ping_os_type_macos="round-trip"
ping_os_type_linux="rtt"
ping_os_type=$ping_os_type_macos


#######以下内容不需要用户修改，自定义参数见上文变量定义部分
###parallel background detect which ssh server is the fastest according round-trip-time using ping and traceroute(for further support)
for i in `seq 0 $((${#ssh_servers[@]} - 1))` ;do
	ip=${ssh_servers[$i]}
	#echo $i $ip
	###get the average round-trip-time
	###ping 3次，每次间隔0.1s，超时1s
	ping -c 2 -i 0.1 -t 1 $ip |grep $ping_os_type|awk -F/ '{print $5}' > /tmp/${ip}_rtt.log 2>&1 & 
	###记录每次ping进程的pid，以便后续根据pid是否存在判断进程是否早学完
	pids[$i]=$!
	#echo pid of $ip ${pids[$i]}
done


####循环检查pids数组中的pid是否运行结束的函数
pids_length=${#pids[@]}
array_check () {
   for i in `seq 0 $((${#pids[@]} - 1))` ;do
      #echo -------------------------------------array for loop----------------------
      if [  ${pids[$i]} == 0 ] ;then
         echo NULL >/dev/null
      else 
      ####通过ps动态检查pid是否结束,返回0说明进程还没有结束
         ps aux|awk '{print $2}' | grep  ^${pids[$i]}$ 2>&1 >/dev/null
         pidstatus=$?
         ###if pids is not exists,that indecates the process is over,and display execute result,clean respective array elements
         if [ $pidstatus != 0 ] ;then
            ####进程结束后，打印执行结果log
	    ip=${ssh_servers[$i]}
	    rtt=`cat /tmp/${ip}_rtt.log`
	    rtts[$i]=$rtt
	    echo  "[$i] ping detect of ${ssh_servers[$i]} is over,and it's rtt is ${rtts[$i]} ms"
	    #####同时pids数组中对应pid重置为0
            pids[$i]=0
	    ####进程结束，返回200供后续判断
	    return 200
	    break
	 fi
      fi
	###wait for 1 seconds to check whether the pids is over
	#sleep 0.1
   done
}


####如果完成任务数complete_num不等于pids数组长度，则循环直到所有任务结束
complete_num=0
while [ ${complete_num} != ${pids_length} ] ;do
	#echo =================================while loop=======================================
	for ((j=0;j<${pids_length};j++)) ;do
		array_check
		####根据array_check函数返回值是否成功来确定complete_num数的增加
		if [ $? == 200 ] ;then
			complete_num=$((${complete_num}+1))
			####打印最近任务完成的数量
			echo -e "\033[35m\033[05m Ping Detect Report: complete_tasks/total_tasks:[${complete_num}/${pids_length}]\033[0m"
		fi
	done
done


###比较取到rtt最小的server地址 
###初始化最小平均round-trip-time
min_rtt=10000
for i in `seq 0 $((${#ssh_servers[@]} - 1))` ;do
	rtt=${rtts[$i]}
	###如果当前rtt比最小的min_rtt还小，则min_rtt=$rtt
	if  [[ $(echo "$rtt < $min_rtt" |bc) = 1 ]];then
		min_rtt=$rtt
		min_ip=${ssh_servers[$i]}
	fi
done
echo ------------------------------
echo the fastest response time is $min_rtt ms of $min_ip ,to connect this server,plese wait a moment......


###kill the ssh session if it's pid is exist.
#ps aux|grep $ssh_user_name
ps aux|grep $ssh_user_name|grep -v grep|awk '{system("kill -9 "$2)}'
#ps aux|grep $ssh_user_name|grep -v grep|awk '{print $2)}'|xargs kill -9
#echo ------------------------------
###make connection to the fastest server
$sshpass_cmd$ssh_obf_cmd$ssh_user_name@$min_ip
pidstatus=$?
if [[ $pidstatus = 0 ]];then
	echo Good luck,you have alredeay connect to the fastest server!
else
	echo ERROR OCCUR,PLEASE CHECK.
fi
#echo ------------------------------
ps aux|grep $ssh_user_name


