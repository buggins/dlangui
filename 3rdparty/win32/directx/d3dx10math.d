/***********************************************************************\
*                              d3dx10math.d                             *
*                                                                       *
*                       Windows API header module                       *
*                                                                       *
*                       Placed into public domain                       *
\***********************************************************************/
module win32.directx.d3dx10math;

version(Tango) {
    import tango.math.Math;
    alias sqrt sqrtf;
} else {
    import std.c.math;
}

private import win32.windows;
private import win32.directx.d3dx10;

struct D3DVECTOR {
	float x;
	float y;
	float z;
}

struct D3DMATRIX {
	union {
		struct {
			float _11, _12, _13, _14;
			float _21, _22, _23, _24;
			float _31, _32, _33, _34;
			float _41, _42, _43, _44;
		}
		float[4][4] m;
	}
}

const D3DX_PI = 3.14159265358979323846;
const D3DX_1BYPI = 1.0 / D3DX_PI;

float D3DXToRadian(float degree) {
	return degree * (D3DX_PI / 180.0);
}

float D3DXToDegree(float radian) {
	return radian * (180.0 / D3DX_PI);
}

const D3DX_16F_DIG			= 3;
const D3DX_16F_EPSILON		= 4.8875809e-4f;
const D3DX_16F_MANT_DIG		= 11;
const D3DX_16F_MAX			= 6.550400e+004;
const D3DX_16F_MAX_10_EXP	= 4;
const D3DX_16F_MAX_EXP		= 15;
const D3DX_16F_MIN			= 6.1035156e-5f;
const D3DX_16F_MIN_10_EXP	= -4;
const D3DX_16F_MIN_EXP		= -14;
const D3DX_16F_RADIX		= 2;
const D3DX_16F_ROUNDS		= 1;
const D3DX_16F_SIGN_MASK	= 0x8000;
const D3DX_16F_EXP_MASK		= 0x7C00;
const D3DX_16F_FRAC_MASK	= 0x03FF;

struct D3DXFLOAT16 {
	//TODO
protected:
    WORD value;
}

struct D3DXVECTOR2 {
	//TODO
	float x, y;
}

struct D3DXVECTOR2_16F {
	//TODO
	D3DXFLOAT16 x, y;
}

struct D3DXVECTOR3 {
	//TODO
	float x, y, z;
}

struct D3DXVECTOR3_16F {
	//TODO
	D3DXFLOAT16 x, y, z;
}

struct D3DXVECTOR4 {
	//TODO
	float x, y, z, w;
}

struct D3DXVECTOR4_16F {
	//TODO
	D3DXFLOAT16 x, y, z, w;
}

struct D3DXMATRIX {
	//TODO
	union {
		struct {
			float _11, _12, _13, _14;
			float _21, _22, _23, _24;
			float _31, _32, _33, _34;
			float _41, _42, _43, _44;
		}
		float[4][4] m;
	}
}

//TODO struct _D3DXMATRIXA16 : D3DXMATRIX

struct D3DXQUATERNION {
	//TODO
	float x, y, z, w;
}

struct D3DXPLANE {
	//TODO
	float a, b, c, d;
}

struct D3DXCOLOR {
	//TODO
	float r, g, b, a;
}

extern(Windows) {
	D3DXFLOAT16* D3DXFloat32To16Array(D3DXFLOAT16* pOut, float* pIn, UINT n);
	float* D3DXFloat16To32Array(float* pOut, D3DXFLOAT16* pIn, UINT n);
}

float D3DXVec2Length(D3DXVECTOR2* pV) {
	debug(D3DX10_DEBUG) {
		if (pV is null) return 0.0;
	}
	return sqrtf((pV.x * pV.x) + (pV.y * pV.y));
}

float D3DXVec2LengthSq(D3DXVECTOR2* pV) {
	debug(D3DX10_DEBUG) {
		if (pV is null) return 0.0;
	}
	return (pV.x * pV.x) + (pV.y * pV.y);
}

float D3DXVec2Dot(D3DXVECTOR2* pV1, D3DXVECTOR2* pV2) {
	debug(D3DX10_DEBUG) {
		if ((pV1 is null) || (pV2 is null)) return 0.0;
	}
	return (pV1.x * pV2.x) + (pV1.y * pV2.y);
}

float D3DXVec2CCW(D3DXVECTOR2* pV1, D3DXVECTOR2* pV2) {
	debug(D3DX10_DEBUG) {
		if ((pV1 is null) || (pV2 is null)) return 0.0;
	}
	return (pV1.x * pV2.y) + (pV1.y * pV2.x);
}

D3DXVECTOR2* D3DXVec2Add(D3DXVECTOR2* pOut, D3DXVECTOR2* pV1, D3DXVECTOR2* pV2) {
	debug(D3DX10_DEBUG) {
		if ((pOut is null) || (pV1 is null) || (pV2 is null)) return null;
	}
	pOut.x = pV1.x + pV2.x;
	pOut.y = pV1.y + pV2.y;
	return pOut;
}

D3DXVECTOR2* D3DXVec2Subtract(D3DXVECTOR2* pOut, D3DXVECTOR2* pV1, D3DXVECTOR2* pV2) {
	debug(D3DX10_DEBUG) {
		if ((pOut is null) || (pV1 is null) || (pV2 is null)) return null;
	}
	pOut.x = pV1.x - pV2.x;
	pOut.y = pV1.y - pV2.y;
	return pOut;
}

D3DXVECTOR2* D3DXVec2Minimize(D3DXVECTOR2* pOut, D3DXVECTOR2* pV1, D3DXVECTOR2* pV2) {
	debug(D3DX10_DEBUG) {
		if ((pOut is null) || (pV1 is null) || (pV2 is null)) return null;
	}
	pOut.x = pV1.x < pV2.x ? pV1.x : pV2.x;
	pOut.y = pV1.y < pV2.y ? pV1.y : pV2.y;
	return pOut;
}

