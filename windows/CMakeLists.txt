# The Flutter tooling requires that developers have a version of Visual Studio
# installed that includes CMake 3.14 or later. You should not increase this
# version, as doing so will cause the plugin to fail to compile for some
# customers of the plugin.
cmake_minimum_required(VERSION 3.14)

# Project-level configuration.
set(PROJECT_NAME "go")
project(${PROJECT_NAME} LANGUAGES CXX)

# Explicitly opt in to modern CMake behaviors to avoid warnings with recent
# versions of CMake.
cmake_policy(VERSION 3.14...3.25)

# This value is used when generating builds using this plugin, so it must
# not be changed
set(PLUGIN_NAME "go_plugin")


# Automatically detect system architecture (x86_64, x86, ARM, etc.)
# Automatically detect system architecture (x86_64, x86, ARM, etc.)
if(CMAKE_SYSTEM_PROCESSOR MATCHES "x86_64")
    set(ARCHITECTURE "x86_64")
elseif(CMAKE_SYSTEM_PROCESSOR MATCHES "i386" OR CMAKE_SYSTEM_PROCESSOR MATCHES "x86")
    set(ARCHITECTURE "x86")
elseif(CMAKE_SYSTEM_PROCESSOR MATCHES "arm64" OR CMAKE_SYSTEM_PROCESSOR MATCHES "aarch64")
    set(ARCHITECTURE "arm64")
else()
    message(WARNING "Unsupported architecture: ${CMAKE_SYSTEM_PROCESSOR}")
    set(ARCHITECTURE "unknown")
endif()

# Use the detected architecture in your install path
install(FILES ${PROJECT_SOURCE_DIR}/${ARCHITECTURE}/libgocoresdk.dll DESTINATION "${CMAKE_INSTALL_PREFIX}"
        COMPONENT Runtime)