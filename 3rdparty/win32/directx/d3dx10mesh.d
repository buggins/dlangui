/***********************************************************************\
*                              d3dx10mesh.d                             *
*                                                                       *
*                       Windows API header module                       *
*                                                                       *
*                       Placed into public domain                       *
\***********************************************************************/
module win32.directx.d3dx10mesh;

private import win32.windows;
private import win32.directx.d3d10;
private import win32.directx.d3dx10;

extern(C) const GUID IID_ID3DX10BaseMesh = {0x7ed943dd, 0x52e8, 0x40b5, [0xa8, 0xd8, 0x76, 0x68, 0x5c, 0x40, 0x63, 0x30]};
extern(C) const GUID IID_ID3DX10MeshBuffer = {0x4b0d117, 0x1041, 0x46b1, [0xaa, 0x8a, 0x39, 0x52, 0x84, 0x8b, 0xa2, 0x2e]};
extern(C) const GUID IID_ID3DX10Mesh = {0x4020e5c2, 0x1403, 0x4929, [0x88, 0x3f, 0xe2, 0xe8, 0x49, 0xfa, 0xc1, 0x95]};
extern(C) const GUID IID_ID3DX10PMesh = {0x8875769a, 0xd579, 0x4088, [0xaa, 0xeb, 0x53, 0x4d, 0x1a, 0xd8, 0x4e, 0x96]};
extern(C) const GUID IID_ID3DX10SPMesh = {0x667ea4c7, 0xf1cd, 0x4386, [0xb5, 0x23, 0x7c, 0x2, 0x90, 0xb8, 0x3c, 0xc5]};
extern(C) const GUID IID_ID3DX10PatchMesh = {0x3ce6cc22, 0xdbf2, 0x44f4, [0x89, 0x4d, 0xf9, 0xc3, 0x4a, 0x33, 0x71, 0x39]};

enum D3DX10_MESH {
    D3DX10_MESH_32_BIT			= 0x001,
    D3DX10_MESH_GS_ADJACENCY	= 0x004
}

struct D3DX10_ATTRIBUTE_RANGE {
    UINT	AttribId;
    UINT	FaceStart;
    UINT	FaceCount;
    UINT	VertexStart;
    UINT	VertexCount;
}

enum D3DX10_MESH_DISCARD_FLAGS {
    D3DX10_MESH_DISCARD_ATTRIBUTE_BUFFER = 0x01,
    D3DX10_MESH_DISCARD_ATTRIBUTE_TABLE = 0x02,
    D3DX10_MESH_DISCARD_POINTREPS = 0x04,
    D3DX10_MESH_DISCARD_ADJACENCY = 0x08,
    D3DX10_MESH_DISCARD_DEVICE_BUFFERS = 0x10
}

struct D3DX10_WELD_EPSILONS {
    FLOAT Position;
    FLOAT BlendWeights;
    FLOAT Normal;
    FLOAT PSize;
    FLOAT Specular;
    FLOAT Diffuse;
    FLOAT[8] Texcoord;
    FLOAT Tangent;
    FLOAT Binormal;
    FLOAT TessFactor;
}

struct D3DX10_INTERSECT_INFO {
    UINT	FaceIndex;
    FLOAT	U;
    FLOAT	V;
    FLOAT	Dist;
}

interface ID3DX10MeshBuffer : IUnknown {
	extern(Windows) :
    HRESULT Map(void** ppData, SIZE_T* pSize);
    HRESULT Unmap();
    SIZE_T GetSize();
}

interface ID3DX10Mesh : IUnknown {
	extern(Windows) :
    UINT GetFaceCount();
    UINT GetVertexCount();
    UINT GetVertexBufferCount();
    UINT GetFlags();
    HRESULT GetVertexDescription(D3D10_INPUT_ELEMENT_DESC** ppDesc, UINT* pDeclCount);
    HRESULT SetVertexData(UINT iBuffer, void* pData);
    HRESULT GetVertexBuffer(UINT iBuffer, ID3DX10MeshBuffer** ppVertexBuffer);
    HRESULT SetIndexData(void* pData, UINT cIndices);
    HRESULT GetIndexBuffer(ID3DX10MeshBuffer** ppIndexBuffer);
    HRESULT SetAttributeData(UINT* pData);
    HRESULT GetAttributeBuffer(ID3DX10MeshBuffer** ppAttributeBuffer);
    HRESULT SetAttributeTable(D3DX10_ATTRIBUTE_RANGE* pAttribTable, UINT  cAttribTableSize);
    HRESULT GetAttributeTable(D3DX10_ATTRIBUTE_RANGE* pAttribTable, UINT* pAttribTableSize);
    HRESULT GenerateAdjacencyAndPointReps(FLOAT Epsilon);
    HRESULT GenerateGSAdjacency();
    HRESULT SetAdjacencyData(UINT* pAdjacency);
    HRESULT GetAdjacencyBuffer(ID3DX10MeshBuffer** ppAdjacency);
    HRESULT SetPointRepData(UINT* pPointReps);
    HRESULT GetPointRepBuffer(ID3DX10MeshBuffer** ppPointReps);
    HRESULT Discard(D3DX10_MESH_DISCARD_FLAGS dwDiscard);
    HRESULT CloneMesh(UINT Flags, LPCSTR pPosSemantic, D3D10_INPUT_ELEMENT_DESC* pDesc, UINT  DeclCount, ID3DX10Mesh** ppCloneMesh);
    HRESULT Optimize(UINT Flags, UINT * pFaceRemap, ID3D10Blob* ppVertexRemap);
    HRESULT GenerateAttributeBufferFromTable();
	HRESULT Intersect(D3DXVECTOR3* pRayPos, D3DXVECTOR3* pRayDir, UINT* pHitCount, UINT* pFaceIndex, float* pU, float* pV, float* pDist, ID3D10Blob* ppAllHits);
	HRESULT IntersectSubset(UINT AttribId, D3DXVECTOR3* pRayPos, D3DXVECTOR3* pRayDir, UINT* pHitCount, UINT* pFaceIndex, float* pU, float* pV, float* pDist, ID3D10Blob* ppAllHits);
    HRESULT CommitToDevice();
    HRESULT DrawSubset(UINT AttribId);
    HRESULT DrawSubsetInstanced(UINT AttribId, UINT InstanceCount, UINT StartInstanceLocation);
    HRESULT GetDeviceVertexBuffer(UINT iBuffer, ID3D10Buffer** ppVertexBuffer);
    HRESULT GetDeviceIndexBuffer(ID3D10Buffer** ppIndexBuffer);
}

