/***********************************************************************\
*                             d3d10effect.d                             *
*                                                                       *
*                       Windows API header module                       *
*                                                                       *
*                       Placed into public domain                       *
\***********************************************************************/
module win32.directx.d3d10effect;
version(Windows):

private import win32.windows;
private import win32.directx.d3d10;


enum D3D10_DEVICE_STATE_TYPES {
	D3D10_DST_SO_BUFFERS = 1,
	D3D10_DST_OM_RENDER_TARGETS,
	D3D10_DST_OM_DEPTH_STENCIL_STATE,
	D3D10_DST_OM_BLEND_STATE,
	D3D10_DST_VS,
	D3D10_DST_VS_SAMPLERS,
	D3D10_DST_VS_SHADER_RESOURCES,
	D3D10_DST_VS_CONSTANT_BUFFERS,
	D3D10_DST_GS,
	D3D10_DST_GS_SAMPLERS,
	D3D10_DST_GS_SHADER_RESOURCES,
	D3D10_DST_GS_CONSTANT_BUFFERS,
	D3D10_DST_PS,
	D3D10_DST_PS_SAMPLERS,
	D3D10_DST_PS_SHADER_RESOURCES,
	D3D10_DST_PS_CONSTANT_BUFFERS,
	D3D10_DST_IA_VERTEX_BUFFERS,
	D3D10_DST_IA_INDEX_BUFFER,
	D3D10_DST_IA_INPUT_LAYOUT,
	D3D10_DST_IA_PRIMITIVE_TOPOLOGY,
	D3D10_DST_RS_VIEWPORTS,
	D3D10_DST_RS_SCISSOR_RECTS,
	D3D10_DST_RS_RASTERIZER_STATE,
	D3D10_DST_PREDICATION
}

struct D3D10_STATE_BLOCK_MASK {
	BYTE VS;
	BYTE[2] VSSamplers;
	BYTE[16] VSShaderResources;
	BYTE[2] VSConstantBuffers;
	BYTE GS;
	BYTE[2] GSSamplers;
	BYTE[16] GSShaderResources;
	BYTE[2] GSConstantBuffers;
	BYTE PS;
	BYTE[2] PSSamplers;
	BYTE[16] PSShaderResources;
	BYTE[2] PSConstantBuffers;
	BYTE[2] IAVertexBuffers;
	BYTE IAIndexBuffer;
	BYTE IAInputLayout;
	BYTE IAPrimitiveTopology;
	BYTE OMRenderTargets;
	BYTE OMDepthStencilState;
	BYTE OMBlendState;
	BYTE RSViewports;
	BYTE RSScissorRects;
	BYTE RSRasterizerState;
	BYTE SOBuffers;
	BYTE Predication;
}

extern (C) const GUID IID_ID3D10StateBlock = {0x803425a, 0x57f5, 0x4dd6, [0x94, 0x65, 0xa8, 0x75, 0x70, 0x83, 0x4a, 0x08]};

interface ID3D10StateBlock : IUnknown {
	extern(Windows) :
	HRESULT Capture();
	HRESULT Apply();
	HRESULT ReleaseAllDeviceObjects();
	HRESULT GetDevice(ID3D10Device ppDevice);
}

HRESULT D3D10StateBlockMaskUnion(D3D10_STATE_BLOCK_MASK* pA, D3D10_STATE_BLOCK_MASK* pB, D3D10_STATE_BLOCK_MASK* pResult);
HRESULT D3D10StateBlockMaskIntersect(D3D10_STATE_BLOCK_MASK* pA, D3D10_STATE_BLOCK_MASK* pB, D3D10_STATE_BLOCK_MASK* pResult);
HRESULT D3D10StateBlockMaskDifference(D3D10_STATE_BLOCK_MASK* pA, D3D10_STATE_BLOCK_MASK* pB, D3D10_STATE_BLOCK_MASK* pResult);
HRESULT D3D10StateBlockMaskEnableCapture(D3D10_STATE_BLOCK_MASK* pMask, D3D10_DEVICE_STATE_TYPES StateType, UINT RangeStart, UINT RangeLength);
HRESULT D3D10StateBlockMaskDisableCapture(D3D10_STATE_BLOCK_MASK* pMask, D3D10_DEVICE_STATE_TYPES StateType, UINT RangeStart, UINT RangeLength);
HRESULT D3D10StateBlockMaskEnableAll(D3D10_STATE_BLOCK_MASK* pMask);
HRESULT D3D10StateBlockMaskDisableAll(D3D10_STATE_BLOCK_MASK* pMask);
BOOL D3D10StateBlockMaskGetSetting(D3D10_STATE_BLOCK_MASK* pMask, D3D10_DEVICE_STATE_TYPES StateType, UINT Entry);
HRESULT D3D10CreateStateBlock(ID3D10Device pDevice, D3D10_STATE_BLOCK_MASK* pStateBlockMask, ID3D10StateBlock ppStateBlock);

const D3D10_EFFECT_COMPILE_CHILD_EFFECT			= 1 << 0;
const D3D10_EFFECT_COMPILE_ALLOW_SLOW_OPS		= 1 << 1;
const D3D10_EFFECT_SINGLE_THREADED				= 1 << 3;
const D3D10_EFFECT_VARIABLE_POOLED				= 1 << 0;
const D3D10_EFFECT_VARIABLE_ANNOTATION			= 1 << 1;
const D3D10_EFFECT_VARIABLE_EXPLICIT_BIND_POINT	= 1 << 2;

struct D3D10_EFFECT_TYPE_DESC {
	LPCSTR	TypeName;
	D3D10_SHADER_VARIABLE_CLASS	Class;
	D3D10_SHADER_VARIABLE_TYPE	Type;
	UINT	Elements;
	UINT	Members;
	UINT	Rows;
	UINT	Columns;
	UINT	PackedSize;
	UINT	UnpackedSize;
	UINT	Stride;
}

extern (C) const GUID IID_ID3D10EffectType = {0x4e9e1ddc, 0xcd9d, 0x4772, [0xa8, 0x37, 0x0, 0x18, 0x0b, 0x9b, 0x88, 0xfd]};