D3DXVECTOR2* D3DXVec2Maximize(D3DXVECTOR2* pOut, D3DXVECTOR2* pV1, D3DXVECTOR2* pV2) {
	debug(D3DX10_DEBUG) {
		if ((pOut is null) || (pV1 is null) || (pV2 is null)) return null;
	}
	pOut.x = pV1.x > pV2.x ? pV1.x : pV2.x;
	pOut.y = pV1.y > pV2.y ? pV1.y : pV2.y;
	return pOut;
}

D3DXVECTOR2* D3DXVec2Scale(D3DXVECTOR2* pOut, D3DXVECTOR2* pV, float s) {
	debug(D3DX10_DEBUG) {
		if ((pOut is null) || (pV is null)) return null;
	}
	pOut.x = pV.x * s;
	pOut.y = pV.y * s;
	return pOut;
}

D3DXVECTOR2* D3DXVec2Lerp(D3DXVECTOR2* pOut, D3DXVECTOR2* pV1, D3DXVECTOR2* pV2, float s) {
	debug(D3DX10_DEBUG) {
		if ((pOut is null) || (pV1 is null) || (pV2 is null)) return null;
	}
	pOut.x = pV1.x + s * (pV2.x - pV1.x);
	pOut.y = pV1.y + s * (pV2.y - pV1.y);
	return pOut;
}

extern(Windows) {
	D3DXVECTOR2* D3DXVec2Normalize(D3DXVECTOR2* pOut, D3DXVECTOR2* pV);
	D3DXVECTOR2* D3DXVec2Hermite(D3DXVECTOR2* pOut, D3DXVECTOR2* pV1, D3DXVECTOR2* pT1, D3DXVECTOR2* pV2, D3DXVECTOR2* pT2, float s);
	D3DXVECTOR2* D3DXVec2CatmullRom(D3DXVECTOR2* pOut, D3DXVECTOR2* pV0, D3DXVECTOR2* pV1, D3DXVECTOR2* pV2, D3DXVECTOR2* pV3, float s);
	D3DXVECTOR2* D3DXVec2BaryCentric(D3DXVECTOR2* pOut, D3DXVECTOR2* pV1, D3DXVECTOR2* pV2, D3DXVECTOR2* pV3, float f, float g);
	D3DXVECTOR4* D3DXVec2Transform(D3DXVECTOR4* pOut, D3DXVECTOR2* pV, D3DXMATRIX* pM);
	D3DXVECTOR2* D3DXVec2TransformCoord(D3DXVECTOR2* pOut, D3DXVECTOR2* pV, D3DXMATRIX* pM);
	D3DXVECTOR2* D3DXVec2TransformNormal(D3DXVECTOR2* pOut, D3DXVECTOR2* pV, D3DXMATRIX* pM);
	D3DXVECTOR4* D3DXVec2TransformArray(D3DXVECTOR4* pOut, UINT OutStride, D3DXVECTOR2* pV, UINT VStride, D3DXMATRIX* pM, UINT n);
	D3DXVECTOR2* D3DXVec2TransformCoordArray(D3DXVECTOR2* pOut, UINT OutStride, D3DXVECTOR2* pV, UINT VStride, D3DXMATRIX* pM, UINT n);
	D3DXVECTOR2* D3DXVec2TransformNormalArray(D3DXVECTOR2* pOut, UINT OutStride, D3DXVECTOR2* pV, UINT VStride, D3DXMATRIX* pM, UINT n);
}

float D3DXVec3Length(D3DXVECTOR3* pV) {
	debug(D3DX10_DEBUG) {
		if (pV is null) return 0.0;
	}
	return sqrtf((pV.x * pV.x) + (pV.y * pV.y) + (pV.z * pV.z));
}

float D3DXVec3LengthSq(D3DXVECTOR3* pV) {
	debug(D3DX10_DEBUG) {
		if (pV is null) return 0.0;
	}
	return (pV.x * pV.x) + (pV.y * pV.y) + (pV.z * pV.z);
}

float D3DXVec3Dot(D3DXVECTOR3* pV1, D3DXVECTOR3* pV2) {
	debug(D3DX10_DEBUG) {
		if ((pV1 is null) || (pV2 is null)) return 0.0;
	}
	return (pV1.x * pV2.x) + (pV1.y * pV2.y) + (pV1.z * pV2.z);
}

D3DXVECTOR3* D3DXVec3Cross(D3DXVECTOR3* pOut, D3DXVECTOR3* pV1, D3DXVECTOR3* pV2) {
	debug(D3DX10_DEBUG) {
		if ((pOut is null) || (pV1 is null) || (pV2 is null)) return 0.0;
	}
	D3DXVECTOR3 v;
	v.x = (pV1.y * pV2.z) - (pV1.z * pV2.y);
	v.y = (pV1.z * pV2.x) - (pV1.x * pV2.z);
	v.z = (pV1.x * pV2.y) - (pV1.y * pV2.x);
	*pOut = v;
	return pOut;
}

D3DXVECTOR3* D3DXVec3Add(D3DXVECTOR3* pOut, D3DXVECTOR3* pV1, D3DXVECTOR3* pV2) {
	debug(D3DX10_DEBUG) {
		if ((pOut is null) || (pV1 is null) || (pV2 is null)) return null;
	}
	pOut.x = pV1.x + pV2.x;
	pOut.y = pV1.y + pV2.y;
	pOut.z = pV1.z + pV2.z;
	return pOut;
}

D3DXVECTOR3* D3DXVec3Subtract(D3DXVECTOR3* pOut, D3DXVECTOR3* pV1, D3DXVECTOR3* pV2) {
	debug(D3DX10_DEBUG) {
		if ((pOut is null) || (pV1 is null) || (pV2 is null)) return null;
	}
	pOut.x = pV1.x - pV2.x;
	pOut.y = pV1.y - pV2.y;
	pOut.z = pV1.z - pV2.z;
	return pOut;
}

