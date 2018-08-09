FROM alpine:edge

ENV CC /usr/bin/clang
ENV CXX /usr/bin/clang++

COPY . /cart-build

RUN echo '@testing http://dl-cdn.alpinelinux.org/alpine/edge/testing' >> /etc/apk/repositories \
    && apk update && apk upgrade \
    && apk add --update --no-cache \
      libtbb@testing \
      libtbb-dev@testing \
      clang-dev \
      libjpeg \
      openblas \
      libpng \
      jasper \
      tiff \
      libwebp \
    && apk add --update --no-cache \
      --virtual .build-deps \
      build-base \
      openblas-dev \
      unzip \
      wget \
      cmake \
      # accelerated baseline JPEG compression and decompression library
      libjpeg-turbo-dev \
      # Portable Network Graphics library
      libpng-dev \
      # A software-based implementation of the codec specified in the emerging JPEG-2000 Part-1 standard (development files)
      jasper-dev \
      # Provides support for the Tag Image File Format or TIFF (development files)
      tiff-dev \
      # Libraries for working with WebP images (development files)
      libwebp-dev \
      linux-headers \
    # Build OpenCV 3.3.0
    && mkdir -p /tmp && cd /tmp \
    && wget -q https://github.com/opencv/opencv/archive/3.3.0.zip \
    && unzip -q 3.3.0.zip \
    && cd /tmp/opencv-3.3.0 \
    && mkdir build \
    && cd build \
    && cmake -D CMAKE_BUILD_TYPE=RELEASE -D CMAKE_INSTALL_PREFIX=/usr/local -D WITH_FFMPEG=NO -D WITH_PYTHON=NO \
         -D WITH_IPP=NO -D WITH_OPENEXR=NO .. \
    && make -j"$(nproc)" \
    && make install \
    # Build cart
    && cd /cart-build && mkdir build && cd build \
    && cmake .. -D CMAKE_INSTALL_PREFIX=/usr/local \
    && make -j"$(nproc)" \
    && make install \
    # Cleanup
    && rm -rf /cart-build \
    && rm -rf /tmp/* \
    && apk del --purge .build-deps \
    && rm -rf /var/cache/apk/*

ENTRYPOINT ["/usr/local/bin/cart"]
