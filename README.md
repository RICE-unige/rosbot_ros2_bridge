> [!WARNING]
> **Repository Archived:** This ROSbot bridge targets ROS2 Foxy on NVIDIA Jetson and will no longer be supported.  
> For ROSbot 2.0 users who need a ROS2 Humble bridge (plus a full Docker dev/sim stack), migrate to [RICE-unige/experimental_robotics](https://github.com/RICE-unige/experimental_robotics). That project has Humble and Jazzy containers, SLAM/navigation tooling, simulators, and a ready-to-run Humble↔ROS1 bridge service you can launch from any laptop on the same network as the robot.

# ROSbot ROS2 Bridge

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![ROS1](https://img.shields.io/badge/ROS1-Noetic-blue)](http://wiki.ros.org/noetic)
[![ROS2](https://img.shields.io/badge/ROS2-Foxy-blue)](https://docs.ros.org/en/foxy/)
[![Docker](https://img.shields.io/badge/Docker-Enabled-blue)](https://www.docker.com/)

Docker-based ROS1-ROS2 bridge for Husarion ROSbot running on NVIDIA Jetson platforms. This bridge enables seamless communication between the ROSbot's ROS1 Melodic system and ROS2 networks, making all robot topics accessible to ROS2 clients on the same network.

## Features

- **Automatic Topic Bridging**: Bridges all ROSbot topics from ROS1 to ROS2
- **Multi-Network Support**: Works across Jetson's ethernet and WiFi interfaces using FastDDS
- **Easy Connection**: Simple script for both Jetson and remote computers
- **ARM64 Optimized**: Built specifically for NVIDIA Jetson platforms

## Hardware Requirements

> [!NOTE]
> Tested on NVIDIA Jetson Nano and Xavier platforms with Husarion ROSbot 2.0.

- Husarion ROSbot 2.0 (ROS1 Melodic)
- NVIDIA Jetson (Nano or Xavier)
- USB Ethernet connection between ROSbot and Jetson

## Network Topology

```
ROSbot (ROS1 Melodic)          Jetson (Bridge)              Remote Computer (ROS2)
10.42.0.18 (USB)        <-->   10.42.0.1 (USB)              
                               10.186.13.9 (WiFi)     <-->   WiFi Network (ROS2 computer)
```

## Quick Start

### 1. Configure Firewall (ROSbot)

Allow Jetson to access ROS master on the ROSbot:

```bash
# On ROSbot
sudo ufw allow from 10.42.0.1
sudo ufw reload
```

### 2. Setup Environment (Jetson)

Copy `.env.example` to `.env` and configure:

```bash
cp .env.example .env
```

Edit `.env`:
```bash
# ROS1 Configuration
ROS_MASTER_URI=http://10.42.0.18:11311
ROS_IP=10.42.0.1

# ROS2 Configuration  
ROS_DOMAIN_ID=27
RMW_IMPLEMENTATION=rmw_fastrtps_cpp
```

### 3. Start the Bridge (Jetson)

```bash
./start.sh
```

The bridge will:
- Build the Docker image (first run takes ~20-25 minutes)
- Connect to ROSbot's ROS1 master
- Bridge all topics to ROS2 with domain ID 27

### 4. Connect to the Bridge

The `connect.sh` script works on both Jetson and remote computers:

**On Jetson** (access bridge container):
```bash
./connect.sh
```

**On Remote Computer** (configure ROS2 environment):

First, copy the script to your remote computer, then run:
```bash
./connect.sh
```

The script automatically detects your environment and:
- **Jetson**: Connects you to the bridge container with ROS2 Foxy sourced
- **Remote Computer**: Configures your shell with correct ROS_DOMAIN_ID and DDS settings

> [!NOTE]
> A "remote computer" refers to any other computer with ROS2 installed that is connected to the same WiFi network as the Jetson.

### 5. Setup Environment on Remote Computer

After running `connect.sh`, make the configuration permanent by adding to `~/.bashrc`:

```bash
export ROS_DOMAIN_ID=27
export RMW_IMPLEMENTATION=rmw_fastrtps_cpp
```

Then source your ROS2 installation:
```bash
source /opt/ros/<your-ros2-distro>/setup.bash
```

### 6. Verify Connection

```bash
# List available topics
ros2 topic list

# Echo laser scan data
ros2 topic echo /scan

# Echo odometry
ros2 topic echo /odom
```

## Management Scripts

- **`start.sh`**: Build and start the bridge
- **`stop.sh`**: Stop and remove the bridge container
- **`connect.sh`**: Connect to bridge (Jetson) or configure environment (remote)

## Configuration

### ROS Domain ID

The bridge uses `ROS_DOMAIN_ID=27` by default. Change this in `.env` if you need a different domain.

### DDS Implementation

FastDDS (`rmw_fastrtps_cpp`) is used for automatic multi-network interface discovery. This is configured in `.env`.

## Troubleshooting

> [!WARNING]
> Make sure the ROSbot firewall allows traffic from the Jetson IP address.

### Cannot see ROS1 topics from Jetson

```bash
# On Jetson - Check ROS_MASTER_URI
echo $ROS_MASTER_URI

# On Jetson - Test connection to ROSbot
rostopic list
```

### Cannot see ROS2 topics from remote computer

Verify:
1. **On Jetson**: Bridge is running: `sudo docker ps | grep ros2_foxy_bridge`
2. **On Remote Computer**: Connected to same WiFi network as Jetson
3. **On Remote Computer**: Matching ROS_DOMAIN_ID (27)
4. **On Remote Computer**: Using FastDDS DDS implementation

### Bridge container fails to start

```bash
# On Jetson - Check logs
sudo docker logs ros2_foxy_bridge

# On Jetson - Verify .env configuration
cat .env
```

## Architecture

- **Base Image**: ARM64 Ubuntu 20.04
- **ROS1**: Noetic (ros-base)
- **ROS2**: Foxy (ros-base)
- **Bridge**: ros1_bridge (built from source)
- **DDS**: FastDDS (rmw_fastrtps_cpp)

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

**Maintained by RICE (Robots and Intelligent Systems for Citizens and the Environment)**
