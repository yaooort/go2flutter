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
# Architecture Detection
# ----------------------
# 使用正则表达式统一匹配处理器架构（不区分大小写）
if(CMAKE_SYSTEM_PROCESSOR MATCHES "^(AMD64|x86_64)$")
    set(ARCHITECTURE "AMD64")
elseif(CMAKE_SYSTEM_PROCESSOR MATCHES "^(i.86|x86)$")
    set(ARCHITECTURE "x86")
elseif(CMAKE_SYSTEM_PROCESSOR MATCHES "^(aarch64|arm64|ARM64)$")
    set(ARCHITECTURE "ARM64")
else()
    message(FATAL_ERROR "Unsupported architecture: ${CMAKE_SYSTEM_PROCESSOR}")
endif()

# File Installation
# -----------------
# 定义动态库路径变量
set(DLL_PATH "${PROJECT_SOURCE_DIR}/${ARCHITECTURE}/libgocoresdk.dll")

# 安装前验证文件是否存在
if(NOT EXISTS ${DLL_PATH})
    message(FATAL_ERROR "Target DLL not found: ${DLL_PATH}")
endif()

# 执行安装命令
install(
        FILES ${DLL_PATH}
        DESTINATION "${CMAKE_INSTALL_PREFIX}"
        PERMISSIONS
        OWNER_READ OWNER_WRITE OWNER_EXECUTE
        GROUP_READ GROUP_EXECUTE
        WORLD_READ WORLD_EXECUTE
        COMPONENT Runtime
)