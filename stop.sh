#!/bin/bash

echo "Stopping ROSbot ROS1-ROS2 Bridge..."

sudo docker stop ros2_foxy_bridge 2>/dev/null
sudo docker rm ros2_foxy_bridge 2>/dev/null

echo "✅ Bridge stopped and container removed"
