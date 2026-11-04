shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, filter_linear_mipmap;
uniform float vignette_strength = 0.9;
uniform float aberration = 0.004;
uniform float grain = 0.03;

float random(vec2 point) {
	return fract(sin(dot(point, vec2(12.9898, 78.233))) * 43758.5453);
}

void fragment() {
	vec2 from_center = SCREEN_UV - 0.5;
	vec2 shift = from_center * aberration;
	vec3 color = vec3(
		texture(screen_texture, SCREEN_UV + shift).r,
		texture(screen_texture, SCREEN_UV).g,
		texture(screen_texture, SCREEN_UV - shift).b
	);
	color *= 1.0 - vignette_strength * dot(from_center, from_center);
	color += (random(SCREEN_UV + fract(TIME)) - 0.5) * grain;
	COLOR = vec4(color, 1.0);
}
