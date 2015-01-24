fastproxy 是一个快速的代理智能线路选择脚本,在访问一些有多个proxy出口的国外网站时，最简单方便快速的选择最优proxy进行连接，提高访问体验，多人试用反馈效果非常棒，详见项目截图。

使用前提：
1、有多个可以通过混淆ssh连接的proxy server；
2、配合chrome的switchysharp代理选择插件；
3、需要有安装sshpass；
4、ssh client需要支持obfuscated功能；

适用系统：mac os & linux

使用：
1、直接下载fastproxy_v1.sh或者fastproxy_v2.sh，建议下载fastproxy_v2.sh，v2效率比v1高很多
2、修改脚本里的ssh用户信息、proxy地址等
3、增加执行权限
4、ln -s  fastproxy_v2.sh  /usr/bin/fastproxy
5、直接运行fastproxy
6、配置chrome的switchysharp代理选择插件
7、享受良好的访问体验（这还取决于proxy到本地的链路速度）