interface ID3D10EffectType {
/* TODO: fix vtbl[0] bug
	extern(Windows) :
	BOOL IsValid();
	HRESULT GetDesc(D3D10_EFFECT_TYPE_DESC* pDesc);
	ID3D10EffectType GetMemberTypeByIndex(UINT Index);
	ID3D10EffectType GetMemberTypeByName(LPCSTR Name);
	ID3D10EffectType GetMemberTypeBySemantic(LPCSTR Semantic);
	LPCSTR GetMemberName(UINT Index);
	LPCSTR GetMemberSemantic(UINT Index);
	*/
}

struct D3D10_EFFECT_VARIABLE_DESC {
	LPCSTR	Name;
	LPCSTR	Semantic;
	UINT	Flags;
	UINT	Annotations;
	UINT	BufferOffset;
	UINT	ExplicitBindPoint;
}

extern (C) const GUID IID_ID3D10EffectVariable = {0xae897105, 0x00e6, 0x45bf, [0xbb, 0x8e, 0x28, 0x1d, 0xd6, 0xdb, 0x8e, 0x1b]};

interface ID3D10EffectVariable {
/* TODO: fix vtbl[0] bug
	extern(Windows) :
	BOOL IsValid();
	ID3D10EffectType GetType();
	HRESULT GetDesc(D3D10_EFFECT_VARIABLE_DESC* pDesc);
	ID3D10EffectVariable GetAnnotationByIndex(UINT Index);
	ID3D10EffectVariable GetAnnotationByName(LPCSTR Name);
	ID3D10EffectVariable GetMemberByIndex(UINT Index);
	ID3D10EffectVariable GetMemberByName(LPCSTR Name);
	ID3D10EffectVariable GetMemberBySemantic(LPCSTR Semantic);
	ID3D10EffectVariable GetElement(UINT Index);
	ID3D10EffectConstantBuffer GetParentConstantBuffer();
	ID3D10EffectScalarVariable AsScalar();
	ID3D10EffectVectorVariable AsVector();
	ID3D10EffectMatrixVariable AsMatrix();
	ID3D10EffectStringVariable AsString();
	ID3D10EffectShaderResourceVariable AsShaderResource();
	ID3D10EffectRenderTargetViewVariable AsRenderTargetView();
	ID3D10EffectDepthStencilViewVariable AsDepthStencilView();
	ID3D10EffectConstantBuffer AsConstantBuffer();
	ID3D10EffectShaderVariable AsShader();
	ID3D10EffectBlendVariable AsBlend();
	ID3D10EffectDepthStencilVariable AsDepthStencil();
	ID3D10EffectRasterizerVariable AsRasterizer();
	ID3D10EffectSamplerVariable AsSampler();
	HRESULT SetRawValue(void* pData, UINT Offset, UINT Count);
	HRESULT GetRawValue(void* pData, UINT Offset, UINT Count);
	*/
}

extern (C) const GUID IID_ID3D10EffectScalarVariable = {0xe48f7b, 0xd2c8, 0x49e8, [0xa8, 0x6c, 0x2, 0x2d, 0xee, 0x53, 0x43, 0x1f]};

interface ID3D10EffectScalarVariable : ID3D10EffectVariable {
/* TODO: fix vtbl[0] bug
	extern(Windows) :
	BOOL IsValid();
	ID3D10EffectType GetType();
	HRESULT GetDesc(D3D10_EFFECT_VARIABLE_DESC* pDesc);
	ID3D10EffectVariable GetAnnotationByIndex(UINT Index);
	ID3D10EffectVariable GetAnnotationByName(LPCSTR Name);
	ID3D10EffectVariable GetMemberByIndex(UINT Index);
	ID3D10EffectVariable GetMemberByName(LPCSTR Name);
	ID3D10EffectVariable GetMemberBySemantic(LPCSTR Semantic);
	ID3D10EffectVariable GetElement(UINT Index);
	ID3D10EffectConstantBuffer GetParentConstantBuffer();
	ID3D10EffectScalarVariable AsScalar();
	ID3D10EffectVectorVariable AsVector();
	ID3D10EffectMatrixVariable AsMatrix();
	ID3D10EffectStringVariable AsString();
	ID3D10EffectShaderResourceVariable AsShaderResource();
	ID3D10EffectRenderTargetViewVariable AsRenderTargetView();
	ID3D10EffectDepthStencilViewVariable AsDepthStencilView();
	ID3D10EffectConstantBuffer AsConstantBuffer();
	ID3D10EffectShaderVariable AsShader();
	ID3D10EffectBlendVariable AsBlend();
	ID3D10EffectDepthStencilVariable AsDepthStencil();
	ID3D10EffectRasterizerVariable AsRasterizer();
	ID3D10EffectSamplerVariable AsSampler();
	HRESULT SetRawValue(void* pData, UINT ByteOffset, UINT ByteCount);
	HRESULT GetRawValue(void* pData, UINT ByteOffset, UINT ByteCount);
	HRESULT SetFloat(float Value);
	HRESULT GetFloat(float* pValue);
	HRESULT SetFloatArray(float* pData, UINT Offset, UINT Count);
	HRESULT GetFloatArray(float* pData, UINT Offset, UINT Count);
	HRESULT SetInt(int Value);
	HRESULT GetInt(int* pValue);
	HRESULT SetIntArray(int* pData, UINT Offset, UINT Count);
	HRESULT GetIntArray(int* pData, UINT Offset, UINT Count);
	HRESULT SetBool(BOOL Value);
	HRESULT GetBool(BOOL* pValue);
	HRESULT SetBoolArray(BOOL* pData, UINT Offset, UINT Count);
	HRESULT GetBoolArray(BOOL* pData, UINT Offset, UINT Count);
	*/
}

extern (C) const GUID IID_ID3D10EffectVectorVariable = {0x62b98c44, 0x1f82, 0x4c67, [0xbc, 0xd0, 0x72, 0xcf, 0x8f, 0x21, 0x7e, 0x81]};

