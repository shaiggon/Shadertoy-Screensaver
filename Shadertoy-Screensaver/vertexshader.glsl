#version 410 core

//attribute vec2 position;
layout (location = 0) in vec2 position;

out vec4 FragCoord_;

void main()
{
    gl_Position = vec4(position, 0.0, 1.0);
    FragCoord_ = vec4(position.x, position.y, 0.0, 1.0);
}