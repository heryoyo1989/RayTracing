#include "CudaComputing.cuh"
#include "cuda_runtime.h"
#include "device_functions.h"
#include "device_launch_parameters.h"
#include "math.h"


__device__ bool HasTheBall ;
__global__ void setDev_ball(bool dev_ball){
	HasTheBall = dev_ball;
}
void setTheBall(bool Ball){
	setDev_ball << <1, 1 >> >(Ball);
}

__device__ bool HasTheCube ;
__global__ void setDev_cube(bool dev_cube){
	HasTheCube = dev_cube;
}
void setTheCube(bool cube){
	setDev_cube << <1, 1 >> >(cube);
}

__device__ bool HasTheCy ;
__global__ void setDev_cy(bool dev_cy){
	HasTheCy = dev_cy;
}

void setTheCylinder(bool Cy){
	setDev_cy << <1, 1 >> >(Cy);
}

__device__ bool HasTheMirror ;
__global__ void setDev_mirror(bool dev_mirror){
	HasTheMirror = dev_mirror;
}

void setTheMirror(bool mi){
	setDev_mirror << <1, 1 >> >(mi);
}

__device__ bool HasTheCurve;
__global__ void setDev_curve(bool dev_curv){
	HasTheCurve = dev_curv;
}

void setTheCurve(bool cur){
	setDev_curve << <1, 1 >> >(cur);
}

__device__ bool HasTheShadow ;
__global__ void setDev_shadow(bool dev_sha){
	HasTheShadow = dev_sha;
}

void setTheShadow(bool sha){
	setDev_shadow << <1, 1 >> >(sha);
}

__device__ bool HasTheBallFlection;
__global__ void setDev_BF(bool dev_sha){
	HasTheBallFlection = dev_sha;
}

void setTheBF(bool sha){
	setDev_BF<< <1, 1 >> >(sha);
}



__device__ float CyHeight = 250;

__device__ float CubeX = 600;
__device__ float CubeY = 0;
__device__ float CubeZ = -400;

__device__ float CyX = 800;
__device__ float CyY = 0;
__device__ float CyZ = -300;


__device__ bool chekcSolution(float a, float b, float c){
	if ((b*b - 4 * a*c)<0)return false;
	return true;
}

__device__ float getSolution1(float a, float b, float c){
	float rst = -b + sqrt(b*b - 4 * a*c);
	rst = rst / (2 * a);
	return rst;
}

__device__ float getSolution2(float a, float b, float c){
	float rst = -b - sqrt(b*b - 4 * a*c);
	rst = rst / (2 * a);
	return rst;
}

__device__ float dot(float3 a, float3 b){
	float c;
	c = a.x*b.x + a.y*b.y + a.z*b.z;
	return c;
}

__device__ float3 normalize(float3 n){
	float length1 = n.x*n.x + n.y*n.y + n.z*n.z;
	float length = sqrt(length1);

	n.x = n.x / length;
	n.y = n.y / length;
	n.z = n.z / length;
	return n;
}

__device__ float bigger(float a, float b){
	if (a > b)return a;
	return b;
}


