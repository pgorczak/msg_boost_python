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
empty relay package.

### "Local" messages
Simply put `generate_msg_boost_python_converters()` in your CMakeLists.txt.
Then, in your python scripts use `import my_package.msg_boost_python` (or for "local" scripts `import msg_boost_python`)

### Other messages
Look at the common_msgs packages (sensor_msgs_boost_python etc.) for examples.
