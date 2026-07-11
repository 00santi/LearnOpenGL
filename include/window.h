#pragma once
#include <glad/glad.h>
#include "GLFW/glfw3.h"

void framebuffer_size_callback(GLFWwindow* window, int w, int h);
void process_input(GLFWwindow *window);
GLFWwindow* init_glfw();
void run(GLFWwindow* window);