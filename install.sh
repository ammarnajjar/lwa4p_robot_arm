#!/bin/bash

# Ubuntu 14.04 64-bit
# ROS-Indigo (the most recent update)
# SocketCAN(ESD CAN card (PLX90xx), sja1000 kernel driver)

sudo sh -c 'echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list'
sudo apt-key adv --keyserver hkp://ha.pool.sks-keyservers.net --recv-key 0xB01FA116

# install Indigo and some dep packages on a fresh ubuntu 14.04
sudo apt-get update && sudo apt-get install -y ros-indigo-desktop        \
	ros-indigo-libntcan ros-indigo-libpcan ros-indigo-controller-manager \
	ros-indigo-controller-manager-msgs ros-indigo-joint-limits-interface \
	ros-indigo-cob-srvs ros-indigo-cob-control-mode-adapter              \
	ros-indigo-cob-dashboard ros-indigo-cob-command-gui libmuparser-dev  \
	python-rosinstall python-wstool

# Initialize rosdep
sudo rosdep init
rosdep update

# prepare catkin workspace
mkdir -p $HOME/catkin_ws/src
cd $HOME/catkin_ws/src
echo ">> Current directory: $(pwd)"
catkin_init_workspace
git clone https://github.com/ammarnajjar/ros_canopen.git -b no-lost-arbitration-handling
git clone https://github.com/ipa320/schunk_robots.git -b indigo_dev
git clone https://github.com/ammarnajjar/lwa4p_moveit_config.git
cd ..
echo ">> Current directory: $(pwd)"
rosdep install --from-paths src --ignore-src --rosdistro indigo -y

# build catkin workspace
source /opt/ros/indigo/setup.bash
catkin_make | tee catkin.log
echo "source $HOME/catkin_ws/devel/setup.bash" >> $HOME/.bashrc
source $HOME/catkin_ws/devel/setup.bash

# prepare moveit workspace
# full documentation: http://moveit.ros.org/install/
mkdir -p $HOME/moveit/src
cd $HOME/moveit/src
echo ">> Current directory: $(pwd)"

wstool init .
wstool merge https://raw.github.com/ros-planning/moveit_docs/indigo-devel/moveit.rosinstall
wstool update
cd ..
echo ">> Current directory: $(pwd)"
rosdep install --from-paths src --ignore-src --rosdistro indigo -y

# build moveit workspace
catkin_make | tee catkin_make.log
echo "source $HOME/moveit/devel/setup.bash" >> $HOME/.bashrc
source $HOME/moveit/devel/setup.bash

# prepare can0
sudo ip link set dev can0 down
sudo ip link set can0 type can bitrate 500000
sudo ip link set dev can0 up
sudo ifconfig can0 txqueuelen 20

echo "Installation done successfully."

# vim: set ft=sh ts=4 sw=4 noet ai :
