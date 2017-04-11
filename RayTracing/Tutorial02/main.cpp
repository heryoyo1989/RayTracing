#include "../CommonLib/common.h"
#include <stdio.h>
#include <string.h>

#include <GL/glew.h>
#include <GL/freeglut.h>
#include <iostream>
using namespace std;
#include "../CommonLib/Utils.h"
#pragma comment(lib, "CommonLib.lib")
#pragma comment(lib, "AntTweakBar64.lib")

#include "../CommonLib/math3d.h"
#include <assert.h>
#include <AntTweakBar.h>

#include "CudaComputing.cuh"


//#define BUFFER_OFFSET(offset) ((GLvoid*) 0 + offset)

#define BUFFER_OFFSET(bytes) ((GLubyte*) 0 + bytes)

const char* pVS = "shader.vert";
const char* pFS = "shader.frag";


GLuint VBO;
GLuint gScaleLocation;

GLuint modelLocation;
GLuint projectLocation;




struct Triangle{
	Vector3f v0;
	Vector3f v1;
	Vector3f v2;
	Vector3f Norm[3];
	//int color_index[3];
	Vector3f face_normal;
	float color[3];
};

Triangle* Tris;
GLuint NumTris;

Vector4f * Points;
Vector3f * Normals;

GLuint ScreenWidth = 1200;
GLuint ScreenHeight = 600;


float *point_float;


float *normal_float;

//face_normal
float *fn_float;
//ambient k
float *amb_float;
//diffuse k
float *diff_float;
//specular k
float *spec_float;
//shiness k
float *shin_float;



GLfloat ambient[4] = { 0.7, 0.7, 0.7, 1.0 };

GLfloat dylightcolor[4] = { 0.0, 0.0, 1.0, 1.0 };

GLfloat dilightcolor[4] = { 0.0, 0.0, 1.0, 1.0 };




GLfloat dyDiffuse[4] = { 0.0, 0.0, 1.0, 1.0 };
GLfloat dySpecular[4] = { 0.1, 0.1, 0.1, 1.0 };
GLfloat dyAmbient[4] = { 0.0, 0.0, 0.1, 1.0 };


GLfloat diDiffuse[4] = { 0.0, 1.0, 0.0, 1.0 };
GLfloat diSpecular[4] = { 0.5, 0.5, 0.5, 1.0 };
GLfloat diAmbient[4] = { 0.0, 0.0, 0.1, 1.0 };

float theta = 0;//speed
float theSpeed = 0.004;
float R = 400;
GLfloat lightposition[3];

//lightposition[2] = R;

GLfloat eyeposition[3];

//eyeposition[2] = R;

char* FileName = "models\\phone.in";

int shaderMode = 1;//mode=1 smooth,mode=2 flat


GLfloat Ns = 2;
GLfloat attenuation = 1;


GLuint LPLocation;
GLuint EPLocation;
GLuint AmLocation;
GLuint LCLocation;
GLuint NSLocation;
GLuint ATLocation;

GLuint VPLocation;
GLuint VNLocation;

GLuint DLLocation;

GLuint SMLocation;

GLuint DyALocation;
GLuint DyDLocation;
GLuint DySLocation;

GLuint DiALocation;
GLuint DiDLocation;
GLuint DiSLocation;


int Index = 0;

int pointIndex = 0;

GLuint vaoHandle;

GLuint KALocation;

GLuint KDLocation;
GLuint KSLocation;
GLuint SHLocation;

GLuint FNLocation;


float CenterX;
float CenterY;
float CenterZ;

int Axis = 0;//1,x;2,y;3,z

bool switch1 = true;
bool switch2 = true;
bool switch3 = true;
bool switch4 = true;
bool switch5 = true;



int modelIndex = 1;//1 phone,2 cude,3 cow_up

