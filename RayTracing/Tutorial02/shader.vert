#version 330 

layout (location = 0)in vec3 vPosition;

layout (location = 1)in vec3 vNormal;

layout (location = 2)in vec3 ka;//material ambient

layout (location = 3)in vec3 kd;//material diffuse

layout (location = 4)in vec3 ks;//material specular

layout (location = 5)in vec3 shine;//material shiness


/*in vec3 vPosition;

in vec3 vNormal;

in vec3 ka;//material ambient

in vec3 kd;//material diffuse

in vec3 ks;//material specular

in vec3 shine;//material shiness*/


//face normal

out vec4 color;

uniform mat4 ModelViewMatrix;

uniform mat4 ProjectionMatrix;



uniform vec3 lightposition;//光源位置

uniform vec3 eyeposition;//相机位置







uniform float Ns;//高光系数

uniform float attenuation;//光线的衰减系数



uniform vec4 ambient;//环境光颜色

uniform vec4 lightcolor;//光源颜色


uniform vec4 dyAmbient;

uniform vec4 dyDiffuse;

uniform vec4 dySpecular;


uniform vec4 dlightcolor;//second light color

uniform vec4 diAmbient;


uniform vec4 diDiffuse;

uniform vec4 diSpecular;

float cx=200;
float cy=300;
float cz=-50;

float Ex=600;
float Ey=300;
float Ez=1000;

float Sphere(float x,float y,float z){
    float rst=0;
	rst=(x-200)*(x-200)+(y-300)*(y-300)+(z+400)*(z+400)-100*100;
	return rst;
}

bool chekcSolution(float a,float b,float c){
    if((b*b-4*a*c)<0)return false;
	return true;
}

float getSolution1(float a,float b,float c){
    float rst=-b+sqrt(b*b-4*a*c);
	rst=rst/(2*a);
	return rst;
}

float getSolution2(float a,float b,float c){
    float rst=-b-sqrt(b*b-4*a*c);
	rst=rst/(2*a);
	return rst;
}

vec4 getHitPoint2(float ex,float ey,float ez,float px,float py,float pz){
    vec4 rst=vec4(0.0,0.0,0.0,7.0);

	

	float k;

	float x;
	float y;
	float z;

	float R=150;

	float a=(px-ex)*(px-ex)+(py-ey)*(py-ey)+(pz-ez)*(pz-ez);
	float b=2*((px-ex)*(ex-cx)+(py-ey)*(ey-cy)+(pz-ez)*(ez-cz));
	float c=(ex-cx)*(ex-cx)+(ey-cy)*(ey-cy)+(ez-cz)*(ez-cz)-R*R;


	if(chekcSolution(a,b,c)==true){
	  k=getSolution2(a,b,c);
	  rst.x=(px-ex)*k+ex;
	  rst.y=(py-ey)*k+ey;
	  rst.z=(pz-ez)*k+ez;
	  rst.w=6.0;
	  return rst;
	}

	z=0;
	k=(z-ez)/(pz-ez);
	x=(px-ex)*k+ex;
	y=(py-ey)*k+ey;
	if(x>=0 && x<=1200 && y>=0 && y<=600){
	   rst.x=x;
	   rst.y=y;
	   rst.z=z;
	   rst.w=7.0;
	   
	   return rst;
	}

	x=0;
	k=(x-ex)/(px-ex);
	y=(py-ey)*k+ey;
	z=(pz-ez)*k+ez;
	if(y>=0 && y<=600 && z>=-600 && z<=0){
	   rst.x=x;
	   rst.y=y;
	   rst.z=z;
	   rst.w=1.0;
	   return rst;
	}

	x=1200;
	k=(x-ex)/(px-ex);
	y=(py-ey)*k+ey;
	z=(pz-ez)*k+ez;
	if(y>=0 && y<=600 && z>=-600 && z<=0){
	   rst.x=x;
	   rst.y=y;
	   rst.z=z;
	   rst.w=2.0;
	   return rst;
	}

	y=0;
	k=(y-ey)/(py-ey);
	x=(px-ex)*k+ex;
	z=(pz-ez)*k+ez;
	if(x>=0 && x<=1200 && z>=-600 && z<=0){
	   rst.x=x;
	   rst.y=y;
	   rst.z=z;
	   rst.w=3.0;
	   return rst;
	}

	y=600;
	k=(y-ey)/(py-ey);
	x=(px-ex)*k+ex;
	z=(pz-ez)*k+ez;
	if(x>=0 && x<=1200 && z>=-600 && z<=0){
	   rst.x=x;
	   rst.y=y;
	   rst.z=z;
	   rst.w=4.0;
	   return rst;
	}
	
	
	return rst;
}