__device__ bool IsHitTheCube(float3 s, float3 center, float e){

	float up = center.y + e;
	float down = center.y;
	float left = center.x - e / 2;
	float right = center.x + e / 2;
	float front = center.z + e / 2;
	float back = center.z - e / 2;

	if (s.y <= up&&s.y >= down&&s.x >= left&&s.x <= right&&s.z <= front&&s.z >= back){
		return true;
	}
	return false;

}
//底中心，边长
__device__ float4 HitTheCube(float3 t,float3 d,float3 center,float e){
	float up=center.y+e;
	float down=center.y;
	float left=center.x-e/2;
	float right=center.x+e/2;
	float front=center.z+e/2;
	float back=center.z-e/2;

	if (t.x - d.x * 5 > right&&t.x <= right){
		return(make_float4(t.x - d.x * 2.5, t.y - d.y * 2.5, t.z - d.z * 2.5, 1.0));
	}
	if (t.x - d.x * 5 < left&&t.x >= left){
		return(make_float4(t.x - d.x * 2.5, t.y - d.y * 2.5, t.z - d.z * 2.5, 2.0));
	}
	if (t.y - d.y * 5 > up&&t.y <= up){
		return(make_float4(t.x - d.x * 2.5, t.y - d.y * 2.5, t.z - d.z * 2.5, 3.0));
	}
	if (t.y - d.y * 5 < down&&t.y >= down){
		return(make_float4(t.x - d.x * 2.5, t.y - d.y * 2.5, t.z - d.z * 2.5, 4.0));
	}
	if (t.z - d.z * 5 > front&&t.z <= front){
		return(make_float4(t.x - d.x * 2.5, t.y - d.y * 2.5, t.z - d.z * 2.5, 5.0));
	}
	if (t.z - d.z * 5 < back&&t.z >= back){
		return(make_float4(t.x - d.x * 2.5, t.y - d.y * 2.5, t.z - d.z * 2.5, 7.0));
	}

	return make_float4(0.0, 0.0, 0.0, 0.0);
}

__device__ bool IsHitTheCylinder(float3 s,float3 c,float r,float h){
	if ((s.x - c.x)*(s.x - c.x) + (s.z - c.z)*(s.z - c.z) <= r*r&&s.y <= h&&s.y>=0){
		return true;
	}
	return false;
}
//底中心，半径，高度
__device__ float4 HitTheCylinder(float3 t,float3 d,float3 c,float r,float h){
	if(t.y <= h&&t.y - d.y * 5>h){
		return make_float4(t.x, t.y, t.z, 3.0);
	}
	if ((t.x - c.x)*(t.x - c.x) + (t.z - c.z)*(t.z - c.z) <= r*r &&
		(t.x - d.x * 5 - c.x)*(t.x - d.x * 5 - c.x) + (t.z - d.z * 5 - c.z)*(t.z - d.z * 5 - c.z) > r*r){
		return make_float4(t.x, t.y, t.z, 9.0);
	}
}


__device__ float4 rayFromShpere(float3 s, float3 dir){
	float4 rst;
	rst.x = 0.0;
	rst.y = 0.0;
	rst.z = 0.0;
	rst.w = 7.0;


	float k;

	float x;
	float y;
	float z;

	float3 d = normalize(dir);


	float R = 140;

	float3 t = s;

	for (int i = 0; i < 100; i++){
		t.x += d.x * 5;
		t.y += d.y * 5;
		t.z += d.z * 5;

		if (HasTheCube&&IsHitTheCube(t, make_float3(CubeX,CubeY,CubeZ), 200)){
			return HitTheCube(t, d, make_float3(CubeX, CubeY, CubeZ), 200);
		}
		if (HasTheCy&&IsHitTheCylinder(t, make_float3(CyX, CyY, CyZ), 100, CyHeight)){
			return HitTheCylinder(t, d, make_float3(CyX, CyY, CyZ), 100, CyHeight);
		}
		//z = 0; 7.0
		if (t.z >= 0 && t.z - 5 * d.z < 0){
			rst.x = t.x - d.x*2.5;
			rst.y = t.y - d.y*2.5;
			rst.z = t.z - d.z*2.5;
			rst.w = 7.0;
			return rst;
		}

		//z=-600 5.0

		//x = 0; 1.0
		if (t.x <= 0 && t.x - 5 * d.x > 0){
			rst.x = t.x - d.x*2.5;
			rst.y = t.y - d.y*2.5;
			rst.z = t.z - d.z*2.5;
			rst.w = 1.0;
			return rst;
		}


		//x = 1200; 2.0
		if (t.x >= 1200 && t.x - 5 * d.x < 1200){
			rst.x = t.x - d.x*2.5;
			rst.y = t.y - d.y*2.5;
			rst.z = t.z - d.z*2.5;
			rst.w = 2.0;
			return rst;
		}


		//y = 0;  3.0
		if (t.y <= 0 && t.y - 5 * d.y > 0){
			rst.x = t.x - d.x*2.5;
			rst.y = t.y - d.y*2.5;
			rst.z = t.z - d.z*2.5;
			rst.w = 3.0;
			return rst;
		}


		//y = 600;  4.0
		if (t.y >= 600 && t.y - 5 * d.y < 600){
			rst.x = t.x - d.x*2.5;
			rst.y = t.y - d.y*2.5;
			rst.z = t.z - d.z*2.5;
			rst.w = 4.0;
			return rst;
		}


	}

	return rst;
}