D3DXVECTOR3* D3DXVec3Minimize(D3DXVECTOR3* pOut, D3DXVECTOR3* pV1, D3DXVECTOR3* pV2) {
	debug(D3DX10_DEBUG) {
		if ((pOut is null) || (pV1 is null) || (pV2 is null)) return null;
	}
	pOut.x = pV1.x < pV2.x ? pV1.x : pV2.x;
	pOut.y = pV1.y < pV2.y ? pV1.y : pV2.y;
	pOut.z = pV1.z < pV2.z ? pV1.z : pV2.z;
	return pOut;
}

D3DXVECTOR3* D3DXVec3Maximize(D3DXVECTOR3* pOut, D3DXVECTOR3* pV1, D3DXVECTOR3* pV2) {
	debug(D3DX10_DEBUG) {
		if ((pOut is null) || (pV1 is null) || (pV2 is null)) return null;
	}
	pOut.x = pV1.x > pV2.x ? pV1.x : pV2.x;
	pOut.y = pV1.y > pV2.y ? pV1.y : pV2.y;
	pOut.z = pV1.z > pV2.z ? pV1.z : pV2.z;
	return pOut;
}

D3DXVECTOR3* D3DXVec3Scale(D3DXVECTOR3* pOut, D3DXVECTOR3* pV, float s) {
	debug(D3DX10_DEBUG) {
		if ((pOut is null) || (pV is null)) return null;
	}
	pOut.x = pV.x * s;
	pOut.y = pV.y * s;
	pOut.z = pV.z * s;
	return pOut;
}

D3DXVECTOR3* D3DXVec3Lerp(D3DXVECTOR3* pOut, D3DXVECTOR3* pV1, D3DXVECTOR3* pV2, float s) {
	debug(D3DX10_DEBUG) {
		if ((pOut is null) || (pV1 is null) || (pV2 is null)) return null;
	}
	pOut.x = pV1.x + s * (pV2.x - pV1.x);
	pOut.y = pV1.y + s * (pV2.y - pV1.y);
	pOut.z = pV1.z + s * (pV2.z - pV1.z);
	return pOut;
}

extern(Windows) {
	D3DXVECTOR3* D3DXVec3Normalize(D3DXVECTOR3* pOut, D3DXVECTOR3* pV);
	D3DXVECTOR3* D3DXVec3Hermite(D3DXVECTOR3* pOut, D3DXVECTOR3* pV1, D3DXVECTOR3* pT1, D3DXVECTOR3* pV2, D3DXVECTOR3* pT2, FLOAT s);
	D3DXVECTOR3* D3DXVec3CatmullRom(D3DXVECTOR3* pOut, D3DXVECTOR3* pV0, D3DXVECTOR3* pV1, D3DXVECTOR3* pV2, D3DXVECTOR3* pV3, FLOAT s);
	D3DXVECTOR3* D3DXVec3BaryCentric(D3DXVECTOR3* pOut, D3DXVECTOR3* pV1, D3DXVECTOR3* pV2, D3DXVECTOR3* pV3, FLOAT f, FLOAT g);
	D3DXVECTOR4* D3DXVec3Transform(D3DXVECTOR4* pOut, D3DXVECTOR3* pV, D3DXMATRIX* pM);
	D3DXVECTOR3* D3DXVec3TransformCoord(D3DXVECTOR3* pOut, D3DXVECTOR3* pV, D3DXMATRIX* pM);
	D3DXVECTOR3* D3DXVec3TransformNormal(D3DXVECTOR3* pOut, D3DXVECTOR3* pV, D3DXMATRIX* pM);
	D3DXVECTOR4* D3DXVec3TransformArray(D3DXVECTOR4* pOut, UINT OutStride, D3DXVECTOR3* pV, UINT VStride, D3DXMATRIX* pM, UINT n);
	D3DXVECTOR3* D3DXVec3TransformCoordArray(D3DXVECTOR3* pOut, UINT OutStride, D3DXVECTOR3* pV, UINT VStride, D3DXMATRIX* pM, UINT n);
	D3DXVECTOR3* D3DXVec3TransformNormalArray(D3DXVECTOR3* pOut, UINT OutStride, D3DXVECTOR3* pV, UINT VStride, D3DXMATRIX* pM, UINT n);
	D3DXVECTOR3* D3DXVec3Project(D3DXVECTOR3* pOut, D3DXVECTOR3* pV, D3D10_VIEWPORT* pViewport, D3DXMATRIX* pProjection, D3DXMATRIX* pView, D3DXMATRIX* pWorld);
	D3DXVECTOR3* D3DXVec3Unproject(D3DXVECTOR3* pOut, D3DXVECTOR3* pV, D3D10_VIEWPORT* pViewport, D3DXMATRIX* pProjection, D3DXMATRIX* pView, D3DXMATRIX* pWorld);
	D3DXVECTOR3* D3DXVec3ProjectArray(D3DXVECTOR3* pOut, UINT OutStride,D3DXVECTOR3* pV, UINT VStride,D3D10_VIEWPORT* pViewport, D3DXMATRIX* pProjection, D3DXMATRIX* pView, D3DXMATRIX* pWorld, UINT n);
	D3DXVECTOR3* D3DXVec3UnprojectArray(D3DXVECTOR3* pOut, UINT OutStride, D3DXVECTOR3* pV, UINT VStride, D3D10_VIEWPORT* pViewport, D3DXMATRIX* pProjection, D3DXMATRIX* pView, D3DXMATRIX* pWorld, UINT n);
}

