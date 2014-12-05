include(CMakeParseArguments)

macro(generate_msg_boost_python_converters)
  set(options)
  set(oneValueArgs FROM_PACKAGE PYTHON_NAME) # optional TODO "DESTINATION")
  set(multiValueArgs)
  cmake_parse_arguments(args "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})
  
  ## Set up variables
  # Source package defaults to CMake project name
  if(NOT DEFINED args_FROM_PACKAGE)
    set(args_FROM_PACKAGE ${PROJECT_NAME})
  endif()
  
  # Package must have been found and declared messages
  if(NOT DEFINED ${args_FROM_PACKAGE}_MESSAGE_FILES)
    message(SEND_ERROR "Package ${args_FROM_PACKAGE} was either not found or it declares no messages.")
  else()
    # Python module name defaults to "msg_boost_python"
    if(NOT DEFINED args_PYTHON_NAME)
      set(${args_PYTHON_NAME} msg_boost_python)
    endif()

    # Unique source file and target names
    set(source_file ${CMAKE_CURRENT_BINARY_DIR}/${args_FROM_PACKAGE}_msg_boost_python.cpp) # optional TODO "DESTINATION"
    set(target_name ${PROJECT_NAME}_${args_FROM_PACKAGE}_msg_boost_python)

    # Get message names
    string(REGEX MATCHALL "\\/([A-Za-z0-9_]+)\\."
           msgs ${${args_FROM_PACKAGE}_MESSAGE_FILES})
    string(REGEX MATCHALL "[A-Za-z0-9_]+"
           msgs ${msgs})

    ## Generate source file in current build dir
    file(WRITE ${source_file} "#include <msg_boost_python/msg_boost_python.hpp>\n\n")
    
    # Include message definition headers for each message
    foreach(msg ${msgs})
      file(APPEND ${source_file} "#include <${args_FROM_PACKAGE}/${msg}.h>\n")
    endforeach()

    # Declare Boost.Python module with according name
    file(APPEND ${source_file} "\nBOOST_PYTHON_MODULE(${args_PYTHON_NAME}) {\n")

    # Generate docstring
    file(APPEND ${source_file} "  boost::python::scope().attr(\"__doc__\") = \"")
    file(APPEND ${source_file} "Boost.Python converters for '${args_FROM_PACKAGE}' messages.\\n\\n")
    file(APPEND ${source_file} "    Boost.Python converters are registered by importing this package.\\n\\n")
    file(APPEND ${source_file} "    Generated for messages in the package '${args_FROM_PACKAGE}'.\\n\\n")
    file(APPEND ${source_file} "    Types covered:\\n")
    foreach(msg ${msgs})
      file(APPEND ${source_file} "        * ${msg}\\n")
    endforeach()
    file(APPEND ${source_file} "\";\n\n")

    # Converters for each message
    foreach(msg ${msgs})
      file(APPEND ${source_file} "  msg_boost_python::create_msg_converters<${args_FROM_PACKAGE}::${msg}>();\n")
    endforeach()

    # End Boost.Python module and source file
    file(APPEND ${source_file} "}\n")

    ## Set up target for build and install
    add_library(${target_name} ${source_file})
    # Use the convenience macro defined in this file
    set_boost_python_module(TARGET ${target_name} BOOST_PYTHON_MODULE_NAME ${args_PYTHON_NAME}) # optional TODO "DESTINATION"
    # Make sure message generation is done before building converters
    add_dependencies(${target_name} ${args_FROM_PACKAGE}_generate_messages_cpp)
    target_link_libraries(${target_name} ${catkin_LIBRARIES})

  endif()

endmacro()


macro(set_boost_python_module)
  set(options)
  set(oneValueArgs TARGET BOOST_PYTHON_MODULE_NAME DEVEL_DESTINATION INSTALL_DESTINATION)
  set(multiValueArgs)
  cmake_parse_arguments(set_boost_python_module "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

  if(NOT DEFINED set_boost_python_module_TARGET)
    message(SEND_ERROR "No target specified.")
  else()
    ## Set up variables
    # BOOST_PYTHON_MODULE - name defaults to target name
    if(NOT DEFINED set_boost_python_module_BOOST_PYTHON_MODULE_NAME)
      set(set_boost_python_module_BOOST_PYTHON_MODULE_NAME ${set_boost_python_module_TARGET})
    endif()
    # Devel python package destination defaults to current Catkin package
    if(NOT DEFINED set_boost_python_module_DEVEL_DESTINATION)
      set(set_boost_python_module_DEVEL_DESTINATION ${CATKIN_DEVEL_PREFIX}/${CATKIN_PACKAGE_PYTHON_DESTINATION})
    endif()
    # Same for install destination
    if(NOT DEFINED set_boost_python_module_INSTALL_DESTINATION)
      set(set_boost_python_module_INSTALL_DESTINATION ${CATKIN_PACKAGE_PYTHON_DESTINATION})
    endif()

    ## Configure target for build
    set_target_properties(${set_boost_python_module_TARGET} PROPERTIES
      OUTPUT_NAME ${set_boost_python_module_BOOST_PYTHON_MODULE_NAME}
      LIBRARY_OUTPUT_DIRECTORY ${set_boost_python_module_DEVEL_DESTINATION}
    )
    # OS specific
    if(UNIX)
      # Do not prepend "lib" to the name
      set_target_properties(${set_boost_python_module_TARGET} PROPERTIES PREFIX "")
    endif()
    if(APPLE)
      # File extension should be ".so" instead of ".dylib"
      set_target_properties(${set_boost_python_module_TARGET} PROPERTIES SUFFIX ".so")
    endif()
    if(WIN32)
      # TODO: WIN32
      # SUFFIX might need to be ".pyo" instead if ".dll"
    endif()

    ## Mark target for for install
    install(TARGETS ${set_boost_python_module_TARGET}
      LIBRARY DESTINATION ${set_boost_python_module_INSTALL_DESTINATION}
    )
  endif()
endmacro()
