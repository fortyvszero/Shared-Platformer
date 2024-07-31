shader_type canvas_item;

uniform bool flash;
uniform vec4 flash_colour : source_color = vec4(1.0);
uniform float flash_pct : hint_range(0.0, 1.0);

uniform bool dissolve;
uniform sampler2D noise_tex;
uniform float dissolve_pct : hint_range(0.0, 1.0) = 0.0f;

void fragment()
{
	if(flash) {
		vec4 original_colour = texture(TEXTURE, UV);
		COLOR = mix(original_colour, flash_colour, flash_pct);
		COLOR.a *= original_colour.a;
	}
	
	if(dissolve) {
		vec4 original_colour = texture(TEXTURE, UV);
		vec4 final_colour = original_colour;
		
		vec4 noise = texture(noise_tex, UV);
		
		if(dissolve_pct >= noise.r)
		{
			final_colour.a = 0.0;
		}
		
		COLOR = final_colour;
	}
}