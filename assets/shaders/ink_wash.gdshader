shader_type canvas_item;
// Simple ink-wash vignette for parchment surfaces.
uniform sampler2D noise_texture : repeat_enable;
uniform float intensity : hint_range(0.0, 1.0) = 0.4;
uniform float scale = 4.0;
uniform vec3 ink_color : source_color = vec3(0.08, 0.07, 0.06);

void fragment() {
    vec2 uv = UV * scale;
    float n = texture(noise_texture, uv + TIME * 0.02).r;
    float vignette = 1.0 - length(UV - 0.5) * 1.4;
    float stain = smoothstep(0.35, 0.75, n) * vignette * intensity;
    vec4 tex = texture(TEXTURE, UV);
    vec3 shaded = mix(tex.rgb, ink_color, stain);
    COLOR = vec4(shaded, tex.a);
}
