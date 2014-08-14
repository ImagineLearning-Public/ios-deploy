#!/bin/bash

ipa=$1
deviceSerial=$2

echo "killing any running instruments processes"

killall instruments

echo "extracting" $ipa...

unzip -q -o $ipa

appBundle=$(find Payload -name "*.app")

echo "using app bundle:" $appBundle

if [ -n "$2" ]
then
	echo "only deploying to device with serial provided"
	deviceArray=($deviceSerial)
else
	echo "deploying to all connected devices"
	deviceArray=($(system_profiler SPUSBDataType | sed -n -e '/iPad/,/Serial/p' -e '/iPhone/,/Serial/p' | grep "Serial Number:" | awk -F ": " '{print $2}'))
fi

#install one at a time
for i in "${deviceArray[@]}"
do
   echo "installing to" $i
   ./ios-deploy -i $i -b $appBundle
   
   echo "using instruments to launch app on" $i
   instruments -t Automation.tracetemplate -w $i com.ImagineLearning.IL -e UIASCRIPT emptyAutomationScript.js 2> $i.log &
done

<<CommentedOut 
#run in parallel
for i in "${deviceArray[@]}"
do
   echo "starting app on " $i
   #./ios-deploy -i $i -b $appBundle -m -d -L
   instruments -t Automation.tracetemplate -w $i com.ImagineLearning.IL -e UIASCRIPT emptyAutomationScript.js 2> $i.log &
done
CommentedOut