__device__ bool IsHitTheBall(float3 e, float3 p, float3 cen, float R){
	float a = (p.x - e.x)*(p.x - e.x) + (p.y - e.y)*(p.y - e.y) + (p.z - e.z)*(p.z - e.z);
	float b = 2 * ((p.x - e.x)*(e.x - cen.x) + (p.y - e.y)*(e.y - cen.y) + (p.z - e.z)*(e.z - cen.z));
	float c = (e.x - cen.x)*(e.x - cen.x) + (e.y - cen.y)*(e.y - cen.y) + (e.z - cen.z)*(e.z - cen.z) - R*R;
	if (chekcSolution(a, b, c) == true){
		return true;
	}
	return false;
}

__device__ float4 HitTheBall(float3 e, float3 p,float3 cen,float R){
	float4 rst;
	rst.x = 0.0;
	rst.y = 0.0;
	rst.z = 0.0;
	rst.w = 0.0;

	float k;

	float a = (p.x - e.x)*(p.x - e.x) + (p.y - e.y)*(p.y - e.y) + (p.z - e.z)*(p.z - e.z);
	float b = 2 * ((p.x - e.x)*(e.x - cen.x) + (p.y - e.y)*(e.y - cen.y) + (p.z - e.z)*(e.z - cen.z));
	float c = (e.x - cen.x)*(e.x - cen.x) + (e.y - cen.y)*(e.y - cen.y) + (e.z - cen.z)*(e.z - cen.z) - R*R;

	//hit the ball
	k = getSolution1(a, b, c);
	rst.x = (p.x - e.x)*k + e.x;
	rst.y = (p.y - e.y)*k + e.y;
	rst.z = (p.z - e.z)*k + e.z;
	rst.w = 6.0;
	float3 L1 = make_float3((p.x - rst.x), (p.y - rst.y), (p.z - rst.z));
	L1 = normalize(L1);
	float3 N = make_float3((rst.x - cen.x), (rst.y - cen.y), (rst.z - cen.z));
	N = normalize(N);
	float3 L2 = make_float3(-2 * dot(L1, N)*N.x + L1.x, -2 * dot(L1, N)*N.y + L1.y, -2 * dot(L1, N)*N.z + L1.z);
	//有所选择
	if (HasTheBallFlection)return rayFromShpere(make_float3(rst.x, rst.y, rst.z), L2);
	return rst;
	
}

