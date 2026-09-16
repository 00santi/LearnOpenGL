package main
import fmt "core:fmt"
import math "core:math"
import gl "vendor:OpenGL"
import glfw "vendor:glfw"
import stbi "vendor:stb/image"

WIDTH, HEIGHT :: 800, 600

main :: proc() {
    window := init_glfw()
    init_opengl()
    
    shader_program := create_shader_program()
    gl.UseProgram(shader_program)
    
    vao, vbo := create_triangle()

    container_texture_data, face_texture_data, container_texture_id, face_texture_id := load_textures()

    border_color :=  []f32 { 1, 1, 0, 1 }
    gl.TexParameterfv(gl.TEXTURE_2D, gl.TEXTURE_BORDER_COLOR, raw_data(border_color))
    gl.Uniform1i(gl.GetUniformLocation(shader_program, "container_texture"), 0)
    gl.Uniform1i(gl.GetUniformLocation(shader_program, "face_texture"), 1)
    horizontal_offset_location := gl.GetUniformLocation(shader_program, "horizontal_offset")
    
    for !glfw.WindowShouldClose(window) {
        glfw.PollEvents()
        gl.ClearColor(0.1, 0.15, 0.25, 1.0)
        gl.Clear(gl.COLOR_BUFFER_BIT)

        gl.ActiveTexture(gl.TEXTURE0)
        gl.BindTexture(gl.TEXTURE_2D, container_texture_id)
        gl.ActiveTexture(gl.TEXTURE1)
        gl.BindTexture(gl.TEXTURE_2D, face_texture_id)
        gl.BindVertexArray(vao)
        
        time_value := f32(glfw.GetTime())
        offset_value := time_value / 50
        gl.Uniform1f(horizontal_offset_location, offset_value)
        
        gl.DrawArrays(gl.TRIANGLES, 0, 3)

        glfw.SwapBuffers(window)
    }

    cleanup(&vao, &vbo, &container_texture_id, &face_texture_id, shader_program, container_texture_data, face_texture_data, window)
}

create_triangle :: proc() -> (_vao, _vbo: u32) {
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

    // positions
    gl.VertexAttribPointer(0, 3, gl.FLOAT, gl.FALSE, 8 * size_of(f32), 0)
    gl.EnableVertexAttribArray(0)
    // colors
    gl.VertexAttribPointer(1, 3, gl.FLOAT, gl.FALSE, 8 * size_of(f32), 3 * size_of(f32))
    gl.EnableVertexAttribArray(1)
    // texture coordinates
    gl.VertexAttribPointer(2, 2, gl.FLOAT, gl.FALSE, 8 * size_of(f32), 6 * size_of(f32))
    gl.EnableVertexAttribArray(2)

    return vao, vbo
}
