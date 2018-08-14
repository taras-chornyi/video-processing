
videodir=grading_videos
#videodir=tmp
output=output.mp4

#
# loop for catting all files
#

for entry in $videodir/*.mp4
do
    files="$files file '$entry'\n"
done

echo -e $files > input.txt

ffmpeg -y -f concat -i input.txt -c:v copy -c:a copy $output

rm -r input.txt
