shader_type canvas_item;

uniform int height: hint_range(0, 5, 1);

void fragment() {
	float pixel_size_x = 1.0 / float(textureSize(TEXTURE, 0).x);
	float pixel_size_y = 1.0 / float(textureSize(TEXTURE, 0).y);
	vec2 pixel_size = vec2(pixel_size_x, pixel_size_y);
	if (texture(TEXTURE, UV).a == 0.0) { 
		for (int x = height; x <= height * 2; x++) {
			for (int y = -height * 2; y <= -height; y++) {
				vec2 pixel_offset = vec2(float(x), float(y));
				if (texture(TEXTURE, UV + (pixel_offset * pixel_size)).a > 0.0) {
					COLOR = vec4(0, 0, 0, .25);
				}
			}
		}
	} else {
		COLOR = texture(TEXTURE, UV);
	}
}