interface ID3D10EffectVectorVariable : ID3D10EffectVariable {
/* TODO: fix vtbl[0] bug
	extern(Windows) :
	BOOL IsValid();
	ID3D10EffectType GetType();
	HRESULT GetDesc(D3D10_EFFECT_VARIABLE_DESC* pDesc);
	ID3D10EffectVariable GetAnnotationByIndex(UINT Index);
	ID3D10EffectVariable GetAnnotationByName(LPCSTR Name);
	ID3D10EffectVariable GetMemberByIndex(UINT Index);
	ID3D10EffectVariable GetMemberByName(LPCSTR Name);
	ID3D10EffectVariable GetMemberBySemantic(LPCSTR Semantic);
	ID3D10EffectVariable GetElement(UINT Index);
	ID3D10EffectConstantBuffer GetParentConstantBuffer();
	ID3D10EffectScalarVariable AsScalar();
	ID3D10EffectVectorVariable AsVector();
	ID3D10EffectMatrixVariable AsMatrix();
	ID3D10EffectStringVariable AsString();
	ID3D10EffectShaderResourceVariable AsShaderResource();
	ID3D10EffectRenderTargetViewVariable AsRenderTargetView();
	ID3D10EffectDepthStencilViewVariable AsDepthStencilView();
	ID3D10EffectConstantBuffer AsConstantBuffer();
	ID3D10EffectShaderVariable AsShader();
	ID3D10EffectBlendVariable AsBlend();
	ID3D10EffectDepthStencilVariable AsDepthStencil();
	ID3D10EffectRasterizerVariable AsRasterizer();
	ID3D10EffectSamplerVariable AsSampler();
	HRESULT SetRawValue(void* pData, UINT ByteOffset, UINT ByteCount);
	HRESULT GetRawValue(void* pData, UINT ByteOffset, UINT ByteCount);
	HRESULT SetBoolVector (BOOL* pData);
	HRESULT SetIntVector  (int* pData);
	HRESULT SetFloatVector(float* pData);
	HRESULT GetBoolVector (BOOL* pData);
	HRESULT GetIntVector  (int* pData);
	HRESULT GetFloatVector(float* pData);
	HRESULT SetBoolVectorArray (BOOL* pData, UINT Offset, UINT Count);
	HRESULT SetIntVectorArray  (int* pData, UINT Offset, UINT Count);
	HRESULT SetFloatVectorArray(float* pData, UINT Offset, UINT Count);
	HRESULT GetBoolVectorArray (BOOL* pData, UINT Offset, UINT Count);
	HRESULT GetIntVectorArray  (int* pData, UINT Offset, UINT Count);
	HRESULT GetFloatVectorArray(float* pData, UINT Offset, UINT Count);
	*/
}

extern (C) const GUID IID_ID3D10EffectMatrixVariable = {0x50666c24, 0xb82f, 0x4eed, [0xa1, 0x72, 0x5b, 0x6e, 0x7e, 0x85, 0x22, 0xe0]};

interface ID3D10EffectMatrixVariable : ID3D10EffectVariable {
/* TODO: fix vtbl[0] bug
	extern(Windows) :
	BOOL IsValid();
	ID3D10EffectType GetType();
	HRESULT GetDesc(D3D10_EFFECT_VARIABLE_DESC* pDesc);
	ID3D10EffectVariable GetAnnotationByIndex(UINT Index);
	ID3D10EffectVariable GetAnnotationByName(LPCSTR Name);
	ID3D10EffectVariable GetMemberByIndex(UINT Index);
	ID3D10EffectVariable GetMemberByName(LPCSTR Name);
	ID3D10EffectVariable GetMemberBySemantic(LPCSTR Semantic);
	ID3D10EffectVariable GetElement(UINT Index);
	ID3D10EffectConstantBuffer GetParentConstantBuffer();
	ID3D10EffectScalarVariable AsScalar();
	ID3D10EffectVectorVariable AsVector();
	ID3D10EffectMatrixVariable AsMatrix();
	ID3D10EffectStringVariable AsString();
	ID3D10EffectShaderResourceVariable AsShaderResource();
	ID3D10EffectRenderTargetViewVariable AsRenderTargetView();
	ID3D10EffectDepthStencilViewVariable AsDepthStencilView();
	ID3D10EffectConstantBuffer AsConstantBuffer();
	ID3D10EffectShaderVariable AsShader();
	ID3D10EffectBlendVariable AsBlend();
	ID3D10EffectDepthStencilVariable AsDepthStencil();
	ID3D10EffectRasterizerVariable AsRasterizer();
	ID3D10EffectSamplerVariable AsSampler();
	HRESULT SetRawValue(void* pData, UINT ByteOffset, UINT ByteCount);
	HRESULT GetRawValue(void* pData, UINT ByteOffset, UINT ByteCount);
	HRESULT SetMatrix(float* pData);
	HRESULT GetMatrix(float* pData);
	HRESULT SetMatrixArray(float* pData, UINT Offset, UINT Count);
	HRESULT GetMatrixArray(float* pData, UINT Offset, UINT Count);
	HRESULT SetMatrixTranspose(float* pData);
	HRESULT GetMatrixTranspose(float* pData);
	HRESULT SetMatrixTransposeArray(float* pData, UINT Offset, UINT Count);
	HRESULT GetMatrixTransposeArray(float* pData, UINT Offset, UINT Count);
	*/
}

extern (C) const GUID IID_ID3D10EffectStringVariable = {0x71417501, 0x8df9, 0x4e0a, [0xa7, 0x8a, 0x25, 0x5f, 0x97, 0x56, 0xba, 0xff]};

interface ID3D10EffectStringVariable : ID3D10EffectVariable {
/* TODO: fix vtbl[0] bug
	extern(Windows) :
	BOOL IsValid();
	ID3D10EffectType GetType();
	HRESULT GetDesc(D3D10_EFFECT_VARIABLE_DESC* pDesc);
	ID3D10EffectVariable GetAnnotationByIndex(UINT Index);
	ID3D10EffectVariable GetAnnotationByName(LPCSTR Name);
	ID3D10EffectVariable GetMemberByIndex(UINT Index);
	ID3D10EffectVariable GetMemberByName(LPCSTR Name);
	ID3D10EffectVariable GetMemberBySemantic(LPCSTR Semantic);
	ID3D10EffectVariable GetElement(UINT Index);
	ID3D10EffectConstantBuffer GetParentConstantBuffer();
	ID3D10EffectScalarVariable AsScalar();
	ID3D10EffectVectorVariable AsVector();
	ID3D10EffectMatrixVariable AsMatrix();
	ID3D10EffectStringVariable AsString();
	ID3D10EffectShaderResourceVariable AsShaderResource();
	ID3D10EffectRenderTargetViewVariable AsRenderTargetView();
	ID3D10EffectDepthStencilViewVariable AsDepthStencilView();
	ID3D10EffectConstantBuffer AsConstantBuffer();
	ID3D10EffectShaderVariable AsShader();
	ID3D10EffectBlendVariable AsBlend();
	ID3D10EffectDepthStencilVariable AsDepthStencil();
	ID3D10EffectRasterizerVariable AsRasterizer();
	ID3D10EffectSamplerVariable AsSampler();
	HRESULT SetRawValue(void* pData, UINT Offset, UINT Count);
	HRESULT GetRawValue(void* pData, UINT Offset, UINT Count);
	HRESULT GetString(LPCSTR* ppString);
	HRESULT GetStringArray(LPCSTR* ppStrings, UINT Offset, UINT Count);
	*/
}

