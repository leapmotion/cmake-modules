#.rst
# FindLeap
# ------------
#
# Created by Walter Gray.
# Locate and configure Leap
#
# Interface Targets
# ^^^^^^^^^^^^^^^^^
#   Leap::Leap
#
# Variables
# ^^^^^^^^^
#   Leap_ROOT_DIR
#   Leap_FOUND
#   Leap_INCLUDE_DIR
#   Leap_LIBRARY
#   Leap_IMPORT_LIB
#   Leap_BUILD_LIBRARIES use ${Leap_BUILD_LIBRARIES} in target_link_libraries command. 
#   Leap_64_BIT - Auto detects 64-bit, turn to OFF if you want to disable.

find_path(Leap_ROOT_DIR
          NAMES include/Leap.h
          HINTS ${EXTERNAL_LIBRARY_DIR}
          PATH_SUFFIXES LeapSDK-${Leap_FIND_VERSION}
                        LeapSDK)
#we should check the version.txt file here...
set(Leap_INCLUDE_DIR "${Leap_ROOT_DIR}/include" )
# default to x86
set(_bit_suffix x86)
math(EXPR BITS "8*${CMAKE_SIZEOF_VOID_P}")
# always check if they change an option to compile as different target.
if(BITS EQUAL 64 OR Leap_64_BIT)
    option(Leap_64_BIT "" ON) # make sure the option is always displayed.
    if(Leap_64_BIT)
        set(_bit_suffix x64)
    endif()
else()
    option(Leap_64_BIT "" OFF)
endif()

set(LeapFinds)
if(MSVC)

  find_library(Leap_IMPORT_LIB_RELEASE "Leap.lib" HINTS "${Leap_ROOT_DIR}/lib/${_bit_suffix}")
  find_library(Leap_IMPORT_LIB_DEBUG "Leap.lib" HINTS "${Leap_ROOT_DIR}/lib/${_bit_suffix}")

  set(Leap_BUILD_LIBRARIES optimized ${Leap_IMPORT_LIB_RELEASE}
                            debug ${Leap_IMPORT_LIB_DEBUG} CACHE STRING "Leap libraries to build against.")
  find_file(Leap_LIBRARY_RELEASE
            NAMES Leap.dll
            HINTS "${Leap_ROOT_DIR}/lib/${_bit_suffix}")
  find_file(Leap_LIBRARY_DEBUG
            NAMES Leapd.dll
                  Leap.dll #fallback on the release library if we must
            HINTS "${Leap_ROOT_DIR}/lib/${_bit_suffix}")
  mark_as_advanced(Leap_IMPORT_LIB_RELEASE Leap_IMPORT_LIB_DEBUG)
  
  set(LeapFinds
  Leap_IMPORT_LIB_RELEASE
  Leap_IMPORT_LIB_DEBUG
  Leap_LIBRARY_RELEASE
  Leap_LIBRARY_DEBUG)

else()
  string(FIND "${CMAKE_CXX_FLAGS}" "-stdlib=libc++" found_lib)

  if(${found_lib} GREATER -1)
    set(_libdir ${Leap_ROOT_DIR}/lib)
  else()
    message(WARNING "Could not locate the library directory")
  endif()

  find_library(Leap_LIBRARY_RELEASE
            NAMES libLeap.dylib
            HINTS "${_libdir}")
  find_library(Leap_LIBRARY_DEBUG
            NAMES libLeapd.dylib
                  libLeap.dylib #fallback on the release library
            HINTS "${_libdir}")
  set(Leap_BUILD_LIBRARIES optimized ${Leap_LIBRARY_RELEASE}
      debug ${Leap_LIBRARY_DEBUG} CACHE STRING "Leap libraries to build againsts.")
  set(LeapFinds
  Leap_LIBRARY_RELEASE
  Leap_LIBRARY_DEBUG)
endif()


include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(Leap DEFAULT_MSG Leap_ROOT_DIR Leap_INCLUDE_DIR ${LeapFinds})

include(CreateImportTargetHelpers)
generate_import_target(Leap SHARED)
