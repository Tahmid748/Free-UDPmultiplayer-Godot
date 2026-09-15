shader_type canvas_item;

uniform vec4 target_color  = vec4(1.0, 1.0, 1.0, 1.0); // color you want to change (white)
uniform vec4 new_color = vec4(1.0, 1.0, 1.0, 1.0);   // color to replace with (red)
uniform float tolerance = 0.1; // how close a color must be to be replaced

void fragment() {
    vec4 tex_color = texture(TEXTURE, UV);
    
    // Check if the color is close enough to the target
    float diff = distance(tex_color.rgb, target_color.rgb);
    
    if (diff < tolerance) {
        COLOR = vec4(new_color.rgb, tex_color.a); // replace with new color
    } else {
        COLOR = tex_color; // leave everything else unchanged
    }
}