HRESULT D3DX10CreateMesh(ID3D10Device* pDevice, D3D10_INPUT_ELEMENT_DESC* pDeclaration, UINT  DeclCount, LPCSTR pPositionSemantic, UINT  VertexCount, UINT  FaceCount, UINT  Options, ID3DX10Mesh** ppMesh);

enum D3DX10_MESHOPT {
    D3DX10_MESHOPT_COMPACT				= 0x01000000,
    D3DX10_MESHOPT_ATTR_SORT			= 0x02000000,
    D3DX10_MESHOPT_VERTEX_CACHE			= 0x04000000,
    D3DX10_MESHOPT_STRIP_REORDER		= 0x08000000,
    D3DX10_MESHOPT_IGNORE_VERTS			= 0x10000000,
    D3DX10_MESHOPT_DO_NOT_SPLIT			= 0x20000000,
    D3DX10_MESHOPT_DEVICE_INDEPENDENT	= 0x00400000
}

extern(C) const GUID IID_ID3DX10SkinInfo = {0x420bd604, 0x1c76, 0x4a34, [0xa4, 0x66, 0xe4, 0x5d, 0x6, 0x58, 0xa3, 0x2c]};

const D3DX10_SKININFO_NO_SCALING = 0;
const D3DX10_SKININFO_SCALE_TO_1 = 1;
const D3DX10_SKININFO_SCALE_TO_TOTAL = 2;

struct D3DX10_SKINNING_CHANNEL {
    UINT SrcOffset;
    UINT DestOffset;
    BOOL IsNormal;
}

interface ID3DX10SkinInfo : IUnknown {
	extern(Windows) :
	HRESULT QueryInterface(REFIID iid, LPVOID* ppv);
	ULONG AddRef();
	ULONG Release();
	UINT GetNumVertices();
	UINT GetNumBones();
	UINT GetMaxBoneInfluences();
	HRESULT AddVertices(UINT Count);
	HRESULT RemapVertices(UINT NewVertexCount, UINT* pVertexRemap);
	HRESULT AddBones(UINT Count);
	HRESULT RemoveBone(UINT Index);
	HRESULT RemapBones(UINT NewBoneCount, UINT* pBoneRemap);
	HRESULT AddBoneInfluences(UINT BoneIndex, UINT InfluenceCount, UINT* pIndices, float* pWeights);
	HRESULT ClearBoneInfluences(UINT BoneIndex);
	UINT GetBoneInfluenceCount(UINT BoneIndex);
	HRESULT GetBoneInfluences(UINT BoneIndex, UINT Offset, UINT Count, UINT* pDestIndices, float* pDestWeights);
	HRESULT FindBoneInfluenceIndex(UINT BoneIndex, UINT VertexIndex, UINT* pInfluenceIndex);
	HRESULT SetBoneInfluence(UINT BoneIndex, UINT InfluenceIndex, float Weight);
	HRESULT GetBoneInfluence(UINT BoneIndex, UINT InfluenceIndex, float* pWeight);
	HRESULT Compact(UINT MaxPerVertexInfluences, UINT ScaleMode, float MinWeight);
	HRESULT DoSoftwareSkinning(UINT StartVertex, UINT VertexCount, void* pSrcVertices, UINT SrcStride, void* pDestVertices, UINT DestStride, D3DXMATRIX* pBoneMatrices, D3DXMATRIX* pInverseTransposeBoneMatrices, D3DX10_SKINNING_CHANNEL* pChannelDescs, UINT NumChannels);
}

HRESULT D3DX10CreateSkinInfo(ID3DX10SkinInfo* ppSkinInfo);

struct D3DX10_ATTRIBUTE_WEIGHTS {
	FLOAT Position;
	FLOAT Boundary;
	FLOAT Normal;
	FLOAT Diffuse;
	FLOAT Specular;
	FLOAT[8] Texcoord;
	FLOAT Tangent;
	FLOAT Binormal;
}

