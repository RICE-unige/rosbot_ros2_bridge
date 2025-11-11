#!/bin/bash

# Detect if running on Jetson or laptop
IS_JETSON=false
if [ -d "/home/jetsonlab/rosbot_ros2_bridge" ] && [ -f "/home/jetsonlab/rosbot_ros2_bridge/.env" ]; then
    IS_JETSON=true
fi

if [ "$IS_JETSON" = true ]; then
    # Running on Jetson - connect to bridge container
    echo "================================================"
    echo "  Connecting to ROS2 Bridge Container"
    echo "================================================"
    echo ""
    
    # Check if container is running
    if ! sudo docker ps | grep -q ros2_foxy_bridge; then
        echo "❌ Bridge container is not running!"
        echo ""
        echo "Start the bridge first:"
        echo "  cd ~/rosbot_ros2_bridge"
        echo "  ./start.sh"
        exit 1
    fi
    
    # Load config to show info
    if [ -f ~/rosbot_ros2_bridge/.env ]; then
        source ~/rosbot_ros2_bridge/.env
        echo "Configuration:"
        echo "  ROS_DOMAIN_ID: $ROS_DOMAIN_ID"
        echo "  RMW: $RMW_IMPLEMENTATION"
        echo ""
    fi
    
    echo "Connecting to bridge container..."
    echo "You can now run ROS2 commands like:"
    echo "  ros2 topic list"
    echo "  ros2 topic echo /scan"
    echo ""
    
    # Exec into container with environment sourced
    sudo docker exec -it ros2_foxy_bridge bash -c "source /opt/ros/foxy/setup.bash && bash"
    
else
    # Running on laptop/computer - configure ROS2 environment
    echo "================================================"
    echo "  ROS2 Bridge Connection Setup"
    echo "================================================"
    echo ""
    
    # Try to detect if .env exists on Jetson (if this script was copied)
    if [ -f .env ]; then
        echo "Found local configuration file (.env)"
        source .env
        DOMAIN_ID=${ROS_DOMAIN_ID:-27}
        RMW_IMPL=${RMW_IMPLEMENTATION:-rmw_fastrtps_cpp}
    else
        # Ask user for configuration
        read -p "Enter ROS_DOMAIN_ID [default: 27]: " DOMAIN_ID
        DOMAIN_ID=${DOMAIN_ID:-27}
        
        echo ""
        echo "Select DDS implementation:"
        echo "  1) FastDDS (recommended)"
        echo "  2) CycloneDDS"
        read -p "Choose (1 or 2) [default: 1]: " DDS_CHOICE
        DDS_CHOICE=${DDS_CHOICE:-1}
        
        if [ "$DDS_CHOICE" = "2" ]; then
            RMW_IMPL="rmw_cyclonedds_cpp"
        else
            RMW_IMPL="rmw_fastrtps_cpp"
        fi
    fi
    
    echo ""
    echo "================================================"
    echo "  Configuration"
    echo "================================================"
    echo "  ROS_DOMAIN_ID=$DOMAIN_ID"
    echo "  RMW_IMPLEMENTATION=$RMW_IMPL"
    echo "================================================"
    echo ""
    
    # Export environment variables
    export ROS_DOMAIN_ID=$DOMAIN_ID
    export RMW_IMPLEMENTATION=$RMW_IMPL
    
    # Check if ROS2 is available
    if command -v ros2 &> /dev/null; then
        echo "✅ ROS2 detected!"
        echo ""
        echo "Testing connection..."
        
        # Test topic list
        if timeout 5 ros2 topic list > /dev/null 2>&1; then
            echo "✅ Successfully connected to ROS2 network!"
            echo ""
            echo "Available topics:"
            ros2 topic list | head -20
            echo ""
            echo "Your environment is configured. You can now run:"
            echo "  ros2 topic list"
            echo "  ros2 topic echo /scan"
            echo "  ros2 topic echo /odom"
        else
            echo "⚠️  No topics found. Make sure:"
            echo "  1. Jetson bridge is running"
            echo "  2. You're on the same network as the Jetson"
            echo "  3. ROS_DOMAIN_ID matches ($DOMAIN_ID)"
        fi
    else
        echo "❌ ROS2 not found on this system"
        echo ""
        echo "Add these to your ~/.bashrc or run them in your terminal:"
        echo ""
        echo "  export ROS_DOMAIN_ID=$DOMAIN_ID"
        echo "  export RMW_IMPLEMENTATION=$RMW_IMPL"
        echo ""
        echo "Then source your ROS2 installation and try:"
        echo "  ros2 topic list"
    fi
    
    echo ""
    echo "================================================"
    echo "To make this permanent, add to ~/.bashrc:"
    echo "================================================"
    echo "export ROS_DOMAIN_ID=$DOMAIN_ID"
    echo "export RMW_IMPLEMENTATION=$RMW_IMPL"
    echo "================================================"
fi
