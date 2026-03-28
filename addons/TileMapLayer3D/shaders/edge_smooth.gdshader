shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_disabled, unshaded;

// ============================================================
// EDGE BEVEL SHADER v7 — BALANCED HIGHLIGHT/SHADOW
// ============================================================
//
// Detects edges via normal/depth discontinuities, computes edge
// direction, applies balanced fake lighting (equal highlight and
// shadow) using the pixel's own color. No white, no foreign tint.
//
// ============================================================

// --- Buffers ---
uniform sampler2D DEPTH_TEXTURE : hint_depth_texture, filter_linear_mipmap;
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;
uniform sampler2D NORMAL_TEXTURE : hint_normal_roughness_texture, filter_nearest;

// --- Master ---
uniform bool active = true;

// --- Bevel ---
uniform float bevel_radius : hint_range(0.5, 20.0, 0.5) = 10.0;
uniform float bevel_intensity : hint_range(0.0, 4.0, 0.01) = 0.8;
// How much shadow/darkness suppresses the bevel (0 = no suppression, 1 = full)
uniform float shadow_sensitivity : hint_range(0.0, 1.0, 0.01) = 0.85;

// --- Curvature shaping ---
// 0.5 = wide, soft, round falloff. 3.0 = tight, sharp, concentrated line.
uniform float curvature_power : hint_range(0.10, 3.0, 0.01) = 0.20;

// --- Edge detection ---
uniform float normal_threshold : hint_range(0.0, 1.0, 0.01) = 0.1;
uniform float depth_threshold : hint_range(0.0, 1.0, 0.01) = 0.9;
uniform float silhouette_cutoff : hint_range(0.1, 5.0, 0.1) = 0.5;



// --- Distance fade ---
uniform float fade_start = 10.0;
uniform float fade_end = 30.0;

// --- Debug ---
uniform bool debug_show_edges = false;


// ============================================================
// DEPTH
// ============================================================

float getDepth(vec2 uv, mat4 inv_proj) {
    float raw = texture(DEPTH_TEXTURE, uv).r;
    vec3 ndc = vec3(uv * 2.0 - 1.0, raw);
    vec4 view = inv_proj * vec4(ndc, 1.0);
    view.xyz /= view.w;
    return -view.z;
}


// ============================================================
// MAIN
// ============================================================

void fragment() {

    // --------------------------------------------------------
    // Base values
    // --------------------------------------------------------
    float center_depth = getDepth(SCREEN_UV, INV_PROJECTION_MATRIX);
    vec3 center_normal = texture(NORMAL_TEXTURE, SCREEN_UV).rgb * 2.0 - 1.0;

    // --------------------------------------------------------
    // Distance fade
    // --------------------------------------------------------
    float distance_fade = 1.0 - smoothstep(fade_start, fade_end, center_depth);

    // --------------------------------------------------------
    // Radius scaling (tied to distance)
    // --------------------------------------------------------
    float depth_scale = clamp(1.0 / center_depth, 0.3, 2.0);
    vec2 pixel_size = bevel_radius * depth_scale * distance_fade / VIEWPORT_SIZE;

    // --------------------------------------------------------
    // Directions
    // --------------------------------------------------------
    vec2 offsets[8] = {
        vec2( 0.0, -1.0),
        vec2( 0.0,  1.0),
        vec2(-1.0,  0.0),
        vec2( 1.0,  0.0),
        vec2(-1.0, -1.0),
        vec2( 1.0, -1.0),
        vec2(-1.0,  1.0),
        vec2( 1.0,  1.0)
    };

    // --------------------------------------------------------
    // Accumulators
    // --------------------------------------------------------
    float edge_weight = 0.0;
    vec2 edge_dir = vec2(0.0);

    // ========================================================
    // MULTI-RADIUS SAMPLING
    // ========================================================
    for (int r = 1; r <= 2; r++) {

        vec2 scaled = pixel_size * float(r);

        for (int i = 0; i < 8; i++) {

            vec2 dir = offsets[i];
            vec2 uv = SCREEN_UV + dir * scaled;

            vec3 n = texture(NORMAL_TEXTURE, uv).rgb * 2.0 - 1.0;
            float d = getDepth(uv, INV_PROJECTION_MATRIX);

            float normal_diff = 1.0 - dot(center_normal, n);
            float depth_diff = abs(center_depth - d);

            float n_edge = smoothstep(normal_threshold, normal_threshold + 0.2, normal_diff);
            float d_edge = smoothstep(depth_threshold, depth_threshold + 0.1, depth_diff);

            float not_silhouette = 1.0 - smoothstep(silhouette_cutoff, silhouette_cutoff + 0.5, depth_diff);

            float edge = max(n_edge, d_edge) * not_silhouette;

            // Outer radius weighs less (soft falloff)
            edge *= (r == 1) ? 1.0 : 0.5;

            edge_weight += edge;
            edge_dir += dir * edge;
        }
    }

    // --------------------------------------------------------
    // Edge amount + shaping
    // --------------------------------------------------------
    float edge_amount = clamp(edge_weight / 12.0, 0.0, 1.0);
    vec2 final_dir = normalize(edge_dir + 0.0001);

    edge_amount = pow(edge_amount, curvature_power);
    edge_amount = smoothstep(0.1, 1.0, edge_amount);
    edge_amount *= distance_fade;

    // --------------------------------------------------------
    // Output
    // --------------------------------------------------------
    if (debug_show_edges) {
        ALBEDO = vec3(edge_amount, 0.0, 0.0);
        ALPHA = edge_amount;
    } else {
        // ----------------------------------------------------
        // Fake bevel lighting from edge direction
        // ----------------------------------------------------
        vec3 bevel_normal = normalize(vec3(-final_dir.x, 0.8, -final_dir.y));
        vec3 light_dir = normalize(vec3(0.4, 0.7, 0.5));

        float lighting = dot(bevel_normal, light_dir);
        lighting = smoothstep(-0.2, 0.8, lighting);

        // ----------------------------------------------------
        // Luminance-gated highlight bevel
        // Scales bevel by how bright the pixel already is.
        // In shadow = dark pixel = tiny/no highlight.
        // In light = bright pixel = visible bevel.
        // ----------------------------------------------------
        vec3 pixel_color = texture(SCREEN_TEXTURE, SCREEN_UV).rgb;
        float luminance = dot(pixel_color, vec3(0.299, 0.587, 0.114));
        // Mix between full effect (1.0) and luminance-gated based on sensitivity
        float shadow_gate = mix(1.0, luminance, shadow_sensitivity);

        float highlight = max(lighting * 2.0 - 1.0, 0.0) * bevel_intensity * edge_amount * shadow_gate;
        vec3 final_color = pixel_color + pixel_color * highlight;

        ALBEDO = final_color * float(active);
        ALPHA = edge_amount * float(active);
    }
}
