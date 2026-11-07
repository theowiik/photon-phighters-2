shader_type canvas_item;

uniform vec3 top_color : source_color = vec3(0.06, 0.05, 0.16);
uniform vec3 bottom_color : source_color = vec3(0.01, 0.0, 0.03);
uniform float star_density = 0.0015;
uniform vec2 star_grid = vec2(640.0, 360.0);

float hash(vec2 point) {
	point = fract(point * vec2(0.3183099, 0.3678794) + 0.1);
	point *= 17.0;
	return fract(point.x * point.y * (point.x + point.y));
}

void fragment() {
	vec3 color = mix(top_color, bottom_color, smoothstep(0.35, 0.85, UV.y));
	float star = step(1.0 - star_density, hash(floor(UV * star_grid)));
	COLOR = vec4(color + vec3(star * 0.35), 1.0);
}