float D3DXVec4Length(D3DXVECTOR4* pV) {
	debug(D3DX10_DEBUG) {
		if (pV is null) return 0.0;
	}
	return sqrtf((pV.x * pV.x) + (pV.y * pV.y) + (pV.z * pV.z) + (pV.w * pV.w));
}

float D3DXVec4LengthSq(D3DXVECTOR4* pV) {
	debug(D3DX10_DEBUG) {
		if (pV is null) return 0.0;
	}
	return (pV.x * pV.x) + (pV.y * pV.y) + (pV.z * pV.z) + (pV.w * pV.w);
}

float D3DXVec4Dot(D3DXVECTOR4* pV1, D3DXVECTOR4* pV2) {
	debug(D3DX10_DEBUG) {
		if ((pV1 is null) || (pV2 is null)) return 0.0;
	}
	return (pV1.x * pV2.x) + (pV1.y * pV2.y) + (pV1.z * pV2.z) + (pV1.w * pV2.w);
}

D3DXVECTOR4* D3DXVec4Add(D3DXVECTOR4* pOut, D3DXVECTOR4* pV1, D3DXVECTOR4* pV2) {
	debug(D3DX10_DEBUG) {
		if ((pOut is null) || (pV1 is null) || (pV2 is null)) return null;
	}
	pOut.x = pV1.x + pV2.x;
	pOut.y = pV1.y + pV2.y;
	pOut.z = pV1.z + pV2.z;
	pOut.w = pV1.w + pV2.w;
	return pOut;
}

D3DXVECTOR4* D3DXVec4Subtract(D3DXVECTOR4* pOut, D3DXVECTOR4* pV1, D3DXVECTOR4* pV2) {
	debug(D3DX10_DEBUG) {
		if ((pOut is null) || (pV1 is null) || (pV2 is null)) return null;
	}
	pOut.x = pV1.x - pV2.x;
	pOut.y = pV1.y - pV2.y;
	pOut.z = pV1.z - pV2.z;
	pOut.w = pV1.w - pV2.w;
	return pOut;
}

D3DXVECTOR4* D3DXVec4Minimize(D3DXVECTOR4* pOut, D3DXVECTOR4* pV1, D3DXVECTOR4* pV2) {
	debug(D3DX10_DEBUG) {
		if ((pOut is null) || (pV1 is null) || (pV2 is null)) return null;
	}
	pOut.x = pV1.x < pV2.x ? pV1.x : pV2.x;
	pOut.y = pV1.y < pV2.y ? pV1.y : pV2.y;
	pOut.z = pV1.z < pV2.z ? pV1.z : pV2.z;
	pOut.w = pV1.w < pV2.w ? pV1.w : pV2.w;
	return pOut;
}

D3DXVECTOR4* D3DXVec4Maximize(D3DXVECTOR4* pOut, D3DXVECTOR4* pV1, D3DXVECTOR4* pV2) {
	debug(D3DX10_DEBUG) {
		if ((pOut is null) || (pV1 is null) || (pV2 is null)) return null;
	}
	pOut.x = pV1.x > pV2.x ? pV1.x : pV2.x;
	pOut.y = pV1.y > pV2.y ? pV1.y : pV2.y;
	pOut.z = pV1.z > pV2.z ? pV1.z : pV2.z;
	pOut.w = pV1.w > pV2.w ? pV1.w : pV2.w;
	return pOut;
}

D3DXVECTOR4* D3DXVec4Scale(D3DXVECTOR4* pOut, D3DXVECTOR4* pV, float s) {
	debug(D3DX10_DEBUG) {
		if ((pOut is null) || (pV is null)) return null;
	}
	pOut.x = pV.x * s;
	pOut.y = pV.y * s;
	pOut.z = pV.z * s;
	pOut.w = pV.w * s;
	return pOut;
}

D3DXVECTOR4* D3DXVec4Lerp(D3DXVECTOR4* pOut, D3DXVECTOR4* pV1, D3DXVECTOR4* pV2, float s) {
	debug(D3DX10_DEBUG) {
		if ((pOut is null) || (pV1 is null) || (pV2 is null)) return null;
	}
	pOut.x = pV1.x + s * (pV2.x - pV1.x);
	pOut.y = pV1.y + s * (pV2.y - pV1.y);
	pOut.z = pV1.z + s * (pV2.z - pV1.z);
	pOut.w = pV1.w + s * (pV2.w - pV1.w);
	return pOut;
}

extern(Windows) {
	D3DXVECTOR4* D3DXVec4Cross(D3DXVECTOR4* pOut, D3DXVECTOR4* pV1, D3DXVECTOR4* pV2, D3DXVECTOR4* pV3);
	D3DXVECTOR4* D3DXVec4Normalize(D3DXVECTOR4* pOut, D3DXVECTOR4* pV);
	D3DXVECTOR4* D3DXVec4Hermite(D3DXVECTOR4* pOut, D3DXVECTOR4* pV1, D3DXVECTOR4* pT1, D3DXVECTOR4* pV2, D3DXVECTOR4* pT2, FLOAT s);
	D3DXVECTOR4* D3DXVec4CatmullRom(D3DXVECTOR4* pOut, D3DXVECTOR4* pV0, D3DXVECTOR4* pV1, D3DXVECTOR4* pV2, D3DXVECTOR4* pV3, FLOAT s);
	D3DXVECTOR4* D3DXVec4BaryCentric(D3DXVECTOR4* pOut, D3DXVECTOR4* pV1, D3DXVECTOR4* pV2, D3DXVECTOR4* pV3, FLOAT f, FLOAT g);
	D3DXVECTOR4* D3DXVec4Transform(D3DXVECTOR4* pOut, D3DXVECTOR4* pV, D3DXMATRIX* pM);
	D3DXVECTOR4* D3DXVec4TransformArray(D3DXVECTOR4* pOut, UINT OutStride, D3DXVECTOR4* pV, UINT VStride, D3DXMATRIX* pM, UINT n);
}

