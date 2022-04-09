#!/bin/bash

#This was created to control the fans in my Dell Poweredge. I am lucky enough to be on the right iDrac version to use this method. 
#I didn't want to get my temperatures from iDrac as currently some of my drives are outside the cooling shroud; hence needing to grab the data from smartctl

#Inspiration from --  https://github.com/kmwoley/unRAID-Tools/blob/master/unraid_array_fan.sh
#and from -- https://www.reddit.com/r/unRAID/comments/guwrjy/so_you_bought_a_dell_poweredge_server_for_unraid/ftc82qi/ 

#Getting my 3 drives
SDC=`smartctl -A /dev/sdc | grep -m 1 -i Temperature_Celsius | awk '{print $10}'`
SDD=`smartctl -A /dev/sdd | grep -m 1 -i Temperature_Celsius | awk '{print $10}'`
SDE=`smartctl -A /dev/sde | grep -m 1 -i Temperature_Celsius | awk '{print $10}'`

#Setting my balacing temps
FAN_LOW_TEMP=33     # Anything this number and below - fan is low
FAN_MEDIUM_TEMP=38  # Setting a medium temp
FAN_HIGH_TEMP=45    # Anything this number or above - fan is high speed

#Averaging out the temps
TOTAL_TEMP=$((SDC+SDD+SDE))
#echo $TOTAL_TEMP
AVG_TEMP=$((TOTAL_TEMP/3))
#AVG_TEMP=38
echo $AVG_TEMP



# Set the fan speed based on average temp
if (( $AVG_TEMP <= $FAN_LOW_TEMP )); then
  # if less than 33degrees set fan to 10%
    ipmitool -I lanplus -H 10.10.10.10 -U root -P yourPassword raw 0x30 0x30 0x02 0xff 0x10
    echo "Activating 10%"
elif (( $AVG_TEMP >= $FAN_LOW_TEMP )) && (( $AVG_TEMP < $FAN_MEDIUM_TEMP )); then
  # if greater than 33degrees and less than 38degrees set fan to 17%
    ipmitool -I lanplus -H 10.10.10.10 -U root -P yourPassword raw 0x30 0x30 0x02 0xff 0x17
    echo "Activating 17%"
elif (( $AVG_TEMP >= $FAN_MEDIUM_TEMP )) && (( $AVG_TEMP < $FAN_HIGH_TEMP )); then
  # if greater than 38degrees and less than 45degrees set fan to 22%
    ipmitool -I lanplus -H 10.10.10.10 -U root -P yourPassword raw 0x30 0x30 0x02 0xff 0x22
    echo "Activating 22%"
elif (( $AVG_TEMP >= $FAN_HIGH_TEMP )); then
  # if higher than 45degrees set fan to 40%
    ipmitool -I lanplus -H 10.10.10.10 -U root -P yourPassword raw 0x30 0x30 0x02 0xff 0x40
    echo "Activating 40%"
else
  # otherwise set to a pretty fast speed
    ipmitool -I lanplus -H 10.10.10.10 -U root -P yourPassword raw 0x30 0x30 0x02 0xff 0x25
    echo "Activating else"
fi
