struct CameraUniform {
    view_proj: mat4x4<f32>,
};

struct InstanceInput {
    @location(4) model_texcoord: vec4<f32>,
    @location(5) model_matrix_0: vec4<f32>,
    @location(6) model_matrix_1: vec4<f32>,
    @location(7) model_matrix_2: vec4<f32>,
    @location(8) model_matrix_3: vec4<f32>,
    @location(9) model_color: vec3<f32>
};


struct VertexInput {
    @location(0) position: vec3<f32>,
    @location(1) tex_coords: vec2<f32>,

}

struct VertexOutput {
    @builtin(position) clip_position: vec4<f32>,
    @location(0) tex_coords: vec2<f32>,
    @location(1) color: vec3<f32>,
}


@group(0) @binding(0)
var<uniform> camera: CameraUniform;

@vertex
fn vs_main(
    model: VertexInput,
    instance: InstanceInput,
) -> VertexOutput {

    let model_matrix = mat4x4<f32>(
        instance.model_matrix_0,
        instance.model_matrix_1,
        instance.model_matrix_2,
        instance.model_matrix_3,
    );

    var out: VertexOutput;
    out.tex_coords = vec2(
    instance.model_texcoord[0] * model.tex_coords[0] + instance.model_texcoord[1] * (1.0-model.tex_coords[0])  ,
    instance.model_texcoord[2] * model.tex_coords[1] + instance.model_texcoord[3] * (1.0-model.tex_coords[1])
    );// model.tex_coords + instance.model_texcoord;
    out.clip_position =  camera.view_proj *model_matrix * vec4<f32>(model.position, 1.0);
    out.color = instance.model_color;
    return out;
}

@group(1) @binding(0)
var t_diffuse: texture_2d<f32>;
@group(1) @binding(1)
var s_diffuse: sampler;


@fragment
fn fs_main(in: VertexOutput) -> @location(0) vec4<f32> {
    let texture = textureSample(t_diffuse, s_diffuse, in.tex_coords);
    let average_intensity = texture.r * 0.299 + texture.g * 0.587 + texture.b * 0.114;
    let font_color = vec3( 1.0 - texture.r , 1.0 - texture.g, 1.0 - texture.b) * in.color;
//    return vec4(texture.rgb, average_intensity);
    return vec4( font_color, texture.r);
}