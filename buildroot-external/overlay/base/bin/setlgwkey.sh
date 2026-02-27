#!/bin/sh
# shellcheck shell=dash disable=SC2169

# list all keychange files
UPDATEFILES=$(ls /etc/config/*.keychange 2>/dev/null)
# perform key exchange for every keychange file
for F in $UPDATEFILES
do
  echo -n "$F "
  #parse the file
  SERIAL=$(grep Serial "$F"| sed s/Serial=//)
  IP=$(grep IP "$F" | sed s/IP=//)
  KEY=$(grep KEY "$F" | sed s/KEY=//)
  CURKEY=$(grep CURKEY "$F" | sed s/CURKEY=//)
  CLASS=$(grep Class "$F" | sed s/Class=//)

  #Check gateway class and set rfd.conf / hs485d.conf path
  if [ "$CLASS" == "Wired" ]
  then
      #Wired
      CONFFILE=/etc/config/hs485d.conf
    elif [ "$CLASS" == "RF" ] 
    then
      #RF
      CONFFILE=/etc/config/rfd.conf
    else 
      exit 1
    fi

  #Start key exchange
  # On success delete key exchange file
  if [ "$IP" == "" ]
  then
    #echo  "Using Serial"
    if /usr/bin/timeout 120 /bin/eq3configcmd setlgwkey -s "$SERIAL" -c "$CURKEY" -n "$KEY" -f "$CONFFILE" -l 1; then
      rm -f "$F"
    fi
  else
    #echo "Using IP"
    if /usr/bin/timeout 120 /bin/eq3configcmd setlgwkey -s "$SERIAL" -h "$IP" -c "$CURKEY" -n "$KEY" -f "$CONFFILE" -l 1; then
      rm -f "$F"
    fi
  fi
done 
