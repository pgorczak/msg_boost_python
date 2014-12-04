include(CMakeParseArguments)

macro(generate_msg_boost_python_converters)
  set(options)
  set(oneValueArgs FROM_PACKAGE PYTHON_NAME) # optional TODO IN_PACKAGE)
  set(multiValueArgs ADDITIONAL_LIBS)
  cmake_parse_arguments(args "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})
  
  if(NOT DEFINED args_FROM_PACKAGE)
  	set(args_FROM_PACKAGE ${PROJECT_NAME})
  endif()
  
  if(NOT DEFINED args_IN_PACKAGE)
  	set(args_IN_PACKAGE ${PROJECT_NAME})
  endif()
  
  if(NOT DEFINED ${args_FROM_PACKAGE}_MESSAGE_FILES)
    message(SEND_ERROR "Package ${args_FROM_PACKAGE} was either not found or it declares no messages.")
  
  else()
		string(REGEX MATCHALL "\\/([A-Za-z0-9_]+)\\."
		       msgs ${${args_FROM_PACKAGE}_MESSAGE_FILES})
		string(REGEX MATCHALL "[A-Za-z0-9_]+"
		       msgs ${msgs})
		
		# Source file name and library name
		set(source_file ${CMAKE_CURRENT_BINARY_DIR}/${args_FROM_PACKAGE}_msg_boost_python.cpp) # optional TODO "IN_PACKAGE"
		set(target_name ${PROJECT_NAME}_${args_FROM_PACKAGE}_msg_boost_python)
		set(python_name msg_boost_python)
		if(DEFINED args_PYTHON_NAME)
			set(python_name ${args_PYTHON_NAME})
		endif()

		# Generate source file in current build dir
		file(WRITE ${source_file} "#include <msg_boost_python/msg_boost_python.hpp>\n\n")
		
		foreach(msg ${msgs})
  		file(APPEND ${source_file} "#include <${args_FROM_PACKAGE}/${msg}.h>\n")
		endforeach()

		file(APPEND ${source_file} "\n\nBOOST_PYTHON_MODULE(${python_name}) {\n")

		foreach(msg ${msgs})
  		file(APPEND ${source_file} "  msg_boost_python::create_msg_converters<${args_FROM_PACKAGE}::${msg}>();\n")
		endforeach()

		file(APPEND ${source_file} "}\n")

		# Setup files for build and install
		
		add_library(${target_name}
  		${source_file}
		)

		add_dependencies(${target_name} ${args_FROM_PACKAGE}_generate_messages_cpp)

		if(UNIX)
  		set_target_properties(${target_name} PROPERTIES PREFIX "")
		endif()
		# TODO: APPLE, WIN32

		set_target_properties(${target_name} PROPERTIES
			OUTPUT_NAME ${python_name}
    	LIBRARY_OUTPUT_DIRECTORY ${CATKIN_DEVEL_PREFIX}/${CATKIN_PACKAGE_PYTHON_DESTINATION} # optional TODO "IN_PACKAGE"
  	)

  	target_link_libraries(${target_name}
  		${catkin_LIBRARIES}
  		${args_ADDITIONAL_LIBS}
		)

  	# Mark target for installation
		install(TARGETS ${target_name}
  		LIBRARY DESTINATION ${CATKIN_PACKAGE_PYTHON_DESTINATION} # optional TODO "IN_PACKAGE"
		)

  endif()

endmacro()