#!/bin/bash
set -e

# Setup ROS2 environment
source "/opt/ros/humble/setup.bash"

# Setup Colcon workspace if built
if [ -f "/root/colcon_ws/install/setup.bash" ]; then
    source "/root/colcon_ws/install/setup.bash"
fi

exec "$@"
