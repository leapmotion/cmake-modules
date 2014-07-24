#.rst
# FindFbxSdk
# ------------
#
# Created by Walter Gray.
# Locate and configure FbxSdk
#
# Interface Targets
# ^^^^^^^^^^^^^^^^^
#   FbxSdk::FbxSdk
#
# Variables
# ^^^^^^^^^
#   FbxSdk_ROOT_DIR
#   FbxSdk_FOUND
#   FbxSdk_INCLUDE_DIR
#   FbxSdk_LIBRARIES

find_path(FbxSdk_ROOT_DIR
          NAMES include/fbxsdk.h
          HINTS ${EXTERNAL_LIBRARY_DIR}
          PATH_SUFFIXES fbx-sdk-${FbxSdk_FIND_VERSION}
                        fbx-sdk
                        fbx-sdk/2014.2)

set(FbxSdk_INCLUDE_DIR "${FbxSdk_ROOT_DIR}/include")

if(MSVC)
  find_library(FbxSdk_LIBRARY_RELEASE "libfbxsdk-mt.lib" HINTS "${FbxSdk_ROOT_DIR}/lib/vs2010/x86/release")
  find_library(FbxSdk_LIBRARY_DEBUG "libfbxsdk-mt.lib" HINTS "${FbxSdk_ROOT_DIR}/lib/vs2010/x86/debug")
else()
  find_library(FbxSdk_LIBRARY_RELEASE "libfbxsdk.a" HINTS "${FbxSdk_ROOT_DIR}/lib/clang/ub/release")
  find_library(FbxSdk_LIBRARY_DEBUG "libfbxsdk.a" HINTS "${FbxSdk_ROOT_DIR}/lib/clang/ub/debug")
endif()
include(SelectConfigurations)
select_configurations(FbxSdk LIBRARY LIBRARIES)

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(FbxSdk DEFAULT_MSG FbxSdk_INCLUDE_DIR FbxSdk_LIBRARIES)

include(CreateImportTargetHelpers)
generate_import_target(FbxSdk STATIC)