vec4 getHitPoint(float ex,float ey,float ez,float px,float py,float pz){
    vec4 rst=vec4(0.0,0.0,0.0,0.0);

	

	float k;

	float x;
	float y;
	float z;

	float R=150;

	float a=(px-ex)*(px-ex)+(py-ey)*(py-ey)+(pz-ez)*(pz-ez);
	float b=2*((px-ex)*(ex-cx)+(py-ey)*(ey-cy)+(pz-ez)*(ez-cz));
	float c=(ex-cx)*(ex-cx)+(ey-cy)*(ey-cy)+(ez-cz)*(ez-cz)-R*R;


	if(chekcSolution(a,b,c)==true){
	  k=getSolution1(a,b,c);
	  rst.x=(px-ex)*k+ex;
	  rst.y=(py-ey)*k+ey;
	  rst.z=(pz-ez)*k+ez;
	  rst.w=6.0;
	  return rst;
	}

	z=-600;
	k=(z-ez)/(pz-ez);
	x=(px-ex)*k+ex;
	y=(py-ey)*k+ey;
	if(x>=0 && x<=1200 && y>=0 && y<=600){
		if(x>=100 && x<=1100 && y>=100 && y<=550){
	   
	   
			return getHitPoint2(ex,ey,-1200-ez,x,y,z);
	   //return getHitPoint2(x,y,z,ex,ey,-1200-ez);
		}else{
			rst.x=x;
			 rst.y=y;
			 rst.z=z;
			 rst.w=5.0;
			 return rst;
		}
	}

	x=0;
	k=(x-ex)/(px-ex);
	y=(py-ey)*k+ey;
	z=(pz-ez)*k+ez;
	if(y>=0 && y<=600 && z>=-600 && z<=0){
	   rst.x=x;
	   rst.y=y;
	   rst.z=z;
	   rst.w=1.0;
	   return rst;
	}

	x=1200;
	k=(x-ex)/(px-ex);
	y=(py-ey)*k+ey;
	z=(pz-ez)*k+ez;
	if(y>=0 && y<=600 && z>=-600 && z<=0){
	   rst.x=x;
	   rst.y=y;
	   rst.z=z;
	   rst.w=2.0;
	   return rst;
	}

	y=0;
	k=(y-ey)/(py-ey);
	x=(px-ex)*k+ex;
	z=(pz-ez)*k+ez;
	if(x>=0 && x<=1200 && z>=-600 && z<=0){
	   rst.x=x;
	   rst.y=y;
	   rst.z=z;
	   rst.w=3.0;
	   return rst;
	}

	y=600;
	k=(y-ey)/(py-ey);
	x=(px-ex)*k+ex;
	z=(pz-ez)*k+ez;
	if(x>=0 && x<=1200 && z>=-600 && z<=0){
	   rst.x=x;
	   rst.y=y;
	   rst.z=z;
	   rst.w=4.0;
	   if((x-600)*(x-600)+(z+300)*(z+300)<100*100)rst.w=8.0;
	   return rst;
	}
	
	
	return rst;
}



vec3 getNormal(){
   return vec3(1,1,1);
}