void readDataFromFile(char* FileName)
{
	//#define MAX_MATERIAL_COUNT 1000;

	Vector3f ambient[1000];
	Vector3f diffuse[1000];
	Vector3f specular[1000];

	float  shine[1000];

	int material_count, color_index[3], i;
	char ch;

	FILE* fp;
	fopen_s(&fp, FileName, "r");

	if (fp == NULL) {
		printf("ERROR: unable to open TriObj [%s]!\n", FileName);
		system("pause");
		exit(1);
	}

	fscanf_s(fp, "%c", &ch);
	while (ch != '\n') // skip the first line – object’s name
		fscanf_s(fp, "%c", &ch, 2);

	fscanf_s(fp, "# triangles = %d\n", &NumTris); // read # of triangles
	fscanf_s(fp, "Material count = %d\n", &material_count); // read material count

	for (i = 0; i<material_count; i++) {
		fscanf_s(fp, "ambient color %f %f %f\n", &(ambient[i].x), &(ambient[i].y), &(ambient[i].z));
		fscanf_s(fp, "diffuse color %f %f %f\n", &(diffuse[i].x), &(diffuse[i].y), &(diffuse[i].z));
		fscanf_s(fp, "specular color %f %f %f\n", &(specular[i].x), &(specular[i].y), &(specular[i].z));
		fscanf_s(fp, "material shine %f\n", &(shine[i]));
	}
	printf("material count in  <%d material>\n", material_count);

	fscanf_s(fp, "%c", &ch);
	while (ch != '\n') // skip documentation line
		fscanf_s(fp, "%c", &ch);

	// allocate triangles for tri model

	printf("Reading in %s (%d triangles). . .\n", FileName, NumTris);

	Tris = (Triangle*)malloc(NumTris*sizeof(Triangle));//= new Triangle[NumTris];

	//Points = (Vector4f*)malloc(3 * NumTris*sizeof(Vector4f));

	point_float = (float *)malloc(9 * NumTris*sizeof(float));

	//Normals = (Vector3f*)malloc(3 * NumTris*sizeof(Vector3f));

	normal_float = (float *)malloc(9 * NumTris*sizeof(float));

	fn_float = (float *)malloc(9 * NumTris*sizeof(float));
	//ambient k
	amb_float = (float *)malloc(9 * NumTris*sizeof(float));
	//diffuse k
	diff_float = (float *)malloc(9 * NumTris*sizeof(float));
	//specular k
	spec_float = (float *)malloc(9 * NumTris*sizeof(float));
	//shiness k
	shin_float = (float *)malloc(9 * NumTris*sizeof(float));


	for (i = 0; i<NumTris; i++) // read triangles
	{
		fscanf_s(fp, "v0 %f %f %f %f %f %f %d\n",
			&(Tris[i].v0.x), &(Tris[i].v0.y), &(Tris[i].v0.z),
			&(Tris[i].Norm[0].x), &(Tris[i].Norm[0].y), &(Tris[i].Norm[0].z),
			&(color_index[0]));

		/*Points[Index].x = Tris[i].v0.x;
		Points[Index].y = Tris[i].v0.y;
		Points[Index].z = Tris[i].v0.z;
		Points[Index].w = 1.0;

		Normals[Index].x = Tris[i].Norm[0].x;
		Normals[Index].y = Tris[i].Norm[0].y;
		Normals[Index].z = Tris[i].Norm[0].z;*/



		/*Tris[i].color[0] = (unsigned char)(int)(255 * (diffuse[color_index[0]].x));
		Tris[i].color[1] = (unsigned char)(int)(255 * (diffuse[color_index[0]].y));
		Tris[i].color[2] = (unsigned char)(int)(255 * (diffuse[color_index[0]].z));*/

		int colorIndex0 = color_index[0];
		//1
		point_float[pointIndex] = Tris[i].v0.x;
		normal_float[pointIndex] = Tris[i].Norm[0].x;

		amb_float[pointIndex] = ambient[colorIndex0].x;
		diff_float[pointIndex] = diffuse[colorIndex0].x;
		spec_float[pointIndex] = specular[colorIndex0].x;
		shin_float[pointIndex] = shine[colorIndex0];
		pointIndex++;
		//2
		point_float[pointIndex] = Tris[i].v0.y;
		normal_float[pointIndex] = Tris[i].Norm[0].y;

		amb_float[pointIndex] = ambient[colorIndex0].y;
		diff_float[pointIndex] = diffuse[colorIndex0].y;
		spec_float[pointIndex] = specular[colorIndex0].y;
		shin_float[pointIndex] = shine[colorIndex0];
		pointIndex++;
		//3
		point_float[pointIndex] = Tris[i].v0.z;
		normal_float[pointIndex] = Tris[i].Norm[0].z;

		amb_float[pointIndex] = ambient[colorIndex0].z;
		diff_float[pointIndex] = diffuse[colorIndex0].z;
		spec_float[pointIndex] = specular[colorIndex0].z;
		shin_float[pointIndex] = shine[colorIndex0];
		pointIndex++;


		fscanf_s(fp, "v1 %f %f %f %f %f %f %d\n",
			&(Tris[i].v1.x), &(Tris[i].v1.y), &(Tris[i].v1.z),
			&(Tris[i].Norm[1].x), &(Tris[i].Norm[1].y), &(Tris[i].Norm[1].z),
			&(color_index[1]));

		int colorIndex1 = color_index[1];
		//4
		point_float[pointIndex] = Tris[i].v1.x;
		normal_float[pointIndex] = Tris[i].Norm[1].x;

		amb_float[pointIndex] = ambient[colorIndex1].x;
		diff_float[pointIndex] = diffuse[colorIndex1].x;
		spec_float[pointIndex] = specular[colorIndex1].x;
		shin_float[pointIndex] = shine[colorIndex1];
		pointIndex++;
		//5
		point_float[pointIndex] = Tris[i].v1.y;
		normal_float[pointIndex] = Tris[i].Norm[1].y;

		amb_float[pointIndex] = ambient[colorIndex1].y;
		diff_float[pointIndex] = diffuse[colorIndex1].y;
		spec_float[pointIndex] = specular[colorIndex1].y;
		shin_float[pointIndex] = shine[colorIndex1];
		pointIndex++;
		//6
		point_float[pointIndex] = Tris[i].v1.z;
		normal_float[pointIndex] = Tris[i].Norm[1].z;

		amb_float[pointIndex] = ambient[colorIndex1].z;
		diff_float[pointIndex] = diffuse[colorIndex1].z;
		spec_float[pointIndex] = specular[colorIndex1].z;
		shin_float[pointIndex] = shine[colorIndex1];
		pointIndex++;




		fscanf_s(fp, "v2 %f %f %f %f %f %f %d\n",
			&(Tris[i].v2.x), &(Tris[i].v2.y), &(Tris[i].v2.z),
			&(Tris[i].Norm[2].x), &(Tris[i].Norm[2].y), &(Tris[i].Norm[2].z),
			&(color_index[2]));

		int colorIndex2 = color_index[2];
		//7
		point_float[pointIndex] = Tris[i].v2.x;
		normal_float[pointIndex] = Tris[i].Norm[2].x;

		amb_float[pointIndex] = ambient[colorIndex2].x;
		diff_float[pointIndex] = diffuse[colorIndex2].x;
		spec_float[pointIndex] = specular[colorIndex2].x;
		shin_float[pointIndex] = shine[colorIndex2];
		pointIndex++;
		//8
		point_float[pointIndex] = Tris[i].v2.y;
		normal_float[pointIndex] = Tris[i].Norm[2].y;

		amb_float[pointIndex] = ambient[colorIndex2].y;
		diff_float[pointIndex] = diffuse[colorIndex2].y;
		spec_float[pointIndex] = specular[colorIndex2].y;
		shin_float[pointIndex] = shine[colorIndex2];
		pointIndex++;
		//9
		point_float[pointIndex] = Tris[i].v2.z;
		normal_float[pointIndex] = Tris[i].Norm[2].z;

		amb_float[pointIndex] = ambient[colorIndex2].z;
		diff_float[pointIndex] = diffuse[colorIndex2].z;
		spec_float[pointIndex] = specular[colorIndex2].z;
		shin_float[pointIndex] = shine[colorIndex2];
		pointIndex++;

		fscanf_s(fp, "face normal %f %f %f\n", &(Tris[i].face_normal.x), &(Tris[i].face_normal.y),
			&(Tris[i].face_normal.z));
		fn_float[pointIndex - 9] = Tris[i].face_normal.x;
		fn_float[pointIndex - 8] = Tris[i].face_normal.y;
		fn_float[pointIndex - 7] = Tris[i].face_normal.z;

		fn_float[pointIndex - 6] = Tris[i].face_normal.x;
		fn_float[pointIndex - 5] = Tris[i].face_normal.y;
		fn_float[pointIndex - 4] = Tris[i].face_normal.z;

		fn_float[pointIndex - 3] = Tris[i].face_normal.x;
		fn_float[pointIndex - 2] = Tris[i].face_normal.y;
		fn_float[pointIndex - 1] = Tris[i].face_normal.z;

	}

	fclose(fp);
	//drawMeshes();
}

