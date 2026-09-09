package main

import fmt "core:fmt"
import gl "vendor:OpenGL"
import glfw "vendor:glfw"

WIDTH, HEIGHT :: 800, 600
window: glfw.WindowHandle

main :: proc() {
    init_glfw()
    init_opengl()

    vertices:= []f32 {
        -0.5, -0.5, 0.0,
         0.5, -0.5, 0.0,
         0.0,  0.5, 0.0
    };
    vbo: u32
    gl.GenBuffers(1, &vbo)
    gl.BindBuffer(gl.ARRAY_BUFFER, vbo)
    gl.BufferData(gl.ARRAY_BUFFER, size_of(vertices), raw_data(vertices), gl.STATIC_DRAW)
    for !glfw.WindowShouldClose(window) {
        glfw.PollEvents()
        
        gl.ClearColor(0.1, 0.15, 0.25, 1.0)
        gl.Clear(gl.COLOR_BUFFER_BIT)

        glfw.SwapBuffers(window)
    }
    
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
    glfw.SetFramebufferSizeCallback(window, framebuffer_size_callback);
    glfw.SetKeyCallback(window, key_callback);
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
