# msg_boost_python

Boost.Python converters for ROS messages

## Usage

After including `msg_boost_python` in `find_package` as a catkin component, you
have access to two macros:
* the main macro `generate_msg_boost_python_converters`
* a convenience macro `set_boost_python_module`

### Generate Boost.Python converters
The main macro `generate_msg_boost_python_converters` has two arguments:
* `FROM_PACKAGE` the "source" package containing the messages you want wrappers for (default is the current `PROJECT_NAME`)
* `PYTHON_NAME` the name of the generated python module (default is `msg_boost_python`)

There are two possible use cases:
* Generate converters for messages from your own package
* Generate converters for messages from some other package

In any case make sure you do the `catkin_python_setup()` to at least generate an
empty Python package for your Catkin package. Minimal setups can be found in
the common_msgs packages (geometry_msgs_boost_python etc.).

### Converters for locally declared messages
Simply put `generate_msg_boost_python_converters()` in your CMakeLists.txt.
Then, in your python scripts use `import my_package.msg_boost_python`
(or for "local" scripts `import msg_boost_python`).

### Converters for messages declared in a different package
Look at the common_msgs packages for examples.

### Setup your own Boost.Python module
The macro `set_boost_python_module` does some routine steps to set up a
Boost.Python module within the Catkin build system.
* Correct the filename depending on the OS (currently Ubuntu or OS X)
* By default build and install into the package's Python destination

*Parameters: *
* `TARGET` the name of the CMake target you defined previously with `add_library`
* `BOOST_PYTHON_MODULE_NAME` the name you gave the Boost.Python module with the `BOOST_PYTHON_MODULE` declaration in your C++ code (by default takes the value from `TARGET`)
* `DEVEL_DESTINATION` set this if you want to specify a custom build destination
* `INSTALL_DESTINATION` set this if you want to specify a custom install destination

*Note:* the macro does not do any linking.

#### Example
If you have a file "source.cpp" containing the something like

```C++
// (... code I want to wrap to python)

BOOST_PYTHON_MODULE(my_module) {
// (... my Boost.Python definitions)
}
```

You need only two lines in you CMakeLists.txt to build it into your current
package's Python module directory:

``` CMake
add_library(my_module source.cpp)
set_boost_python_module(my_module)
```

## Try It

TODO

This example uses the converters to mirror a geometry_msgs/Point

```C++
#include <boost/python/def.hpp>
#include <boost/python/module.hpp>
#include <boost/python/args.hpp>

#include <geometry_msgs/Point.h>

geometry_msgs::Point::ConstPtr mirror(geometry_msgs::Point::ConstPtr point_in) {
  geometry_msgs::Point::Ptr point_out(new geometry_msgs::Point);
  point_out->x = point_in->x * -1;
  point_out->y = point_in->y * -1;
  point_out->z = point_in->z * -1;
  return point_out;
}

using namespace boost::python;

BOOST_PYTHON_MODULE(my_module)
{
  def("mirror", mirror, args("point"), "Mirror a geometry_msgs/Point");
}
```

If you rely on geometry_msgs_boost_python, you can call the function from Python
like this:

```Python
from geometry_msgs.msg import Point
from geometry_msgs_boost_python import msg

import my_module

p = Point(1,2,3)
print p
print my_module.mirror(p)

# x: 1
# y: 2
# z: 3
# x: -1.0
# y: -2.0
# z: -3.0
```
