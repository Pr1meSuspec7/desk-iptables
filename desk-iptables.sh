#!/bin/bash

######### POLICY EXAMPLE #########
# ACCEPT AN IP ADDRESS INBOUND (SOURCE IP OF THE SESSION)
# iptables -A INPUT -s 15.15.15.51 -j ACCEPT

# ACCEPT PACKET OUTBOUND FROM ens192 ON PORT 5223 TO DESTINATION 15.15.15.15
# iptables -A OUTPUT -o ens192 -p tcp --dports 5223 -d 15.15.15.15 -j ACCEPT

# ACCEPT AN IP ADDRESS OUTBOUND (DESTINATION IP OF THE SESSION)
# iptables -A OUTPUT -d 15.15.15.51 -j ACCEPT
##################################

if [ "$(id -u)" != "0" ]; then
    echo -e "\033[5;41;1;37m This script must be run as root \033[0m" 1>&2
    exit 1
fi

BAR='####################'

# FLUSH
echo "Remove all rules"
for i in {1..20}; do
    echo -ne "\r${BAR:0:$i}" # print $i chars of $BAR from 0 position
    sleep .1
done
netfilter-persistent flush &> /dev/null
# iptables -F
# iptables -X
# iptables -t nat -F
# iptables -t nat -X
# iptables -t mangle -F
# iptables -t mangle -X

# SET DEFAULT RULES ACCEPT
# iptables -P INPUT ACCEPT
# iptables -P FORWARD ACCEPT
# iptables -P OUTPUT ACCEPT


######### POLICY INPUT #########
echo -e "\nInstall policy INPUT"
for i in {1..20}; do
    echo -ne "\r${BAR:0:$i}" # print $i chars of $BAR from 0 position
    sleep .1
done
# PERMETTE LE RISPOSTE INPUT STABILITE E CORRELATE DEL TRAFFICO OUTPUT LEGITTIMO
# ALLOWS THE INPUT RESOURCES ESTABLISHED AND RELATED TO THE LEGAL OUTPUT TRAFFIC
iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

# PERMETTE TUTTO IL TRAFFICO CON DST LOOPBACK
# ALLOWS ALL TRAFFIC WITH DST LOOPBACK
iptables -A INPUT -i lo -j ACCEPT

# Torrent [Transmission]
iptables -A INPUT -p tcp --dport 51414 -j ACCEPT -m comment --comment "Transmission"

# LOGGING
iptables -A INPUT -m limit --limit 1/sec -j LOG --log-prefix "Input denied: " --log-level 4 -m comment --comment "Log Input Drop"



######### POLICY OUTPUT #########
echo -e "\nInstall policy OUTPUT"
for i in {1..20}; do
    echo -ne "\r${BAR:0:$i}" # print $i chars of $BAR from 0 position
    sleep .1
done
# PERMETTE LE RISPOSTE OUTPUT STABILITE E CORRELATE DEL TRAFFICO INPUT LEGITTIMO
# ALLOWS THE OUTPUT RESOURCES ESTABLISHED AND RELATED TO THE LEGAL INPUT TRAFFIC
iptables -A OUTPUT -m conntrack --ctstate ESTABLISHED -j ACCEPT

# ALLOWS ALL TRAFFIC WITH SRC LOOPBACK
iptables -A OUTPUT -o lo -j ACCEPT

# SSH
iptables -A OUTPUT -p tcp --dport 22 -j ACCEPT -m comment --comment "SSH outgoing"

# DNS/NTP
iptables -A OUTPUT -p tcp -m multiport --dport 53,123 -j ACCEPT
iptables -A OUTPUT -p udp -m multiport --dport 53,123 -j ACCEPT

# NAVIGATION
iptables -A OUTPUT -p tcp -m multiport --dports 80,443 -j ACCEPT -m comment --comment "Web Browsing"

# MAIL
iptables -A OUTPUT -p tcp -m multiport --dports 25,110,143,465,587,993,995 -j ACCEPT -m comment --comment "Mail"

# PING
iptables -A OUTPUT -p icmp --icmp-type echo-request -j ACCEPT -m comment --comment "Ping Output"

# PRINT
iptables -A OUTPUT -p tcp -m multiport --dports 515,1900,5357,8611,8612,8613,9100 -j ACCEPT -m comment --comment "Print"
iptables -A OUTPUT -p udp -m multiport --dports 515,1900,5357,8611,8612,8613,9100 -j ACCEPT -m comment --comment "Print"

# SNMP
iptables -A OUTPUT -p udp -m multiport --dports 161,162 -j ACCEPT -m comment --comment "SNMP"
iptables -A OUTPUT -p tcp -m multiport --dports 161,162 -j ACCEPT -m comment --comment "SNMP"

# LOGGING
iptables -A OUTPUT -m limit --limit 1/sec -j LOG --log-prefix "Output denied: " --log-level 4 -m comment --comment "Log Output Drop"

echo -e "\nInstall policy default DROP"
for i in {1..20}; do
    echo -ne "\r${BAR:0:$i}" # print $i chars of $BAR from 0 position
    sleep .1
done

# DEFAULT POLICY DROP
iptables -P INPUT DROP
iptables -P OUTPUT DROP
iptables -P FORWARD DROP

echo -e "\nSave config"
for i in {1..20}; do
    echo -ne "\r${BAR:0:$i}" # print $i chars of $BAR from 0 position
    sleep .1
done
netfilter-persistent save &> /dev/null

#echo -e "\nDone!\r" && sleep 1
echo -e "\n\033[5;42;1;37m Done! \033[0m\r" && sleep 1

echo -e "Do you wish to show chain?"
select yn in "Yes" "No"; do
    case $yn in 
        Yes ) iptables -S; break;; 
        No ) echo -e "Bye Bye\r"; break;; 
    esac; 
done