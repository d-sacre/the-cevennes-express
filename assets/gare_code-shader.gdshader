shader_type spatial;


uniform sampler2D normalmap;
uniform sampler2D colortex;

varying vec2 tex_position;

void vertex() {
  //tex_position = VERTEX.xz;
}

void fragment() {
    NORMALMAP = texture(normalmap, UV).xyz;
    ALBEDO = texture(colortex, UV).xyz;
}