#version 330
// compatibility

out vec4 FragColor;

in vec4 color;

void main()
{
		
		FragColor = vec4(color.x,color.y,color.z,color.w);
		
}