void initPixels(){

	point_float = (float *)malloc(3 * ScreenWidth*ScreenHeight*sizeof(float));
	for (int j = 0; j <ScreenHeight; j++){
		for (int i = 0; i <ScreenWidth; i++){
			point_float[j * ScreenWidth * 3 + i * 3] = (float)i;
			point_float[j * ScreenWidth * 3 + i * 3 + 1] = (float)j;
			point_float[j * ScreenWidth * 3 + i * 3 + 2] = 0;
		}
	}
	eyeposition[1] = 600;
	eyeposition[2] = 300;
	eyeposition[3] = 900;
}

static void AddShader(GLuint ShaderProgram, const char* shaderText, GLenum shaderType)
{
	GLuint ShaderObj = glCreateShader(shaderType);
	if (ShaderObj == 0)
	{
		ErrorOut();
		system("pause");
		exit(1);
	}

	const GLchar* p[1];
	p[0] = shaderText;
	GLint L[1];
	L[0] = strlen(shaderText);

	glShaderSource(ShaderObj, 1, p, L);

	glCompileShader(ShaderObj);

	GLint success;
	glGetShaderiv(ShaderObj, GL_COMPILE_STATUS, &success);
	if (!success) {
		GLchar InfoLog[1024];
		glGetShaderInfoLog(ShaderObj, 1024, NULL, InfoLog);
		fprintf(stderr, "Error compiling shader type %d: '%s'\n", shaderType, InfoLog);
		system("pause");
		exit(1);
	}

	glAttachShader(ShaderProgram, ShaderObj);
}


