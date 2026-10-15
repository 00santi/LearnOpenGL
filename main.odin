package main
import fmt "core:fmt"
import math "core:math"
import gl "vendor:OpenGL"
import glfw "vendor:glfw"
import stbi "vendor:stb/image"

WIDTH, HEIGHT :: 800, 600
Mat4 :: matrix[4, 4]f32

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
    transform_location := gl.GetUniformLocation(shader_program, "transform")
    
    for !glfw.WindowShouldClose(window) {
        glfw.PollEvents()
        gl.ClearColor(0.1, 0.15, 0.25, 1.0)
        gl.Clear(gl.COLOR_BUFFER_BIT)

        gl.ActiveTexture(gl.TEXTURE0)
        gl.BindTexture(gl.TEXTURE_2D, container_texture_id)
        gl.ActiveTexture(gl.TEXTURE1)
        gl.BindTexture(gl.TEXTURE_2D, face_texture_id)
        gl.BindVertexArray(vao)

        time := f32(glfw.GetTime())
        translation := mat4_translation(0.1 * time, -0.5, 0)
        rotation := mat4_rotation_z(3.5 * time)
        scale := mat4_scale(0.5, 0.5, 1)
        transform := translation * rotation * scale
        
        gl.UniformMatrix4fv(transform_location, 1, false, raw_data(&transform))
        
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

mat4_translation :: proc(x, y, z: f32) -> Mat4 {
    return {
    	1, 0, 0, x,
     	0, 1, 0, y,
      	0, 0, 1, z,
       	0, 0, 0, 1,
    }
}

mat4_rotation_z :: proc(angle: f32) -> Mat4 {
    c := math.cos(angle)
    s := math.sin(angle)

    return {
         c,  s, 0, 0,
        -s,  c, 0, 0,
         0,  0, 1, 0,
         0,  0, 0, 1,
    }
}

mat4_scale :: proc(x, y, z: f32) -> Mat4 {
	return {
    	x, 0, 0, 0,
     	0, y, 0, 0,
      	0, 0, z, 0,
       	0, 0, 0, 1,
    }
}
