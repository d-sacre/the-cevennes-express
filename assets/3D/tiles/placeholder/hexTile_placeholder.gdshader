// NOTE: Shader automatically converted from Godot Engine 3 3.5.3.stable's SpatialMaterial.

shader_type spatial;
render_mode async_visible,blend_mix,depth_draw_opaque,cull_back,diffuse_burley,specular_schlick_ggx;

uniform sampler2D texture_albedo_default : hint_albedo;
uniform sampler2D texture_albedo_highlight : hint_albedo;

uniform bool highlight;

uniform sampler2D texture_emission : hint_black_albedo;
uniform float emission_energy;

uniform vec3 uv1_scale;
uniform vec3 uv1_offset;
uniform vec3 uv2_scale;
uniform vec3 uv2_offset;


void vertex() {
	UV=UV*uv1_scale.xy+uv1_offset.xy;
}


void fragment() {
	vec2 base_uv = UV;
	
	if (highlight){
		vec4 albedo_tex = texture(texture_albedo_highlight,base_uv);
		ALBEDO = albedo_tex.rgb;

		vec3 emission_tex = texture(texture_emission,base_uv).rgb;
		EMISSION = emission_tex*emission_energy;
	} else {
		vec4 albedo_tex = texture(texture_albedo_default,base_uv);
		ALBEDO = albedo_tex.rgb;
	}
}