extern (C) const GUID IID_ID3D10EffectShaderResourceVariable = {0xc0a7157b, 0xd872, 0x4b1d, [0x80, 0x73, 0xef, 0xc2, 0xac, 0xd4, 0xb1, 0xfc]};

interface ID3D10EffectShaderResourceVariable : ID3D10EffectVariable {
/* TODO: fix vtbl[0] bug
	extern(Windows) :
	BOOL IsValid();
	ID3D10EffectType GetType();
	HRESULT GetDesc(D3D10_EFFECT_VARIABLE_DESC* pDesc);
	ID3D10EffectVariable GetAnnotationByIndex(UINT Index);
	ID3D10EffectVariable GetAnnotationByName(LPCSTR Name);
	ID3D10EffectVariable GetMemberByIndex(UINT Index);
	ID3D10EffectVariable GetMemberByName(LPCSTR Name);
	ID3D10EffectVariable GetMemberBySemantic(LPCSTR Semantic);
	ID3D10EffectVariable GetElement(UINT Index);
	ID3D10EffectConstantBuffer GetParentConstantBuffer();
	ID3D10EffectScalarVariable AsScalar();
	ID3D10EffectVectorVariable AsVector();
	ID3D10EffectMatrixVariable AsMatrix();
	ID3D10EffectStringVariable AsString();
	ID3D10EffectShaderResourceVariable AsShaderResource();
	ID3D10EffectRenderTargetViewVariable AsRenderTargetView();
	ID3D10EffectDepthStencilViewVariable AsDepthStencilView();
	ID3D10EffectConstantBuffer AsConstantBuffer();
	ID3D10EffectShaderVariable AsShader();
	ID3D10EffectBlendVariable AsBlend();
	ID3D10EffectDepthStencilVariable AsDepthStencil();
	ID3D10EffectRasterizerVariable AsRasterizer();
	ID3D10EffectSamplerVariable AsSampler();
	HRESULT SetRawValue(void* pData, UINT Offset, UINT Count);
	HRESULT GetRawValue(void* pData, UINT Offset, UINT Count);
	HRESULT SetResource(ID3D10ShaderResourceView pResource);
	HRESULT GetResource(ID3D10ShaderResourceView* ppResource);
	HRESULT SetResourceArray(ID3D10ShaderResourceView* ppResources, UINT Offset, UINT Count);
	HRESULT GetResourceArray(ID3D10ShaderResourceView* ppResources, UINT Offset, UINT Count);
	*/
}

extern (C) const GUID IID_ID3D10EffectRenderTargetViewVariable = {0x28ca0cc3, 0xc2c9, 0x40bb, [0xb5, 0x7f, 0x67, 0xb7, 0x37, 0x12, 0x2b, 0x17]};

interface ID3D10EffectRenderTargetViewVariable : ID3D10EffectVariable {
/* TODO: fix vtbl[0] bug
	extern(Windows) :
	BOOL IsValid();
	ID3D10EffectType GetType();
	HRESULT GetDesc(D3D10_EFFECT_VARIABLE_DESC* pDesc);
	ID3D10EffectVariable GetAnnotationByIndex(UINT Index);
	ID3D10EffectVariable GetAnnotationByName(LPCSTR Name);
	ID3D10EffectVariable GetMemberByIndex(UINT Index);
	ID3D10EffectVariable GetMemberByName(LPCSTR Name);
	ID3D10EffectVariable GetMemberBySemantic(LPCSTR Semantic);
	ID3D10EffectVariable GetElement(UINT Index);
	ID3D10EffectConstantBuffer GetParentConstantBuffer();
	ID3D10EffectScalarVariable AsScalar();
	ID3D10EffectVectorVariable AsVector();
	ID3D10EffectMatrixVariable AsMatrix();
	ID3D10EffectStringVariable AsString();
	ID3D10EffectShaderResourceVariable AsShaderResource();
	ID3D10EffectRenderTargetViewVariable AsRenderTargetView();
	ID3D10EffectDepthStencilViewVariable AsDepthStencilView();
	ID3D10EffectConstantBuffer AsConstantBuffer();
	ID3D10EffectShaderVariable AsShader();
	ID3D10EffectBlendVariable AsBlend();
	ID3D10EffectDepthStencilVariable AsDepthStencil();
	ID3D10EffectRasterizerVariable AsRasterizer();
	ID3D10EffectSamplerVariable AsSampler();
	HRESULT SetRawValue(void* pData, UINT Offset, UINT Count);
	HRESULT GetRawValue(void* pData, UINT Offset, UINT Count);
	HRESULT SetRenderTarget(ID3D10RenderTargetView pResource);
	HRESULT GetRenderTarget(ID3D10RenderTargetView* ppResource);
	HRESULT SetRenderTargetArray(ID3D10RenderTargetView* ppResources, UINT Offset, UINT Count);
	HRESULT GetRenderTargetArray(ID3D10RenderTargetView* ppResources, UINT Offset, UINT Count);
	*/
}

extern (C) const GUID IID_ID3D10EffectDepthStencilViewVariable = {0x3e02c918, 0xcc79, 0x4985, [0xb6, 0x22, 0x2d, 0x92, 0xad, 0x70, 0x16, 0x23]};

