#!/bin/bash
<<'###BLOCK-COMMENT'
# timelapse-prepare-and-run-ffmpeg.sh
This bash script makes a time lapse video and according subtitle file with timestamps based on date-named JPG files using ffmpeg.
Input is the current directory, all JPG files are processed in order of filename alphabetically.
It does not have any input parameters.
Output are
- two mp4 video files: video.mp4 in original resolution and video1080.mp4 scaled to 1080pixel vertical
- one subtitle file containing time for each frame: subtitles.srt 


---
name    : timelapse-prepare-and-run-ffmpeg.sh
author  : leo sauermann
date    : 2021-05
license : https://opensource.org/licenses/MIT
seeAlso : https://github.com/leobard/timelapse-prepare-and-run-ffmpeg.sh
---


# Running
```bash
$ ./timelapse-prepare-and-run-ffmpeg.sh
```

# Input filenames
precondition: the files are named using exiftool already and start with the date and time 

example beginnings of filenames:
```
2021-05-17_0025
2021-05-17_00250543.jpg
2021-05-17_00250543-2021-05-17_00250705.jpg
```


How to rename a directory of photos from `IMG001.JPG` to above:
```cmd.exe
exiftool "-FileName<${datetimeoriginal}${subsectimeoriginal}%-c.%e" -d %Y-%m-%d_%H%M%S . 
```

```bash
exiftool '-FileName<${datetimeoriginal}${subsectimeoriginal}%-c.%e' -d %Y-%m-%d_%H%M%S . 
```

The files may also be handled by enfuse beforehand, then the names are concatenated and longer
`2021-05-17_00250543-2021-05-17_00250705.jpg`


# Generated Subtitles
assuming 25fps
each frame is therefore 0.04 sec

Example of a block of the resulting SRT:
```srt
1
00:00:00,040 --> 00:00:00,080
2021-05-17 00:25

```

###BLOCK-COMMENT


echo "Preparing lists.txt and subtitles.srt. This takes a while because of awk invocation for floating-point addition..."
# frame number = subtitle number
frame=1
# subtitle start in sec (msec as decimal fraction)
fstart=0.0
rm list.txt
rm subtitles.srt
for f in *.jpg; do 
	# create both the input for ffmpeg and the subtitle file with the filenames
    # https://trac.ffmpeg.org/wiki/Concatenate
	echo "file '$f'" >> list.txt
	
	# No floating point in bash - but in awk. invocation takes ages. todo: rewrite to integer math.
	fend=$(echo $fstart 0.04 | awk '{ printf "%f", $1 + $2 }')
		
	datepart=${f:0:10}
	hourpart=${f:11:2}
	minutepart=${f:13:2}
	
	fstartstr=$(date -d@$fstart -u +%H:%M:%S,%3N)
	fendstr=$(date -d@$fend -u +%H:%M:%S,%3N)
	
	printf "%i\n%s --> %s\n%s %s:%s\n\n" $frame $fstartstr $fendstr $datepart $hourpart $minutepart >> subtitles.srt
	
	# increase counters
	let frame=$frame+1
	fstart=$fend
done

echo "Written list.txt and subtitles.srt"


echo "Running ffmpeg now"
rm video.mp4
ffmpeg -f concat -i list.txt -c:v libx264 -pix_fmt yuv420p video.mp4
rm video1080.mp4
ffmpeg -f concat -i list.txt -c:v libx264 -pix_fmt yuv420p -vf scale=-4:1080 video1080.mp4