void CompileShaders()
{
	string vs, fs;
	if (!ReadFile(pVS, vs))
	{
		system("pause");
		exit(1);
	}
	if (!ReadFile(pFS, fs))
	{
		system("pause");
		exit(1);
	}

	GLuint ShaderProgram = glCreateProgram();
	if (0 == ShaderProgram)
	{
		ErrorOut();
		system("pause");
		exit(1);
	}

	AddShader(ShaderProgram, vs.c_str(), GL_VERTEX_SHADER);
	AddShader(ShaderProgram, fs.c_str(), GL_FRAGMENT_SHADER);

	glLinkProgram(ShaderProgram);
	GLint Success = 0;
	GLchar ErrorLog[1024] = { 0 };
	glGetProgramiv(ShaderProgram, GL_LINK_STATUS, &Success);
	if (Success == 0) {
		glGetProgramInfoLog(ShaderProgram, sizeof(ErrorLog), NULL, ErrorLog);
		fprintf(stderr, "Error linking shader program: '%s'\n", ErrorLog);
		system("pause");
		exit(1);
	}


	modelLocation = glGetUniformLocation(ShaderProgram, "ModelViewMatrix");
	projectLocation = glGetUniformLocation(ShaderProgram, "ProjectionMatrix");

	LPLocation = glGetUniformLocation(ShaderProgram, "lightposition");
	EPLocation = glGetUniformLocation(ShaderProgram, "eyeposition");
	AmLocation = glGetUniformLocation(ShaderProgram, "ambient");
	LCLocation = glGetUniformLocation(ShaderProgram, "lightcolor");
	NSLocation = glGetUniformLocation(ShaderProgram, "Ns");
	ATLocation = glGetUniformLocation(ShaderProgram, "attenuation");

	DLLocation = glGetUniformLocation(ShaderProgram, "dlightcolor");

	DyALocation = glGetUniformLocation(ShaderProgram, "dyAmbient");
	DyDLocation = glGetUniformLocation(ShaderProgram, "dyDiffuse");
	DySLocation = glGetUniformLocation(ShaderProgram, "dySpecular");

	DiALocation = glGetUniformLocation(ShaderProgram, "diAmbient");
	DiDLocation = glGetUniformLocation(ShaderProgram, "diDiffuse");
	DiSLocation = glGetUniformLocation(ShaderProgram, "diSpecular");



	glValidateProgram(ShaderProgram);
	glGetProgramiv(ShaderProgram, GL_VALIDATE_STATUS, &Success);
	if (Success == 0) {
		glGetProgramInfoLog(ShaderProgram, sizeof(ErrorLog), NULL, ErrorLog);
		fprintf(stderr, "Error linking shader program: '%s'\n", ErrorLog);
		system("pause");
		exit(1);
	}
	glUseProgram(ShaderProgram);

}

