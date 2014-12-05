# msg_boost_python

Boost.Python converters for ROS messages

## Usage

After including `msg_boost_python` in `find_package` as a catkin component, you
have access to the macro `generate_msg_boost_python_converters` which supports
two arguments:
* `FROM_PACKAGE`: the "source" package containing the messages you want wrappers for (default is the current `PROJECT_NAME`)
* `PYTHON_NAME`: the name of the generated python module (default is `msg_boost_python`)

There are two covered use cases:
* Generate converters for messages from your own package
* Generate converters for messages from some other package

In any case make sure you do the `catkin_python_setup()` to at least generate an
empty package. The minimal setups can be found in the common_msgs packages
(geometry_msgs_boost_python etc.).

### "Local" messages
Simply put `generate_msg_boost_python_converters()` in your CMakeLists.txt.
Then, in your python scripts use `import my_package.msg_boost_python` (or for "local" scripts `import msg_boost_python`)

### Other messages
Look at the common_msgs packages for examples.


## Try It

TODO

If you know what Boost.Python is about, look at this example which uses the
converters to mirror a geometry_msgs/Point

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

BOOST_PYTHON_MODULE(test_module)
{
  def("mirror", mirror, args("point"), "Mirror a geometry_msgs/Point");
}
```
