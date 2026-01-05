FROM ros:humble

ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies
RUN apt-get update && apt-get install -y \
      cmake \
      build-essential \
      libceres-dev \
      libeigen3-dev \
      libgoogle-glog-dev \
      libgflags-dev \
      libopencv-dev \
      libsuitesparse-dev \
      ros-humble-cv-bridge \
      ros-humble-image-transport \
      ros-humble-message-filters \
      ros-humble-tf2 \
      ros-humble-tf2-ros \
      ros-humble-tf2-geometry-msgs \
      ros-humble-rosbridge-suite \
      ros-humble-foxglove-bridge \
      ros-humble-pcl-ros \
      ros-humble-pcl-conversions \
      && rm -rf /var/lib/apt/lists/*

# Setup workspace
WORKDIR /root/colcon_ws/src
WORKDIR /root/colcon_ws

# Copy entrypoint script if needed, or just use the ros one and add ours
# For now, we will source in the command or use a custom entrypoint
COPY ./docker/ros_entrypoint.sh /ros_entrypoint.sh
RUN apt-get update && apt-get install -y dos2unix && dos2unix /ros_entrypoint.sh && chmod +x /ros_entrypoint.sh && rm -rf /var/lib/apt/lists/*
ENTRYPOINT ["/ros_entrypoint.sh"]

# Default command
CMD ["bash"]
