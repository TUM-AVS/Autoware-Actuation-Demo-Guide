#!/bin/bash

set -e

echo "🔧 Enabling X11 forwarding for root user..."
sudo xhost local:root

echo "🐳 Starting pre-built Autoware-Actuation-Demo Docker container (with Message Converter) with X11 forwarding and mounted volumes..."
docker run -it \
  --net host \
  -v /tmp/.X11-unix:/tmp/.X11-unix:rw \
  -v "${HOME}/.Xauthority:${HOME}/.Xauthority:rw" \
  -e XAUTHORITY="${HOME}/.Xauthority" \
  -e DISPLAY="${DISPLAY}" \
  ghcr.io/tum-avs/autoware-actuation-demo-guide:running \
  bash -c "
    echo '📥 Checking for map data in ~/autoware_map...';
    mkdir -p ~/autoware_map;
    if [ ! -f ~/autoware_map/sample-map-planning ]; then
      echo '⬇️ Downloading map data...';
      gdown -O ~/autoware_map/sample-map-planning.zip 'https://docs.google.com/uc?export=download&id=1499_nsbUbIeturZaDj7jhUownh5fvXHd';
      echo '🗂️ Unzipping map data...';
      unzip -d ~/autoware_map ~/autoware_map/sample-map-planning.zip;
    else
      echo '✅ Map data already exists.';
    fi;

    echo '📡 Sourcing ROS 2 workspace...';
    cd /actuation-demo/;
    source install/setup.bash;

    echo '🚀 Launching Autoware simulation...';
    ros2 launch actuation_demos planning_simulator.launch.xml map_path:=\$HOME/autoware_map/sample-map-planning vehicle_model:=sample_vehicle sensor_model:=sample_sensor_kit
  "