void main()
{
		mat4 ProjectModelMatrix= ProjectionMatrix * ModelViewMatrix ;

        mat4 NormalMatrix = inverse(ModelViewMatrix);


		//gl_Position = ProjectModelMatrix * vec4(vPosition.x,vPosition.y,1.0,1.0);

		gl_Position = vec4(-1.0+vPosition.x/600,-1.0+vPosition.y/300,vPosition.z,1.0);

        color=vec4(0.0,0.0,1.0,1.0);

		/*********************************************************************/
	    /*vec4 temp=getHitPoint(Ex,Ey,Ez,vPosition.x,vPosition.y,vPosition.z);
				 
		 if(temp.w!=0.0){
			vec3 N;

			vec3 kd=vec3(1.0,1.0,1.0);

			vec3 ks=vec3(1.0,1.0,1.0);

			vec3 ka=vec3(1.0,1.0,1.0);

			if(temp.w==6.0){
				N=vec3(temp.x-cx,temp.y-cy,temp.z-cz);
				kd=vec3(0.5,0.5,0.5);

				ks=vec3(0.5,0.5,0.5);

				ka=vec3(0.5,0.5,0.5);
			}
			if(temp.w==5.0){
				N=vec3(0,0,1);
				kd=vec3(0.9,0.9,0.9);

				ks=vec3(0.9,0.9,0.9);

				ka=vec3(0.9,0.9,0.9);
			}
			if(temp.w==1.0){
				N=vec3(1,0,0);
			}
			if(temp.w==2.0){
				N=vec3(-1,0,0);
			}
			if(temp.w==3.0){
			    N=vec3(0,1,0);
			}
			if(temp.w==4.0){
			    N=vec3(0,-1,0);
			}
			if(temp.w==7.0){
			    N=vec3(0,0,-1);
				kd=vec3(0.4,0.4,0.4);

				ks=vec3(0.4,0.4,0.4);

				ka=vec3(0.4,0.4,0.4);
			}

			 N=normalize(N);

			 vec3 V = normalize( vec3(temp.x,temp.y,temp.z) - vec3(Ex,Ey,Ez));


			 /////////////////////////////////////// first light

			 vec3 L = -normalize( vec3(temp.x,temp.y,temp.z) - vec3(800,600,-400));

		     vec3 H = normalize(V + L);

		
		//翻译成cuda
		     vec4 diffuse1 = vec4(kd,1.0) * dyDiffuse * max(dot(N , L) , 0.0);

		     vec4 specular1 = vec4(ks,1.0) * dySpecular * pow(max(dot(N , H) , 0) , 1.0) ;

			 vec4 ambient1 = vec4(ka,1.0) * dyAmbient;

			 

		     if(dot(N,L)<0) specular1 = vec4(0.0,0.0,0.0,0.0);

			 vec4 color1 = specular1 + diffuse1 + ambient1;
			 if(temp.w==8.0){
			     color1=vec4(1.0,1.0,0.0,1.0);
			 }

      
			 /////////////////////////////////////// second light
			 vec3 L2 = normalize(vec3 (0,1,1));
	
			 vec3 H2 = normalize(V + L2);

		
			 vec4 diffuse2 = vec4(0.5,0.5,0.5,1.0) * diDiffuse * max(dot(N , L2), 0);

			 vec4 specular2 = vec4(0.5,0.5,0.5,1.0) * diSpecular * pow(max(dot(N , H2), 0), 1.0);

			 vec4 ambient2 = vec4(0.5,0.5,0.5,1.0) * diAmbient;

			 if(dot( N , L2 )<0)specular2=vec4(0.0,0.0,0.0,0.0);


			 vec4 color2 = diffuse2 + specular2 + ambient2;


			 /////////////////////////////////////////////////////   Final
        
			 vec4 globalAmbient = vec4(0.0,0.0,0.0,1.0) ;*/

			 color = vec4(0,0,1,1);
		// }

		     
				 
		 //if(temp.w==0.0)color = vec4(0,0,0,1);

			
}



























/*
vec3 ECPosition = vec3(gl_ModelViewMatrix * gl_Vertex);
vec3 N = normalize(gl_NormalMatrix * gl_Normal);
vec3 L = normalize(lightposition - ECPosition);
vec3 V = normalize(eyeposition - ECPosition);
vec3 H = normalize(V + L);

vec3 diffuse = lightcolor * max(dot(N , L) , 0);
vec3 specular = lightcolor * pow(max(dot(N , H) , 0) , Ns) * attenuation;

color = vec4(clamp((diffuse + specular) , 0.0 , 1.0) , 1.0);
color = color + ambient;

gl_Position = ftransform()*/