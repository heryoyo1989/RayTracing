#pragma  once

class Vector3f
{
public:
		float x, y, z;
		Vector3f(){}
		Vector3f(float _x, float _y, float _z)
		{
				x = _x;
				y = _y;
				z = _z;
		}
};

class Vector4f
{
public:
	float x, y, z, w;
	Vector4f(){}
	Vector4f(float _x, float _y, float _z, float _w)
	{
		x = _x;
		y = _y;
		z = _z;
		w = _w;
	}
};