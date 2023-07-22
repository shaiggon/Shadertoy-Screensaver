#version 120

uniform float time;

void main()
{
    float r = 0.5 * (1.0 + sin(time));
    float g = 0.5 * (1.0 + cos(time + 23.0));
    gl_FragColor = vec4(r, g, 0.0, 1.0);
}
