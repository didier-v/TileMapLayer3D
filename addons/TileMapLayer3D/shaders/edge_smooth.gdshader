shader_type spatial;
 render_mode blend_add, depth_draw_opaque, cull_disabled, unshaded;
//render_mode blend_add, depth_draw_opaque, cull_disabled, diffuse_toon, specular_toon;


// Edge Smooth Shader v3 — Screen-Space Bevel
// Detects normal/depth edges and applies a subtle light gradient to simulate
// smooth beveled edges. Uses additive blending so it only ADDS light where
// the bevel would catch it — never darkens. Fully unshaded (no double-lighting).

uniform sampler2D DEPTH_TEXTURE : hint_depth_texture, filter_linear_mipmap;
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;
uniform sampler2D NORMAL_TEXTURE : hint_normal_roughness_texture, filter_nearest;

// --- Tunable parameters ---
uniform bool active = true;
// How wide the bevel band is (in pixels)
uniform float bevel_radius : hint_range(0.5, 12.0, 0.5) = 7.5;
// Intensity of the bevel highlight (fraction of own color added back)
uniform float bevel_intensity : hint_range(0.0, 1.0, 0.01) = 0.75;
// Sensitivity for detecting normal changes (lower = more edges)
uniform float normal_threshold : hint_range(0.0, 1.0, 0.01) = 0.1;
// Sensitivity for detecting depth steps (wall-wall corners)
uniform float depth_threshold : hint_range(0.0, 1.0, 0.01) = 0.95;
// Skip edges with depth gap larger than this (open-air silhouettes)
uniform float silhouette_cutoff : hint_range(0.1, 5.0, 0.1) = 0.5;
// Debug: visualize detected edges
uniform bool debug_show_edges = false;

float getDepth(vec2 screen_uv, mat4 inv_proj) {
	float raw_depth = texture(DEPTH_TEXTURE, screen_uv).r;
	vec3 ndc = vec3(screen_uv * 2.0 - 1.0, raw_depth);
	vec4 view_space = inv_proj * vec4(ndc, 1.0);
	view_space.xyz /= view_space.w;
	return -view_space.z;
}

void fragment() {
	if (active)
	{
		vec2 pixel_size = bevel_radius / VIEWPORT_SIZE;

		float center_depth = getDepth(SCREEN_UV, INV_PROJECTION_MATRIX);
		vec3 center_normal = texture(NORMAL_TEXTURE, SCREEN_UV).rgb * 2.0 - 1.0;

		// 8-direction sampling
		vec2 offsets[8] = {
			vec2( 0.0, -1.0) * pixel_size,
			vec2( 0.0,  1.0) * pixel_size,
			vec2(-1.0,  0.0) * pixel_size,
			vec2( 1.0,  0.0) * pixel_size,
			vec2(-1.0, -1.0) * pixel_size,
			vec2( 1.0, -1.0) * pixel_size,
			vec2(-1.0,  1.0) * pixel_size,
			vec2( 1.0,  1.0) * pixel_size
		};

		float normal_edge_sum = 0.0;
		float depth_edge_sum = 0.0;

		for (int i = 0; i < 8; i++) {
			vec2 sample_uv = SCREEN_UV + offsets[i];
			vec3 neighbor_normal = texture(NORMAL_TEXTURE, sample_uv).rgb * 2.0 - 1.0;
			float neighbor_depth = getDepth(sample_uv, INV_PROJECTION_MATRIX);

			float normal_diff = 1.0 - dot(center_normal, neighbor_normal);
			float is_normal_edge = smoothstep(normal_threshold, normal_threshold + 0.2, normal_diff);

			float depth_diff = abs(center_depth - neighbor_depth);
			float is_depth_edge = smoothstep(depth_threshold, depth_threshold + 0.1, depth_diff);

			float is_not_silhouette = 1.0 - smoothstep(silhouette_cutoff, silhouette_cutoff + 0.5, depth_diff);

			normal_edge_sum += is_normal_edge * is_not_silhouette;
			depth_edge_sum += is_depth_edge * is_not_silhouette;
		}

		float edge_amount = clamp(max(normal_edge_sum, depth_edge_sum) / 8.0, 0.0, 1.0);

		if (debug_show_edges) {
			float n = clamp(normal_edge_sum / 8.0, 0.0, 1.0);
			float d = clamp(depth_edge_sum / 8.0, 0.0, 1.0);
			// Additive debug: bright red/green overlay
			ALBEDO = vec3(n, d, 0.0) * 0.7;
			ALPHA = max(n, d) * 0.8;
		} else {
			// Use the pixel's OWN color as the highlight source.
			// Additive blend adds a fraction of the mesh color back — edges get
			// subtly brighter with their own color, no foreign tint.
			vec3 pixel_color = texture(SCREEN_TEXTURE, SCREEN_UV).rgb;
			ALBEDO = pixel_color * bevel_intensity * edge_amount;
			ALPHA = edge_amount;
		}
	}
	else
	{
		// Inactive: fully transparent, adds nothing
		ALBEDO = vec3(0.0);
		ALPHA = 0.0;
	}
}
