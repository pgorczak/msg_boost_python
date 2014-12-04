cmake_minimum_required(VERSION 2.8.3)
project(msg_boost_python)

find_package(catkin REQUIRED COMPONENTS
  message_runtime
)

find_package(Boost REQUIRED COMPONENTS python)
find_package(PythonLibs REQUIRED)

catkin_package(
  CFG_EXTRAS msg_boost_python_macros.cmake
  INCLUDE_DIRS include ${Boost_INCLUDE_DIRS} ${PYTHON_INCLUDE_PATH}
  LIBRARIES msg_boost_python
  CATKIN_DEPENDS message_runtime
  DEPENDS Boost PythonLibs
)

include_directories(include)

include_directories(
  ${catkin_INCLUDE_DIRS}
  ${Boost_INCLUDE_DIRS}
  ${PYTHON_INCLUDE_PATH}
)

add_library(msg_boost_python
  include/msg_boost_python/msg_boost_python.hpp
  src/msg_boost_python.cpp)

## Specify libraries to link a library or executable target against
target_link_libraries(msg_boost_python
  ${catkin_LIBRARIES}
  ${Boost_LIBRARIES}
  ${PYTHON_LIBRARIES}
)

# Mark cpp header files for installation
install(FILES include/${PROJECT_NAME}/${PROJECT_NAME}.hpp
 DESTINATION ${CATKIN_PACKAGE_INCLUDE_DESTINATION}
)

# Mark executables and/or libraries for installation
install(TARGETS msg_boost_python
  LIBRARY DESTINATION ${CATKIN_PACKAGE_LIB_DESTINATION}
)
