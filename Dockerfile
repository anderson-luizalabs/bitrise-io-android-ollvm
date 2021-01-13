FROM ubuntu:16.04

ENV DEBIAN_FRONTEND noninteractive
RUN apt-get -qq update
RUN echo "en_US.UTF-8 UTF-8" > /etc/locale.gen
RUN apt-get install -qqy locales apt-utils
RUN locale-gen en_US.UTF-8
RUN dpkg-reconfigure locales

ENV LC_ALL en_US.UTF-8
ENV LANG en_US.UTF-8
ENV ANDROID_SDK_ROOT /opt/android-sdk-linux
ENV ANDROID_HOME /opt/android-sdk-linux

ENV PATH "${PATH}:${ANDROID_HOME}/tools"
ENV PATH "${PATH}:${ANDROID_HOME}/platform-tools"
ENV PATH "${PATH}:${ANDROID_HOME}/emulator"
ENV PATH "${PATH}:${ANDROID_HOME}/tools/bin"

#### DEPENDENCIES APT-GET ####
RUN apt-get install -qqy \
        build-essential \
        bzip2 \
        curl \
        git-core \
        html2text \
        lib32gcc1 \
        lib32ncurses5-dev \
        lib32stdc++6 \
        lib32z1 \
        libc6-i386 \
        libreadline6-dev \
        libsqlite3-dev \
        libssl-dev \
        libyaml-dev \
        nodejs \
        openjdk-8-jdk \
        sudo \
        unzip \
        unzip \
        wget \
        zip \
        zlib1g-dev \
        python-dev \
        python3-dev
#### END DEPENDENCIES APT-GET ####

# ------------------------------------------------------
# --- Download Android Command line Tools into $ANDROID_SDK_ROOT

RUN cd /opt \
    && wget -q https://dl.google.com/android/repository/commandlinetools-linux-6609375_latest.zip --no-check-certificate -O android-commandline-tools.zip \
    && mkdir -p ${ANDROID_SDK_ROOT}/cmdline-tools \
    && unzip -q android-commandline-tools.zip -d ${ANDROID_SDK_ROOT}/cmdline-tools \
    && rm android-commandline-tools.zip

ENV PATH ${PATH}:${ANDROID_SDK_ROOT}/platform-tools:${ANDROID_SDK_ROOT}/cmdline-tools/tools/bin

RUN yes | sdkmanager --licenses

RUN touch /root/.android/repositories.cfg

# Platform tools
RUN yes | sdkmanager "platform-tools"
RUN yes | sdkmanager --update --channel=3
RUN yes | sdkmanager \
    "platforms;android-29" \
    "ndk;16.1.4479499" \
    "cmake;3.6.4111459"

ENV CMAKE_VERSION 3.6.4111459
ENV CMAKE_PATH ${ANDROID_SDK_ROOT}/cmake/${CMAKE_VERSION}
ENV PATH ${PATH}:${CMAKE_PATH}/bin

ENV NDK_VERSION 16.1.4479499
ENV ANDROID_NDK ${ANDROID_SDK_ROOT}/ndk/${NDK_VERSION}
ENV PATH ${PATH}:${ANDROID_NDK}

WORKDIR /project

COPY llvm-obfuscator ollvm-src

RUN mkdir ollvm-bin \
    && cd ollvm-bin  \
    && cmake -G "Unix Makefiles" -DCMAKE_BUILD_TYPE=Release -DLLVM_INCLUDE_TESTS=OFF ../ollvm-src/ \
    && make -j7

# #### DOCKER INFO ###
RUN echo "Container build on `date`" > /DOCKER_INFO
ENTRYPOINT cat /DOCKER_INFO && /bin/bash
# #### DOCKER INFO END ###
