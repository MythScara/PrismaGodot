shader_type canvas_item;

// Size of the viewport (should be passed in from script)
uniform vec2 viewport_size;

// Vignette parameters (expressed as factors relative to the maximum distance from the center)
uniform float inner_radius_factor : hint_range(0.0, 1.0) = 0.7;
uniform float outer_radius_factor : hint_range(0.0, 1.0) = 1.0;
uniform float vignette_strength : hint_range(0.0, 1.0) = 0.8;

// Tint color for the vignette (default is black)
uniform vec3 vignette_color : hint_color = vec3(0.0);

void fragment() {
    // Calculate the center of the viewport.
    vec2 center = viewport_size * 0.5;

    // Compute the maximum distance from the center to any corner.
    float max_dist = length(viewport_size) * 0.5;

    // Determine inner and outer radii for the vignette effect.
    float inner_radius = max_dist * inner_radius_factor;
    float outer_radius = max_dist * outer_radius_factor;

    // Calculate the distance from the current fragment to the center.
    float dist = distance(FRAGCOORD.xy, center);

    // Smoothly interpolate between the inner and outer radii.
    float t = smoothstep(inner_radius, outer_radius, dist);

    // Blend the original color with the vignette color.
    // At the center (t=0) the original color remains unchanged;
    // at the edges (t=1), the color is tinted by 'vignette_color' based on 'vignette_strength'.
    COLOR.rgb = mix(COLOR.rgb, vignette_color, t * vignette_strength);
}
