package main

import fmt "core:fmt"
import math "core:math"
import gl "vendor:OpenGL"
import glfw "vendor:glfw"

WIDTH, HEIGHT :: 800, 600
window: glfw.WindowHandle

main :: proc() {
    init_glfw()
    init_opengl()
    shader_program := create_shader_program()

    vertices := []f32 {
        -0.5, 0.5, 0.0,
         0.5, 0.5, 0.0,
         -0.5, -0.5, 0.0,
         0.5, -0.5, 0.0
    }

    indices := []u16 {
        0, 1, 2,
        1, 2, 3,
    }
    
    vao, vbo, ebo: u32
    gl.GenVertexArrays(1, &vao)
    gl.GenBuffers(1, &vbo)
    gl.GenBuffers(1, &ebo)

    gl.BindVertexArray(vao)
    gl.BindBuffer(gl.ARRAY_BUFFER, vbo)
    gl.BufferData(gl.ARRAY_BUFFER, len(vertices) * size_of(vertices[0]), raw_data(vertices), gl.STATIC_DRAW)
    gl.VertexAttribPointer(0, 3, gl.FLOAT, gl.FALSE, 3 * size_of(f32), 0)
    gl.EnableVertexAttribArray(0)
    gl.BindBuffer(gl.ELEMENT_ARRAY_BUFFER, ebo)
    gl.BufferData(gl.ELEMENT_ARRAY_BUFFER, len(indices) * size_of(indices[0]), raw_data(indices), gl.STATIC_DRAW)
    
    for !glfw.WindowShouldClose(window) {
        glfw.PollEvents()
        
        gl.ClearColor(0.1, 0.15, 0.25, 1.0)
        gl.Clear(gl.COLOR_BUFFER_BIT)

        gl.UseProgram(shader_program)
        
        time_value := f32(glfw.GetTime())
        green_value := (math.sin(time_value) / 2.0) + 0.5
        my_color_location := gl.GetUniformLocation(shader_program, "my_color")
        gl.Uniform4f(my_color_location, 0.0, green_value, 0.0, 1.0)
        
        gl.BindVertexArray(vao)
        gl.DrawElements(gl.TRIANGLES, 6, gl.UNSIGNED_SHORT, nil)

        glfw.SwapBuffers(window)
    }

    gl.DeleteProgram(shader_program)
    deinit()
}

init_glfw :: proc() {
	ensure(glfw.Init() == true, "error initializing glfw")
	glfw.WindowHint(glfw.CONTEXT_VERSION_MAJOR, 3)
    glfw.WindowHint(glfw.CONTEXT_VERSION_MINOR, 3)
    glfw.WindowHint(glfw.OPENGL_PROFILE, glfw.OPENGL_CORE_PROFILE)
    
    window = glfw.CreateWindow(WIDTH, HEIGHT, "OpenGL Window", nil, nil)
    ensure(window != nil, "error initializing window")
    glfw.MakeContextCurrent(window)
    glfw.SetFramebufferSizeCallback(window, framebuffer_size_callback)
    glfw.SetKeyCallback(window, key_callback)
}

init_opengl :: proc() {
	gl.load_up_to(3, 3, glfw.gl_set_proc_address)
    gl.Viewport(0, 0, WIDTH, HEIGHT)
}

framebuffer_size_callback :: proc "c" (w: glfw.WindowHandle, new_width, new_height: i32) {
	gl.Viewport(0, 0, new_width, new_height)
}

key_callback :: proc "c" (w: glfw.WindowHandle, key, scancode, action, mods: i32) {
	if key == glfw.KEY_ESCAPE && action == glfw.PRESS {
		glfw.SetWindowShouldClose(w, true)
	}
}

deinit :: proc() {
    glfw.Terminate()
    glfw.DestroyWindow(window)
}

vertex_shader: cstring =
`#version 330 core
layout (location = 0) in vec3 a_pos;
out vec4 vertex_color;

void main() {
    gl_Position = vec4(a_pos, 1.0);
    vertex_color = vec4(0.5, 0.0, 0.0, 1.0);
}`

fragment_shader: cstring = 
`#version 330 core
in vec4 vertex_color;
out vec4 frag_color;
uniform vec4 my_color;

void main() {
    frag_color = my_color;
}`

create_shader_program :: proc() -> u32 {
	vertex_shader_id := gl.CreateShader(gl.VERTEX_SHADER)
    gl.ShaderSource(vertex_shader_id, 1, &vertex_shader, nil)
    gl.CompileShader(vertex_shader_id)
    success: i32
    gl.GetShaderiv(vertex_shader_id, gl.COMPILE_STATUS, &success)
    assert(success != 0, "error compiling vertex shader")

    fragment_shader_id := gl.CreateShader(gl.FRAGMENT_SHADER)
    gl.ShaderSource(fragment_shader_id, 1, &fragment_shader, nil)
    gl.CompileShader(fragment_shader_id)
    gl.GetShaderiv(fragment_shader_id, gl.COMPILE_STATUS, &success)
    assert(success != 0, "error compiling fragment shader")

    program := gl.CreateProgram()
    gl.AttachShader(program, vertex_shader_id)
    gl.AttachShader(program, fragment_shader_id)

    gl.LinkProgram(program)
    gl.GetProgramiv(program, gl.LINK_STATUS, &success)
    assert(success != 0, "error linking shaders")
    
    gl.DeleteShader(vertex_shader_id)
    gl.DeleteShader(fragment_shader_id)
    
    return program
}
