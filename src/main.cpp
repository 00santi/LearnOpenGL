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

const char *fragmentShaderSource1 = "#version 330 core\n"
    "out vec4 FragColor;\n"
    "void main()\n"
    "{\n"
    "   FragColor = vec4(1.0f, 0.5f, 0.2f, 1.0f);\n"
    "}\0";

const char *fragmentShaderSource2 = "#version 330 core\n"
    "out vec4 FragColor;\n"
    "void main()\n"
    "{\n"
    "   FragColor = vec4(0.68f, 0.85f, 0.9f, 1.0f);\n"
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

    float vertices1[] = {
        0.05, 0.05, 0.0,
        0.05, 0.7, 0.0,
        0.7, 0.7, 0.0,
   };

    float vertices2[] = {
        -0.05, -0.05, 0.0,
        -0.05, -0.7, 0.0,
        -0.7, -0.05, 0.0,
    };

    const GLuint VAO1 = create_VAO(); // also binds the VAO it creates
    const GLuint VBO1 = create_VBO(vertices1, sizeof(vertices1)); // binds the buffer it creates
    glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 3 * sizeof(float), (void*)0);
    glEnableVertexAttribArray(0);

    const GLuint VAO2 = create_VAO();
    const GLuint VBO2 = create_VBO(vertices2, sizeof(vertices2));
    glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 3 * sizeof(float), (void*)0);
    glEnableVertexAttribArray(0);

    const GLuint vertexShader1 = compile_vertex_shader(vertexShaderSource);
    const GLuint fragmentShader1 = compile_fragment_shader(fragmentShaderSource1);
    const GLuint shaderProgram1 = create_shader_program(vertexShader1, fragmentShader1); // deletes vertex and fragment shaders after linking

    const GLuint vertexShader2 = compile_vertex_shader(vertexShaderSource);
    const GLuint fragmentShader2 = compile_fragment_shader(fragmentShaderSource2);
    const GLuint shaderProgram2 = create_shader_program(vertexShader2, fragmentShader2);

    while (!glfwWindowShouldClose(window)) {
        glClear(GL_COLOR_BUFFER_BIT);

        glUseProgram(shaderProgram1);
        glBindVertexArray(VAO1);
        glDrawArrays(GL_TRIANGLES, 0, 3);

        glUseProgram(shaderProgram2);
        glBindVertexArray(VAO2);
        glDrawArrays(GL_TRIANGLES, 0, 3);

        glfwSwapBuffers(window);
        glfwPollEvents();
    }

    glDeleteProgram(shaderProgram1);
    glDeleteProgram(shaderProgram2);
    glDeleteBuffers(1, &VBO1);
    glDeleteBuffers(1, &VBO2);
    glDeleteVertexArrays(1, &VAO1);
    glDeleteVertexArrays(1, &VAO2);
    glfwTerminate();
}
