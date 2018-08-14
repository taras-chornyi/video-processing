#!/bin/bash
#
#
# Author: Taras Chornyi, 2015-2018
#

assetsdir=assets

ffmpeg="ffmpeg -threads 4"
#ffmpeg="cpulimit -l 300 ffmpeg -threads 4"
ffprobe="ffprobe"

# Team's names
team1=TM1
team2=TM2

# The first file in the collections of files
startVideoFile=1190686

# First file of the first time 
firstTimeFile=P1190687.MP4
# First file of the second time
secondTimeFile=P1190743.MP4

#
# goals number of file
#

goalNumber1=1190741
goalNumber2=1190772
goalNumber3=1190800

goalNumber4=1190285
goalNumber5=1190318
goalNumber6=1190340
goalNumber7=1190398

goalNumber8=1140707
goalNumber9=1140728
goalNumber10=1140742
goalNumber11=1140750
#goalNumber10=1080814
#goalNumber11=1080814


#
# Video parameters (grading, fonts, overlays, codecs and etc)
#

videodir=grading_videos
mkdir $videodir

timebkg="$assetsdir/timebkg.png"
cmdbkg="$assetsdir/cmdbkg.png"
agecmdbkg="$assetsdir/agebkg.png"
logo="$assetsdir/arsenal.png"
title="$assetsdir/titlebkg.png"

font1="$assetsdir/SFNSDisplay-Bold.ttf"

output=output.mp4
vcodec="libx264 -preset superfast -pix_fmt yuv420p"  #-qscale:v 3"
#vcodec="libx264 -preset medium -crf 19"  #-qscale:v 3"
#vcodec="libx264 -preset ultrafast -crf 19"  #-qscale:v 3"
#curves="curves=r='0.149/0.066 0.831/0.905 0.905/0.91':g='0.149/0.066 0.831/0.905 0.905/0.91':b='0.149/0.066 0.831/0.905 0.905/0.91'"
master="0.149/0.065 0.831/0.905 0.905/0.97"
#curves="curves=r='$master':g='$master':b='$master'"
curves="curves=preset=medium_contrast"
scale="scale=1920x1080"

drawcommand1="drawtext='$font1:text=$team1:reload=0:x=645:y=143:fontsize=50:fontcolor=white@0.99:shadowx=3:shadowy=3:shadowcolor=555555ff'"
drawcommand2="drawtext='$font1:text=$team2:reload=0:x=950:y=143:fontsize=50:fontcolor=white@0.99:shadowx=3:shadowy=3:shadowcolor=555555ff'"
drawagetext="drawtext='$font1:text=$age:reload=0:x=3580:y=143:fontsize=50:fontcolor=white@0.99:shadowx=3:shadowy=3:shadowcolor=555555ff'"
overlay="overlay=200:120"
overlay1="overlay=600:120"
overlay3="overlay=3750:120"
#overlayage="overlay=3500:120"
acodec=libmp3lame

#

# goals timing and location
#

destination="reload=0:$font1:y=143:x=790:fontsize=50:fontcolor=white@0.99:shadowx=5:shadowy=5:shadowcolor=111111"
f00="drawtext=text='0 - 0':$destination"
f01="drawtext=text='1 - 0':$destination"
f02="drawtext=text='1 - 1':$destination"
f03="drawtext=text='1 - 2':$destination"

f04="drawtext=text='1 - 3':$destination"
f05="drawtext=text='2 - 3':$destination"
f06="drawtext=text='3 - 3':$destination"
f07="drawtext=text='3 - 4':$destination"

f08="drawtext=text='7 - 1':$destination"
f09="drawtext=text='8 - 1':$destination"
f10="drawtext=text='9 - 1':$destination"
f11="drawtext=text='10 - 1':$destination"


#
# Information bar
#
draw_info(){
    offset=(4096-2500)/2
    overlay_info="overlay=enable='between(t,$1,$2+1)':x='min($2*(w+$offset)-(abs($2-2*(t-$1)))*(w+$offset)-w,$offset)':y=1780"

    fpar="reload=0:$font1:fontsize=50:fontcolor=white@0.99:shadowx=5:shadowy=5:shadowcolor=111111"
    widtext=4096/2
    text_info=drawtext="$font:enable='between(t,$1,$2+1)':textfile=$3:x='min($2*(tw+(w-tw)/2)-(abs($2-2*(t-$1)))*(tw+(w-tw)/2)-tw,(w-tw)/2)':y=1820:$fpar"
}


#
# Get base time function
#

int_basetime=0
get_time(){
    basetime=$($ffprobe -v quiet -print_format flat -show_format $1 | grep creation_time | cut -d= -f2- | tr -d '"')
    int_basetime=$(date -j -f "%Y-%m-%dT%H:%M:%S" $basetime +%s)
    #int_basetime=$(date -j -f "\"%Y-%M-%d %H:%M:%S\"" "$basetime" +%s)
    #basetime="${basetime/\"/}"
    #basetime="${basetime/\"/}"
    #int_basetime=$(date -j -f "\"%Y-%M-%d %H:%M:%S\"" "$basetime" +%s)
    #int_basetime=$(date +"%Y-%M-%d %H:%M:%S" $basetime)
    #int_basetime=$(date +%s -d"2013-12-01 12:00:00")
    #int_basetime=$(date +%s -d"$basetime")
	#echo $basetime
}