interface ID3D10EffectDepthStencilViewVariable : ID3D10EffectVariable {
/* TODO: fix vtbl[0] bug
	extern(Windows) :
	BOOL IsValid();
	ID3D10EffectType GetType();
	HRESULT GetDesc(D3D10_EFFECT_VARIABLE_DESC* pDesc);
	ID3D10EffectVariable GetAnnotationByIndex(UINT Index);
	ID3D10EffectVariable GetAnnotationByName(LPCSTR Name);
	ID3D10EffectVariable GetMemberByIndex(UINT Index);
	ID3D10EffectVariable GetMemberByName(LPCSTR Name);
	ID3D10EffectVariable GetMemberBySemantic(LPCSTR Semantic);
	ID3D10EffectVariable GetElement(UINT Index);
	ID3D10EffectConstantBuffer GetParentConstantBuffer();
	ID3D10EffectScalarVariable AsScalar();
	ID3D10EffectVectorVariable AsVector();
	ID3D10EffectMatrixVariable AsMatrix();
	ID3D10EffectStringVariable AsString();
	ID3D10EffectShaderResourceVariable AsShaderResource();
	ID3D10EffectRenderTargetViewVariable AsRenderTargetView();
	ID3D10EffectDepthStencilViewVariable AsDepthStencilView();
	ID3D10EffectConstantBuffer AsConstantBuffer();
	ID3D10EffectShaderVariable AsShader();
	ID3D10EffectBlendVariable AsBlend();
	ID3D10EffectDepthStencilVariable AsDepthStencil();
	ID3D10EffectRasterizerVariable AsRasterizer();
	ID3D10EffectSamplerVariable AsSampler();
	HRESULT SetRawValue(void* pData, UINT Offset, UINT Count);
	HRESULT GetRawValue(void* pData, UINT Offset, UINT Count);
	HRESULT SetDepthStencil(ID3D10DepthStencilView pResource);
	HRESULT GetDepthStencil(ID3D10DepthStencilView* ppResource);
	HRESULT SetDepthStencilArray(ID3D10DepthStencilView* ppResources, UINT Offset, UINT Count);
	HRESULT GetDepthStencilArray(ID3D10DepthStencilView* ppResources, UINT Offset, UINT Count);
	*/
}

extern (C) const GUID IID_ID3D10EffectConstantBuffer = {0x56648f4d, 0xcc8b, 0x4444, [0xa5, 0xad, 0xb5, 0xa3, 0xd7, 0x6e, 0x91, 0xb3]};

interface ID3D10EffectConstantBuffer : ID3D10EffectVariable {
/* TODO: fix vtbl[0] bug
	extern(Windows) :
	ID3D10EffectType GetType();
	HRESULT GetDesc(D3D10_EFFECT_VARIABLE_DESC* pDesc);
	ID3D10EffectVariable GetAnnotationByIndex(UINT Index);
	ID3D10EffectVariable GetAnnotationByName(LPCSTR Name);
	ID3D10EffectVariable GetMemberByIndex(UINT Index);
	ID3D10EffectVariable GetMemberByName(LPCSTR Name);
	ID3D10EffectVariable GetMemberBySemantic(LPCSTR Semantic);
	ID3D10EffectVariable GetElement(UINT Index);
	ID3D10EffectConstantBuffer GetParentConstantBuffer();
	ID3D10EffectScalarVariable AsScalar();
	ID3D10EffectVectorVariable AsVector();
	ID3D10EffectMatrixVariable AsMatrix();
	ID3D10EffectStringVariable AsString();
	ID3D10EffectShaderResourceVariable AsShaderResource();
	ID3D10EffectRenderTargetViewVariable AsRenderTargetView();
	ID3D10EffectDepthStencilViewVariable AsDepthStencilView();
	ID3D10EffectConstantBuffer AsConstantBuffer();
	ID3D10EffectShaderVariable AsShader();
	ID3D10EffectBlendVariable AsBlend();
	ID3D10EffectDepthStencilVariable AsDepthStencil();
	ID3D10EffectRasterizerVariable AsRasterizer();
	ID3D10EffectSamplerVariable AsSampler();
	HRESULT SetRawValue(void* pData, UINT Offset, UINT Count);
	HRESULT GetRawValue(void* pData, UINT Offset, UINT Count);
	HRESULT SetConstantBuffer(ID3D10Buffer pConstantBuffer);
	HRESULT GetConstantBuffer(ID3D10Buffer* ppConstantBuffer);
	HRESULT SetTextureBuffer(ID3D10ShaderResourceView pTextureBuffer);
	HRESULT GetTextureBuffer(ID3D10ShaderResourceView* ppTextureBuffer);
	*/
}

struct D3D10_EFFECT_SHADER_DESC {
	BYTE*	pInputSignature;
	BOOL	IsInline;
	BYTE*	pBytecode;
	UINT	BytecodeLength;
	LPCSTR	SODecl;
	UINT	NumInputSignatureEntries;
	UINT	NumOutputSignatureEntries;
}

extern (C) const GUID IID_ID3D10EffectShaderVariable = {0x80849279, 0xc799, 0x4797, [0x8c, 0x33, 0x4, 0x7, 0xa0, 0x7d, 0x9e, 0x6]};