__device__ float4 HitTheMirror(float3 e, float3 p, float3 cen){
	float4 rst;
	rst.x = 0.0;
	rst.y = 0.0;
	rst.z = 0.0;
	rst.w = 7.0;


	float k;

	float x;
	float y;
	float z;



	float R = 140;

	if (HasTheBall&&IsHitTheBall(e, p, cen, R) == true){
		return HitTheBall(e, p, cen, R);
	}

	float3 d = normalize(make_float3(p.x - e.x, p.y - e.y, p.z - e.z));
	float3 t = p;
	for (int i = 0; i < 200; i++){
		t = make_float3(t.x + d.x * 5, t.y + d.y * 5, t.z + d.z * 5);
		if (HasTheCube&&IsHitTheCube(t, make_float3(CubeX, CubeY, CubeZ), 200)){
			return HitTheCube(t, d, make_float3(CubeX, CubeY, CubeZ), 200);
		}
		if (HasTheCy&&IsHitTheCylinder(t, make_float3(CyX, CyY, CyZ), 100, CyHeight)){
			return HitTheCylinder(t, d, make_float3(CyX, CyY, CyZ), 100, CyHeight);
		}
	}

	z = 0;
	k = (z - e.z) / (p.z - e.z);
	x = (p.x - e.x)*k + e.x;
	y = (p.y - e.y)*k + e.y;
	if (x >= 0 && x <= 1200 && y >= 0 && y <= 600){
		rst.x = x;
		rst.y = y;
		rst.z = z;
		rst.w = 7.0;

		return rst;
	}

	x = 0;
	k = (x - e.x) / (p.x - e.x);
	y = (p.y - e.y)*k + e.y;
	z = (p.z - e.z)*k + e.z;
	if (y >= 0 && y <= 600 && z >= -600 && z <= 0){
		rst.x = x;
		rst.y = y;
		rst.z = z;
		rst.w = 1.0;
		return rst;
	}

	x = 1200;
	k = (x - e.x) / (p.x - e.x);
	y = (p.y - e.y)*k + e.y;
	z = (p.z - e.z)*k + e.z;
	if (y >= 0 && y <= 600 && z >= -600 && z <= 0){
		rst.x = x;
		rst.y = y;
		rst.z = z;
		rst.w = 2.0;
		return rst;
	}

	y = 0;
	k = (y - e.y) / (p.y - e.y);
	x = (p.x - e.x)*k + e.x;
	z = (p.z - e.z)*k + e.z;
	if (x >= 0 && x <= 1200 && z >= -600 && z <= 0){
		rst.x = x;
		rst.y = y;
		rst.z = z;
		rst.w = 3.0;
		return rst;
	}

	y = 600;
	k = (y - e.y) / (p.y - e.y);
	x = (p.x - e.x)*k + e.x;
	z = (p.z - e.z)*k + e.z;
	if (x >= 0 && x <= 1200 && z >= -600 && z <= 0){
		rst.x = x;
		rst.y = y;
		rst.z = z;
		rst.w = 4.0;
		return rst;
	}


	return rst;
}

__device__ float4 HitCurveMirror(float3 s, float3 d,float3 ball){
	float4 rst;
	rst.x = 0.0;
	rst.y = 0.0;
	rst.z = 0.0;
	rst.w = 7.0;


	float3 L1;
	float3 N;
	float3 L2;

	float3 t = s;
	d = normalize(d);
	//hit poin
	for (int i = 0; i < 200; i++){
		t.x += d.x * 5;
		t.y += d.y * 5;
		t.z += d.z * 5;
		if (t.y>500)return(make_float4(t.x, t.y, t.z, 4.0));
		if ((t.x - 600)*(t.x - 600) + (t.z + 225)*(t.z + 225) >= 625 * 625 && (t.x - d.x * 5 - 600)*(t.x - d.x * 5 - 600) + (t.z - d.z * 5 + 225)*(t.z - d.z * 5 + 225) < 625 * 625){
			L1 = make_float3(-d.x, -d.y, -d.z);
			L1 = normalize(L1);
			N = make_float3(600 - t.x, 0,-225 - t.z);
			N = normalize(N);
			L2 = make_float3(2 * dot(L1, N)*N.x - L1.x, 2 * dot(L1, N)*N.y - L1.y, 2 * dot(L1, N)*N.z - L1.z);
			
			return HitTheMirror(t, make_float3(t.x + L2.x, t.y + L2.y, t.z + L2.z), ball);
			break;
		}
	}


	return rst;
}

