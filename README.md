#### CMake-Modules
This repo is a set of helpful CMake modules we use internally and would like to share,
including customizedFind<Package> files and utility modules. It is intended to be
incorporated into projects as a subtree. This is NOT intended as a sample for using
CMake with the Leap API, though some of the functionality here will be helpful
if that's what you want to do. These modules are written for CMake 3.1+, and may not
function properly on older versions.

##### Repo Directory Layout
* Root directory of the repo contains cmake modules created by Leap Motion.
* cmakeleap directory contains patched cmake modules that are normally included with cmake.
```
# At the beginning of your CMakeLists.txt
# Use the following to use Leap specific cmake modules and you are only using the Leap library.
list(APPEND CMAKE_MODULE_PATH "${PATH_TO_THIS_REPO}/cmake-modules")

################################################################################
# Add this line if you want to include the patched cmake modules.
################################################################################
include(LeapWithCMake)

```

##### Usage
First add the cmake-module repo as a remote, so you can more easily reference it
```
  git remote add -f cmake-modules-repo git@github.com:leapmotion/cmake-modules.git
```

To setup cmake-modules in your repository (only run once as a setup step):
```
  git subtree add --prefix cmake-modules cmake-modules-repo develop
```

To update the copy of cmake-modules in your repository from the latest code in the cmake-modules repo:
```
  git fetch cmake-modules-repo develop
  git subtree pull --prefix cmake-modules cmake-modules-repo develop
```

To push changes from your repository upstream into the cmake-module repo:
```
  git subtree push --prefix cmake-modules cmake-modules-repo <branch>
  Open a pull request to merge <branch> to develop
```


For more information on subtrees see Atlassian's [Git Subtree Tutorial](http://blogs.atlassian.com/2013/05/alternatives-to-git-submodule-git-subtree/)

#### Best Practices
These are practices we have found useful in producing and maintaining large-scale CMake projects
##### Rule 1: Always check the docs & existing modules for examples
Documentation for CMake is rapidly improving. See if you can find answers in the links below.

