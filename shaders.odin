package main
import gl "vendor:OpenGL"

vertex_shader: cstring =
`#version 330 core
layout (location = 0) in vec3 a_pos;
layout (location = 1) in vec3 a_color;
layout (location = 2) in vec2 a_tex_coord;

out vec3 vertex_color;
out vec2 tex_coord;
uniform mat4 transform;

void main() {
    gl_Position = transform * vec4(a_pos, 1.0);
    vertex_color = a_color;
    tex_coord = a_tex_coord;
}`

fragment_shader: cstring = 
`#version 330 core
in vec3 vertex_color;
in vec2 tex_coord;

out vec4 frag_color;
uniform sampler2D container_texture;
uniform sampler2D face_texture;

void main() {
    frag_color = mix(texture(container_texture, tex_coord), texture(face_texture, tex_coord), 0.2);
}`

create_shader_program :: proc() -> (shader_program: u32) {
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
