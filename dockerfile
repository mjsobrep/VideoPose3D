# from https://github.com/facebookresearch/detectron2/blob/main/docker/Dockerfile
FROM nvidia/cuda:11.3.1-cudnn8-devel-ubuntu18.04
# use an older system (18.04) to avoid opencv incompatibility (issue#3524)

ENV DEBIAN_FRONTEND noninteractive
#get deps
RUN apt-get update -y && \
 apt-get install -y --no-install-recommends \
    python3-dev python3-pip git g++ wget make libopencv-dev \
    libhdf5-dev python3-setuptools ffmpeg ninja-build build-essential


#RUN apt-get update && apt-get install -y \
#    python3-opencv ca-certificates python3-dev git wget sudo ninja-build
#RUN ln -sv /usr/bin/python3 /usr/bin/python

# create a non-root user
ARG USER_ID=1000
RUN useradd -m --no-log-init --system  --uid ${USER_ID} appuser -g sudo
RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
USER appuser
WORKDIR /home/appuser

ENV PATH="/home/appuser/.local/bin:${PATH}"

#for python api
RUN pip3 install --upgrade pip
RUN pip3 install numpy opencv-python tqdm scipy matplotlib

RUN pip3 install torch==1.10.1+cu113 torchvision==0.11.2+cu113 torchaudio==0.10.1+cu113 -f https://download.pytorch.org/whl/cu113/torch_stable.html

#RUN pip3 install 'git+https://github.com/facebookresearch/detectron2.git'
RUN pip3 install detectron2 -f https://dl.fbaipublicfiles.com/detectron2/wheels/cu113/torch1.10/index.html

RUN mkdir -p /home/appuser/VideoPose3D/checkpoint

COPY --chown=appuser:sudo . /home/appuser/VideoPose3D

WORKDIR /home/appuser/VideoPose3D/checkpoint
RUN wget -q https://dl.fbaipublicfiles.com/video-pose-3d/pretrained_h36m_detectron_coco.bin

WORKDIR /home/appuser/VideoPose3D/