#
# Get time for the first time start
#

get_time $firstTimeFile
startFirstTime=$int_basetime

#
# Set time for the second time start
#

get_time $secondTimeFile
startSecondTime=$int_basetime

#
# Additional filter
#
filter1="[0:v]eq=contrast=1:brightness=0:saturation=1:gamma=1:gamma_r=1:gamma_g=1:gamma_b=1:gamma_weight=1[outv]"
#eq="eq=contrast=0.0:brightness=0.00:saturation=0.0"
eq="eq=contrast=1.0:brightness=0.05:saturation=1.1:gamma=1:gamma_r=1:gamma_g=1:gamma_b=1:gamma_weight=1"

#
# processing video files function 
#
processing_video() {

	local filter=$curves,$overlay,$overlay1,$drawcommand1,$drawcommand2 #,$overlay3
	local filter_goal=$f00    
                  
    if [ $1 -ge $goalNumber1 ] && [ $1 -lt $goalNumber2 ] ; then
      	filter_goal=$f01
    fi
    if [ $1 -ge $goalNumber2 ] && [ $1 -lt $goalNumber3 ] ; then
        filter_goal=$f02
    fi
    if [ $1 -ge $goalNumber3 ] ; then
        filter_goal=$f03
    fi
<<'COMMENT'
	if [ $1 -ge $goalNumber4 ] && [ $1 -lt $goalNumber5 ] ; then
        filter_goal=$f04
    fi
	if [ $1 -ge $goalNumber5 ] && [ $1 -lt $goalNumber6 ] ; then
        filter_goal=$f05
    fi
    if [ $1 -ge $goalNumber6 ] && [ $1 -lt $goalNumber7 ]; then
        filter_goal=$f06
    fi
 	if [ $1 -ge $goalNumber7 ] ; then
        filter_goal=$f07
    fi
COMMENT

	drawtime_params="reload=0:$font1:fontsize=50:fontcolor=white@0.99:shadowx=3:shadowy=3:shadowcolor=555555ff"
    filter=$filter,$filter_goal,$eq

	file=$(printf "%0.3d.mp4" $2)
    echo -e "Processing file" $file 
	if [ -f $videodir/$file ]; then
		echo -e $file " file already exist. Skipping processing..."
		return
    fi

    get_time $entry
	if [ $int_basetime -lt $startFirstTime ]; then
		draw_info 1 12 info/info1
        filter=$curves,$overlay_info,$text_info
  		$ffmpeg -i $3 -i $title -c:v $vcodec -c:a $acodec -filter_complex "$filter" $videodir/$file
    fi
    if [ $int_basetime -ge $startFirstTime ] && [ $int_basetime -lt $startSecondTime ]; then
        int__starttime=$((int_basetime - startFirstTime))
        int_starttime=$((int__starttime*1000000))
        drawtime="drawtext=expansion=strftime:basetime=$int_starttime:text='%M\\:%S':$drawtime_params:x=410:y=143"
        drawpart="drawtext=text='1st':$drawtime_params:x=245:y=143"
        filter=$filter,$drawtime,$drawpart
    fi

    if [ $int_basetime -ge $startSecondTime ]; then
        int_starttime=$((int_basetime - startSecondTime))
        int_starttime=$((int_starttime*1000000))
        drawtime="drawtext=expansion=strftime:basetime=$int_starttime:text='%M\\:%S':$drawtime_params:x=410:y=143"
        drawpart="drawtext=text='2nd':$drawtime_params:x=230:y=143"
        filter=$filter,$drawtime,$drawpart
    fi

    if [ P$1.MP4 = $firstTimeFile ]; then
        draw_info 1 10 info/info2
        filter=$filter,$overlay_info,$text_info
    fi
    if [ P$1.MP4 = $secondTimeFile ]; then
        draw_info 1 10 info/info3
        filter=$filter,$overlay_info,$text_info
    fi

    #filter=$filter,$scale
	
  	$ffmpeg -i $3 -i $timebkg -i $cmdbkg -i $title -c:v $vcodec -c:a $acodec -filter_complex "$filter" $videodir/$file
}

#
# processing reply fragments function
#

processing_reply() {
	filter=$curves,$overlay3
    $ffmpeg -i $2 -i $logo -c:v $vcodec -c:a $acodec -filter_complex "$filter" $videodir/$(printf "%0.3d.mp4" $1)
}

#
# main loop
#

i=1
for entry in *.MP4
do
	file_number=${entry:1:7}

    prefix=${entry:8:1}
	if [ $prefix == '_' ]; then
		processing_reply $i $entry
	else 
		processing_video $file_number $i $entry
	fi 

    ((i++))
done


#rm -r input.txt


