shader_type canvas_item;

uniform float radius : hint_range(0.0, 2.0) = 1.2;

void fragment() {
	vec2 uv = UV - 0.5;
	float len = length(uv);
	
	// Diubah agar transisi lubang tengahnya jauh lebih lebar dan luas
	float vignette = smoothstep(radius, radius - 0.5, len * 1.1);
	
	COLOR = vec4(0.0, 0.0, 0.0, 1.0 - vignette);
}
