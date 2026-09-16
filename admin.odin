package main
import gl "vendor:OpenGL"
import glfw "vendor:glfw"
import stbi "vendor:stb/image"

init_glfw :: proc() -> glfw.WindowHandle {
	assert(glfw.Init() == true, "error initializing glfw")
	glfw.WindowHint(glfw.CONTEXT_VERSION_MAJOR, 3)
    glfw.WindowHint(glfw.CONTEXT_VERSION_MINOR, 3)
    glfw.WindowHint(glfw.OPENGL_PROFILE, glfw.OPENGL_CORE_PROFILE)
    
    window := glfw.CreateWindow(WIDTH, HEIGHT, "OpenGL Window", nil, nil)
    assert(window != nil, "error initializing window")
    glfw.MakeContextCurrent(window)
    glfw.SetFramebufferSizeCallback(window, framebuffer_size_callback)
    glfw.SetKeyCallback(window, key_callback)

    return window
}

init_opengl :: proc() {
	gl.load_up_to(3, 3, glfw.gl_set_proc_address)
    gl.Viewport(0, 0, WIDTH, HEIGHT)
}

cleanup :: proc(vao, vbo, container_texture_id, face_texture_id: ^u32, shader_program: u32, container_texture_data, face_texture_data: ^u8, window: glfw.WindowHandle) {
	gl.DeleteVertexArrays(1, vao)
    gl.DeleteBuffers(1, vbo)
    gl.DeleteTextures(1, container_texture_id)
    gl.DeleteTextures(1, face_texture_id)
    gl.DeleteProgram(shader_program)
    stbi.image_free(container_texture_data)
    stbi.image_free(face_texture_data)
    glfw.Terminate()
    glfw.DestroyWindow(window)
}

framebuffer_size_callback :: proc "c" (w: glfw.WindowHandle, new_width, new_height: i32) {
	gl.Viewport(0, 0, new_width, new_height)
}

key_callback :: proc "c" (w: glfw.WindowHandle, key, scancode, action, mods: i32) {
	if key == glfw.KEY_ESCAPE && action == glfw.PRESS {
		glfw.SetWindowShouldClose(w, true)
	}
}
