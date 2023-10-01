# this macro generates 2 files for a given module ${_name}
# ${_name}.dox file which contains the actual doxygen documentation
# ${_name}.dot file which defines the local dependency as graph
# which will be then processed by dot

macro(itk_module_doxygen _name)

  # _content defines the content of the ${_name}.dox file
  set(_content "/**\n")
  set(_content "${_content} \\defgroup ${_name} Module ${_name} \n")
  set(_content "${_content} ${ITK_MODULE_${_name}_DESCRIPTION} \n")

  set(_content "${_content} \\par Dependencies:\n")

  # _dotcontent defines the content of the ${_name}.dot
  set(_dotcontent "graph \"${_name}\" { \n")

  foreach(d ${ITK_MODULE_${_name}_DEPENDS})
    set(_content "${_content} \\li \\ref ${d} \n")
    set(_dotcontent "${_dotcontent} \"${_name}\" -- \"${d}\"; \n")
  endforeach()

  set(_dotcontent "${_dotcontent} }")

  # add the image that will be generated by dot based on the defined graph
  # here
  set(_content "${_content} \\dot \n")
  set(_content "${_content} ${_dotcontent} \n")
  set(_content "${_content} \\enddot \n")
  set(_content "${_content} */\n")

  if(ITK_SOURCE_DIR)
    configure_file("${ITK_SOURCE_DIR}/Utilities/Doxygen/Module.dox.in"
                   "${ITK_BINARY_DIR}/Utilities/Doxygen/Modules/${_name}.dox" @ONLY)
  endif()

  if(NOT ${_name}_THIRD_PARTY AND EXISTS ${${_name}_SOURCE_DIR}/include)
    if(Python3_EXECUTABLE
       AND BUILD_TESTING
       AND NOT DISABLE_MODULE_TESTS)
      itk_add_test(
        NAME
        ${_name}InDoxygenGroup
        COMMAND
        ${Python3_EXECUTABLE}
        "${ITK_CMAKE_DIR}/../Utilities/Doxygen/mcdoc.py"
        check
        ${_name}
        ${${_name}_SOURCE_DIR}/include)
      itk_memcheck_ignore(${_name}InDoxygenGroup)
    endif()
  endif()
endmacro()
