#include <msg_boost_python/msg_boost_python.hpp>
#include <sensor_msgs/PointCloud2.h>

BOOST_PYTHON_MODULE(sensor_msgs) {
  msg_boost_python::create_msg_converters<sensor_msgs::PointCloud2>();
}
