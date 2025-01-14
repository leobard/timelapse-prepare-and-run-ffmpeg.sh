# timelapse-prepare-and-run-ffmpeg.sh
This bash script makes a 25 fps time lapse video and according subtitle file with timestamps based on date-named JPG files using ffmpeg.
Input is the current directory, all JPG files are processed in order of filename alphabetically.
It does not have any input parameters.


```yaml
name    : timelapse-prepare-and-run-ffmpeg.sh
author  : leo sauermann
date    : 2021-05
license : https://opensource.org/licenses/MIT
seeAlso : https://github.com/leobard/timelapse-prepare-and-run-ffmpeg.sh
```


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

cmd.exe version:
```cmd.exe
exiftool "-FileName<${datetimeoriginal}${subsectimeoriginal}%-c.%e" -d %Y-%m-%d_%H%M%S . 
```

bash version:
```bash
exiftool '-FileName<${datetimeoriginal}${subsectimeoriginal}%-c.%e' -d %Y-%m-%d_%H%M%S . 
```

The files may also be handled by enfuse beforehand, then the names are concatenated and longer
`2021-05-17_00250543-2021-05-17_00250705.jpg`

# Output files

The script will generate three output files

```
video.mp4
video1080.mp4
subtitles.srt
```

## Videos

The two video files are: `video.mp4` in original resolution and `video1080.mp4` scaled to 1080 pixel vertical resolution.

## Subtitles

The subtitle file `subtitles.srt` stores the date and time of each frame as subtitle of length 0.04 seconds. That is 25 frames per second. These are intended as meta-data for further post-processing.

Example of a block of the resulting SRT:
```srt
1
00:00:00,040 --> 00:00:00,080
2021-05-17 00:25

```