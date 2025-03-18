shader_type canvas_item;

uniform float radius = 1.0;
uniform float softness = 0.5;
uniform float opacity = 0.8;
uniform vec4 color : source_color = vec4(0.0, 0.0, 0.0, 1.0);
uniform vec2 center = vec2(0.5, 0.5);
uniform bool enabled = true;
uniform bool use_texture = false;
uniform sampler2D vignette_texture;

void fragment() {
    if (!enabled) {
        COLOR = texture(SCREEN_TEXTURE, SCREEN_UV);
        return;
    }

    vec4 screen_color = texture(SCREEN_TEXTURE, SCREEN_UV);
    float vignette_strength;

    if (use_texture) {
        // Use the texture's alpha channel for vignette strength
        vignette_strength = texture(vignette_texture, UV).a;
    } else {
        // Calculate distance-based vignette
        float dist = distance(SCREEN_UV, center);
        vignette_strength = smoothstep(radius, radius - softness, dist);
    }

    // Apply vignette by mixing screen color with tinted color
    COLOR = mix(screen_color, screen_color * color, vignette_strength * opacity);
}