* [CMake 3.1.0 Documentation](http://www.cmake.org/cmake/help/v3.1/index.html)
* [CMake git-master Documentation](http://www.cmake.org/cmake/help/git-master/)

##### Naming conventions
* UPPER_CASE identifiers are public
* Mixed_CASE identifiers are also public assuming the first word is a namespace, as with package find modules
* _lower_idents with preceding underscores should be used for private, temporary variables
* lower_idents should also be used for function calls
* UPPER_CASE should be used for naming arguments to functions (see [CMakeParseArguments](http://www.cmake.org/cmake/help/git-master/module/CMakeParseArguments.html))

##### General Guidelines
1. Prefer setting target properties over global or directory properties, eg. use target_include_directories over include_directories.
2. Prefer Generator expressions over PROPERTY_<Config> variants wherever allowed. See [Generator Expressions Manual](http://www.cmake.org/cmake/help/v3.1/manual/cmake-generator-expressions.7.html)
3. install() is meant to define a step to package the build products of a library, and install them on the host system for use by cmake by adding it to the [Package Registry](http://www.cmake.org/cmake/help/v3.0/manual/cmake-packages.7.html#package-registry). For steps such as copying .DLLs or resource files to the appropriate location so a build can be run and debugged at all, use add_custom_command(<Target> POST_BUILD ...), or the TargetCopyLocalFiles module.
4. Never manually add a library directly in a CMakeLists.txt file (eg, via find_library or find_path). Instead, write a Find<Package>.cmake module. See the guidelines for writing find modules further down, as well as the official [Module Developer Docs](http://www.cmake.org/cmake/help/v3.1manual/cmake-developer.7.html#modules)
5. Avoid the target_link_libraries signatures which use[debug|optimized|general]. Use Generator Expressions instead.
6. Make use of INTERFACE targets and other pseudo targets to specify usage requirements. See
    * [Pseudo Targets](http://www.cmake.org/cmake/help/v3.0/manual/cmake-buildsystem.7.html#pseudo-targets) for information on what Pseudo Targets and Usage Requirements in general are.
    * [Packages](http://www.cmake.org/cmake/help/v3.0/manual/cmake-packages.7.html) for information on what packages are and how to write <Package>Config.cmake files that provide IMPORT targets.
7. Group settings first by locality, then by purpose. For example, in the root CMakeLists.txt every setting should be used by at 2 different sub-projects. If it isn't, then it should be moved to the CMakeLists file where it is actually used. Within file you might group all the options, then all the compiler and linker settings, then all the gloabal find_package operations. Any settings used by only one project should be set in that project's CMakeLists file.
##### Creating New Projects
This assumes that you have added cmake-modules as a subtree in a folder at the root of your project.

##### Directory Structure
Root: A global CMakeLists.txt file containing global settings for all sub-projects.
If you have only one sub project, you may add and configure it at the end of the root cmakelists file.

##### Handling Resources in OS X Bundles
See [CMake: Bundles and Frameworks](http://www.cmake.org/Wiki/CMake:Bundles_And_Frameworks)
as well as documentation for the [MACOSX_PACKAGE_LOCATION](http://www.cmake.org/cmake/help/v3.0/prop_sf/MACOSX_PACKAGE_LOCATION.html)

##### Root CMakeLists.txt
```
cmake_minimum_required(VERSION 3.1)
project(<Your project name>)
list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake-modules")
set(CMAKE_CONFIGURATION_TYPES "Release;Debug" CACHE STRING "" FORCE) #Disables MinSizeRel & MaxSpeedRel
set(CMAKE_INCLUDE_CURRENT_DIR ON) #essentially the same as include_directories(.) in every subdir
set(COPY_LOCAL_FILES_NO_AUTOSCAN ON) #Only do this if you are using the TargetImportedLibraries or TargetCopyLocalFiles modules.
set_property(GLOBAL PROPERTY USE_FOLDERS ON)

################################################################################
# Include patches to cmake modules. 
################################################################################
include(LeapWithCMake)

include(TargetImportedLibraries)
#These lines are specific to how Leap organizes our external dependencies and may not apply to your project.
include(LeapCMakeTemplates)
leap_find_external_libraries()

#Set any global flags for the project here, such as compiler settings you want used universally
#if(MSVC)  #Uncomment this if you want to use use /MT instead of /MD on Windows
#  add_compile_options($<$<CONFIG:debug>:/MTd> $<$<CONFIG:release>:/MT>)
#endif()

#Call add_subdirectory on relevant sub-directories here
add_subdirectory(<Subdirectory>)
...

verify_shared_libraries_resolved()

```

##### Project's CMakeLists.txt
```
set(<Project>_SRC <list of files here>)
set(<Project>_HEADERS <list of headers here>)
add_<executable/library>(<Project> ${<Project>_SRC} ${<Project>_HEADERS})
################################################################################
# target_package command
################################################################################
target_package(<Project> <Package> <Version> REQUIRED) #Repeat as nessecary
target_link_libraries(<Project> ... ${Leap_BUILD_LIBRARIES})


#set target's custom build settings here

#define install steps here

```
##### Simple CMakeLists.txt without patched cmake module changes and no external libraries.
```
cmake_minimum_required(VERSION 3.1)
project(<Your project name>)
list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake-modules")
set(CMAKE_CONFIGURATION_TYPES "Release;Debug" CACHE STRING "" FORCE) #Disables MinSizeRel & MaxSpeedRel
set(CMAKE_INCLUDE_CURRENT_DIR ON) #essentially the same as include_directories(.) in every subdir
set(COPY_LOCAL_FILES_NO_AUTOSCAN ON) #Only do this if you are using the TargetImportedLibraries or TargetCopyLocalFiles modules.
set_property(GLOBAL PROPERTY USE_FOLDERS ON)
################################################################################
# Find leap and include libraries. 
################################################################################
find_package(Leap REQUIRED)
include_directories(${Leap_INCLUDE_DIR})

add_<executable/library>(<Project> ${<Project>_SRC} ${<Project>_HEADERS})
################################################################################
# No target package command. 
################################################################################
target_link_libraries(<Project> ${Leap_BUILD_LIBRARIES} )
```

##### Writing Find Modules
For packages which do not provide Package<Config>.cmake commands, or ones that do not yet support import targets,
you will have to author your own find module. This may be as simple as
```
include(${CMAKE_ROOT}/Modules/Find<Package>.cmake)
include(CreateImportTargetHelpers)
generate_import_target(<Package> <Library Type>)
```
but may also be much more complicated. See the existing Find modules in this repo for examples, and
CreateImportTargetHelpers.cmake's documentation on how it works.

All Import targets generated by a Find module should use the
<Package>::<Component> naming convention where <Package>::<Package> is an import target which will include
all components specified as arguments to find_package. Private import targets should use
<Package>::_<lower_component>

#### Notes & TODOs

- Better helpers and handling for modules which may be either SHARED or STATIC.

- Proposed solution is to define SHARED_LIBRARY and STATIC_LIBRARY separately, then set
  LIBRARY to whichever one exists, and if both are defined then create an option so the
  user can choose. Alternatively, we could detect which are available, default to SHARED
  if both are, and expose an Xxx_IMPORT_TYPE cache variable that the user could override.
  This would also let us throw errors if the files for the desired type are unavailable.

- Make a cmake module for installing executables/resources in a platform-agnostic way
  (e.g. Mac has a particular "bundle" format it follows).

- The organization of the Components (with its component and library dependencies) should
  be implemented using a cmake module, so little redundant boilerplate is necessary.

- Write variants of find_file and find_path which actually return ALL matches, instead of
  an ill-defined single match. This functionality is distinctly lacking in cmake, and
  causes nontrivial problems when trying to find files/paths.

