#!/bin/bash
if [[ !  -d "/srv/yt/downloads" ]]
then
exit 1
fi
if [[ !  -d "/var/log/yt"  ]]
then
exit 1
fi
video_name="$(youtube-dl -title $1 2> /dev/null)"
video_name="$(echo ${video_name} | tr ' ' '_')"
mkdir /srv/yt/downloads/${video_name}
cd /srv/yt/downloads/${video_name}
youtube-dl $1 1> /dev/null
cp *'.mp4' "${video_name}.mp4"
rm *' '*
mkdir description
cd description
youtube-dl --get-description $1>${video_name}.description 2> /dev/null
echo "Video $1 was downloaded."
echo "File path : /srv/yt/downloads/${video_name}/${video_name}.mp4"
echo "[$(date +"%Y-%m-%d %T")] Video $1 was downloaded. File path : /srv/yt/downloads/${video_name}/${video_name}.mp4">>/var/log/yt/download.log
