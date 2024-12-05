shader_type canvas_item;
uniform float fill_amt = 1;
void fragment() {
	 COLOR = vec4(COLOR.rgb, step(1.0-fill_amt, 1.0 - UV.x));
}
