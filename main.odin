package main

import fmt "core:fmt"
import gl "vendor:OpenGL"
import glfw "vendor:glfw"

WIDTH, HEIGHT :: 800, 600
window: glfw.WindowHandle

main :: proc() {
    init_glfw()
    gl.load_up_to(3, 3, glfw.gl_set_proc_address)
    gl.Viewport(0, 0, WIDTH, HEIGHT)

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
}

deinit :: proc() {
    glfw.Terminate()
    glfw.DestroyWindow(window)
}
