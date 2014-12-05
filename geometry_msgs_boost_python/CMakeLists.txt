cmake_minimum_required(VERSION 2.8.3)
project(geometry_msgs_boost_python)

find_package(catkin REQUIRED COMPONENTS
  msg_boost_python
  geometry_msgs
)

catkin_python_setup()

catkin_package()

include_directories(
  ${catkin_INCLUDE_DIRS}
)

generate_msg_boost_python_converters(
  FROM_PACKAGE geometry_msgs
  PYTHON_NAME msg
)
