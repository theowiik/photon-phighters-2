shader_type sky;

uniform vec3 top_color : source_color = vec3(0.06, 0.05, 0.16);
uniform vec3 bottom_color : source_color = vec3(0.01, 0.0, 0.03);
uniform float star_density = 0.0015;

float hash(vec3 point) {
	point = fract(point * 0.3183099 + 0.1);
	point *= 17.0;
	return fract(point.x * point.y * point.z * (point.x + point.y + point.z));
}

void sky() {
	vec3 color = mix(bottom_color, top_color, smoothstep(-0.25, 0.25, EYEDIR.y));
	float star = step(1.0 - star_density, hash(floor(EYEDIR * 900.0)));
	COLOR = color + vec3(star * 0.35);
}
