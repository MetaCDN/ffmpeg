# cross compile build native FFmpeg static with SRT

FROM ubuntu:18.04 AS kjsl_ubuntu18_baseline
MAINTAINER kevleyski

# Pull in build cross compiler tool dependencies using Advanced Package Tool
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Australia/Sydney

RUN set -x \
    && apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get --fix-missing -y install tzdata wget curl autoconf automake build-essential libass-dev libfreetype6-dev \
                                            libsdl1.2-dev libtheora-dev libtool libva-dev libvdpau-dev libvorbis-dev libxcb1-dev libxcb-shm0-dev \
                                            libxcb-xfixes0-dev pkg-config texinfo zlib1g-dev gettext tcl libssl-dev cmake mercurial unzip git \
                                            libdrm-dev valgrind libpciaccess-dev libxslt1-dev geoip-bin libgeoip-dev zlib1g-dev libpcre3 libpcre3-dev \
                                            libbz2-dev ca-certificates libssl-dev nasm strace vim \
    && mkdir ~/kjsl \
    && apt-get -y install yasm \
    && cd ~/kjsl \
    && wget http://www.tortall.net/projects/yasm/releases/yasm-1.3.0.tar.gz \
    && tar xzvf yasm-1.3.0.tar.gz \
    && rm -f yasm-1.3.0.tar.gz \
    && cd yasm-1.3.0 \
    && ./configure --prefix="$HOME/kjsl" --bindir="$HOME/bin" \
    && make -j$(cat /proc/cpuinfo | grep processor | wc -l) \
    && make install

# Intel VAAPI
RUN set -x \
    && cd ~/kjsl \
    && git clone https://github.com/kevleyski/libva libva \
    && cd libva \
    && PATH="$HOME/bin:$PATH" PKG_CONFIG_PATH="$HOME/kjsl/lib/pkgconfig" ./autogen.sh \
    && PATH="$HOME/bin:$PATH" PKG_CONFIG_PATH="$HOME/kjsl/lib/pkgconfig" ./configure --prefix="$HOME/kjsl" \
    && PATH="$HOME/bin:$PATH" make -j$(cat /proc/cpuinfo | grep processor | wc -l) \
    && make install

RUN set -x \
    && cd ~/kjsl \
    && git clone https://github.com/kevleyski/ffmpeg_vaapi_cmrt cmrt \
    && cd cmrt \
    && PATH="$HOME/bin:$PATH" PKG_CONFIG_PATH="$HOME/kjsl/lib/pkgconfig" ./autogen.sh \
    && PATH="$HOME/bin:$PATH" PKG_CONFIG_PATH="$HOME/kjsl/lib/pkgconfig" ./configure --prefix="$HOME/kjsl" \
    && PATH="$HOME/bin:$PATH" make -j$(cat /proc/cpuinfo | grep processor | wc -l) \
    && make install

RUN set -x \
    && cd ~/kjsl \
    && git clone https://github.com/kevleyski/ffmpeg_vaapi_intel-hybrid-driver intel-hybrid-driver \
    && cd intel-hybrid-driver \
    && PATH="$HOME/bin:$PATH" PKG_CONFIG_PATH="$HOME/kjsl/lib/pkgconfig" ./autogen.sh \
    && PATH="$HOME/bin:$PATH" PKG_CONFIG_PATH="$HOME/kjsl/lib/pkgconfig" ./configure --prefix="$HOME/kjsl" \
    && PATH="$HOME/bin:$PATH" make -j$(cat /proc/cpuinfo | grep processor | wc -l) \
    && make install

RUN set -x \
    && cd ~/kjsl \
    && git clone https://github.com/kevleyski/intel-vaapi-driver intel-vaapi-driver \
    && cd intel-vaapi-driver \
    && PATH="$HOME/bin:$PATH" PKG_CONFIG_PATH="$HOME/kjsl/lib/pkgconfig" ./autogen.sh \
    && PATH="$HOME/bin:$PATH" PKG_CONFIG_PATH="$HOME/kjsl/lib/pkgconfig" ./configure --prefix="$HOME/kjsl" \
    && PATH="$HOME/bin:$PATH" make -j$(cat /proc/cpuinfo | grep processor | wc -l) \
    && make install

