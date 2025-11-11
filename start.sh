#!/bin/bash

# Load environment variables
if [ -f .env ]; then
    source .env
else
    # Default values
    ROS_MASTER_URI=http://10.42.0.18:11311
    ROS1_IP=10.42.0.1
    ROS_DOMAIN_ID=27
    RMW_IMPLEMENTATION=rmw_fastrtps_cpp
fi

echo "Starting ROSbot ROS1-ROS2 Bridge..."
echo "ROS_MASTER_URI: $ROS_MASTER_URI"
echo "ROS_DOMAIN_ID: $ROS_DOMAIN_ID"
echo "RMW_IMPLEMENTATION: $RMW_IMPLEMENTATION"
echo ""

# Stop existing container if running
sudo docker stop ros2_foxy_bridge 2>/dev/null
sudo docker rm ros2_foxy_bridge 2>/dev/null

# Start ROS2 Foxy bridge
echo "Starting ROS2 Foxy bridge..."
sudo docker run -d --name ros2_foxy_bridge --network host \
  -e ROS_MASTER_URI=$ROS_MASTER_URI \
  -e ROS_IP=$ROS1_IP \
  -e ROS_DOMAIN_ID=$ROS_DOMAIN_ID \
  -e RMW_IMPLEMENTATION=$RMW_IMPLEMENTATION \
  rosbot_ros2_bridge_arm64 \
  ros2 run ros1_bridge dynamic_bridge --bridge-all-topics

echo ""
echo "✅ Bridge started successfully!"
echo ""
echo "View logs:    sudo docker logs -f ros2_foxy_bridge"
echo "Check status: sudo docker ps"
echo "Stop:         ./stop.sh"