__device__ float4 HitTheWall(float3 e,float3 p,float3 cen){
	float4 rst;
	rst.x = 0.0;
	rst.y = 0.0;
	rst.z = 0.0;
	rst.w = 0.0;

	float x;
	float y;
	float z;

	float k;

	z = -600;
	k = (z - e.z) / (p.z - e.z);
	x = (p.x - e.x)*k + e.x;
	y = (p.y - e.y)*k + e.y;
	if (x >= 0 && x <= 1200 && y >= 0 && y <= 600){
		
		if (x >= 100 && x <= 1100 && y >= 100 && y <= 550){
			if (HasTheMirror){
				if (HasTheCurve){
					return HitCurveMirror(make_float3(p.x, p.y, p.z), make_float3(p.x - e.x, p.y - e.y, p.z - e.z), make_float3(cen.x, cen.y, cen.z));
				}
				return HitTheMirror(make_float3(e.x,e.y,-1200-e.z), make_float3(x,y,z), cen);
			}
			if (!HasTheMirror){
				rst.x = x;
				rst.y = y;
				rst.z = z;
				rst.w = 5.0;
				return rst;
			}
			
		}
		else{
			rst.x = x;
			rst.y = y;
			rst.z = z;
			rst.w = 5.0;
			return rst;
		}
	}

	x = 0;
	k = (x - e.x) / (p.x - e.x);
	y = (p.y - e.y)*k + e.y;
	z = (p.z - e.z)*k + e.z;
	if (y >= 0 && y <= 600 && z >= -600 && z <= 0){
		rst.x = x;
		rst.y = y;
		rst.z = z;
		rst.w = 1.0;
		return rst;
	}

	x = 1200;
	k = (x - e.x) / (p.x - e.x);
	y = (p.y - e.y)*k + e.y;
	z = (p.z - e.z)*k + e.z;
	if (y >= 0 && y <= 600 && z >= -600 && z <= 0){
		rst.x = x;
		rst.y = y;
		rst.z = z;
		rst.w = 2.0;
		return rst;
	}

	y = 0;
	k = (y - e.y) / (p.y - e.y);
	x = (p.x - e.x)*k + e.x;
	z = (p.z - e.z)*k + e.z;
	if (x >= 0 && x <= 1200 && z >= -600 && z <= 0){
		rst.x = x;
		rst.y = y;
		rst.z = z;
		rst.w = 3.0;
		return rst;
	}

	y = 600;
	k = (y - e.y) / (p.y - e.y);
	x = (p.x - e.x)*k + e.x;
	z = (p.z - e.z)*k + e.z;
	if (x >= 0 && x <= 1200 && z >= -600 && z <= 0){
		rst.x = x;
		rst.y = y;
		rst.z = z;
		rst.w = 4.0;
		if ((x - 600)*(x - 600) + (z + 300)*(z + 300)<100 * 100)rst.w = 8.0;
		return rst;
	}


	return rst;
}

__device__ float4 getHitPoint(float3 e, float3 p, float3 cen){
	
	
    //hit the ball
	float R = 140;

	if (IsHitTheBall(e, p, cen, R) == true && HasTheBall==true){
		return HitTheBall(e, p, cen, R);
	}
	//hit the cube and the cylinder
	float3 d = normalize(make_float3(p.x-e.x,p.y-e.y,p.z-e.z));
	float3 t = p;
	for (int i = 0; i < 100; i++){
		t = make_float3(t.x + d.x * 5, t.y + d.y * 5, t.z + d.z * 5);
		if (HasTheCube&&IsHitTheCube(t, make_float3(CubeX, CubeY, CubeZ), 200)){
			return HitTheCube(t, d, make_float3(CubeX, CubeY, CubeZ), 200);
		}
		if (HasTheCy&&IsHitTheCylinder(t, make_float3(CyX, CyY, CyZ), 100, CyHeight)){
			return HitTheCylinder(t, d, make_float3(CyX, CyY, CyZ), 100, CyHeight);
		}
	}

	

	//hit the wall
	
	return HitTheWall(e, p, cen);
}

__device__ float3 getNormal(float4 p,float cx,float cy,float cz){
	float3 N;
	

	if (p.w != 0.0){
		if (p.w == 6.0){
			N = make_float3(p.x - cx, p.y - cy, p.z - cz);
		}
		if (p.w == 5.0){
			N = make_float3(0, 0, 1);
		}
		if (p.w == 1.0){
			N = make_float3(1, 0, 0);
		}
		if (p.w == 2.0){
			N = make_float3(-1, 0, 0);
		}
		if (p.w == 3.0){
			N = make_float3(0, 1, 0);
		}
		if (p.w == 4.0){
			N = make_float3(0, -1, 0);
		}
		if (p.w == 7.0){
			N = make_float3(0, 0, -1);
		}
		if (p.w == 9.0){
			N = make_float3(p.x-800,0,p.z+300);
		}
	}

		N = normalize(N);
		return N;
}



