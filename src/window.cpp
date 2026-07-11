#include "window.h"
#include <cstdlib>
#include <iostream>

void framebuffer_size_callback(GLFWwindow* window, int w, int h) {
    glViewport(0, 0, w, h);
}

void process_input(GLFWwindow *window) {
    if (glfwGetKey(window, GLFW_KEY_ESCAPE) ==  GLFW_PRESS)
        glfwSetWindowShouldClose(window, true);
}

GLFWwindow* init_glfw() {
    if (!glfwInit()) std::exit(1);
    glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 3);
    glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, 3);
    glfwWindowHint(GLFW_OPENGL_PROFILE, GLFW_OPENGL_CORE_PROFILE);

    GLFWwindow *window = glfwCreateWindow(800, 600, "OpenGL", nullptr, nullptr);
    if (!window) {
        std::cout << "Failed to create GLFW window\n";
        glfwTerminate();
        std::exit(1);
    }
    glfwMakeContextCurrent(window);
    glfwSetFramebufferSizeCallback(window, framebuffer_size_callback);
    return window;
}