//glPerspective gluLookat
void myReshape(int w, int h){
	/*glViewport(0, 0, (GLsizei)w, (GLsizei)h);

	glMatrixMode(GL_PROJECTION);
	glLoadIdentity();
	gluPerspective(60.0, (GLfloat)w / (GLfloat)h, 0.1, 1000.0);*/

	glEnable(GL_DEPTH_TEST);

	TwWindowSize(w, h);
}

void initVBO()
{
	// Create and populate the buffer objects  
	GLuint vboHandles[2];
	glGenBuffers(2, vboHandles);
	GLuint positionBufferHandle = vboHandles[0];
	GLuint normalBufferHandle = vboHandles[1];



	//加载数据到VBO  
	glBindBuffer(GL_ARRAY_BUFFER, positionBufferHandle);

	//glBufferData(GL_ARRAY_BUFFER, 9 * NumTris * sizeof(float), point_float, GL_STATIC_DRAW);

	glBufferData(GL_ARRAY_BUFFER, 3 * ScreenWidth*ScreenHeight * sizeof(float), point_float, GL_STATIC_DRAW);

	//glBindBuffer(GL_ARRAY_BUFFER, normalBufferHandle);

	//glBufferData(GL_ARRAY_BUFFER, 9 * NumTris * sizeof(float), normal_float, GL_STATIC_DRAW);

	glGenVertexArrays(1, &vaoHandle);
	glBindVertexArray(vaoHandle);

	//调用glVertexAttribPointer之前需要进行绑定操作  
	glBindBuffer(GL_ARRAY_BUFFER, positionBufferHandle);
	glEnableVertexAttribArray(0);//顶点坐标  
	glVertexAttribPointer(0, 2, GL_FLOAT, GL_FALSE, 2 * sizeof(float), (GLvoid *)0);
	//glDisableVertexAttribArray(0);

	//glBindBuffer(GL_ARRAY_BUFFER, normalBufferHandle);
	//glEnableVertexAttribArray(1);//顶点向量
	//glVertexAttribPointer(1, 3, GL_FLOAT, GL_FALSE, 3 * sizeof(float), (GLvoid *)0);
	//glDisableVertexAttribArray(1);

}



void GetCenterData()
{
	float xmin = 1000, xmax = 0, ymin = 1000, ymax = 0, zmin = 1000, zmax = 0;

	for (int i = 0; i < NumTris; i++){
		if (Tris[i].v0.x > xmax)xmax = Tris[i].v0.x;
		if (Tris[i].v0.x < xmin)xmin = Tris[i].v0.x;

		if (Tris[i].v0.y > ymax)ymax = Tris[i].v0.y;
		if (Tris[i].v0.y < ymin)ymin = Tris[i].v0.y;

		if (Tris[i].v0.z > zmax)zmax = Tris[i].v0.z;
		if (Tris[i].v0.z < zmin)zmin = Tris[i].v0.z;

	}
	CenterX = (xmax + xmin)*0.5;
	CenterY = (ymax + ymin)*0.5;
	CenterZ = (zmax + zmin)*0.5;

	eyeposition[0] = CenterX;
	eyeposition[1] = CenterY;
	eyeposition[2] = R + CenterZ;
}