interface ID3D10EffectShaderVariable : ID3D10EffectVariable {
/* TODO: fix vtbl[0] bug
	extern(Windows) :
	ID3D10EffectType GetType();
	HRESULT GetDesc(D3D10_EFFECT_VARIABLE_DESC* pDesc);
	ID3D10EffectVariable GetAnnotationByIndex(UINT Index);
	ID3D10EffectVariable GetAnnotationByName(LPCSTR Name);
	ID3D10EffectVariable GetMemberByIndex(UINT Index);
	ID3D10EffectVariable GetMemberByName(LPCSTR Name);
	ID3D10EffectVariable GetMemberBySemantic(LPCSTR Semantic);
	ID3D10EffectVariable GetElement(UINT Index);
	ID3D10EffectConstantBuffer GetParentConstantBuffer();
	ID3D10EffectScalarVariable AsScalar();
	ID3D10EffectVectorVariable AsVector();
	ID3D10EffectMatrixVariable AsMatrix();
	ID3D10EffectStringVariable AsString();
	ID3D10EffectShaderResourceVariable AsShaderResource();
	ID3D10EffectRenderTargetViewVariable AsRenderTargetView();
	ID3D10EffectDepthStencilViewVariable AsDepthStencilView();
	ID3D10EffectConstantBuffer AsConstantBuffer();
	ID3D10EffectShaderVariable AsShader();
	ID3D10EffectBlendVariable AsBlend();
	ID3D10EffectDepthStencilVariable AsDepthStencil();
	ID3D10EffectRasterizerVariable AsRasterizer();
	ID3D10EffectSamplerVariable AsSampler();
	HRESULT SetRawValue(void* pData, UINT Offset, UINT Count);
	HRESULT GetRawValue(void* pData, UINT Offset, UINT Count);
	HRESULT GetShaderDesc(UINT ShaderIndex, D3D10_EFFECT_SHADER_DESC* pDesc);
	HRESULT GetVertexShader(UINT ShaderIndex, ID3D10VertexShader* ppVS);
	HRESULT GetGeometryShader(UINT ShaderIndex, ID3D10GeometryShader* ppGS);
	HRESULT GetPixelShader(UINT ShaderIndex, ID3D10PixelShader* ppPS);
	HRESULT GetInputSignatureElementDesc(UINT ShaderIndex, UINT Element, D3D10_SIGNATURE_PARAMETER_DESC* pDesc);
	HRESULT GetOutputSignatureElementDesc(UINT ShaderIndex, UINT Element, D3D10_SIGNATURE_PARAMETER_DESC* pDesc);
	*/
}

extern (C) const GUID IID_ID3D10EffectBlendVariable = {0x1fcd2294, 0xdf6d, 0x4eae, [0x86, 0xb3, 0xe, 0x91, 0x60, 0xcf, 0xb0, 0x7b]};

interface ID3D10EffectBlendVariable : ID3D10EffectVariable {
/* TODO: fix vtbl[0] bug
	extern(Windows) :
	ID3D10EffectType GetType();
	HRESULT GetDesc(D3D10_EFFECT_VARIABLE_DESC* pDesc);
	ID3D10EffectVariable GetAnnotationByIndex(UINT Index);
	ID3D10EffectVariable GetAnnotationByName(LPCSTR Name);
	ID3D10EffectVariable GetMemberByIndex(UINT Index);
	ID3D10EffectVariable GetMemberByName(LPCSTR Name);
	ID3D10EffectVariable GetMemberBySemantic(LPCSTR Semantic);
	ID3D10EffectVariable GetElement(UINT Index);
	ID3D10EffectConstantBuffer GetParentConstantBuffer();
	ID3D10EffectScalarVariable AsScalar();
	ID3D10EffectVectorVariable AsVector();
	ID3D10EffectMatrixVariable AsMatrix();
	ID3D10EffectStringVariable AsString();
	ID3D10EffectShaderResourceVariable AsShaderResource();
	ID3D10EffectRenderTargetViewVariable AsRenderTargetView();
	ID3D10EffectDepthStencilViewVariable AsDepthStencilView();
	ID3D10EffectConstantBuffer AsConstantBuffer();
	ID3D10EffectShaderVariable AsShader();
	ID3D10EffectBlendVariable AsBlend();
	ID3D10EffectDepthStencilVariable AsDepthStencil();
	ID3D10EffectRasterizerVariable AsRasterizer();
	ID3D10EffectSamplerVariable AsSampler();
	HRESULT SetRawValue(void* pData, UINT Offset, UINT Count);
	HRESULT GetRawValue(void* pData, UINT Offset, UINT Count);
	HRESULT GetBlendState(UINT Index, ID3D10BlendState* ppBlendState);
	HRESULT GetBackingStore(UINT Index, D3D10_BLEND_DESC* pBlendDesc);
	*/
}

extern (C) const GUID IID_ID3D10EffectDepthStencilVariable = {0xaf482368, 0x330a, 0x46a5, [0x9a, 0x5c, 0x1, 0xc7, 0x1a, 0xf2, 0x4c, 0x8d]};

interface ID3D10EffectDepthStencilVariable : ID3D10EffectVariable {
/* TODO: fix vtbl[0] bug
	extern(Windows) :
	ID3D10EffectType GetType();
	HRESULT GetDesc(D3D10_EFFECT_VARIABLE_DESC* pDesc);
	ID3D10EffectVariable GetAnnotationByIndex(UINT Index);
	ID3D10EffectVariable GetAnnotationByName(LPCSTR Name);
	ID3D10EffectVariable GetMemberByIndex(UINT Index);
	ID3D10EffectVariable GetMemberByName(LPCSTR Name);
	ID3D10EffectVariable GetMemberBySemantic(LPCSTR Semantic);
	ID3D10EffectVariable GetElement(UINT Index);
	ID3D10EffectConstantBuffer GetParentConstantBuffer();
	ID3D10EffectScalarVariable AsScalar();
	ID3D10EffectVectorVariable AsVector();
	ID3D10EffectMatrixVariable AsMatrix();
	ID3D10EffectStringVariable AsString();
	ID3D10EffectShaderResourceVariable AsShaderResource();
	ID3D10EffectRenderTargetViewVariable AsRenderTargetView();
	ID3D10EffectDepthStencilViewVariable AsDepthStencilView();
	ID3D10EffectConstantBuffer AsConstantBuffer();
	ID3D10EffectShaderVariable AsShader();
	ID3D10EffectBlendVariable AsBlend();
	ID3D10EffectDepthStencilVariable AsDepthStencil();
	ID3D10EffectRasterizerVariable AsRasterizer();
	ID3D10EffectSamplerVariable AsSampler();
	HRESULT SetRawValue(void* pData, UINT Offset, UINT Count);
	HRESULT GetRawValue(void* pData, UINT Offset, UINT Count);
	HRESULT GetDepthStencilState(UINT Index, ID3D10DepthStencilState* ppDepthStencilState);
	HRESULT GetBackingStore(UINT Index, D3D10_DEPTH_STENCIL_DESC* pDepthStencilDesc);
	*/
}

extern (C) const GUID IID_ID3D10EffectRasterizerVariable = {0x21af9f0e, 0x4d94, 0x4ea9, [0x97, 0x85, 0x2c, 0xb7, 0x6b, 0x8c, 0xb, 0x34]};

