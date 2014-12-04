/** Get more info:
 * [1] http://misspent.wordpress.com/2009/09/27/how-to-write-boost-python-converters
 * [2] http://wiki.ros.org/ROS/Tutorials/Using%20a%20C%2B%2B%20class%20in%20Python
 * [3] https://docs.python.org/2/c-api/object.html
**/

#ifndef MSG_BOOST_PYTHON_HPP
#define MSG_BOOST_PYTHON_HPP

#include <boost/algorithm/string.hpp>
#include <boost/format.hpp>
#include <boost/python.hpp>
#include <boost/python/detail/wrap_python.hpp> // Access to Python C-API
#include <ros/serialization.h>

namespace msg_boost_python {

namespace utils {
// StringIO is used in rospy message serialization. Import the necessary python module. (equivalent to "from StringIO import StringIO")
const boost::python::object StringIO = boost::python::import("StringIO").attr("StringIO");

// Python string objects used for fast method/attribute access
PyObject* const py_str_serialize = PyString_FromString("serialize");
PyObject* const py_str___module__ = PyString_FromString("__module__");
PyObject* const py_str___name__ = PyString_FromString("__name__");

/// Separate a ros::message_traits::datatype string into package and message strings
/// Example: geometry_msgs/Twist -> geometry_msgs, Twist
void split_package_message(const std::string datatype, std::string& package, std::string& message);

/// Format a python module name from package and message names
/// Example: geometry_msgs/Twist -> geometry_msgs.msg._Twist
static boost::format format_py_module_name("%1%.msg._%2%");

/// Turn a ros::message_traits::datatype string into a boost python object representing the according python message class
/// Example: geometry_msgs/Twist -> geometry_msgs.msg._Twist
boost::python::object get_py_message_type(const std::string datatype);

/// Turn a ros::message_traits::datatype string into a python module name
/// Example: geometry_msgs/Twist -> geometry_msgs.msg._Twist
PyObject* make_py_module_name(const std::string datatype);

/// Turn a ros::message_traits::datatype string into a python class name
/// Example: geometry_msgs/Twist -> Twist
PyObject* make_py_class_name(const std::string datatype);

} // namespace utils

template<typename Msg>
struct MsgToPython
{
  typedef typename Msg::Ptr MsgPtr;
  typedef typename Msg::ConstPtr MsgConstPtr;

  static std::string datatype_;
  static boost::python::object MsgPy;

  /// Transfer data from a C++ message (pointer) to the equivalent boost python object
  static PyObject* convert(MsgConstPtr const& msg_cpp) {
    // Code from the tutorial [2]
    size_t msg_size = ros::serialization::serializationLength(*msg_cpp);
    boost::shared_array<uint8_t> buffer(new uint8_t[msg_size]);
    ros::serialization::OStream stream(buffer.get(), msg_size);
    ros::serialization::serialize(stream, *msg_cpp);
    std::string str_msg;
    str_msg.reserve(msg_size);
    for (size_t i = 0; i < msg_size; ++i)
    {
      str_msg.push_back(buffer[i]);
    }
    // Instantiate python message object
    boost::python::object msg_py = MsgToPython::MsgPy();
    // Call the python object's deserialize function with the data from the C++ message
    msg_py.attr("deserialize")(boost::python::str(str_msg));
    // Prevent python object from going out of scope after returning (explanation in [1])
    return boost::python::incref(msg_py.ptr());
  }
};
// Static members
template<typename Msg>
std::string MsgToPython<Msg>::datatype_ = ros::message_traits::datatype(Msg());
template<typename Msg>
boost::python::object MsgToPython<Msg>::MsgPy = utils::get_py_message_type(MsgToPython<Msg>::datatype_);


template<typename Msg>
struct MsgFromPython
{
  typedef typename Msg::Ptr MsgPtr;
  typedef typename Msg::ConstPtr MsgConstPtr;

