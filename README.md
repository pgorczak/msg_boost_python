# msg_boost_python

### Boost.Python converters for ROS messages

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

#### Converters for locally declared messages
Simply put `generate_msg_boost_python_converters()` in your CMakeLists.txt.
Then, in your python scripts use `import my_package.msg_boost_python`
(or for "local" scripts `import msg_boost_python`).

#### Converters for messages declared in a different package
Look at the common_msgs packages (geometry_msgs_boost_python etc.) for examples.

### Setup your own Boost.Python module
The macro `set_boost_python_module` does some routine steps to set up a
Boost.Python module within the Catkin build system.
* Correct the filename depending on the OS (currently Ubuntu or OS X)
* By default build and install into the package's Python destination

Arguments:
* `TARGET` the name of the CMake target you defined previously with `add_library`
* `BOOST_PYTHON_MODULE_NAME` the name you gave the Boost.Python module with the `BOOST_PYTHON_MODULE` declaration in your C++ code (by default takes the value from `TARGET`)
* `DEVEL_DESTINATION` set this if you want to specify a custom build destination
* `INSTALL_DESTINATION` set this if you want to specify a custom install destination

**Note:** the macro does not do any linking.

## More Info

More information and examples can be found
[on my GitHub page](https://pgorczak.github.io/projects/msg_boost_python/).
