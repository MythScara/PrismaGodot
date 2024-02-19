shader_type canvas_item;

uniform vec2 screen_size; // Add this line

void fragment() {
    float radius = 0.75;
    float softness = 0.45;
    vec2 center = vec2(0.5, 0.5);
    vec2 pos = FRAGCOORD.xy / screen_size; // Use the uniform here
    float dist = distance(pos, center);
    float vignette = smoothstep(radius, radius - softness, dist);
    COLOR.rgb *= mix(1.0, 0.0, vignette);
}