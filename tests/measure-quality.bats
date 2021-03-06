#
# Copyright (c) 2020 Intel Corporation
#
# Permission is hereby granted, free of charge, to any person obtaining 
# a copy of this software and associated documentation files (the 
# "Software"), to deal in the Software without restriction, including 
# without limitation the rights to use, copy, modify, merge, publish, 
# distribute, sublicense, and/or sell copies of the Software, and to 
# permit persons to whom the Software is furnished to do so, subject to 
# the following conditions:
#
# The above copyright notice and this permission notice shall be 
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, 
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF 
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. 
# IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY 
# CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, 
# TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE 
# SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

load utils

# subsample by 4
subs="ffmpeg -i \
  /opt/data/embedded/WAR_TRAILER_HiQ_10_withAudio.mp4 \
  -s 480x270 -sws_flags lanczos -vframes 100 WAR.mp4"
@test "measure quality: transcode 65 frames, calculate metrics, measure bdrate and check measuring artifacts" {
  run docker_run /bin/bash -c "set -ex; $subs; \
    measure quality --nframes 65 WAR.mp4; \
    result=\$(cat /opt/data/artifacts/measure/quality/*{.metrics,bdrate} | wc -l); \
    [[ \$result = 24 ]]"
  print_output
  [ $status -eq 0 ]
}

# convert to yuv420
cyuv="ffmpeg -i WAR.mp4 \
  -c:v rawvideo -pix_fmt yuv420p -vsync passthrough WAR.yuv"

@test "measure quality: encode 5 frames of a user-defined YUV video with AVC" {
  run docker_run /bin/bash -c "set -ex; $subs; $cyuv; \
    measure quality -w 480 -h 270 -f 24 \
    --nframes 5 --skip-metrics --skip-bdrate \
    WAR.yuv; \
    result=\$(find /opt/data/artifacts/measure/quality/ -not -empty -type f -ls | wc -l); \
    [[ \$result = 30 ]]"
  print_output
  [ $status -eq 0 ]
}

@test "measure quality: encode 5 frames of a user-defined YUV video with HEVC" {
  run docker_run /bin/bash -c "set -ex; $subs; $cyuv; \
    measure quality -w 480 -h 270 -f 24 \
    --codec HEVC --nframes 5 --skip-metrics --skip-bdrate \
    WAR.yuv; \
    result=\$(find /opt/data/artifacts/measure/quality/ -not -empty -type f -ls | wc -l); \
    [[ \$result = 30 ]]"
  print_output
  [ $status -eq 0 ]
}

# mock ParkScene: subsample to 720p
subs2="ffmpeg -i \
  /opt/data/embedded/WAR_TRAILER_HiQ_10_withAudio.mp4 \
  -s 1280x720 -sws_flags lanczos -vframes 240 ParkScene.mp4"

# mock ParkScene: convert to yuv
cyuv2="ffmpeg -i ParkScene.mp4 -c:v rawvideo -pix_fmt yuv420p \
  -vsync passthrough ParkScene_1280x720_24.yuv"

@test "measure quality: encode 5 frames of a predefined YUV video with AVC" {
  run docker_run /bin/bash -c "set -ex; $subs2; $cyuv2; \
    measure quality --nframes 5 --skip-metrics --skip-bdrate \
    ParkScene_1280x720_24.yuv; \
    result=\$(find /opt/data/artifacts/measure/quality/ -not -empty -type f -ls | wc -l); \
    [[ \$result = 30 ]]"
  print_output
  [ $status -eq 0 ]
}

@test "measure quality: encode 5 frames of a predefined YUV video with HEVC" {
  run docker_run /bin/bash -c "set -ex; $subs2; $cyuv2; \
    measure quality --codec HEVC --nframes 5 --skip-metrics --skip-bdrate \
    ParkScene_1280x720_24.yuv; \
    result=\$(find /opt/data/artifacts/measure/quality/ -not -empty -type f -ls | wc -l); \
    [[ \$result = 30 ]]"
  print_output
  [ $status -eq 0 ]
}

# get raw H.264 stream from an mp4 container
get264="ffmpeg -i WAR.mp4 -vcodec copy -an WAR.h264"

@test "measure quality: transcode 5 frames of a user-defined raw H.264 video stream into AVC stream" {
  run docker_run /bin/bash -c "set -ex; $subs; $get264; \
    measure quality --nframes 5 --skip-metrics --skip-bdrate \
    WAR.h264; \
    result=\$(find /opt/data/artifacts/measure/quality/ -not -empty -type f -ls | wc -l); \
    [[ \$result = 30 ]]"
  print_output
  [ $status -eq 0 ]
}

@test "measure quality: transcode 5 frames of a user-defined raw H.264 video stream into HEVC stream" {
  run docker_run /bin/bash -c "set -ex; $subs; $get264; \
    measure quality --codec HEVC --nframes 5 --skip-metrics --skip-bdrate \
    WAR.h264; \
    result=\$(find /opt/data/artifacts/measure/quality/ -not -empty -type f -ls | wc -l); \
    [[ \$result = 30 ]]"
  print_output
  [ $status -eq 0 ]
}

# get raw HEVC stream from an mp4 container
get265="ffmpeg -i WAR.mp4 -y -vframes 5 -c:v libx265 -preset medium -b:v 15M -vsync 0 WAR.h265"

@test "measure quality: transcode 5 frames of a user-defined raw HEVC video stream into AVC stream" {
  run docker_run /bin/bash -c "set -ex; $subs; $get265; \
    measure quality --nframes 5 --skip-metrics --skip-bdrate \
    WAR.h265; \
    result=\$(find /opt/data/artifacts/measure/quality/ -not -empty -type f -ls | wc -l); \
    [[ \$result = 30 ]]"
  print_output
  [ $status -eq 0 ]
}

@test "measure quality: transcode 5 frames of a user-defined raw HEVC video stream into HEVC stream" {
  run docker_run /bin/bash -c "set -ex; $subs; $get265; \
    measure quality --codec HEVC --nframes 5 --skip-metrics --skip-bdrate \
    WAR.h265; \
    result=\$(find /opt/data/artifacts/measure/quality/ -not -empty -type f -ls | wc -l); \
    [[ \$result = 30 ]]"
  print_output
  [ $status -eq 0 ]
}