__device__ float4 getColor(float4 p,float3 n,float ex,float ey,float ez){
	
	


	float dist = (p.x - ex)*(p.x - ex) + (p.y - ey)*(p.y - ey) + (p.z - ez)*(p.z - ez);
	dist /= 1200000;
	if (dist < 1)dist = 1;
	
	//翻译成cuda dyD,dyS,dyA 整成参数
	float4 kd = make_float4(0.5, 0.5, 0.5, 1.0);

	float4 ks = make_float4(0.0, 0.0, 0.1, 1.0);

	float4 ka = make_float4(0.1, 0.1, 0.1, 1.0);


	
	float4 dyDiffuse = make_float4(1.0, 1.0, 1.0, 1.0);

	float4 dySpecular = make_float4(0.5, 0.5, 0.5, 1.0);

    float4 dyAmbient = make_float4(0.2, 0.2, 0.2, 1.0);


	

	if (p.w == 6.0){//the ball
		kd = make_float4(0.5, 0.5, 0.9, 1.0);

		ks = make_float4(0.0, 0.0, 0.0, 1.0);

		ka = make_float4(0.5, 0.5, 0.5, 1.0);
	}
	if (p.w == 5.0){//back wall
		kd = make_float4(0.0, 0.6, 0.0, 1.0);

		ks = make_float4(0.9, 0.0, 0.0, 1.0);

		ka = make_float4(0.05, 0.0, 0.0, 1.0);
	}
	if (p.w == 1.0){//left wall
		kd = make_float4(0.5, 0.0, 0.0, 1.0);

		ks = make_float4(0.1, 0.0, 0.0, 1.0);

		ka = make_float4(0.9, 0.9, 0.1, 1.0);
	}
	if (p.w == 2.0){//right wall
		kd = make_float4(0.0, 0.0, 0.5, 1.0);

		ks = make_float4(0.1, 0.0, 0.0, 1.0);

		ka = make_float4(0.9, 0.9, 0.1, 1.0);
	}
	if (p.w == 3.0){//floor
		kd = make_float4(0.0, 0.5, 0.5, 1.0);

		ks = make_float4(1.0, 1.0, 1.0, 1.0);

		ka = make_float4(0.9, 0.9, 0.1, 1.0);
	}
	if (p.w == 4.0){//ceil
		kd = make_float4(0.0, 0.5, 0.5, 1.0);

		ks = make_float4(1.0, 1.0, 1.0, 1.0);

		ka = make_float4(0.9, 0.9, 0.1, 1.0);
	}
	if (p.w == 7.0){//front wall
		kd = make_float4(0.5, 0.0, 0.7, 1.0);

		ks = make_float4(0.4, 0.4, 0.4, 1.0);

		ka = make_float4(0.4, 0.4, 0.4, 1.0);
	}

	if (p.w == 9.0){
		kd = make_float4(0.0, 1.0, 1.0, 1.0);

		ks = make_float4(0.4, 0.4, 0.4, 1.0);

		ka = make_float4(0.4, 0.4, 0.4, 1.0);
	}
	

	float3 V = normalize(make_float3(ex - p.x, ey - p.y, ez - p.z));


	float3 L = normalize(make_float3(600 - p.x, 600 - p.y, -300 - p.z));

	

	float3 H = normalize(make_float3(V.x + L.x, V.y + L.y, V.z + L.z));

	float4 ambient1 = make_float4(ka.x*dyAmbient.x , ka.y*dyAmbient.y , ka.z*dyAmbient.z , ka.w*dyAmbient.w );
	
	float max1 = bigger(dot(n, L), 0.0f);
	float4 diffuse1 = make_float4(kd.x*max1*dyDiffuse.x / dist, kd.y*max1*dyDiffuse.y / dist, kd.z*max1*dyDiffuse.z / dist, kd.w*max1*dyDiffuse.w / dist);
		
	float max2 = powf(bigger(dot(n, H), 0.0f),10.0f);
	float4 specular1 = make_float4(ks.x*max2*dySpecular.x,ks.y*max2*dySpecular.y, ks.z*max2*dySpecular.z, ks.w*max2*dySpecular.w);
	
	if(dot(n,L)<0) specular1 =make_float4(0.0,0.0,0.0,0.0);






	float4 color1 = make_float4(ambient1.x + diffuse1.x+specular1.x, 
		ambient1.y + diffuse1.y + specular1.y,
		ambient1.z + diffuse1.z + specular1.z,
		ambient1.w + diffuse1.w + specular1.w);

	if (p.w == 8.0){
		color1 = make_float4(1.0, 1.0, 0.0, 1.0);
	}

	return color1;
}