void init(){

	//readDataFromFile(FileName);

	//GetCenterData();

	initPixels();

	GLenum res = glewInit();
	if (res != GLEW_OK) {
		fprintf(stderr, "Error: '%s'\n", glewGetErrorString(res));
		return;
	}

	CompileShaders();

	initVBO();

	glClearColor(0.0f, 0.0f, 0.0f, 0.0f);
}



void TW_CALL setShaderMode(const void *value, void * /*clientData*/)
{
	shaderMode = *static_cast<const int *>(value);
	initVBO();
}

void TW_CALL getShaderMode(void *value, void * /*clientData*/)
{
	*static_cast<int *>(value) = shaderMode;
}

void changeModel(){
	pointIndex = 0;

	if (modelIndex == 1){
		R = 400;
		FileName = "models\\phone.in";
		readDataFromFile(FileName);

		GetCenterData();

		initVBO();
	}
	if (modelIndex == 2){
		R = 4;
		FileName = "models\\cube.in";
		readDataFromFile(FileName);

		GetCenterData();


		initVBO();
	}
	if (modelIndex == 3){
		R = 800;
		FileName = "models\\cow_up.in";
		readDataFromFile(FileName);

		GetCenterData();
		for (int i = 0; i < 9 * NumTris; i++){
			normal_float[i] = -normal_float[i];
		}

		initVBO();
	}
}

void TW_CALL setModelIndex(const void *value, void * /*clientData*/){
	modelIndex = *static_cast<const int *>(value);
	changeModel();
}

void TW_CALL getModelIndex(void *value, void * /*clientData*/){
	*static_cast<int *>(value) = modelIndex;
}


void getUniform(){
	//gluLookAt(eyeposition[0], eyeposition[1], eyeposition[2], CenterX, CenterY, CenterZ, 0.0, 1.0, 0.0);

	//gluLookAt(eyeposition[0], eyeposition[1], eyeposition[2], 0, 0, 0, 0.0, 1.0, 0.0);

	GLfloat modelViewMatrix[16];

	glGetFloatv(GL_MODELVIEW_MATRIX, modelViewMatrix);

	glUniformMatrix4fv(modelLocation, 1, GL_FALSE, modelViewMatrix);

	GLfloat proViewMatrix[16];

	glGetFloatv(GL_PROJECTION_MATRIX, proViewMatrix);

	glUniformMatrix4fv(projectLocation, 1, GL_FALSE, proViewMatrix);

	if (switch3 == true)theSpeed = 0.004;
	if (switch3 == false)theSpeed = 0.0;

	if (switch4 == true)glEnable(GL_DEPTH_TEST);
	if (switch4 == false)glDisable(GL_DEPTH_TEST);

	theta += theSpeed;

	if (Axis == 0){
		theta = 0;
		lightposition[0] = CenterX;
		lightposition[1] = CenterY;
		lightposition[2] = -R + CenterZ;
	}

	if (Axis == 1){
		lightposition[0] = 0 + CenterX;
		lightposition[1] = R*sin(theta) + CenterY;
		lightposition[2] = -R*cos(theta) + CenterZ;
	}
	if (Axis == 2){
		lightposition[0] = R*sin(theta) + CenterX;
		lightposition[1] = 0 + CenterY;
		lightposition[2] = -R*cos(theta) + CenterZ;
	}
	if (Axis == 3){
		lightposition[0] = R*cos(theta) + CenterX;
		lightposition[1] = R*sin(theta) + CenterY;
		lightposition[2] = 0 + CenterZ;
	}
	eyeposition[1] = 600;
	eyeposition[2] = 300;
	eyeposition[3] = 400;

	lightposition[0] = 600;
	lightposition[1] = 300;
	lightposition[2] = -200;

	glUniform3f(LPLocation, lightposition[0], lightposition[1], lightposition[2]);
	glUniform3f(EPLocation, eyeposition[0], eyeposition[1], eyeposition[2]);
	glUniform4f(AmLocation, ambient[0], ambient[1], ambient[2], ambient[3]);
	glUniform4f(LCLocation, dylightcolor[0], dylightcolor[1], dylightcolor[2], dylightcolor[3]);
	glUniform1f(NSLocation, Ns);
	glUniform1f(ATLocation, attenuation);

	glUniform4f(DLLocation, dilightcolor[0], dilightcolor[1], dilightcolor[2], dilightcolor[3]);



	if (switch1 == true){
		glUniform4f(DyALocation, dyAmbient[0], dyAmbient[1], dyAmbient[2], dyAmbient[3]);
		glUniform4f(DyDLocation, dyDiffuse[0], dyDiffuse[1], dyDiffuse[2], dyDiffuse[3]);
		glUniform4f(DySLocation, dySpecular[0], dySpecular[1], dySpecular[2], dySpecular[3]);
	}
	if (switch1 == false){
		glUniform4f(DyALocation, 0, 0, 0, 0);
		glUniform4f(DyDLocation, 0, 0, 0, 0);
		glUniform4f(DySLocation, 0, 0, 0, 0);
	}

	if (switch2 == true){
		glUniform4f(DiALocation, diAmbient[0], diAmbient[1], diAmbient[2], diAmbient[3]);
		glUniform4f(DiDLocation, diDiffuse[0], diDiffuse[1], diDiffuse[2], diDiffuse[3]);
		glUniform4f(DiSLocation, diSpecular[0], diSpecular[1], diSpecular[2], diSpecular[3]);
	}

	if (switch2 == false){
		glUniform4f(DiALocation, 0.0f, 0.0f, 0.0f, 0);
		glUniform4f(DiDLocation, 0.0f, 0.0f, 0.0f, 0);
		glUniform4f(DiSLocation, 0.0f, 0.0f, 0.0f, 0);
	}



	glBindVertexArray(vaoHandle);
	glEnable(GL_CULL_FACE);
	if (switch5){
		glFrontFace(GL_CCW);
	}
	else{
		glFrontFace(GL_CW);
	}
}