D3DXMATRIX* D3DXMatrixIdentity(D3DXMATRIX *pOut) {
	debug(D3DX10_DEBUG) {
		if (pOut is null) return NULL;
	}
	pOut.m[0][1] = pOut.m[0][2] = pOut.m[0][3] =
	pOut.m[1][0] = pOut.m[1][2] = pOut.m[1][3] =
	pOut.m[2][0] = pOut.m[2][1] = pOut.m[2][3] =
	pOut.m[3][0] = pOut.m[3][1] = pOut.m[3][2] = 0.0;
	pOut.m[0][0] = pOut.m[1][1] = pOut.m[2][2] = pOut.m[3][3] = 1.0;
	return pOut;
}


BOOL D3DXMatrixIsIdentity(D3DXMATRIX *pM) {
	debug(D3DX10_DEBUG) {
		if(pM is null) return FALSE;
	}
	return (pM.m[0][0] == 1.0f) && (pM.m[0][1] == 0.0f) && (pM.m[0][2] == 0.0f) && (pM.m[0][3] == 0.0f) &&
	       (pM.m[1][0] == 0.0f) && (pM.m[1][1] == 1.0f) && (pM.m[1][2] == 0.0f) && (pM.m[1][3] == 0.0f) &&
	       (pM.m[2][0] == 0.0f) && (pM.m[2][1] == 0.0f) && (pM.m[2][2] == 1.0f) && (pM.m[2][3] == 0.0f) &&
	       (pM.m[3][0] == 0.0f) && (pM.m[3][1] == 0.0f) && (pM.m[3][2] == 0.0f) && (pM.m[3][3] == 1.0f);
}

extern(Windows) {
	FLOAT D3DXMatrixDeterminant(D3DXMATRIX* pM);
	HRESULT D3DXMatrixDecompose(D3DXVECTOR3* pOutScale, D3DXQUATERNION* pOutRotation, D3DXVECTOR3* pOutTranslation, D3DXMATRIX* pM);
	D3DXMATRIX* D3DXMatrixTranspose(D3DXMATRIX* pOut, D3DXMATRIX* pM);
	D3DXMATRIX* D3DXMatrixMultiply(D3DXMATRIX* pOut, D3DXMATRIX* pM1, D3DXMATRIX* pM2);
	D3DXMATRIX* D3DXMatrixMultiplyTranspose(D3DXMATRIX* pOut, D3DXMATRIX* pM1, D3DXMATRIX* pM2);
	D3DXMATRIX* D3DXMatrixInverse(D3DXMATRIX* pOut, FLOAT* pDeterminant, D3DXMATRIX* pM);
	D3DXMATRIX* D3DXMatrixScaling(D3DXMATRIX* pOut, FLOAT sx, FLOAT sy, FLOAT sz);
	D3DXMATRIX* D3DXMatrixTranslation(D3DXMATRIX* pOut, FLOAT x, FLOAT y, FLOAT z);
	D3DXMATRIX* D3DXMatrixRotationX(D3DXMATRIX* pOut, FLOAT Angle);
	D3DXMATRIX* D3DXMatrixRotationY(D3DXMATRIX* pOut, FLOAT Angle);
	D3DXMATRIX* D3DXMatrixRotationZ(D3DXMATRIX* pOut, FLOAT Angle);
	D3DXMATRIX* D3DXMatrixRotationAxis(D3DXMATRIX* pOut, D3DXVECTOR3* pV, FLOAT Angle);
	D3DXMATRIX* D3DXMatrixRotationQuaternion(D3DXMATRIX* pOut, D3DXQUATERNION* pQ);
	D3DXMATRIX* D3DXMatrixRotationYawPitchRoll(D3DXMATRIX* pOut, FLOAT Yaw, FLOAT Pitch, FLOAT Roll);
	D3DXMATRIX* D3DXMatrixTransformation(D3DXMATRIX* pOut, D3DXVECTOR3* pScalingCenter, D3DXQUATERNION* pScalingRotation, D3DXVECTOR3* pScaling, D3DXVECTOR3* pRotationCenter, D3DXQUATERNION* pRotation, D3DXVECTOR3* pTranslation);
	D3DXMATRIX* D3DXMatrixTransformation2D(D3DXMATRIX* pOut, D3DXVECTOR2* pScalingCenter, FLOAT ScalingRotation, D3DXVECTOR2* pScaling, D3DXVECTOR2* pRotationCenter, FLOAT Rotation, D3DXVECTOR2* pTranslation);
	D3DXMATRIX* D3DXMatrixAffineTransformation(D3DXMATRIX* pOut, FLOAT Scaling, D3DXVECTOR3* pRotationCenter, D3DXQUATERNION* pRotation, D3DXVECTOR3* pTranslation);
	D3DXMATRIX* D3DXMatrixAffineTransformation2D(D3DXMATRIX* pOut, FLOAT Scaling, D3DXVECTOR2* pRotationCenter, FLOAT Rotation, D3DXVECTOR2* pTranslation);
	D3DXMATRIX* D3DXMatrixLookAtRH(D3DXMATRIX* pOut, D3DXVECTOR3* pEye, D3DXVECTOR3* pAt, D3DXVECTOR3* pUp);
	D3DXMATRIX* D3DXMatrixLookAtLH(D3DXMATRIX* pOut, D3DXVECTOR3* pEye, D3DXVECTOR3* pAt, D3DXVECTOR3* pUp);
	D3DXMATRIX* D3DXMatrixPerspectiveRH(D3DXMATRIX* pOut, FLOAT w, FLOAT h, FLOAT zn, FLOAT zf);
	D3DXMATRIX* D3DXMatrixPerspectiveLH(D3DXMATRIX* pOut, FLOAT w, FLOAT h, FLOAT zn, FLOAT zf);
	D3DXMATRIX* D3DXMatrixPerspectiveFovRH(D3DXMATRIX* pOut, FLOAT fovy, FLOAT Aspect, FLOAT zn, FLOAT zf);
	D3DXMATRIX* D3DXMatrixPerspectiveFovLH(D3DXMATRIX* pOut, FLOAT fovy, FLOAT Aspect, FLOAT zn, FLOAT zf);
	D3DXMATRIX* D3DXMatrixPerspectiveOffCenterRH(D3DXMATRIX* pOut, FLOAT l, FLOAT r, FLOAT b, FLOAT t, FLOAT zn, FLOAT zf);
	D3DXMATRIX* D3DXMatrixPerspectiveOffCenterLH(D3DXMATRIX* pOut, FLOAT l, FLOAT r, FLOAT b, FLOAT t, FLOAT zn, FLOAT zf);
	D3DXMATRIX* D3DXMatrixOrthoRH(D3DXMATRIX* pOut, FLOAT w, FLOAT h, FLOAT zn, FLOAT zf);
	D3DXMATRIX* D3DXMatrixOrthoLH(D3DXMATRIX* pOut, FLOAT w, FLOAT h, FLOAT zn, FLOAT zf);
	D3DXMATRIX* D3DXMatrixOrthoOffCenterRH(D3DXMATRIX* pOut, FLOAT l, FLOAT r, FLOAT b, FLOAT t, FLOAT zn, FLOAT zf);
	D3DXMATRIX* D3DXMatrixOrthoOffCenterLH(D3DXMATRIX* pOut, FLOAT l, FLOAT r, FLOAT b, FLOAT t, FLOAT zn, FLOAT zf);
	D3DXMATRIX* D3DXMatrixShadow(D3DXMATRIX* pOut, D3DXVECTOR4* pLight, D3DXPLANE* pPlane);
	D3DXMATRIX* D3DXMatrixReflect(D3DXMATRIX* pOut, D3DXPLANE* pPlane);
}

