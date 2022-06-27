#!/bin/bash

if [ "$#" -ne 6 ]
then
  echo "Use: $0 <OLT IP> <ONT PASSWORD> <SLOT> <PON> <ID ONU> <IP SERVER>"
  exit
fi

OLT=$1
ONT_PASS=$2
SLOT_ID=$3
PORT_ID=$4
ONT_ID=$5
IP_SERVER=$6

let ifIndex=$SLOT_ID*33554432+33554432+$PORT_ID*65536-65536+$ONT_ID*512-512+29360128

snmpset -v 1 -c public  -On ${OLT} .1.3.6.1.4.1.637.61.1.35.10.1.1.52.${ifIndex} a ${IP_SERVER}  2>/dev/null >/dev/null

PORT=`snmpget -v 1 -c public -On ${OLT} .1.3.6.1.4.1.637.61.1.35.10.1.1.53.${ifIndex} 2>/dev/null | cut -f2 -d":"`

cat  ${HOME}/.ssh/known_hosts | grep -iv "${OLT}" > /tmp/known.$$.tmp
mv /tmp/known.$$.tmp  ${HOME}/.ssh/known_hosts

sshpass -p ${ONT_PASS} ssh -o StrictHostKeyChecking=no -p ${PORT} ONTUSER@${OLT}
snmpset -v 1 -c public -On ${OLT} .1.3.6.1.4.1.637.61.1.35.10.1.1.52.${ifIndex} a 0.0.0.0  2>/dev/null >/dev/null
