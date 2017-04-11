#ifndef _CUDACOMPUTING_CUH_

#define _CUDACOMPUTING_CUH_

struct vec3{
	float x;
	float y;
	float z;
};

struct vec4{
	float x;
	float y;
	float z;
	float w;
};

void add(int * a, int * b);

void computeRays(int widhth, int height, char *tex);

void setTheBall(bool Ball);

void setTheCube(bool cube);

void setTheCylinder(bool Cy);

void setTheMirror(bool mi);

void setTheCurve(bool cur);

void setTheShadow(bool sha);

void setTheBF(bool sha);

/*float cx = 200;
float cy = 300;
float cz = -50;

float Ex = 600;
float Ey = 300;
float Ez = 1000;*/



#endif