float D3DXQuaternionLength(D3DXQUATERNION *pQ) {
	debug(D3DX10_DEBUG) {
		if (pQ is null) return 0.0f;
	}
    return sqrtf((pQ.x * pQ.x) + (pQ.y * pQ.y) + (pQ.z * pQ.z) + (pQ.w * pQ.w));
}

float D3DXQuaternionLengthSq(D3DXQUATERNION *pQ) {
	debug(D3DX10_DEBUG) {
		if(pQ is null) return 0.0f;
	}
    return (pQ.x * pQ.x) + (pQ.y * pQ.y) + (pQ.z * pQ.z) + (pQ.w * pQ.w);
}

float D3DXQuaternionDot(D3DXQUATERNION *pQ1, D3DXQUATERNION *pQ2) {
	debug(D3DX10_DEBUG) {
		if((pQ1 is null) || (pQ2 is null)) return 0.0f;
	}
    return (pQ1.x * pQ2.x) + (pQ1.y * pQ2.y) + (pQ1.z * pQ2.z) + (pQ1.w * pQ2.w);
}

D3DXQUATERNION* D3DXQuaternionIdentity(D3DXQUATERNION *pOut) {
	debug(D3DX10_DEBUG) {
		if(pOut is null) return null;
	}
    pOut.x = pOut.y = pOut.z = 0.0f;
    pOut.w = 1.0f;
    return pOut;
}

bool D3DXQuaternionIsIdentity(D3DXQUATERNION *pQ) {
	debug(D3DX10_DEBUG) {
		if(pQ is null) return false;
	}
    return (pQ.x == 0.0f) && (pQ.y == 0.0f) && (pQ.z == 0.0f) && (pQ.w == 1.0f);
}

D3DXQUATERNION* D3DXQuaternionConjugate(D3DXQUATERNION *pOut, D3DXQUATERNION *pQ) {
	debug(D3DX10_DEBUG) {
		if((pOut is null) || (pQis is null)) return null;
	}
    pOut.x = -pQ.x;
    pOut.y = -pQ.y;
    pOut.z = -pQ.z;
    pOut.w =  pQ.w;
    return pOut;
}

extern(Windows) {
	void D3DXQuaternionToAxisAngle(D3DXQUATERNION* pQ, D3DXVECTOR3* pAxis, FLOAT* pAngle);
	D3DXQUATERNION* D3DXQuaternionRotationMatrix(D3DXQUATERNION* pOut, D3DXMATRIX* pM);
	D3DXQUATERNION* D3DXQuaternionRotationAxis(D3DXQUATERNION* pOut, D3DXVECTOR3* pV, FLOAT Angle);
	D3DXQUATERNION* D3DXQuaternionRotationYawPitchRoll(D3DXQUATERNION* pOut, FLOAT Yaw, FLOAT Pitch, FLOAT Roll);
	D3DXQUATERNION* D3DXQuaternionMultiply(D3DXQUATERNION* pOut, D3DXQUATERNION* pQ1, D3DXQUATERNION* pQ2);
	D3DXQUATERNION* D3DXQuaternionNormalize(D3DXQUATERNION* pOut, D3DXQUATERNION* pQ);
	D3DXQUATERNION* D3DXQuaternionInverse(D3DXQUATERNION* pOut, D3DXQUATERNION* pQ);
	D3DXQUATERNION* D3DXQuaternionLn(D3DXQUATERNION* pOut, D3DXQUATERNION* pQ);
	D3DXQUATERNION* D3DXQuaternionExp(D3DXQUATERNION* pOut, D3DXQUATERNION* pQ);
	D3DXQUATERNION* D3DXQuaternionSlerp(D3DXQUATERNION* pOut, D3DXQUATERNION* pQ1, D3DXQUATERNION* pQ2, FLOAT t);
	D3DXQUATERNION* D3DXQuaternionSquad(D3DXQUATERNION* pOut, D3DXQUATERNION* pQ1, D3DXQUATERNION* pA, D3DXQUATERNION* pB, D3DXQUATERNION* pC, FLOAT t);
	void D3DXQuaternionSquadSetup(D3DXQUATERNION* pAOut, D3DXQUATERNION* pBOut, D3DXQUATERNION* pCOut, D3DXQUATERNION* pQ0, D3DXQUATERNION* pQ1, D3DXQUATERNION* pQ2, D3DXQUATERNION* pQ3);
	D3DXQUATERNION* D3DXQuaternionBaryCentric(D3DXQUATERNION* pOut, D3DXQUATERNION* pQ1, D3DXQUATERNION* pQ2, D3DXQUATERNION* pQ3, FLOAT f, FLOAT g);
}

