#pragma once

GLuint compile_vertex_shader(const char *vertexShaderSource);
GLuint compile_fragment_shader(const char *fragmentShaderSource);
GLuint create_shader_program(GLuint vertexShader, GLuint fragmentShader);
