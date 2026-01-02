#!/bin/bash

# Define image name
IMAGE_NAME="vins-fusion-ros2"

# Define workspace path inside container
CONTAINER_WS="/root/colcon_ws"

# Run the container
# --net=host: Use host networking (simplest for ROS2 communication)
# -v $(pwd)/..:/...: Mount the parent directory (repo root) to the colcon workspace source
# --privileged: Often helpful for hardware access (RealSense etc)
# -e DISPLAY: Pass display for GUI
# /ros_entrypoint.sh: Ensure entrypoint is used

echo "Starting VINS-Fusion-ROS2 container..."
echo "Mounting $(realpath ..) to $CONTAINER_WS/src/VINS-Fusion-ROS2"

sudo docker run -it --rm \
    --net=host \
    --privileged \
    -v $(realpath ..):$CONTAINER_WS/src/VINS-Fusion-ROS2 \
    -v /dev/shm:/dev/shm \
    -e DISPLAY=$DISPLAY \
    -e QT_X11_NO_MITSHM=1 \
    --name vins_fusion_ros2 \
    $IMAGE_NAME \
    bash -c "ros2 launch rosbridge_server rosbridge_websocket_launch.xml & echo 'Rosbridge started on ws://localhost:9090'; exec bash"
