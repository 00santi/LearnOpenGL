cmake_minimum_required(VERSION 4.2)
project(OpenGL)
set(CMAKE_CXX_STANDARD 20)

include(FetchContent)
FetchContent_Declare(
        glfw
        GIT_REPOSITORY https://github.com/glfw/glfw.git
        GIT_TAG 3.4
)
FetchContent_MakeAvailable(glfw)

add_executable(OpenGL
        src/main.cpp
        src/glad.c
        src/window.cpp
        src/shaders.cpp
)

target_include_directories(OpenGL PRIVATE
        include
)

target_link_libraries(OpenGL PRIVATE
        glfw
        opengl32
)