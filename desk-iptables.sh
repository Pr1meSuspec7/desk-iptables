#!/bin/bash

######### POLICY EXAMPLE #########
# ACCEPT AN IP ADDRESS INBOUND (SOURCE IP OF THE SESSION)
# iptables -A INPUT -s 15.15.15.51 -j ACCEPT

# ACCEPT PACKET OUTBOUND FROM ens192 ON PORT 5223 TO DESTINATION 15.15.15.15
# iptables -A OUTPUT -o ens192 -p tcp --dports 5223 -d 15.15.15.15 -j ACCEPT

# ACCEPT AN IP ADDRESS OUTBOUND (DESTINATION IP OF THE SESSION)
# iptables -A OUTPUT -d 15.15.15.51 -j ACCEPT
##################################

BAR='####################'

# FLUSHA
echo "Rimuovo tutte le regole"
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

# IMPOSTA LA DEFAULT SU ACCEPT
# iptables -P INPUT ACCEPT
# iptables -P FORWARD ACCEPT
# iptables -P OUTPUT ACCEPT


######### POLICY INPUT #########
echo -e "\nInstallo policy INPUT"
for i in {1..20}; do
    echo -ne "\r${BAR:0:$i}" # print $i chars of $BAR from 0 position
    sleep .1
done
# PERMETTE LE RISPOSTE INPUT STABILITE E CORRELATE DEL TRAFFICO OUTPUT LEGITTIMO
iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

# PERMETTE TUTTO IL TRAFFICO CON DST LOOPBACK
iptables -A INPUT -i lo -j ACCEPT

# Torrent [Transmission]
iptables -A INPUT -p tcp --dport 51414 -j ACCEPT -m comment --comment "Transmission"

# LOGGING
iptables -A INPUT -m limit --limit 1/sec -j LOG --log-prefix "Input denied: " --log-level 4 -m comment --comment "Log Input Drop"



######### POLICY OUTPUT #########
echo -e "\nInstallo policy OUTPUT"
for i in {1..20}; do
    echo -ne "\r${BAR:0:$i}" # print $i chars of $BAR from 0 position
    sleep .1
done
# PERMETTE LE RISPOSTE OUTPUT DEL PC ALLE CONN INPUT LEGITTIME
iptables -A OUTPUT -m conntrack --ctstate ESTABLISHED -j ACCEPT

# PERMETTE TUTTO IL TRAFFICO CON SRC LOOPBACK
iptables -A OUTPUT -o lo -j ACCEPT

# SSH
iptables -A OUTPUT -p tcp --dport 22 -j ACCEPT -m comment --comment "SSH outgoing"

# DNS/NTP
iptables -A OUTPUT -p tcp -m multiport --dport 53,123 -j ACCEPT
iptables -A OUTPUT -p udp -m multiport --dport 53,123 -j ACCEPT

# NAVIGAZIONE
iptables -A OUTPUT -p tcp -m multiport --dports 80,443 -j ACCEPT -m comment --comment "Navigazione Web"

# MAIL
iptables -A OUTPUT -p tcp -m multiport --dports 25,110,143,465,587,993,995 -j ACCEPT -m comment --comment "Mail"

# PING
iptables -A OUTPUT -p icmp --icmp-type echo-request -j ACCEPT -m comment --comment "Ping Output"

# STAMPA
iptables -A OUTPUT -p tcp -m multiport --dports 515,1900,5357,8611,8612,8613,9100 -j ACCEPT -m comment --comment "Stampa"
iptables -A OUTPUT -p udp -m multiport --dports 515,1900,5357,8611,8612,8613,9100 -j ACCEPT -m comment --comment "Stampa"

# SNMP
iptables -A OUTPUT -p udp -m multiport --dports 161,162 -j ACCEPT -m comment --comment "SNMP"
iptables -A OUTPUT -p tcp -m multiport --dports 161,162 -j ACCEPT -m comment --comment "SNMP"

# PLEX INTERFACCIA WEB
iptables -A OUTPUT -p tcp --dport 32400 -d 192.168.178.110 -j ACCEPT -m comment --comment "PLEX"

# LOGGING
iptables -A OUTPUT -m limit --limit 1/sec -j LOG --log-prefix "Output denied: " --log-level 4 -m comment --comment "Log Output Drop"

echo -e "\nInstallo policy default DROP"
for i in {1..20}; do
    echo -ne "\r${BAR:0:$i}" # print $i chars of $BAR from 0 position
    sleep .1
done

# DEFAULT POLICY DROP
iptables -P INPUT DROP
iptables -P OUTPUT DROP
iptables -P FORWARD DROP

echo -e "\nSalvataggio impostazioni"
for i in {1..20}; do
    echo -ne "\r${BAR:0:$i}" # print $i chars of $BAR from 0 position
    sleep .1
done
netfilter-persistent save &> /dev/null

echo -e "\nCompletato!\r" && sleep 1

echo -e "Do you wish to show chain?"
select yn in "Yes" "No"; do
    case $yn in 
        Yes ) iptables -S; break;; 
        No ) echo -e "Bye Bye\r"; break;; 
    esac; 
done