__device__ bool shadowRay(float3 s, float3 e, float3 center, float R){
	int divide = 100;
	float divX = (e.x - s.x) / divide;
	float divY = (e.y - s.y) / divide;
	float divZ = (e.z - s.z) / divide;
	float3 t = s;
	for (int i = 0; i < divide; i++){
		t.x += divX;
		t.y += divY;
		t.z += divZ;
		if (HasTheBall&&((t.x - divX - center.x)*(t.x - divX - center.x) + (t.y - divY - center.y)*(t.y - divY - center.y) + (t.z - divZ - center.z)*(t.z - divZ - center.z) > R*R) && ((t.x - center.x)*(t.x - center.x) + (t.y - center.y)*(t.y - center.y) + (t.z - center.z)*(t.z - center.z) <= R*R)){
			return true;
			break;
		}
		if (HasTheCube&&IsHitTheCube(t, make_float3(CubeX, CubeY, CubeZ), 200) == true){
			return true;
			break;
		}
		if (HasTheCy&&IsHitTheCylinder(t, make_float3(CyX, CyY, CyZ), 100, CyHeight)){
			return true;
			break;
		}
	}
	return false;
}

//global
__global__ void computeSingleRay(char* tex){
	//vec4 temp = getHitPoint(Ex, Ey, Ez, vPosition.x, vPosition.y, vPosition.z);
	//width height 应该是参数
	//position=thread.x
	//线程代表着位置
	//int j = threadIdx.x;
	//int i = blockIdx.x;
	
	unsigned int i = blockIdx.x*blockDim.x + threadIdx.x;
	unsigned int j = blockIdx.y*blockDim.y + threadIdx.y;

	float Ex = 600;
	float Ey = 300;
	float Ez = 800;
	
	float Cx = 200;
	float Cy = 300;
	float Cz = -350;

	float3 E = make_float3(Ex, Ey, Ez);
	float3 P = make_float3(i, j, 0);
	float3 C = make_float3(Cx,Cy, Cz);
	//float Cx = 200;
	

//计算出hit 的位置 float4
	float4 position = getHitPoint(E,P,C);

//根据位置算出normal	
	float3 normal = getNormal(position,Cx,Cy,Cz);
//由normal算出颜色 vec4
	float4 color = getColor(position, normal,Ex,Ey,Ez);
	
	float3 p = make_float3(position.x, position.y, position.z);
	float3 e = make_float3(600, 600, -300);
	float3 c = make_float3(Cx, Cy, Cz);
	
	if (HasTheShadow&&shadowRay(p, e, c, 140) && position.w != 6.0)color = make_float4(color.x*0.2, color.y*0.2, color.z*0.2, 1);

	tex[j * 1200 * 3 + i * 3] = color.x*255;
	tex[j * 1200 * 3 + i * 3 + 1] = color.y*255;
	tex[j * 1200 * 3 + i * 3 + 2] = color.z*255;
}

//1200*600 size, Ex Ey Ez
void computeRays(int width,int height,char *tex){

	char * dev_Tex;

	cudaMalloc((char**)&dev_Tex, 3 * width * height * sizeof(char));

	dim3 block(8, 8, 1);
	dim3 grid(width/ block.x, height / block.y, 1);
	
	computeSingleRay << <grid, block >> >(dev_Tex);

	cudaMemcpy(tex, dev_Tex, 3 * width * height * sizeof(char), cudaMemcpyDeviceToHost);

	cudaFree(dev_Tex);
}


