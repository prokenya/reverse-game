shader_type canvas_item;

uniform vec4 flash_color:source_color;
uniform float factor = 0.0;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment()
{
	if (COLOR.a > 0.2)
	{
		COLOR = mix(COLOR,flash_color,factor);
	}

}