RUN set -x \
    && cd ~/kjsl \
    && git clone https://github.com/kevleyski/libva-utils libva-utils \
    && cd libva-utils \
    && PATH="$HOME/bin:$PATH" PKG_CONFIG_PATH="$HOME/kjsl/lib/pkgconfig" ./autogen.sh \
    && PATH="$HOME/bin:$PATH" PKG_CONFIG_PATH="$HOME/kjsl/lib/pkgconfig" ./configure --prefix="$HOME/kjsl" \
    && PATH="$HOME/bin:$PATH" make -j$(cat /proc/cpuinfo | grep processor | wc -l) \
    && make install

# libSRT (dependency /usr/bin/tclsh)
RUN set -x \
    && cd ~/kjsl \
    && git clone https://github.com/kevleyski/srt srt \
    && cd srt \
    && PATH="$HOME/bin:$PATH" PKG_CONFIG_PATH="$HOME/kjsl/lib/pkgconfig" ./configure --prefix="$HOME/kjsl" --enable-static --disable-shared \
    && PATH="$HOME/bin:$PATH" make -j$(cat /proc/cpuinfo | grep processor | wc -l) \
    && make install

# x264 software encoder
RUN set -x \
    && cd ~/kjsl \
    && git clone https://github.com/kevleyski/x264 \
    && cd x264 \
    && PATH="$HOME/bin:$PATH" PKG_CONFIG_PATH="$HOME/kjsl/lib/pkgconfig" ./configure  --enable-static \
    && PATH="$HOME/bin:$PATH" make -j$(cat /proc/cpuinfo | grep processor | wc -l) \
    && make install

# FDK_AAC
RUN set -x \
    && cd ~/kjsl \
    && git clone https://github.com/MetaCDN/fdk-aac \
    && cd fdk-aac \
    && autoreconf -fiv \
    && PATH="$HOME/bin:$PATH" PKG_CONFIG_PATH="$HOME/kjsl/lib/pkgconfig" ./configure  --enable-static --disable-shared \
    && PATH="$HOME/bin:$PATH" make -j$(cat /proc/cpuinfo | grep processor | wc -l) \
    && make install

# NVIDIA CUDA SDK
RUN set -x \
    && cd ~/kjsl \
    && wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu1804/x86_64/cuda-ubuntu1804.pin \
    && mv cuda-ubuntu1804.pin /etc/apt/preferences.d/cuda-repository-pin-600 \
    && wget https://developer.download.nvidia.com/compute/cuda/11.6.0/local_installers/cuda-repo-ubuntu1804-11-6-local_11.6.0-510.39.01-1_amd64.deb \
    && dpkg -i cuda-repo-ubuntu1804-11-6-local_11.6.0-510.39.01-1_amd64.deb \
    && apt-key add /var/cuda-repo-ubuntu1804-11-6-local/7fa2af80.pub \
    && apt-get update \
    && apt-get -y install cuda

# NVIDIA NVENC SDK
RUN set -x \
    && cd ~/kjsl \
    && git clone https://git.videolan.org/git/ffmpeg/nv-codec-headers.git \
    && cd nv-codec-headers \
    && PATH="$HOME/bin:$PATH" make -j$(cat /proc/cpuinfo | grep processor | wc -l) \
    && make install

## Build FFmpeg
FROM kjsl_ubuntu18_baseline AS kjsl_ffmpeg

COPY . /root/kjsl/ffmpeg/

RUN cd $HOME/kjsl/ffmpeg \
    && PATH="$HOME/bin:/usr/local/cuda-11.6/bin:$PATH" PKG_CONFIG_PATH="$HOME/kjsl/lib/pkgconfig" ./configure \
      --prefix="$HOME/kjsl" \
      --extra-cflags="-I$HOME/kjsl/include" \
      --extra-ldflags="-L$HOME/kjsl/lib" \
      --extra-libs="-lpthread -lm" \
      --bindir="$HOME/kjsl/bin" \
      --enable-ffplay \
      --enable-gpl \
      --disable-libxcb \
      --disable-xlib \
      --disable-lzma \
      --disable-alsa \
      --enable-libx264 \
      --enable-vaapi \
      --enable-nonfree \
      --enable-openssl \
      --enable-libsrt \
      --enable-libfreetype \
      --enable-libfdk_aac \
      --enable-cuda-sdk \
      --enable-cuvid \
      --enable-nvenc \
      --disable-doc \
      --pkg-config-flags="--static" \
    && PATH="$HOME/bin:/usr/local/cuda-11.6/bin:$PATH" make -j$(cat /proc/cpuinfo | grep processor | wc -l) \
    && make install \
    && hash -r
