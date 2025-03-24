# wsl2 端口转发

## 端口转发

netsh interface portproxy add v4tov4 listenport=22 listenaddress=10.1.50.43 connectport=22 connectaddress=172.19.66.74

netsh interface portproxy show all

netsh interface portproxy delete v4tov4 listenaddress=10.1.50.43 listenport=22

## 防火墙

netsh advfirewall firewall add rule name="Allow ssh 22 in" protocol=TCP dir=in localport=22 action=allow

netsh advfirewall firewall show rule name="Allow ssh 22 in"

netsh advfirewall firewall delete rule name="Allow ssh 22 in"
