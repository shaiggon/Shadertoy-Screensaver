#version 410 core

//attribute vec2 position;
layout (location = 0) in vec2 position;
uniform vec3  iResolution;

//out vec4 FragCoord_;

void main()
{
    gl_Position = vec4(position, 0.0, 1.0);
    //vec2 p = (position.xy + vec2(1.0)) * 0.5;
    //FragCoord_ = vec4(p.x * iResolution.x, p.y * iResolution.y, 0.0, 1.0);
    //gl_Position = vec4(p.x * iResolution.x, p.y * iResolution.y, 0.0, 1.0);
    //gl_FragCoord = vec4(p.x * iResolution.x, p.y * iResolution.y, 0.0, 1.0);
}