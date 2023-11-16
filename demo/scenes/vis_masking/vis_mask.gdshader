shader_type canvas_item;
uniform sampler2D mask_texture;

void fragment() {
	vec4 mask = texture(mask_texture, UV);
	vec4 color = texture(TEXTURE, UV);
	COLOR = color * mask;
}