GLubyte* imageTex;
GLuint m_textureObj;
float myCx = 200;
bool TheBall = false;
bool TheCube = false;
bool TheCy = false;
bool TheMirror = false;
bool TheCurve = false;
bool TheShadow = false;
bool TheBF = false;
void getTexture(){
	int w = 1200;
	int h = 600;
	imageTex = (GLubyte*)malloc(w*h * 3 * sizeof(GLubyte));
	char *tempTex = (char*)malloc(3 * w*h*sizeof(char));
	//替代下面的计算
	setTheBall(TheBall);
	setTheCube(TheCube);
	setTheCylinder(TheCy);
	setTheMirror(TheMirror);
	setTheCurve(TheCurve);
	setTheShadow(TheShadow);
	setTheBF(TheBF);
	computeRays(1200, 600, tempTex);

	/*for (int y = 0; y < h; y++)
	{
		for (int x = 0; x < w; x++)
		{
			imageTex[y*w * 3 + x * 3 + 0] = tempTex[y*w * 3 + x * 3 + 0];
			imageTex[y*w * 3 + x * 3 + 1] = tempTex[y*w * 3 + x * 3 + 1];
			imageTex[y*w * 3 + x * 3 + 2] = tempTex[y*w * 3 + x * 3 + 2];

		}
	}*/

	glGenTextures(1, &m_textureObj);


	
	glEnable(GL_TEXTURE_2D);
	glBindTexture(GL_TEXTURE_2D, m_textureObj);


	glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB, w, h, 0, GL_RGB, GL_UNSIGNED_BYTE, tempTex);
	//glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB, w, h, 0, GL_RGB, GL_FLOAT, tempTex);

	glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
	glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP);

	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP);
}

int speed = 5;
static void myDisplay()
{
	myCx += speed;
	if (myCx >= 1130||myCx<=70)speed = -speed;
	
	getTexture();
	glClearColor(0.0, 0.0, 0.0, 1.0);
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
	
	glEnable(GL_TEXTURE_2D);
	
	glBindTexture(GL_TEXTURE_2D, m_textureObj);
	glBegin(GL_QUADS);
	float w = 1.0;
	float h = 1.0;
	glTexCoord2f(1.0, 0.0); glVertex3f(w, -h, 0);
	glTexCoord2f(0.0, 0.0); glVertex3f(-w, -h, 0);
	glTexCoord2f(0.0, 1.0); glVertex3f(-w, h, 0);
	glTexCoord2f(1.0, 1.0); glVertex3f(w, h, 0);

	glEnd();


	//glBindVertexArray(0);

	//TwDraw();

	glutSwapBuffers();

	//glFlush();

}