  static std::string datatype_;
  static PyObject* py_module_name_;
  static PyObject* py_class_name_;

  MsgFromPython() {
    // Register the check function, the conversion function and the target C++ type
    boost::python::converter::registry::push_back(&check_type, &to_msg_const_ptr, boost::python::type_id<MsgConstPtr>());
  }

  /// Check if the passed python object class matches
  static void* check_type(PyObject* py_object) {
    PyObject* obj_type = PyObject_Type(py_object);
    if(PyObject_RichCompareBool(MsgFromPython::py_module_name_, PyObject_GetAttr(obj_type, utils::py_str___module__), Py_EQ) == 1)
    {
      // Module equal (ROS package)
      if(PyObject_RichCompareBool(MsgFromPython::py_class_name_, PyObject_GetAttr(obj_type, utils::py_str___name__), Py_EQ) == 1)
      {
        // Class equal (ROS message)
        return py_object;
      }
    }
    return 0;
  }

  /// Transfer data from a python message object to a C++ message const-pointer
  /// TODO if this should be extended to support other C++ types (e.g. direct message instances or non-const pointers), part of this function should be moved to a re-usable method.
  static void to_msg_const_ptr(PyObject* msg_py, boost::python::converter::rvalue_from_python_stage1_data* data) {
    // First serialize the python object
    // 1. Instatiate a StringIO object
    // 2. Call the python instance's serialize() method and write to the StringIO object
    // 3. Use StringIO's getvalue() method to copy its contents into a python str
    // 4. Free the StringIO's buffer
    boost::python::object py_string_io = utils::StringIO();
    PyObject_CallMethodObjArgs(msg_py, utils::py_str_serialize, py_string_io.ptr(), NULL);
    boost::python::object msg_py_str = py_string_io.attr("getvalue")();
    py_string_io.attr("close")(); // Free StringIO object's buffer
    // Rely on std::string as an intermediate format as python strings have no concept of characters/bytes.
    std::string msg_string = boost::python::extract<std::string>(msg_py_str);
    // Code from the tutorial [2]
    size_t msg_size = msg_string.size();
    boost::shared_array<uint8_t> buffer(new uint8_t[msg_size]);
    for (size_t i = 0; i < msg_size; ++i)
    {
      buffer[i] = msg_string[i];
    }
    ros::serialization::IStream stream(buffer.get(), msg_size);
    // Create a pointer to a new C++ message object
    MsgPtr msg_cpp(new Msg());
    // Deserialize data into that object
    ros::serialization::Serializer<Msg>::read(stream, *msg_cpp);

    // Get a pointer to the part of memory where we should store the requested C++ object
    void* object_storage = ((boost::python::converter::rvalue_from_python_storage<MsgConstPtr>*)data)->storage.bytes;
    // initialize C++ object in the object storage
    // "placement-new": http://www.drdobbs.com/cpp/calling-constructors-with-placement-new/232901023?pgno=2
    new (object_storage) MsgConstPtr(msg_cpp);
    // Stash the memory chunk pointer for later use by boost.python
    data->convertible = object_storage;
  }
};
// Static members
template<typename Msg>
std::string MsgFromPython<Msg>::datatype_ = ros::message_traits::datatype(Msg());
template<typename Msg>
PyObject* MsgFromPython<Msg>::py_module_name_ = utils::make_py_module_name(MsgFromPython<Msg>::datatype_);
template<typename Msg>
PyObject* MsgFromPython<Msg>::py_class_name_ = utils::make_py_class_name(MsgFromPython<Msg>::datatype_);

/// Function for convenient converter creation
template<typename Msg>
void create_msg_converters() {
  typedef typename Msg::ConstPtr MsgConstPtr;
  boost::python::to_python_converter<MsgConstPtr, MsgToPython<Msg> >();
  MsgFromPython<Msg>();
}

} // namespace msg_boost_python

#endif // MSG_BOOST_PYTHON_HPP
