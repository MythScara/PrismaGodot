shader_type canvas_item;

uniform bool enabled = true;
uniform vec2 center = vec2(0.5, 0.5);
uniform float radius : hint_range(0.0, 2.0) = 1.0;
uniform float softness : hint_range(0.0, 1.0) = 0.5;
uniform float opacity : hint_range(0.0, 1.0) = 0.8;
uniform vec4 color : source_color = vec4(0.0, 0.0, 0.0, 1.0);

// Advanced Settings
uniform bool aspect_ratio_correction = true;
uniform float shape_power : hint_range(0.1, 4.0) = 2.0;
uniform float feather_curve : hint_range(0.0, 2.0) = 1.0;
uniform float dither_strength : hint_range(0.0, 1.0) = 0.0;

uniform vec4 color_tint : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform float saturation_boost = 1.0;
uniform float brightness_boost = 1.0;


uniform float pulsate_speed = 0.0;
uniform float pulsate_amplitude : hint_range(0.0, 1.0) = 0.1;
uniform float flicker_speed = 0.0;
uniform float flicker_amplitude : hint_range(0.0, 1.0) = 0.0;

uniform float offset_x = 0.0;
uniform float offset_y = 0.0;

uniform bool dynamic_center = false;
uniform vec2 dynamic_center_position = vec2(0.5, 0.5);
uniform float center_track_smoothness = 0.9;

// Noise
uniform float noise_strength : hint_range(0.0, 1.0) = 0.0;
uniform float noise_scale = 50.0;
uniform float noise_speed = 0.1;
uniform vec2 noise_offset = vec2(0.0, 0.0);

// Screen space gradient
uniform bool gradient_enabled;
uniform vec2 gradient_start = vec2(0,0);
uniform vec2 gradient_end = vec2(1,1);
uniform vec4 gradient_color : source_color = vec4(1.0, 1.0, 1.0, 0.0);

// ---  Noise Function (from The Book of Shaders) ---
float rand(vec2 n) {
	return fract(sin(dot(n, vec2(12.9898, 4.1414))) * 43758.5453);
}

float noise(vec2 p){
	vec2 ip = floor(p);
	vec2 u = fract(p);
	u = u*u*(3.0-2.0*u);

	float res = mix(
		mix(rand(ip),rand(ip+vec2(1.0,0.0)),u.x),
		mix(rand(ip+vec2(0.0,1.0)),rand(ip+vec2(1.0,1.0)),u.x),u.y);
	return res*res;
}

void fragment() {
    if (!enabled) {
        COLOR = texture(TEXTURE, UV); // Pass-through if disabled
        return;
    }

    vec2 uv = UV;
	vec2 current_center = center;

	if (dynamic_center) {
		current_center = mix(current_center, dynamic_center_position, 1.0 - center_track_smoothness);
	}


    // Apply offsets
    current_center += vec2(offset_x, offset_y);

    // Aspect ratio correction
    if (aspect_ratio_correction) {
        vec2 aspect_ratio = vec2(1.0, SCREEN_PIXEL_SIZE.y / SCREEN_PIXEL_SIZE.x);
		if (aspect_ratio.y < 1.0){
			aspect_ratio = vec2(SCREEN_PIXEL_SIZE.x / SCREEN_PIXEL_SIZE.y, 1.0);
		}
        uv = (uv - current_center) * aspect_ratio + current_center;
    }

    // Distance calculation (with shape power)
    float dist = distance(uv, current_center);
	dist = pow(dist, shape_power);


    // Pulsation
    float current_radius = radius + pulsate_amplitude * sin(TIME * pulsate_speed * 2.0 * 3.14159);

    // Vignette calculation (with feather curve)
    float vignette = smoothstep(current_radius, current_radius - softness, dist);
	vignette = pow(vignette, feather_curve);

    // Flicker
    float flicker = 1.0 + flicker_amplitude * (rand(UV + TIME * flicker_speed) - 0.5) * 2.0; // -1 to 1 range
    float current_opacity = opacity * flicker;

	// Dithering (add before applying opacity)
	float dither = (rand(FRAGCOORD.xy / 8.0) - 0.5) * dither_strength;  //Scale 8.0 is a good start point
	vignette = clamp(vignette + dither, 0.0, 1.0);  //Important: dither before opacity!


    // Apply vignette
    vec4 base_color = texture(TEXTURE, UV);


	// ---  Noise ---
	float noise_val = noise((UV + noise_offset) * noise_scale + TIME * noise_speed) * noise_strength;
	vec4 noise_color = vec4(noise_val, noise_val, noise_val, 0.0);  // Grayscale noise

    // --- Color Adjustments ---
	vec3 hsv = rgb2hsv(base_color.rgb); // Convert to HSV for saturation and brightness
	hsv.y *= saturation_boost;
	hsv.z *= brightness_boost;
	base_color.rgb = hsv2rgb(hsv);

	// --- Gradient ---
    if (gradient_enabled)
    {
        float gradient_factor = 1.0 - smoothstep(0.0, 1.0, dot(UV - gradient_start, normalize(gradient_end - gradient_start)));
        base_color = mix(base_color, gradient_color, gradient_color.a * gradient_factor); //Premultiply alpha.
    }

    // --- Combine ---
	vec4 vignette_color = mix(base_color, color * color_tint, (1.0 - vignette) * current_opacity);
    COLOR = mix(base_color, vignette_color + noise_color, 1.0);

}
// --- RGB to HSV helper functions ---
vec3 rgb2hsv(vec3 c)
{
    vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
    vec4 p = mix(vec4(c.bg, K.wz), vec4(c.gb, K.xy), step(c.b, c.g));
    vec4 q = mix(vec4(p.xyw, c.r), vec4(c.r, p.yzx), step(p.x, c.r));

    float d = q.x - min(q.w, q.y);
    float e = 1.0e-10;
    return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
}

vec3 hsv2rgb(vec3 c)
{
    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}
