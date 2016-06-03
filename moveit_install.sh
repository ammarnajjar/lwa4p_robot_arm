#!/bin/bash

# full documentation: http://moveit.ros.org/install/
# OS: ubuntu 14.04

sudo apt-get update && sudo apt-get install -y python-wstool
mkdir -p $HOME/moveit/src
cd $HOME/moveit/src

echo ">> Current directory: $(pwd)"
wstool init .
wstool merge https://raw.github.com/ros-planning/moveit_docs/indigo-devel/moveit.rosinstall
wstool update
cd ..
echo ">> Current directory: $(pwd)"
rosdep install --from-paths src --ignore-src --rosdistro indigo -y

# build
source /opt/ros/indigo/setup.bash

catkin_make | tee catkin_make.log
echo "source $HOME/moveit/devel/setup.bash" >> $HOME/.bashrc
source $HOME/moveit/devel/setup.bash

# vim: set ft=sh ts=4 sw=4 noet ai :