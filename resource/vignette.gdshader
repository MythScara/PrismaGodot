[shader_type canvas_item]

uniform float radius : hint_range(0.0, 2.0) = 1.0;
uniform float softness : hint_range(0.0, 1.0) = 0.5;
uniform float opacity : hint_range(0.0, 1.0) = 0.8;
uniform vec4 color : source_color = vec4(0.0, 0.0, 0.0, 1.0);
uniform vec2 center = vec2(0.5, 0.5);
uniform bool enabled = true;

void fragment() {
    if (enabled) {
        vec2 uv = SCREEN_UV;
        float dist = distance(uv, center);
        float vignette = smoothstep(radius, radius - softness, dist);
        vec4 base_color = texture(SCREEN_TEXTURE, SCREEN_UV);
        COLOR = mix(base_color, color, (1.0 - vignette) * opacity);
    } else {
        COLOR = texture(SCREEN_TEXTURE, SCREEN_UV);
    }
}
