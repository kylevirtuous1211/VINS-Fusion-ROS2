#!/bin/bash

SESSION="vins_ros2_demo"

echo "========================================================"
echo "   VINS-Fusion ROS2 Demo Launcher"
echo "========================================================"
echo ""

# 1. Kill existing processes inside the container
echo "--------------------------------------------------------"
echo "[Step 1] Cleaning up old processes in container..."
echo "--------------------------------------------------------"
sudo docker exec vins_fusion_build pkill -f "ros2 bag play" 2>/dev/null
sudo docker exec vins_fusion_build pkill -f "vins_node" 2>/dev/null
sudo docker exec vins_fusion_build pkill -f "rosbridge" 2>/dev/null
echo " > Cleaning up legacy ROS1 container (freed ports)..."
sudo docker exec ros1_vins_fusion pkill -f "foxglove" 2>/dev/null
sudo docker exec ros1_vins_fusion pkill -f "rosbridge" 2>/dev/null

# Clean up existing tmux session
tmux kill-session -t $SESSION 2>/dev/null

# Wait for cleanup
sleep 3
echo "Cleanup done."
echo ""

# 2. Setup tmux layout
echo "--------------------------------------------------------"
echo "[Step 2] Setting up Tmux session '$SESSION'..."
echo "--------------------------------------------------------"
tmux new-session -d -s $SESSION
tmux split-window -h
tmux select-pane -t $SESSION:0.0
tmux split-window -v
tmux select-pane -t $SESSION:0.2
tmux split-window -v
tmux select-pane -t $SESSION:0.3

# Layout:
# Pane 0 (TL): Foxglove Bridge (Comm)
# Pane 1 (BL): VINS Node (Algorithm)
# Pane 2 (TR): System Monitor
# Pane 3 (BR): Rosbag Play (Data)

# 3. Send Commands

echo "--------------------------------------------------------"
echo "[Step 3] Launching components..."
echo "--------------------------------------------------------"

# Pane 0: TL - Foxglove Bridge (Port 8765)
echo " > Starting Foxglove Bridge (Pane 0)..."
tmux send-keys -t $SESSION:0.0 'echo "Pane 0: Foxglove Bridge (Port 8765)"; sudo docker exec -it vins_fusion_build bash -c "source /opt/ros/humble/setup.bash && ros2 launch foxglove_bridge foxglove_bridge_launch.xml"' C-m

# Pane 1: BL - VINS Node
# Running with use_sim_time:=True to sync with bag clock
echo " > Starting VINS Node (Pane 1)..."
tmux send-keys -t $SESSION:0.1 'echo "Pane 1: Waiting 5s then starting VINS..."; sleep 5; sudo docker exec -it vins_fusion_build bash -c "source /root/colcon_ws/install/setup.bash && ros2 run vins vins_node /root/colcon_ws/src/VINS-Fusion-ROS2/config/euroc/euroc_stereo_imu_config.yaml --ros-args -p use_sim_time:=True"' C-m

# Pane 2: TR - System Monitor (htop or top)
echo " > Starting Monitor (Pane 2)..."
tmux send-keys -t $SESSION:0.2 'echo "Pane 2: System Monitor"; sudo docker exec -it vins_fusion_build bash -c "top"' C-m

# Pane 3: BR - Rosbag Play
echo " > Queuing Rosbag Play (Pane 3)..."
tmux send-keys -t $SESSION:0.3 'echo "Pane 3: Waiting 10s for VINS..."; sleep 10; echo "Playing Rosbag (--clock loop)..."; sudo docker exec -it vins_fusion_build bash -c "source /opt/ros/humble/setup.bash && cd /root/colcon_ws/src/VINS-Fusion-ROS2 && ros2 bag play MH_01_easy_ros2 --clock --loop"' C-m

# Layout equality
tmux select-layout tiled

# Attach
echo ""
echo "========================================================"
echo "   Demo Started! Attaching to session..."
echo "   (Press Ctrl+B then D to detach)"
echo "========================================================"
sleep 1
tmux attach -t $SESSION