interface ID3D10EffectRasterizerVariable : ID3D10EffectVariable {
/* TODO: fix vtbl[0] bug
	extern(Windows) :
	ID3D10EffectType GetType();
	HRESULT GetDesc(D3D10_EFFECT_VARIABLE_DESC* pDesc);
	ID3D10EffectVariable GetAnnotationByIndex(UINT Index);
	ID3D10EffectVariable GetAnnotationByName(LPCSTR Name);
	ID3D10EffectVariable GetMemberByIndex(UINT Index);
	ID3D10EffectVariable GetMemberByName(LPCSTR Name);
	ID3D10EffectVariable GetMemberBySemantic(LPCSTR Semantic);
	ID3D10EffectVariable GetElement(UINT Index);
	ID3D10EffectConstantBuffer GetParentConstantBuffer();
	ID3D10EffectScalarVariable AsScalar();
	ID3D10EffectVectorVariable AsVector();
	ID3D10EffectMatrixVariable AsMatrix();
	ID3D10EffectStringVariable AsString();
	ID3D10EffectShaderResourceVariable AsShaderResource();
	ID3D10EffectRenderTargetViewVariable AsRenderTargetView();
	ID3D10EffectDepthStencilViewVariable AsDepthStencilView();
	ID3D10EffectConstantBuffer AsConstantBuffer();
	ID3D10EffectShaderVariable AsShader();
	ID3D10EffectBlendVariable AsBlend();
	ID3D10EffectDepthStencilVariable AsDepthStencil();
	ID3D10EffectRasterizerVariable AsRasterizer();
	ID3D10EffectSamplerVariable AsSampler();
	HRESULT SetRawValue(void* pData, UINT Offset, UINT Count);
	HRESULT GetRawValue(void* pData, UINT Offset, UINT Count);
	HRESULT GetRasterizerState(UINT Index, ID3D10RasterizerState* ppRasterizerState);
	HRESULT GetBackingStore(UINT Index, D3D10_RASTERIZER_DESC* pRasterizerDesc);
	*/
}

extern (C) const GUID IID_ID3D10EffectSamplerVariable = {0x6530d5c7, 0x07e9, 0x4271, [0xa4, 0x18, 0xe7, 0xce, 0x4b, 0xd1, 0xe4, 0x80]};

interface ID3D10EffectSamplerVariable : ID3D10EffectVariable {
/* TODO: fix vtbl[0] bug
	extern(Windows) :
	ID3D10EffectType GetType();
	HRESULT GetDesc(D3D10_EFFECT_VARIABLE_DESC* pDesc);
	ID3D10EffectVariable GetAnnotationByIndex(UINT Index);
	ID3D10EffectVariable GetAnnotationByName(LPCSTR Name);
	ID3D10EffectVariable GetMemberByIndex(UINT Index);
	ID3D10EffectVariable GetMemberByName(LPCSTR Name);
	ID3D10EffectVariable GetMemberBySemantic(LPCSTR Semantic);
	ID3D10EffectVariable GetElement(UINT Index);
	ID3D10EffectConstantBuffer GetParentConstantBuffer();
	ID3D10EffectScalarVariable AsScalar();
	ID3D10EffectVectorVariable AsVector();
	ID3D10EffectMatrixVariable AsMatrix();
	ID3D10EffectStringVariable AsString();
	ID3D10EffectShaderResourceVariable AsShaderResource();
	ID3D10EffectRenderTargetViewVariable AsRenderTargetView();
	ID3D10EffectDepthStencilViewVariable AsDepthStencilView();
	ID3D10EffectConstantBuffer AsConstantBuffer();
	ID3D10EffectShaderVariable AsShader();
	ID3D10EffectBlendVariable AsBlend();
	ID3D10EffectDepthStencilVariable AsDepthStencil();
	ID3D10EffectRasterizerVariable AsRasterizer();
	ID3D10EffectSamplerVariable AsSampler();
	HRESULT SetRawValue(void* pData, UINT Offset, UINT Count);
	HRESULT GetRawValue(void* pData, UINT Offset, UINT Count);
	HRESULT GetSampler(UINT Index, ID3D10SamplerState* ppSampler);
	HRESULT GetBackingStore(UINT Index, D3D10_SAMPLER_DESC* pSamplerDesc);
	*/
}

struct D3D10_PASS_DESC {
	LPCSTR		Name;
	UINT		Annotations;
	BYTE*		pIAInputSignature;
	SIZE_T		IAInputSignatureSize;
	UINT		StencilRef;
	UINT		SampleMask;
	FLOAT[4]	BlendFactor;
}

struct D3D10_PASS_SHADER_DESC {
	ID3D10EffectShaderVariable	pShaderVariable;
	UINT						ShaderIndex;
}

extern (C) const GUID IID_ID3D10EffectPass = {0x5cfbeb89, 0x1a06, 0x46e0, [0xb2, 0x82, 0xe3, 0xf9, 0xbf, 0xa3, 0x6a, 0x54]};

/+interface ID3D10EffectPass {
/* TODO: fix vtbl[0] bug
	extern(Windows) :
	BOOL IsValid();
	HRESULT GetDesc(D3D10_PASS_DESC* pDesc);
	HRESULT GetVertexShaderDesc(D3D10_PASS_SHADER_DESC* pDesc);
	HRESULT GetGeometryShaderDesc(D3D10_PASS_SHADER_DESC* pDesc);
	HRESULT GetPixelShaderDesc(D3D10_PASS_SHADER_DESC* pDesc);
	ID3D10EffectVariable GetAnnotationByIndex(UINT Index);
	ID3D10EffectVariable GetAnnotationByName(LPCSTR Name);
	HRESULT Apply(UINT Flags);
	HRESULT ComputeStateBlockMask(D3D10_STATE_BLOCK_MASK* pStateBlockMask);
	*/
}+/
/**
 * HACK to FIX vtbl[0] bug:
 * This is an example HACK how to fix all interfaces which are NOT derived from
 * IUnknown. They need the first entry in their vtbl[] point to the first
 * virtual function.
 * See:
 * http://www.digitalmars.com/d/cpp_interface.html
 * http://d.puremagic.com/issues/show_bug.cgi?id=1687
 */
