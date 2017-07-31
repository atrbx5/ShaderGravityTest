{uniforms}

vec4 p = u_inverseModelTransform * u_inverseViewTransform * vec4(_surface.position, 1.0);
vec3 pos = vec3(p.x, p.y, p.z);

float f = {math};

vec3 color = vec3(256.0, 0.0, 0.0);

color.b = floor(f / 256.0 / 256.0);
color.g = floor((f - color.b * 256.0 * 256.0) / 256.0);
color.r = floor(f - color.b * 256.0 * 256.0 - color.g * 256.0);


_output.color.rgb = color / 256.0;




