#include <glad/glad.h>
#include <GLFW/glfw3.h>
#include <iostream>
#include "window.h"
#include "shaders.h"

const char *vertexShaderSource = "#version 330 core\n"
    "layout (location = 0) in vec3 aPos;\n"
    "void main()\n"
    "{\n"
    "   gl_Position = vec4(aPos.x, aPos.y, aPos.z, 1.0);\n"
    "}\0";

const char *fragmentShaderSource = "#version 330 core\n"
    "out vec4 FragColor;\n"
    "void main()\n"
    "{\n"
    "   FragColor = vec4(1.0f, 0.5f, 0.2f, 1.0f);\n"
    "}\0";

void init_glad() {
    if (!gladLoadGLLoader((GLADloadproc) glfwGetProcAddress)) {
        std::cout << "Failed to initialize GLAD" << std::endl;
        std::exit(1);
    }
}

GLuint create_VAO() {
    GLuint VAO;
    glGenVertexArrays(1, &VAO);
    glBindVertexArray(VAO);
    return VAO;
}

GLuint create_VBO(const float vertices[], const int size) {
    GLuint VBO;
    glGenBuffers(1, &VBO);
    glBindBuffer(GL_ARRAY_BUFFER, VBO);
    glBufferData(GL_ARRAY_BUFFER, size, vertices, GL_STATIC_DRAW);
    return VBO;
}

GLuint create_EBO(const unsigned int indices[], const int size) {
    GLuint EBO;
    glGenBuffers(1, &EBO);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, EBO);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, size, indices, GL_STATIC_DRAW);
    return EBO;
}

int main() {
    GLFWwindow* window = init_glfw();
    init_glad();
    glViewport(0, 0, 800, 600);

    float vertices[] = {
        0.05, 0.05, 0.0,
        0.05, 0.7, 0.0,
        0.7, 0.7, 0.0,
        -0.05, -0.05, 0.0,
        -0.05, -0.7, 0.0,
        -0.7, -0.05, 0.0,
   };
    unsigned int indices[] = {
        0, 1, 2,
        3, 4, 5
    };

    const GLuint VAO = create_VAO();
    const GLuint VBO = create_VBO(vertices, sizeof(vertices));
    const GLuint EBO = create_EBO(indices, sizeof(indices));
    glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 3 * sizeof(float), (void*)0);
    glEnableVertexAttribArray(0);

    const GLuint vertexShader = compile_vertex_shader(vertexShaderSource);
    const GLuint fragmentShader = compile_fragment_shader(fragmentShaderSource);
    const GLuint shaderProgram = create_shader_program(vertexShader, fragmentShader);

    while (!glfwWindowShouldClose(window)) {
        glClear(GL_COLOR_BUFFER_BIT);

        glUseProgram(shaderProgram);
        glBindVertexArray(VAO);
        glDrawElements(GL_TRIANGLES, 6, GL_UNSIGNED_INT, 0);
        glBindVertexArray(0);

        glfwSwapBuffers(window);
        glfwPollEvents();
    }

    glDeleteProgram(shaderProgram);
    glDeleteBuffers(1, &VBO);
    glDeleteBuffers(1, &EBO);
    glDeleteVertexArrays(1, &VAO);
    glfwTerminate();
}
