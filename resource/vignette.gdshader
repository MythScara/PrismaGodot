shader_type canvas_item;

uniform vec2 viewport_size; // Size of the viewport

void fragment() {
    // Calculate the center of the viewport
    vec2 center = viewport_size / 2.0;
    
    // Convert fragment coordinates to viewport coordinates
    vec2 frag_coord = FRAGCOORD.xy;
    
    // Calculate the distance from the fragment to the center of the viewport
    float dist = distance(frag_coord, center);
    
    // Calculate the radius of the vignette effect
    float radius = length(viewport_size) / 2.0;
    
    // Calculate the vignette intensity
    float vignette = smoothstep(radius, radius * 0.7, dist);
    
    // Apply the vignette effect
    COLOR.rgb *= vignette;
}