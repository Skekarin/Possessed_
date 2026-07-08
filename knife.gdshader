shader_type canvas_item;

uniform vec4 outline_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform float outline_width : hint_range(0.0, 5.0) = 1.5;
uniform bool show_outline = false;
uniform vec2 sprite_scale = vec2(1.0, 1.0);

void fragment() {
    vec4 tex = texture(TEXTURE, UV);
    COLOR = tex;
    if (show_outline && tex.a < 0.5) {
        float alpha = 0.0;
        vec2 pixel = TEXTURE_PIXEL_SIZE / sprite_scale;
        for (float x = -outline_width; x <= outline_width; x += 1.0) {
            for (float y = -outline_width; y <= outline_width; y += 1.0) {
                vec2 offset = vec2(x, y) * pixel;
                alpha = max(alpha, texture(TEXTURE, UV + offset).a);
            }
        }
        if (alpha > 0.0) {
            COLOR = vec4(outline_color.rgb, 1.0);
        }
    }
}