void myMouse(int button, int state, int x, int y){

}


void myKeyboard(unsigned char key, int x, int y){


	if (key == '1'){
		TheBall = !TheBall;
	}
	if (key == '2'){
		TheCube = !TheCube;
	}
	
	if (key == '3'){
		TheCy = !TheCy;
	}
	if (key == '4'){
		TheMirror = !TheMirror;
	}
	if (key == '5'){
		TheCurve = !TheCurve;
	}
	if (key == '6'){
		TheShadow = !TheShadow;
	}
	if (key == '7'){
		TheBF = !TheBF;
	}
}


// Function called at exit
void Terminate(void)
{
	TwTerminate();
}

void DrawTwBar(){
	TwBar *bar; // Pointer to the tweak bar
	//atexit(Terminate);  // Called after glutMainLoop ends

	// Initialize AntTweakBar
	TwInit(TW_OPENGL, NULL);

	glutMouseFunc((GLUTmousebuttonfun)TwEventMouseButtonGLUT);
	// - Directly redirect GLUT mouse motion events to AntTweakBar
	glutMotionFunc((GLUTmousemotionfun)TwEventMouseMotionGLUT);
	// - Directly redirect GLUT mouse "passive" motion events to AntTweakBar (same as MouseMotion)
	glutPassiveMotionFunc((GLUTmousemotionfun)TwEventMouseMotionGLUT);
	// - Directly redirect GLUT key events to AntTweakBar
	glutKeyboardFunc((GLUTkeyboardfun)TwEventKeyboardGLUT);
	// - Directly redirect GLUT special key events to AntTweakBar
	glutSpecialFunc((GLUTspecialfun)TwEventSpecialGLUT);
	// - Send 'glutGetModifers' function pointer to AntTweakBar;
	//   required because the GLUT key event functions do not report key modifiers states.
	TwGLUTModifiersFunc(glutGetModifiers);


	bar = TwNewBar("shaderAtrribue");

	TwDefine(" shaderAtrribue position='950 20' size='200 560' color='96 96 224' "); // change default tweak bar size and color


	
	TwAddVarRW(bar, "Ball", TW_TYPE_BOOLCPP, &TheBall, "");
	TwAddVarRW(bar, "Cube", TW_TYPE_BOOLCPP, &TheCube, "");
	TwAddVarRW(bar, "Cylinder", TW_TYPE_BOOLCPP, &TheCy, "");
	TwAddVarRW(bar, "Mirror", TW_TYPE_BOOLCPP, &TheMirror, "");
	TwAddVarRW(bar, "CurveMirror", TW_TYPE_BOOLCPP, &TheCurve, "");
	TwAddVarRW(bar, "Shadow", TW_TYPE_BOOLCPP, &TheShadow, "");
	TwAddVarRW(bar, "BallReflection", TW_TYPE_BOOLCPP, &TheBF, "");

	
}

void main(int argc, char** argv)
{
	glutInit(&argc, argv);
	glutInitDisplayMode(GLUT_DOUBLE | GLUT_RGB | GLUT_DEPTH);
	glutInitWindowSize(ScreenWidth, ScreenHeight);
	glutInitWindowPosition(100, 100);
	glutCreateWindow("Shader");

	//init();

	glutReshapeFunc(myReshape);

	glutDisplayFunc(myDisplay);

	glutIdleFunc(myDisplay);
	//glutMouseFunc(myMouse);
	glutKeyboardFunc(myKeyboard);	

	//DrawTwBar();

	//glutSetOption(GLUT_ACTION_ON_WINDOW_CLOSE, GLUT_ACTION_GLUTMAINLOOP_RETURNS);   
	glutMainLoop();
	//glutLeaveMainLoop();

}