shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_disabled, diffuse_toon, specular_toon;
uniform vec4 albedo_color : source_color = vec4(1.0);
uniform float alpha_threshold = 0.5;
uniform bool use_nearest_texture = true;
uniform sampler2D albedo_texture_nearest : source_color, filter_nearest, repeat_disable;
uniform sampler2D albedo_texture_linear : source_color, filter_linear, repeat_disable;
uniform bool debug_show_backfaces = true;

varying flat vec4 uv_rect_data;
varying flat vec4 anim_data;

void vertex() {
    uv_rect_data = INSTANCE_CUSTOM;
    anim_data = COLOR;
}

void fragment() {
    vec2 uv_min = uv_rect_data.rg;
    vec2 uv_max = uv_rect_data.ba;

    // Animation data packed as (cols, rows, total_frames, speed)
    float anim_cols = anim_data.r;
    float anim_rows = anim_data.g;
    float anim_total = anim_data.b;
    float anim_speed = anim_data.a;

    if (anim_speed > 0.0 && anim_total > 1.0) {
        float cols = round(anim_cols);
        float rows = round(anim_rows);
        float total = round(anim_total);
        float frame_index = floor(mod(TIME * anim_speed, total) + 0.001);
        float col = mod(frame_index, cols);
        float row = floor(frame_index / cols);
        vec2 full_size = uv_max - uv_min;
        vec2 frame_size = vec2(full_size.x / cols, full_size.y / rows);
        uv_min = uv_min + vec2(col * frame_size.x, row * frame_size.y);
        uv_max = uv_min + frame_size;
    }

    vec2 flipped_uv = vec2(UV.x, 1.0 - UV.y);
    vec2 remapped_uv = mix(uv_min, uv_max, flipped_uv);

    // Atlas-bleed prevention: clamp UVs to valid texel range
    vec2 tex_size = vec2(textureSize(albedo_texture_nearest, 0));
    vec2 inset = 0.5 / tex_size;
    if (anim_speed > 0.0 && anim_total > 1.0) {
        inset = 1.0 / tex_size;
    }
    vec2 final_uv = clamp(remapped_uv, uv_min + inset, uv_max - inset);

    // Sample texture with correct filter mode
    vec4 tex_color;
    if (anim_speed > 0.0 && anim_total > 1.0) {
        // Animated: force mip 0 to prevent cross-frame mipmap bleeding
        tex_color = use_nearest_texture
            ? textureLod(albedo_texture_nearest, final_uv, 0.0)
            : textureLod(albedo_texture_linear, final_uv, 0.0);
    } else {
        tex_color = use_nearest_texture
            ? texture(albedo_texture_nearest, final_uv)
            : texture(albedo_texture_linear, final_uv);
    }

    if (tex_color.a < alpha_threshold) {
        discard;
    }

    if (debug_show_backfaces && !FRONT_FACING) {
        ALBEDO = vec3(1.0, 0.0, 0.0);
    } else {
        ALBEDO = albedo_color.rgb * tex_color.rgb;
    }
}