float D3DXPlaneDot(D3DXPLANE *pP, D3DXVECTOR4 *pV) {
	debug(D3DX10_DEBUG) {
		if((pP is null) || (pV is null)) return 0.0f;
	}
    return (pP.a * pV.x) + (pP.b * pV.y) + (pP.c * pV.z) + (pP.d * pV.w);
}

float D3DXPlaneDotCoord(D3DXPLANE *pP, D3DXVECTOR3 *pV) {
	debug(D3DX10_DEBUG) {
		if((pP is null) || (pV is null)) return 0.0f;
	}
    return (pP.a * pV.x) + (pP.b * pV.y) + (pP.c * pV.z) + pP.d;
}

float D3DXPlaneDotNormal(D3DXPLANE *pP, D3DXVECTOR3 *pV) {
	debug(D3DX10_DEBUG) {
		if((pP is null) || (pV is null)) return 0.0f;
	}
    return (pP.a * pV.x) + (pP.b * pV.y) + (pP.c * pV.z);
}

D3DXPLANE* D3DXPlaneScale(D3DXPLANE *pOut, D3DXPLANE *pP, float s) {
	debug(D3DX10_DEBUG) {
		if((pOut is null) || (pP is null)) return null;
	}
    pOut.a = pP.a * s;
    pOut.b = pP.b * s;
    pOut.c = pP.c * s;
    pOut.d = pP.d * s;
    return pOut;
}

extern(Windows) {
	D3DXPLANE* D3DXPlaneNormalize(D3DXPLANE* pOut, D3DXPLANE* pP);
	D3DXVECTOR3* D3DXPlaneIntersectLine(D3DXVECTOR3* pOut, D3DXPLANE* pP, D3DXVECTOR3* pV1, D3DXVECTOR3* pV2);
	D3DXPLANE* D3DXPlaneFromPointNormal(D3DXPLANE* pOut, D3DXVECTOR3* pPoint, D3DXVECTOR3* pNormal);
	D3DXPLANE* D3DXPlaneFromPoints(D3DXPLANE* pOut, D3DXVECTOR3* pV1, D3DXVECTOR3* pV2, D3DXVECTOR3* pV3);
	D3DXPLANE* D3DXPlaneTransform(D3DXPLANE* pOut, D3DXPLANE* pP, D3DXMATRIX* pM);
	D3DXPLANE* D3DXPlaneTransformArray(D3DXPLANE* pOut, UINT OutStride, D3DXPLANE* pP, UINT PStride, D3DXMATRIX* pM, UINT n);
}

D3DXCOLOR* D3DXColorNegative(D3DXCOLOR* pOut, D3DXCOLOR* pC) {
	debug(D3DX10_DEBUG) {
		if((pOut is null) || (pC is null)) return null;
	}
    pOut.r = 1.0f - pC.r;
    pOut.g = 1.0f - pC.g;
    pOut.b = 1.0f - pC.b;
    pOut.a = pC.a;
    return pOut;
}

D3DXCOLOR* D3DXColorAdd(D3DXCOLOR* pOut, D3DXCOLOR* pC1, D3DXCOLOR* pC2) {
	debug(D3DX10_DEBUG) {
		if((pOut is null) || (pC1 is null) || (pC2 is null)) return null;
	}
    pOut.r = pC1.r + pC2.r;
    pOut.g = pC1.g + pC2.g;
    pOut.b = pC1.b + pC2.b;
    pOut.a = pC1.a + pC2.a;
    return pOut;
}

D3DXCOLOR* D3DXColorSubtract(D3DXCOLOR* pOut, D3DXCOLOR* pC1, D3DXCOLOR* pC2) {
	debug(D3DX10_DEBUG) {
		if((pOut is null) || (pC1 is null) || (pC2 is null)) return null;
	}
    pOut.r = pC1.r - pC2.r;
    pOut.g = pC1.g - pC2.g;
    pOut.b = pC1.b - pC2.b;
    pOut.a = pC1.a - pC2.a;
    return pOut;
}

D3DXCOLOR* D3DXColorScale(D3DXCOLOR* pOut, D3DXCOLOR* pC, float s) {
	debug(D3DX10_DEBUG) {
		if((pOut is null) || (pC is null)) return null;
	}
    pOut.r = pC.r * s;
    pOut.g = pC.g * s;
    pOut.b = pC.b * s;
    pOut.a = pC.a * s;
    return pOut;
}

D3DXCOLOR* D3DXColorModulate(D3DXCOLOR* pOut, D3DXCOLOR* pC1, D3DXCOLOR* pC2) {
	debug(D3DX10_DEBUG) {
		if((pOut is null) || (pC1 is null) || (pC2 is null)) return null;
	}
    pOut.r = pC1.r * pC2.r;
    pOut.g = pC1.g * pC2.g;
    pOut.b = pC1.b * pC2.b;
    pOut.a = pC1.a * pC2.a;
    return pOut;
}

