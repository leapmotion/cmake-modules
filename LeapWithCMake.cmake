option(USE_CMAKE_LEAP_MODULES "Use cmake modules that have been corrected by Leap Motion LLC." ON)

set(Leap_CMAKE_MODULE_DIR "${CMAKE_CURRENT_LIST_DIR}/cmakeleap")

if(USE_CMAKE_LEAP_MODULES)
    # do not add path twice
    if(NOT _USING_CMAKE_LEAP_MODULES)
        list(APPEND CMAKE_MODULE_PATH "${Leap_CMAKE_MODULE_DIR}")
    endif(NOT _USING_CMAKE_LEAP_MODULES)
    set(_USING_CMAKE_LEAP_MODULES TRUE)

endif(USING_CMAKE_LEAP_MODULES)