struct ID3D10EffectPassVtbl {
	extern(Windows) :
	BOOL function(ID3D10EffectPass) IsValid;
	HRESULT function(ID3D10EffectPass, D3D10_PASS_DESC* pDesc) GetDesc;
	HRESULT function(ID3D10EffectPass, D3D10_PASS_SHADER_DESC* pDesc) GetVertexShaderDesc;
	HRESULT function(ID3D10EffectPass, D3D10_PASS_SHADER_DESC* pDesc) GetGeometryShaderDesc;
	HRESULT function(ID3D10EffectPass, D3D10_PASS_SHADER_DESC* pDesc) GetPixelShaderDesc;
	ID3D10EffectVariable function(ID3D10EffectPass, UINT Index) GetAnnotationByIndex;
	ID3D10EffectVariable function(ID3D10EffectPass, LPCSTR Name) GetAnnotationByName;
	HRESULT function(ID3D10EffectPass, UINT Flags) Apply;
	HRESULT function(ID3D10EffectPass, D3D10_STATE_BLOCK_MASK* pStateBlockMask) ComputeStateBlockMask;
}
alias ID3D10EffectPassVtbl** ID3D10EffectPass;

struct D3D10_TECHNIQUE_DESC {
	LPCSTR	Name;
	UINT	Passes;
	UINT	Annotations;
}

extern (C) const GUID IID_ID3D10EffectTechnique = {0xdb122ce8, 0xd1c9, 0x4292, [0xb2, 0x37, 0x24, 0xed, 0x3d, 0xe8, 0xb1, 0x75]};

/+interface ID3D10EffectTechnique {
/* TODO: fix vtbl[0] bug
	extern(Windows) :
	BOOL IsValid();
	HRESULT GetDesc(D3D10_TECHNIQUE_DESC* pDesc);
	ID3D10EffectVariable GetAnnotationByIndex(UINT Index);
	ID3D10EffectVariable GetAnnotationByName(LPCSTR Name);
	ID3D10EffectPass GetPassByIndex(UINT Index);
	ID3D10EffectPass GetPassByName(LPCSTR Name);
	HRESULT ComputeStateBlockMask(D3D10_STATE_BLOCK_MASK* pStateBlockMask);
	*/
}+/
/**
 * HACK to FIX vtbl[0] bug:
 * This is an example HACK how to fix all interfaces which are NOT derived from
 * IUnknown. They need the first entry in their vtbl[] point to the first
 * virtual function.
 * See:
 * http://www.digitalmars.com/d/cpp_interface.html
 * http://d.puremagic.com/issues/show_bug.cgi?id=1687
 */
struct ID3D10EffectTechniqueVtbl {
	extern(Windows) :
	BOOL function(ID3D10EffectTechnique) IsValid;
	HRESULT function(ID3D10EffectTechnique, D3D10_TECHNIQUE_DESC* pDesc) GetDesc;
	ID3D10EffectVariable function(ID3D10EffectTechnique, UINT Index) GetAnnotationByIndex;
	ID3D10EffectVariable function(ID3D10EffectTechnique, LPCSTR Name) GetAnnotationByName;
	ID3D10EffectPass function(ID3D10EffectTechnique, UINT Index) GetPassByIndex;
	ID3D10EffectPass function(ID3D10EffectTechnique, LPCSTR Name) GetPassByName;
	HRESULT function(ID3D10EffectTechnique, D3D10_STATE_BLOCK_MASK* pStateBlockMask) ComputeStateBlockMask;
}
alias ID3D10EffectTechniqueVtbl** ID3D10EffectTechnique;

struct D3D10_EFFECT_DESC {
	BOOL	IsChildEffect;
	UINT	ConstantBuffers;
	UINT	SharedConstantBuffers;
	UINT	GlobalVariables;
	UINT	SharedGlobalVariables;
	UINT	Techniques;
}

extern (C) const GUID IID_ID3D10Effect = {0x51b0ca8b, 0xec0b, 0x4519, [0x87, 0xd, 0x8e, 0xe1, 0xcb, 0x50, 0x17, 0xc7]};

interface ID3D10Effect : IUnknown {
	extern(Windows) :
	BOOL IsValid();
	BOOL IsPool();
	HRESULT GetDevice(ID3D10Device* ppDevice);
	HRESULT GetDesc(D3D10_EFFECT_DESC* pDesc);
	ID3D10EffectConstantBuffer GetConstantBufferByIndex(UINT Index);
	ID3D10EffectConstantBuffer GetConstantBufferByName(LPCSTR Name);
	ID3D10EffectVariable GetVariableByIndex(UINT Index);
	ID3D10EffectVariable GetVariableByName(LPCSTR Name);
	ID3D10EffectVariable GetVariableBySemantic(LPCSTR Semantic);
	ID3D10EffectTechnique GetTechniqueByIndex(UINT Index);
	ID3D10EffectTechnique GetTechniqueByName(LPCSTR Name);
	HRESULT Optimize();
	BOOL IsOptimized();
}

extern (C) const GUID IID_ID3D10EffectPool = {0x9537ab04, 0x3250, 0x412e, [0x82, 0x13, 0xfc, 0xd2, 0xf8, 0x67, 0x79, 0x33]};

interface ID3D10EffectPool : IUnknown {
	extern(Windows) :
	ID3D10Effect AsEffect();
}

HRESULT D3D10CompileEffectFromMemory(void* pData, SIZE_T DataLength, LPCSTR pSrcFileName, D3D10_SHADER_MACRO* pDefines, ID3D10Include pInclude, UINT HLSLFlags, UINT FXFlags, ID3D10Blob* ppCompiledEffect, ID3D10Blob* ppErrors);
HRESULT D3D10CreateEffectFromMemory(void* pData, SIZE_T DataLength, UINT FXFlags, ID3D10Device pDevice, ID3D10EffectPool pEffectPool, ID3D10Effect* ppEffect);
HRESULT D3D10CreateEffectPoolFromMemory(void* pData, SIZE_T DataLength, UINT FXFlags, ID3D10Device pDevice, ID3D10EffectPool* ppEffectPool);
HRESULT D3D10DisassembleEffect(ID3D10Effect pEffect, BOOL EnableColorCode, ID3D10Blob* ppDisassembly);