D3DXCOLOR* D3DXColorLerp(D3DXCOLOR* pOut, D3DXCOLOR* pC1, D3DXCOLOR* pC2, float s) {
	debug(D3DX10_DEBUG) {
		if((pOut is null) || (pC1 is null) || (pC2 is null)) return null;
	}
    pOut.r = pC1.r + s * (pC2.r - pC1.r);
    pOut.g = pC1.g + s * (pC2.g - pC1.g);
    pOut.b = pC1.b + s * (pC2.b - pC1.b);
    pOut.a = pC1.a + s * (pC2.a - pC1.a);
    return pOut;
}

extern(Windows) {
	D3DXCOLOR* D3DXColorAdjustSaturation(D3DXCOLOR* pOut, D3DXCOLOR* pC, float s);
	D3DXCOLOR* D3DXColorAdjustContrast(D3DXCOLOR* pOut, D3DXCOLOR* pC, float c);
	FLOAT D3DXFresnelTerm(float CosTheta, float RefractionIndex);     
}

extern (C) const GUID IID_ID3DXMatrixStack = {0xc7885ba7, 0xf990, 0x4fe7, [0x92, 0x2d, 0x85, 0x15, 0xe4, 0x77, 0xdd, 0x85]};

interface ID3DXMatrixStack : IUnknown {
	extern(Windows) :
	HRESULT Pop();
	HRESULT Push();
	HRESULT LoadIdentity();
	HRESULT LoadMatrix(D3DXMATRIX* pM );
	HRESULT MultMatrix(D3DXMATRIX* pM );
	HRESULT MultMatrixLocal(D3DXMATRIX* pM );
	HRESULT RotateAxis(D3DXVECTOR3* pV, float Angle);
	HRESULT RotateAxisLocal(D3DXVECTOR3* pV, float Angle);
	HRESULT RotateYawPitchRoll(float Yaw, float Pitch, float Roll);
	HRESULT RotateYawPitchRollLocal(float Yaw, float Pitch, float Roll);
	HRESULT Scale(float x, float y, float z);
	HRESULT ScaleLocal(float x, float y, float z);
	HRESULT Translate(float x, float y, float z );
	HRESULT TranslateLocal(float x, float y, float z);
	D3DXMATRIX* GetTop();
}

//TODO extern(Windows) HRESULT D3DXCreateMatrixStack(UINT Flags, D3DXMATRIXSTACK* ppStack);

const D3DXSH_MINORDER = 2;
const D3DXSH_MAXORDER = 6;

extern(Windows) {
	float* D3DXSHEvalDirection(float* pOut, UINT Order, D3DXVECTOR3* pDir);
	float* D3DXSHRotate(float* pOut, UINT Order, D3DXMATRIX* pMatrix, float* pIn);
	float* D3DXSHRotateZ(float* pOut, UINT Order, float Angle, float* pIn);
	float* D3DXSHAdd(float* pOut, UINT Order, float* pA, float* pB);
	float* D3DXSHScale(float* pOut, UINT Order, float* pIn, float Scale);
	float D3DXSHDot(UINT Order, float* pA, float* pB);
	float* D3DXSHMultiply2(float* pOut, float* pF, float* pG);
	float* D3DXSHMultiply3(float* pOut, float* pF, float* pG);
	float* D3DXSHMultiply4(float* pOut, float* pF, float* pG);
	float* D3DXSHMultiply5(float* pOut, float* pF, float* pG);
	float* D3DXSHMultiply6(float* pOut, float* pF, float* pG);
	HRESULT D3DXSHEvalDirectionalLight(UINT Order, D3DXVECTOR3* pDir, float RIntensity, float GIntensity, float BIntensity, float* pROut, float* pGOut, float* pBOut);
	HRESULT D3DXSHEvalSphericalLight(UINT Order, D3DXVECTOR3* pPos, float Radius, float RIntensity, float GIntensity, float BIntensity, float* pROut, float* pGOut, float* pBOut);
	HRESULT D3DXSHEvalConeLight(UINT Order, D3DXVECTOR3* pDir, float Radius, float RIntensity, float GIntensity, float BIntensity, float* pROut, float* pGOut, float* pBOut);
	HRESULT D3DXSHEvalHemisphereLight(UINT Order, D3DXVECTOR3* pDir, D3DXCOLOR Top, D3DXCOLOR Bottom, float* pROut, float* pGOut, float* pBOut);
	BOOL D3DXIntersectTri(D3DXVECTOR3* p0, D3DXVECTOR3* p1, D3DXVECTOR3* p2, D3DXVECTOR3* pRayPos, D3DXVECTOR3* pRayDir, float* pU, float* pV, float* pDist);
	BOOL D3DXSphereBoundProbe(D3DXVECTOR3* pCenter, float Radius, D3DXVECTOR3* pRayPosition, D3DXVECTOR3* pRayDirection);
	BOOL D3DXBoxBoundProbe(D3DXVECTOR3* pMin, D3DXVECTOR3* pMax, D3DXVECTOR3* pRayPosition, D3DXVECTOR3* pRayDirection);
	HRESULT D3DXComputeBoundingSphere(D3DXVECTOR3* pFirstPosition, DWORD NumVertices, DWORD dwStride, D3DXVECTOR3* pCenter, float* pRadius);
	HRESULT D3DXComputeBoundingBox(D3DXVECTOR3* pFirstPosition, DWORD NumVertices, DWORD dwStride, D3DXVECTOR3* pMin, D3DXVECTOR3* pMax);
}

enum D3DX_CPU_OPTIMIZATION {
	D3DX_NOT_OPTIMIZED = 0,
	D3DX_3DNOW_OPTIMIZED,
	D3DX_SSE2_OPTIMIZED,
	D3DX_SSE_OPTIMIZED
}

extern(Windows) D3DX_CPU_OPTIMIZATION D3DXCpuOptimizations(bool Enable);
