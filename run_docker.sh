#!/bin/bash
set -o errexit
set -o pipefail

rerun=false

while getopts :d: flag
do
    case "${flag}" in
        d) data=${OPTARG};;
        :) echo 'missing argument' >&2; exit 1;;
        \?) echo 'invalid option' >&2; exit 1
    esac
done

echo "Processing Files in data folder: $data"
vid_file=$(basename "$(ls "$data"/*.mp4)")
echo "found file: $vid_file"


mkdir -p "$data/keypoint_output"
mkdir -p "$data/custom_dataset"
mkdir -p "$data/viz_out"

#echo "running pose detection"
#docker run \
#    --mount type=bind,source="$data",target=/data \
#    --rm \
#    -it \
#    --workdir /home/appuser/VideoPose3D/inference \
#    videopose3d \
#    python3 infer_video_d2.py \
#    --cfg COCO-Keypoints/keypoint_rcnn_R_101_FPN_3x.yaml \
#    --output-dir /data/keypoint_output \
#    --image-ext mp4 \
#    /data

echo "creating custom dataset"
docker run \
    --mount type=bind,source="$data",target=/data \
    --rm \
    -it \
    --workdir /home/appuser/VideoPose3D/data \
    videopose3d\
    python3 prepare_data_2d_custom.py \
    -i /data/keypoint_output \
    -o /data/custom_dataset/myvideos

echo "Running 3D regression"
docker run \
    --mount type=bind,source="$data",target=/data \
    --rm \
    -it \
    videopose3d\
    python3 run.py -d /data/custom_dataset/myvideos -k /data/keypoint_output/"$vid_file" -arc 3,3,3,3,3 -c checkpoint --evaluate pretrained_h36m_detectron_coco.bin --render --viz-subject "$vid_file" --viz-action custom --viz-camera 0 --viz-video "/data/$vid_file" --viz-output /data/viz_out/viz.mp4 --viz-size 6
