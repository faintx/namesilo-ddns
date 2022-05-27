#!/bin/bash

# sudo apt install libxml2-utils

# crontab -e
# redirecet stderr and stdout to /dev/null
# every 2 hours
# * */2 * * * $HOME/namesilo_ddns.sh > /dev/null 2>&1

# hourly
# 0 * * * * $HOME/namesilo_ddns.sh > /dev/null 2>&1
# @hourly $HOME/namesilo_ddns.sh > /dev/null 2>&1

# grep CRON /var/log/syslog
# https://blog.csdn.net/toopoo/article/details/105409383
# https://www.cnblogs.com/Lucky-Suri/p/15131608.html

TRACE_DIR="$HOME/.namesilo_dns"
TRACE_LOG="$TRACE_DIR/log.log"

##Domain name:
DOMAIN="Domain"
DOMAIN_XML="$TRACE_DIR/Domain.xml"

##Host name (subdomain). Optional. If present, must end with a dot (.)
HOST="subdomain."

##APIKEY obtained from Namesilo:
APIKEY="Your API KEY"

## Do not edit lines below ##

[ -d temp ] || mkdir -p "$TRACE_DIR"

##Saved history pubic IP from last check
IP_FILE="$TRACE_DIR/PubIP"

##Response from Namesilo
RESPONSE="$TRACE_DIR/namesilo_response.xml"

##Get the current public IP using DNS
CUR_IP="$(curl -s https://api64.ipify.org)"
ODRC=$?

## exit if retrive IP failed
if [ $ODRC -ne 0 ]; then
   echo "$(date +'%Y-%m-%d %H:%M:%S') Exit: IP Lookup at api.ipify.org failed!" >> $TRACE_LOG
   exit 1
elif [ -z $CUR_IP ]; then
   echo "$(date +'%Y-%m-%d %H:%M:%S') Exit: Get Empty IP Address at api.ipify.org!" >> $TRACE_LOG
   exit 1
# check IPv4
elif [[ "$CUR_IP" =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]]; then
   echo "$(date +'%Y-%m-%d %H:%M:%S') Exit: IPv6 Address expected but get IPv4 Address!" >> $TRACE_LOG
   exit 1
fi

echo "$(date +'%Y-%m-%d %H:%M:%S') Get IP Address $CUR_IP from web" >> $TRACE_LOG

##Check file for previous IP address
if [ -f $IP_FILE ]; then
  KNOWN_IP=$(cat $IP_FILE)
else
  KNOWN_IP=
fi

##See if the IP has changed
if [ "$CUR_IP" != "$KNOWN_IP" ]; then  
  ##Update DNS record in Namesilo:
  curl -s "https://www.namesilo.com/api/dnsListRecords?version=1&type=xml&key=$APIKEY&domain=$DOMAIN" > $DOMAIN_XML 
  RECORD_ID=`xmllint --xpath "//namesilo/reply/resource_record/record_id[../host/text() = '$HOST$DOMAIN' ]" $DOMAIN_XML | grep -oP '(?<=<record_id>).*?(?=</record_id>)'`
  DEST_IP=`xmllint --xpath "//namesilo/reply/resource_record/value[../host/text() = '$HOST$DOMAIN' ]" $DOMAIN_XML | grep -oP '(?<=<value>).*?(?=</value>)'`
  
  echo "$(date +'%Y-%m-%d %H:%M:%S') Namesilo IP Address is $DEST_IP, record_id is $RECORD_ID " >> $TRACE_LOG
  
  if [ -z $RECORD_ID ]; then
    echo "$(date +'%Y-%m-%d %H:%M:%S') Exit: NO RECORD_ID found!" >> $TRACE_LOG
    exit 1
  fi
  
  if [ "$CUR_IP" == "$DEST_IP" ]; then
    echo $CUR_IP > $IP_FILE
    echo "$(date +'%Y-%m-%d %H:%M:%S') Exit: IP Address in Namesilo is same as current IP" >> $TRACE_LOG
	exit 0
  fi  
  
  echo $CUR_IP > $IP_FILE
  echo "$(date +'%Y-%m-%d %H:%M:%S') Public IP changed to $CUR_IP from $DEST_IP" >> $TRACE_LOG
  
  UPDATE_URL="https://www.namesilo.com/api/dnsUpdateRecord?version=1&type=xml&key=$APIKEY&domain=$DOMAIN&rrid=$RECORD_ID&rrhost=$HOST&rrvalue=$CUR_IP&rrttl=7207"
  
  echo "$(date +'%Y-%m-%d %H:%M:%S') Update DNS: $UPDATE_URL" >> $TRACE_LOG
  curl -s "$UPDATE_URL" > $RESPONSE
  RESPONSE_CODE=`xmllint --xpath "//namesilo/reply/code/text()"  $RESPONSE`
    case $RESPONSE_CODE in
    300)
      #logger -t IP.Check -- Update success. Now $HOST$DOMAIN IP address is $CUR_IP;;
	  echo "$(date +'%Y-%m-%d %H:%M:%S') Update success. Now $HOST$DOMAIN IP address is $CUR_IP" >> $TRACE_LOG ;;
    280)
	  echo "$(date +'%Y-%m-%d %H:%M:%S') Duplicate record exists. No update necessary" >> $TRACE_LOG ;;
    *)
      ## put the old IP back, so that the update will be tried next time
      echo $KNOWN_IP > $IP_FILE 
	  echo "$(date +'%Y-%m-%d %H:%M:%S') DDNS update failed code $RESPONSE_CODE!" >> $TRACE_LOG ;;
    esac
else
  echo "$(date +'%Y-%m-%d %H:%M:%S') Exit: Current IP Address is same as previous local one" >> $TRACE_LOG
fi

exit 0