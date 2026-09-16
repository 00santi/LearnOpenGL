package main
import gl "vendor:OpenGL"
import stbi "vendor:stb/image"

load_textures :: proc() -> (_container_texture_data, _face_texture_data: ^u8, _container_texture_id, _face_texture_id: u32) {
	container_texture_width, container_texture_height, container_nr_channels: i32
    container_texture_data: ^u8 = stbi.load("textures/container.jpg", &container_texture_width, &container_texture_height, &container_nr_channels, 0)
    assert(container_texture_data != nil, "error loading container texture")

    face_texture_width, face_texture_height, face_nr_channels: i32
    face_texture_data: ^u8 = stbi.load("textures/awesomeface.png", &face_texture_width, &face_texture_height, &face_nr_channels, 0)
    assert(face_texture_data != nil, "error loading face texture")
    
    container_texture_id, face_texture_id: u32
    gl.GenTextures(1, &container_texture_id)
    gl.GenTextures(1, &face_texture_id)

    // 
    // unit 0 : container texture
    // 
    gl.ActiveTexture(gl.TEXTURE0)
    gl.BindTexture(gl.TEXTURE_2D, container_texture_id)

    gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, gl.MIRRORED_REPEAT)
    gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, gl.MIRRORED_REPEAT)
    gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.NEAREST_MIPMAP_NEAREST)
    gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.LINEAR)
    
    gl.TexImage2D(gl.TEXTURE_2D, 0, gl.RGB, container_texture_width, container_texture_height, 0, gl.RGB, gl.UNSIGNED_BYTE, container_texture_data)
    gl.GenerateMipmap(gl.TEXTURE_2D)

    // 
    // unit 1 : face texture
    //
    gl.ActiveTexture(gl.TEXTURE1)
    gl.BindTexture(gl.TEXTURE_2D, face_texture_id)

    gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, gl.MIRRORED_REPEAT)
    gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, gl.MIRRORED_REPEAT)
    gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.NEAREST_MIPMAP_NEAREST)
    gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.LINEAR)
    
    gl.TexImage2D(gl.TEXTURE_2D, 0, gl.RGBA, face_texture_width, face_texture_height, 0, gl.RGBA, gl.UNSIGNED_BYTE, face_texture_data)
    gl.GenerateMipmap(gl.TEXTURE_2D)

    return container_texture_data, face_texture_data, container_texture_id, face_texture_id
}