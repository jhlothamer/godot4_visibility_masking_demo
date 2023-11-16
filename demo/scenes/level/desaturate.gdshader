shader_type canvas_item;

void fragment() {
	vec4 color = texture(TEXTURE, UV);
	float bw = (min(color.r, min(color.g, color.b)) + max(color.r, max(color.g, color.b))) * 0.5;
    COLOR = vec4(bw, bw, bw, 1.0);
}
