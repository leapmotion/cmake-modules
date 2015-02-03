#.rst
# FindBullet
# ------------
#
# Locate and configure Bullet Physics
#
# Interface Targets
# ^^^^^^^^^^^^^^^^^
#   FindBullet::FindBullet
#
# Variables
# ^^^^^^^^^
#   Bullet_ROOT_DIR
#   Bullet_FOUND
#   Bullet_INCLUDE_DIR
#   Bullet_LIBRARIES
#

find_path(BULLET_ROOT NAMES "src/btBulletDynamicsCommon.h" PATH_SUFFIXES bullet-2.82-r2704 bullet-2.81-rev2613)

include(${CMAKE_ROOT}/Modules/FindBullet.cmake)

include(CreateImportTargetHelpers)

find_package_handle_standard_args(BULLET DEFAULT_MSG BULLET_ROOT BULLET_INCLUDE_DIR)
find_package_handle_standard_args(BULLET_COLLISION DEFAULT_MSG BULLET_COLLISION_LIBRARY BULLET_COLLISION_LIBRARY_DEBUG)
find_package_handle_standard_args(BULLET_DYNAMICS DEFAULT_MSG BULLET_DYNAMICS_LIBRARY BULLET_DYNAMICS_LIBRARY_DEBUG)
find_package_handle_standard_args(BULLET_MATH DEFAULT_MSG BULLET_MATH_LIBRARY BULLET_MATH_LIBRARY_DEBUG)

generate_import_target(BULLET_COLLISION STATIC TARGET Bullet::Collision)
generate_import_target(BULLET_DYNAMICS STATIC TARGET Bullet::Dynamics)
generate_import_target(BULLET_MATH STATIC TARGET Bullet::Math)
generate_import_target(BULLET INTERFACE TARGET Bullet::Bullet)

set_property(TARGET Bullet::Bullet APPEND PROPERTY INTERFACE_LINK_LIBRARIES Bullet::Collision Bullet::Dynamics Bullet::Math)
