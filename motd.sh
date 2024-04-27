#!/bin/bash

HOSTNAME=$(hostname | tr a-z A-Z)
DISTRO=$(cat /etc/os-release | cut -d= -f2 | head -n1 | sed 's/"//g')

MEM_TOTAL=$(echo "$(cat /proc/meminfo | grep MemTotal | awk {'print $2'}) / 1024 / 1024" | bc -l | xargs printf "%.*f\n" 2)
MEM_AVAILABLE=$(echo "$(cat /proc/meminfo | grep MemAvailable | awk {'print $2'}) / 1024 / 1024" | bc -l | xargs printf "%.*f\n" 2)
MEM_USED=$(echo "$(echo "(1 - $MEM_AVAILABLE / $MEM_TOTAL)*100" | bc -l)" | xargs printf "%.*f\n" 0)
MEM_USED_INT=$(echo "$(echo "(1 - $MEM_AVAILABLE / $MEM_TOTAL)*100" | bc -l)" | xargs printf "%.*f\n" 0)

CPUS=$(cat /proc/cpuinfo | grep 'cpu core' | head -n1 | awk {'print $4'})
LOAD1=$(cat /proc/loadavg | awk {'print $1'})
LOAD5=$(cat /proc/loadavg | awk {'print $2'})
LOAD15=$(cat /proc/loadavg | awk {'print $3'})

DISK_TOTAL=$(df -h | grep "/$" | awk {'print $2'} | sed 's/G//g')
DISK_USED=$(df -h | grep "/$" | awk {'print $5'} | sed 's/%//g')

APACHE_STATUS=$(systemctl status apache2 | grep Active | awk {'print $2'})
APACHE_UPTIME=$(systemctl status apache2 | grep Active | awk {'print $9'})
MARIADB_STATUS=$(systemctl status mariadb | grep Active | awk {'print $2'})
MARIADB_UPTIME=$(systemctl status mariadb | grep Active | awk {'print $9'})

function status(){
    STATUS=$1
    UPTIME=$2

    if [ $STATUS == "active" ]; then
        echo -e "\033[1;34mactive\033[0m  \033[1;35mUptime: $UPTIME\033[0m" 
    else
        echo -e "\033[1;31minactive\033[0m"
    fi
}

function percent(){
    PERCENT=$1
    if [ $PERCENT -le 50 ]; then
        echo -e "\033[1;34m$PERCENT %\033[0m"
    elif [ $PERCENT -gt 50  && $PERCENT -le 80 ]; then
        echo -e "\033[1;33m$PERCENT %\033[0m"
    elif [ $PERCENT -gt 80 ]; then
        echo -e "\033[1;31m$PERCENT %\033[0m"
    fi
}

APACHE_STATUS=$(status $APACHE_STATUS $APACHE_UPTIME)
MARIADB_STATUS=$(status $MARIADB_STATUS $MARIADB_UPTIME)

MEM_USED=$(percent $MEM_USED)
DISK_USED=$(percent $DISK_USED)

echo -e "---------------------------------------------------------------------------------------\n"

echo -e "Nome do Servidor: $HOSTNAME\n"

echo -e "Distribuicao Linux: $DISTRO\n"

echo -e "CPUs: $CPUS    Carga media:  \033[1;34m1 min - $LOAD1\033[0m  \033[1;34m5 min - $LOAD5\033[0m  \033[1;34m15 min - $LOAD15\033[0m\n"

echo -e "RAM: $MEM_TOTAL GB    Disponivel: $MEM_AVAILABLE GB    Usado: $MEM_USED\n"

echo -e "DISK: $DISK_TOTAL GB   Usado: $DISK_USED\n"

echo -e "Status:   Apache - $APACHE_STATUS  Mariadb - $MARIADB_STATUS\n"

echo -e "---------------------------------------------------------------------------------------\n"
