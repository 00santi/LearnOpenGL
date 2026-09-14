package main

import fmt "core:fmt"
import math "core:math"
import gl "vendor:OpenGL"
import glfw "vendor:glfw"
import stbi "vendor:stb/image"

WIDTH, HEIGHT :: 800, 600
window: glfw.WindowHandle

main :: proc() {
    init_glfw()
    init_opengl()
    shader_program := create_shader_program()

    texture_width, texture_height, nr_channels: i32
    texture_data: ^u8 = stbi.load("textures/container.jpg", &texture_width, &texture_height, &nr_channels, 0)
    assert(texture_data != nil, "error loading texture")

    vertices := []f32 {
    //	  x     y   z    r  g  b    x  y-texture
        -0.5, -0.5, 0,   0, 1, 0,   0.0, 0,
         0.0,  0.5, 0,   0, 0, 1,   0.5, 1,
         0.5, -0.5, 0,   1, 0, 0,   1.0, 0,
    }
    
    vao, vbo: u32
    gl.GenVertexArrays(1, &vao)
    gl.GenBuffers(1, &vbo)

    gl.BindVertexArray(vao)
    gl.BindBuffer(gl.ARRAY_BUFFER, vbo)
    gl.BufferData(gl.ARRAY_BUFFER, len(vertices) * size_of(vertices[0]), raw_data(vertices), gl.STATIC_DRAW)
    
    gl.VertexAttribPointer(0, 3, gl.FLOAT, gl.FALSE, 8 * size_of(f32), 0)
    gl.EnableVertexAttribArray(0)
    gl.VertexAttribPointer(1, 3, gl.FLOAT, gl.FALSE, 8 * size_of(f32), 3 * size_of(f32))
    gl.EnableVertexAttribArray(1)

    texture_id: u32
    gl.GenTextures(1, &texture_id)
    gl.BindTexture(gl.TEXTURE_2D, texture_id)

    gl.VertexAttribPointer(2, 2, gl.FLOAT, gl.FALSE, 8 * size_of(f32), 6 * size_of(f32))
    gl.EnableVertexAttribArray(2)

    gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, gl.MIRRORED_REPEAT)
    gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, gl.MIRRORED_REPEAT)
    gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.NEAREST)
    gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.LINEAR)
    
    border_color :=  []f32 { 1, 1, 0, 1 }
    gl.TexParameterfv(gl.TEXTURE_2D, gl.TEXTURE_BORDER_COLOR, raw_data(border_color)) 
    
    gl.TexImage2D(gl.TEXTURE_2D, 0, gl.RGB, texture_width, texture_height, 0, gl.RGB, gl.UNSIGNED_BYTE, texture_data)
    gl.GenerateMipmap(gl.TEXTURE_2D)

    
    
    for !glfw.WindowShouldClose(window) {
        glfw.PollEvents()
        
        gl.ClearColor(0.1, 0.15, 0.25, 1.0)
        gl.Clear(gl.COLOR_BUFFER_BIT)

        gl.UseProgram(shader_program)
        
        time_value := f32(glfw.GetTime())
        offset_value := time_value / 50
        horizontal_offset_location := gl.GetUniformLocation(shader_program, "horizontal_offset")
        gl.Uniform1f(horizontal_offset_location, offset_value)

        gl.BindTexture(gl.TEXTURE_2D, texture_id)
        gl.BindVertexArray(vao)
        gl.DrawArrays(gl.TRIANGLES, 0, 3)

        glfw.SwapBuffers(window)
    }

    gl.DeleteProgram(shader_program)
    stbi.image_free(texture_data)
    deinit_glfw()
}


vertex_shader: cstring =
`#version 330 core
layout (location = 0) in vec3 a_pos;
layout (location = 1) in vec3 a_color;
layout (location = 1) in vec2 a_tex_coord;

out vec3 vertex_color;
out vec2 tex_coord;
uniform float horizontal_offset;

void main() {
    gl_Position = vec4(a_pos.x + horizontal_offset, -a_pos.y, a_pos.z, 1.0);
    vertex_color = a_color;
    tex_coord = a_tex_coord;
}`

fragment_shader: cstring = 
`#version 330 core
in vec3 vertex_color;
in vec2 tex_coord;

out vec4 frag_color;
uniform sampler2D container_texture;

void main() {
    frag_color = texture(container_texture, tex_coord);
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

init_glfw :: proc() {
	assert(glfw.Init() == true, "error initializing glfw")
	glfw.WindowHint(glfw.CONTEXT_VERSION_MAJOR, 3)
    glfw.WindowHint(glfw.CONTEXT_VERSION_MINOR, 3)
    glfw.WindowHint(glfw.OPENGL_PROFILE, glfw.OPENGL_CORE_PROFILE)
    
    window = glfw.CreateWindow(WIDTH, HEIGHT, "OpenGL Window", nil, nil)
    assert(window != nil, "error initializing window")
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

deinit_glfw :: proc() {
    glfw.Terminate()
    glfw.DestroyWindow(window)
}
