#include <msg_boost_python/msg_boost_python.hpp>

namespace msg_boost_python {
namespace utils {

void split_package_message(const std::string datatype, std::string& package, std::string& message) {
  std::vector<std::string> package_message;
  boost::algorithm::split(package_message, datatype, boost::is_from_range('/','/')); // separate at the '/'
  package = package_message[0];
  message = package_message[1];
}

boost::python::object get_py_message_type(const std::string datatype) {
  std::string package, message;
  split_package_message(datatype, package, message);
  return boost::python::import(boost::str(format_py_module_name % package % message).c_str()).attr(message.c_str());
}

PyObject* make_py_module_name(const std::string datatype) {
  std::string package, message;
  split_package_message(datatype, package, message);
  return PyString_FromString(boost::str(format_py_module_name % package % message).c_str());
}

PyObject* make_py_class_name(const std::string datatype) {
  std::string package, message;
  split_package_message(datatype, package, message);
  return PyString_FromString(message.c_str());
}

} // namespace utils
} // namespace msg_boost_python
