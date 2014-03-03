// D3DX Types and Constants ---------------------------------------------------------------------------------------

module win32.directx.d3dx9;

public import win32.directx.d3d9;
public import win32.windows;

alias D3DMATRIX D3DXMATRIX;

const uint MAXD3DDECLLENGTH = 64;
const uint MAX_FVF_DECL_SIZE = MAXD3DDECLLENGTH + 1;

align(4) struct D3DXATTRIBUTERANGE
{
    DWORD AttribId;
    DWORD FaceStart;
    DWORD FaceCount;
    DWORD VertexStart;
    DWORD VertexCount;
}

align(4) struct D3DXVECTOR2
{
	float x = 0, y = 0;

	static D3DXVECTOR2 opCall(float x, float y)
	{
		D3DXVECTOR2 v;
		v.x = x;
		v.y = y;
		return v;
	}
}

alias D3DVECTOR D3DXVECTOR3;

align(4) struct D3DXVECTOR4
{
	float x = 0, y = 0, z = 0, w = 0;

	static D3DXVECTOR4 opCall(float x, float y, float z, float w)
	{
		D3DXVECTOR4 v;
		v.x = x;
		v.y = y;
		v.z = z;
		v.w = w;
		return v;
	}
}

align(4) struct D3DXQUATERNION
{
	float x = 0, y = 0, z = 0, w = 0;
}

align(4) struct D3DXFRAME
{
    LPSTR                   Name;
    D3DXMATRIX              TransformationMatrix;

    D3DXMESHCONTAINER*     pMeshContainer;

    D3DXFRAME       *pFrameSibling;
    D3DXFRAME       *pFrameFirstChild;
}

align(4) struct D3DXMESHCONTAINER
{
    LPSTR                   Name;

    D3DXMESHDATA            MeshData;

    D3DXMATERIAL*          pMaterials;
    D3DXEFFECTINSTANCE*    pEffects;
    DWORD                   NumMaterials;
    DWORD                  *pAdjacency;

    ID3DXSkinInfo          pSkinInfo;

    D3DXMESHCONTAINER* pNextMeshContainer;
}

align(4) struct D3DXMESHDATA
{
    D3DXMESHDATATYPE Type;

    // current mesh data interface
    union
    {
        ID3DXMesh              pMesh;
        ID3DXPMesh             pPMesh;
        ID3DXPatchMesh         pPatchMesh;
    }
}

alias uint D3DXMESHDATATYPE;
enum : uint
{
    D3DXMESHTYPE_MESH      = 0x001,             // Normal ID3DXMesh data
    D3DXMESHTYPE_PMESH     = 0x002,             // Progressive Mesh - ID3DXPMesh
    D3DXMESHTYPE_PATCHMESH = 0x003             // Patch Mesh - ID3DXPatchMesh
}

align(4) struct D3DXMATERIAL
{
    D3DMATERIAL9  MatD3D;
    LPSTR         pTextureFilename;
}

alias uint D3DXEFFECTDEFAULTTYPE;
enum : uint
{
    D3DXEDT_STRING = 0x1,       // pValue points to a null terminated ASCII string
    D3DXEDT_FLOATS = 0x2,       // pValue points to an array of floats - number of floats is NumBytes / sizeof(float)
    D3DXEDT_DWORD  = 0x3       // pValue points to a DWORD
}

align(4) struct D3DXEFFECTDEFAULT
{
    LPSTR                 pParamName;
    D3DXEFFECTDEFAULTTYPE Type;           // type of the data pointed to by pValue
    DWORD                 NumBytes;       // size in bytes of the data pointed to by pValue
    LPVOID                pValue;         // data for the default of the effect
}

align(4) struct D3DXEFFECTINSTANCE
{
    LPSTR               pEffectFilename;
    DWORD               NumDefaults;
    D3DXEFFECTDEFAULT* pDefaults;
}

alias uint D3DXPATCHMESHTYPE;
enum : uint
{
    D3DXPATCHMESH_RECT   = 0x001,
    D3DXPATCHMESH_TRI    = 0x002,
    D3DXPATCHMESH_NPATCH = 0x003
}

align(4) struct D3DXPATCHINFO
{
    D3DXPATCHMESHTYPE PatchType;
    D3DDEGREETYPE Degree;
    D3DBASISTYPE Basis;
}

const uint LF_FACESIZE = 32;

align(4) struct D3DXFONT_DESCA
{
    INT Height;
    UINT Width;
    UINT Weight;
    UINT MipLevels;
    BOOL Italic;
    BYTE CharSet;
    BYTE OutputPrecision;
    BYTE Quality;
    BYTE PitchAndFamily;
    CHAR FaceName[LF_FACESIZE];
}

align(4) struct D3DXFONT_DESCW
{
    INT Height;
    UINT Width;
    UINT Weight;
    UINT MipLevels;
    BOOL Italic;
    BYTE CharSet;
    BYTE OutputPrecision;
    BYTE Quality;
    BYTE PitchAndFamily;
    WCHAR FaceName[LF_FACESIZE];
}

align(4) struct TEXTMETRICA
{
    LONG        tmHeight;
    LONG        tmAscent;
    LONG        tmDescent;
    LONG        tmInternalLeading;
    LONG        tmExternalLeading;
    LONG        tmAveCharWidth;
    LONG        tmMaxCharWidth;
    LONG        tmWeight;
    LONG        tmOverhang;
    LONG        tmDigitizedAspectX;
    LONG        tmDigitizedAspectY;
    BYTE        tmFirstChar;
    BYTE        tmLastChar;
    BYTE        tmDefaultChar;
    BYTE        tmBreakChar;
    BYTE        tmItalic;
    BYTE        tmUnderlined;
    BYTE        tmStruckOut;
    BYTE        tmPitchAndFamily;
    BYTE        tmCharSet;
}

align(4) struct TEXTMETRICW
{
    LONG        tmHeight;
    LONG        tmAscent;
    LONG        tmDescent;
    LONG        tmInternalLeading;
    LONG        tmExternalLeading;
    LONG        tmAveCharWidth;
    LONG        tmMaxCharWidth;
    LONG        tmWeight;
    LONG        tmOverhang;
    LONG        tmDigitizedAspectX;
    LONG        tmDigitizedAspectY;
    WCHAR       tmFirstChar;
    WCHAR       tmLastChar;
    WCHAR       tmDefaultChar;
    WCHAR       tmBreakChar;
    BYTE        tmItalic;
    BYTE        tmUnderlined;
    BYTE        tmStruckOut;
    BYTE        tmPitchAndFamily;
    BYTE        tmCharSet;
}

align(4) struct D3DXEFFECT_DESC
{
    LPCSTR Creator;                     // Creator string
    UINT Parameters;                    // Number of parameters
    UINT Techniques;                    // Number of techniques
    UINT Functions;                     // Number of function entrypoints
}

alias char* D3DXHANDLE;

align(4) struct D3DXPARAMETER_DESC
{
    LPCSTR Name;                        // Parameter name
    LPCSTR Semantic;                    // Parameter semantic
    D3DXPARAMETER_CLASS Class;          // Class
    D3DXPARAMETER_TYPE Type;            // Component type
    UINT Rows;                          // Number of rows
    UINT Columns;                       // Number of columns
    UINT Elements;                      // Number of array elements
    UINT Annotations;                   // Number of annotations
    UINT StructMembers;                 // Number of structure member sub-parameters
    DWORD Flags;                        // D3DX_PARAMETER_* flags
    UINT Bytes;                         // Parameter size, in bytes
}

alias uint D3DXPARAMETER_CLASS;
enum : uint
{
    D3DXPC_SCALAR,
    D3DXPC_VECTOR,
    D3DXPC_MATRIX_ROWS,
    D3DXPC_MATRIX_COLUMNS,
    D3DXPC_OBJECT,
    D3DXPC_STRUCT
}

alias uint D3DXPARAMETER_TYPE;
enum : uint
{
    D3DXPT_VOID,
    D3DXPT_BOOL,
    D3DXPT_INT,
    D3DXPT_FLOAT,
    D3DXPT_STRING,
    D3DXPT_TEXTURE,
    D3DXPT_TEXTURE1D,
    D3DXPT_TEXTURE2D,
    D3DXPT_TEXTURE3D,
    D3DXPT_TEXTURECUBE,
    D3DXPT_SAMPLER,
    D3DXPT_SAMPLER1D,
    D3DXPT_SAMPLER2D,
    D3DXPT_SAMPLER3D,
    D3DXPT_SAMPLERCUBE,
    D3DXPT_PIXELSHADER,
    D3DXPT_VERTEXSHADER,
    D3DXPT_PIXELFRAGMENT,
    D3DXPT_VERTEXFRAGMENT
}

align(4) struct D3DXTECHNIQUE_DESC
{
    LPCSTR Name;                        // Technique name
    UINT Passes;                        // Number of passes
    UINT Annotations;                   // Number of annotations
}

align(4) struct D3DXPASS_DESC
{
    LPCSTR Name;                        // Pass name
    UINT Annotations;                   // Number of annotations

    DWORD *pVertexShaderFunction; // Vertex shader function
    DWORD *pPixelShaderFunction;  // Pixel shader function
}

align(4) struct D3DXFUNCTION_DESC
{
    LPCSTR Name;                        // Function name
    UINT Annotations;                   // Number of annotations
}

struct D3DXTRACK_DESC
{
    DWORD Priority;
    FLOAT Weight = 0;
    FLOAT Speed = 0;
    double Position = 0;
    BOOL Enable;
}

align(4) struct D3DXEVENT_DESC
{
    DWORD      Type;
    UINT                Track;
    double              StartTime = 0;
    double              Duration = 0;
    DWORD Transition;
    union
    {
        FLOAT           Weight = 0;
        FLOAT           Speed;
        double          Position;
        BOOL            Enable;
    };
}

align(4) struct D3DXKEY_VECTOR3
{
    FLOAT Time = 0;
    D3DXVECTOR3 Value;
}

align(4) struct D3DXKEY_QUATERNION
{
    FLOAT Time = 0;
    D3DXQUATERNION Value;
}

align(4) struct D3DXKEY_CALLBACK
{
    FLOAT Time = 0;
    LPVOID pCallbackData;
}

align(4) struct D3DXIMAGE_INFO
{
    UINT                    Width;
    UINT                    Height;
    UINT                    Depth;
    UINT                    MipLevels;
    D3DFORMAT               Format;
    D3DRESOURCETYPE         ResourceType;
    D3DXIMAGE_FILEFORMAT    ImageFileFormat;
}

alias uint D3DXIMAGE_FILEFORMAT;
enum : uint
{
    D3DXIFF_BMP         = 0,
    D3DXIFF_JPG         = 1,
    D3DXIFF_TGA         = 2,
    D3DXIFF_PNG         = 3,
    D3DXIFF_DDS         = 4,
    D3DXIFF_PPM         = 5,
    D3DXIFF_DIB         = 6,
}

align(4) struct D3DXATTRIBUTEWEIGHTS
{
    FLOAT Position = 0;
    FLOAT Boundary = 0;
    FLOAT Normal = 0;
    FLOAT Diffuse = 0;
    FLOAT Specular = 0;
    FLOAT Texcoord[8] = 0;
    FLOAT Tangent = 0;
    FLOAT Binormal = 0;
}

align(4) struct D3DXPLANE
{
	FLOAT a = 0, b = 0, c = 0, d = 0;
}

alias uint D3DXMESH;
enum : uint
{
    D3DXMESH_32BIT                  = 0x001,
    D3DXMESH_DONOTCLIP              = 0x002,
    D3DXMESH_POINTS                 = 0x004,
    D3DXMESH_RTPATCHES              = 0x008,
    D3DXMESH_NPATCHES               = 0x4000,
    D3DXMESH_VB_SYSTEMMEM           = 0x010,
    D3DXMESH_VB_MANAGED             = 0x020,
    D3DXMESH_VB_WRITEONLY           = 0x040,
    D3DXMESH_VB_DYNAMIC             = 0x080,
    D3DXMESH_VB_SOFTWAREPROCESSING = 0x8000,
    D3DXMESH_IB_SYSTEMMEM           = 0x100,
    D3DXMESH_IB_MANAGED             = 0x200,
    D3DXMESH_IB_WRITEONLY           = 0x400,
    D3DXMESH_IB_DYNAMIC             = 0x800,
    D3DXMESH_IB_SOFTWAREPROCESSING= 0x10000,
    D3DXMESH_VB_SHARE               = 0x1000,
    D3DXMESH_USEHWONLY              = 0x2000,
    D3DXMESH_SYSTEMMEM              = 0x110,
    D3DXMESH_MANAGED                = 0x220,
    D3DXMESH_WRITEONLY              = 0x440,
    D3DXMESH_DYNAMIC                = 0x880,
    D3DXMESH_SOFTWAREPROCESSING   = 0x18000,
}

align(4) struct D3DXMACRO
{
    LPCSTR Name;
    LPCSTR Definition;
}

align(4) struct D3DXSEMANTIC
{
    UINT Usage;
    UINT UsageIndex;
}

alias uint D3DXINCLUDE_TYPE;
enum : uint
{
    D3DXINC_LOCAL,
    D3DXINC_SYSTEM,
}

enum : uint
{
	D3DXFX_DONOTSAVESTATE         = (1 << 0),
	D3DXFX_DONOTSAVESHADERSTATE   = (1 << 1),
	D3DXFX_DONOTSAVESAMPLERSTATE  = (1 << 2),
	D3DXFX_NOT_CLONEABLE          = (1 << 11)
}

alias uint D3DXMESHSIMP;
enum : uint
{
    D3DXMESHSIMP_VERTEX   = 0x1,
    D3DXMESHSIMP_FACE     = 0x2
}

enum : uint
{
	DT_TOP                      = 0x00000000,
	DT_LEFT                     = 0x00000000,
	DT_CENTER                   = 0x00000001,
	DT_RIGHT                    = 0x00000002,
	DT_VCENTER                  = 0x00000004,
	DT_BOTTOM                   = 0x00000008,
	DT_WORDBREAK                = 0x00000010,
	DT_SINGLELINE               = 0x00000020,
	DT_EXPANDTABS               = 0x00000040,
	DT_TABSTOP                  = 0x00000080,
	DT_NOCLIP                   = 0x00000100,
	DT_EXTERNALLEADING          = 0x00000200,
	DT_CALCRECT                 = 0x00000400,
	DT_NOPREFIX                 = 0x00000800,
	DT_INTERNAL                 = 0x00001000
}

enum : uint
{
	D3DXSPRITE_DONOTSAVESTATE               = (1 << 0),
	D3DXSPRITE_DONOTMODIFY_RENDERSTATE      = (1 << 1),
	D3DXSPRITE_OBJECTSPACE                  = (1 << 2),
	D3DXSPRITE_BILLBOARD                    = (1 << 3),
	D3DXSPRITE_ALPHABLEND                   = (1 << 4),
	D3DXSPRITE_SORT_TEXTURE                 = (1 << 5),
	D3DXSPRITE_SORT_DEPTH_FRONTTOBACK       = (1 << 6),
	D3DXSPRITE_SORT_DEPTH_BACKTOFRONT       = (1 << 7)
}

enum : uint
{
	D3DX_FILTER_NONE             = (1 << 0),
	D3DX_FILTER_POINT            = (2 << 0),
	D3DX_FILTER_LINEAR           = (3 << 0),
	D3DX_FILTER_TRIANGLE         = (4 << 0),
	D3DX_FILTER_BOX              = (5 << 0),
	D3DX_FILTER_MIRROR_U         = (1 << 16),
	D3DX_FILTER_MIRROR_V         = (2 << 16),
	D3DX_FILTER_MIRROR_W         = (4 << 16),
	D3DX_FILTER_MIRROR           = (7 << 16),
	D3DX_FILTER_DITHER           = (1 << 19),
	D3DX_FILTER_DITHER_DIFFUSION = (2 << 19),
	D3DX_FILTER_SRGB_IN          = (1 << 21),
	D3DX_FILTER_SRGB_OUT         = (2 << 21),
	D3DX_FILTER_SRGB             = (3 << 21)
}

const uint D3DX_DEFAULT            = cast(UINT) -1;

alias uint D3DXMESHOPT;
enum : uint
{
    D3DXMESHOPT_COMPACT       = 0x01000000,
    D3DXMESHOPT_ATTRSORT      = 0x02000000,
    D3DXMESHOPT_VERTEXCACHE   = 0x04000000,
    D3DXMESHOPT_STRIPREORDER  = 0x08000000,
    D3DXMESHOPT_IGNOREVERTS   = 0x10000000,  // optimize faces only, don't touch vertices
    D3DXMESHOPT_DONOTSPLIT    = 0x20000000,  // do not split vertices shared between attribute groups when attribute sorting
    D3DXMESHOPT_DEVICEINDEPENDENT = 0x00400000  // Only affects VCache.  uses a static known good cache size for all cards
}

enum : uint
{
    D3DXPLAY_LOOP = 0,
    D3DXPLAY_ONCE = 1,
    D3DXPLAY_PINGPONG = 2
}
alias uint D3DXPLAYBACK_TYPE;


// D3DX Interfaces ---------------------------------------------------------------------------------------

interface ID3DXSkinInfo : IUnknown
{
	extern(Windows):

    // Specify the which vertices do each bones influence and by how much
    HRESULT SetBoneInfluence(DWORD bone, DWORD numInfluences, DWORD* vertices, FLOAT* weights);
	HRESULT SetBoneVertexInfluence(DWORD boneNum, DWORD influenceNum, float weight);
    DWORD GetNumBoneInfluences(DWORD bone);
	HRESULT GetBoneInfluence(DWORD bone, DWORD* vertices, FLOAT* weights);
	HRESULT GetBoneVertexInfluence(DWORD boneNum, DWORD influenceNum, float *pWeight, DWORD *pVertexNum);
    HRESULT GetMaxVertexInfluences(DWORD* maxVertexInfluences);
    DWORD GetNumBones();
	HRESULT FindBoneVertexInfluenceIndex(DWORD boneNum, DWORD vertexNum, DWORD *pInfluenceIndex);

    // This gets the max face influences based on a triangle mesh with the specified index buffer
    HRESULT GetMaxFaceInfluences(IDirect3DIndexBuffer9 pIB, DWORD NumFaces, DWORD* maxFaceInfluences);

    // Set min bone influence. Bone influences that are smaller than this are ignored
    HRESULT SetMinBoneInfluence(FLOAT MinInfl);
    // Get min bone influence.
    FLOAT GetMinBoneInfluence();

    // Bone names are returned by D3DXLoadSkinMeshFromXof. They are not used by any other method of this object
    HRESULT SetBoneName(DWORD Bone, LPCSTR pName); // pName is copied to an internal string buffer
    LPCSTR GetBoneName(DWORD Bone); // A pointer to an internal string buffer is returned. Do not free this.

    // Bone offset matrices are returned by D3DXLoadSkinMeshFromXof. They are not used by any other method of this object
    HRESULT SetBoneOffsetMatrix(DWORD Bone, D3DXMATRIX *pBoneTransform); // pBoneTransform is copied to an internal buffer
    D3DXMATRIX* GetBoneOffsetMatrix(DWORD Bone); // A pointer to an internal matrix is returned. Do not free this.

    // Clone a skin info object
    HRESULT Clone(ID3DXSkinInfo* ppSkinInfo);

    // Update bone influence information to match vertices after they are reordered. This should be called
    // if the target vertex buffer has been reordered externally.
    HRESULT Remap(DWORD NumVertices, DWORD* pVertexRemap);

    // These methods enable the modification of the vertex layout of the vertices that will be skinned
    HRESULT SetFVF(DWORD FVF);
    HRESULT SetDeclaration(D3DVERTEXELEMENT9 *pDeclaration);
    DWORD GetFVF();
    HRESULT GetDeclaration(D3DVERTEXELEMENT9 Declaration[MAX_FVF_DECL_SIZE]);

    // Apply SW skinning based on current pose matrices to the target vertices.
    HRESULT UpdateSkinnedMesh(
        D3DXMATRIX* pBoneTransforms,
        D3DXMATRIX* pBoneInvTransposeTransforms,
        LPCVOID pVerticesSrc,
        PVOID pVerticesDst);

    // Takes a mesh and returns a new mesh with per vertex blend weights and a bone combination
    // table that describes which bones affect which subsets of the mesh
    HRESULT ConvertToBlendedMesh(
        ID3DXMesh pMesh,
        DWORD Options,
        DWORD *pAdjacencyIn,
        LPDWORD pAdjacencyOut,
        DWORD* pFaceRemap,
        ID3DXBuffer* ppVertexRemap,
        DWORD* pMaxFaceInfl,
        DWORD* pNumBoneCombinations,
        ID3DXBuffer* ppBoneCombinationTable,
        ID3DXMesh* ppMesh);

    // Takes a mesh and returns a new mesh with per vertex blend weights and indices
    // and a bone combination table that describes which bones palettes affect which subsets of the mesh
    HRESULT ConvertToIndexedBlendedMesh(
        ID3DXMesh pMesh,
        DWORD Options,
        DWORD paletteSize,
        DWORD *pAdjacencyIn,
        LPDWORD pAdjacencyOut,
        DWORD* pFaceRemap,
        ID3DXBuffer* ppVertexRemap,
        DWORD* pMaxVertexInfl,
		DWORD *pNumBoneCombinations,
        ID3DXBuffer* ppBoneCombinationTable,
        ID3DXMesh* ppMesh);
}

interface ID3DXBaseMesh : IUnknown
{
    extern(Windows):

    // ID3DXBaseMesh
    HRESULT DrawSubset( DWORD AttribId) ;
    DWORD GetNumFaces() ;
    DWORD GetNumVertices() ;
    DWORD GetFVF() ;
    HRESULT GetDeclaration( D3DVERTEXELEMENT9 Declaration[MAX_FVF_DECL_SIZE]) ;
    DWORD GetNumBytesPerVertex() ;
    DWORD GetOptions() ;
    HRESULT GetDevice( IDirect3DDevice9* ppDevice) ;
    HRESULT CloneMeshFVF( DWORD Options,
                DWORD FVF, IDirect3DDevice9 pD3DDevice, ID3DXMesh* ppCloneMesh) ;
    HRESULT CloneMesh( DWORD Options,
                 D3DVERTEXELEMENT9 *pDeclaration, IDirect3DDevice9 pD3DDevice, ID3DXMesh* ppCloneMesh) ;
    HRESULT GetVertexBuffer( IDirect3DVertexBuffer9* ppVB) ;
    HRESULT GetIndexBuffer( IDirect3DIndexBuffer9* ppIB) ;
    HRESULT LockVertexBuffer( DWORD Flags, LPVOID *ppData) ;
    HRESULT UnlockVertexBuffer() ;
    HRESULT LockIndexBuffer( DWORD Flags, LPVOID *ppData) ;
    HRESULT UnlockIndexBuffer() ;
    HRESULT GetAttributeTable(
                 D3DXATTRIBUTERANGE *pAttribTable, DWORD* pAttribTableSize) ;

    HRESULT ConvertPointRepsToAdjacency(  DWORD* pPRep, DWORD* pAdjacency) ;
    HRESULT ConvertAdjacencyToPointReps(  DWORD* pAdjacency, DWORD* pPRep) ;
    HRESULT GenerateAdjacency( FLOAT Epsilon, DWORD* pAdjacency) ;

    HRESULT UpdateSemantics( D3DVERTEXELEMENT9 Declaration[MAX_FVF_DECL_SIZE]) ;
}

interface ID3DXMesh : ID3DXBaseMesh
{
    extern(Windows):

    // ID3DXMesh
    HRESULT LockAttributeBuffer( DWORD Flags, DWORD** ppData) ;
    HRESULT UnlockAttributeBuffer() ;
    HRESULT Optimize( DWORD Flags,  DWORD* pAdjacencyIn, DWORD* pAdjacencyOut,
                     DWORD* pFaceRemap, ID3DXBuffer *ppVertexRemap,
                     ID3DXMesh* ppOptMesh) ;
    HRESULT OptimizeInplace( DWORD Flags,  DWORD* pAdjacencyIn, DWORD* pAdjacencyOut,
                     DWORD* pFaceRemap, ID3DXBuffer *ppVertexRemap) ;
    HRESULT SetAttributeTable(  D3DXATTRIBUTERANGE *pAttribTable, DWORD cAttribTableSize) ;
}

interface ID3DXBuffer : IUnknown
{
    extern(Windows):

    // ID3DXBuffer
    LPVOID GetBufferPointer();
    DWORD GetBufferSize();
}

interface ID3DXPMesh : ID3DXBaseMesh
{
    extern(Windows):

    // ID3DXPMesh
    HRESULT ClonePMeshFVF( DWORD Options,
                DWORD FVF, IDirect3DDevice9 pD3DDevice, ID3DXPMesh* ppCloneMesh) ;
    HRESULT ClonePMesh( DWORD Options,
                 D3DVERTEXELEMENT9 *pDeclaration, IDirect3DDevice9 pD3DDevice, ID3DXPMesh* ppCloneMesh) ;
    HRESULT SetNumFaces( DWORD Faces) ;
    HRESULT SetNumVertices( DWORD Vertices) ;
    DWORD GetMaxFaces() ;
    DWORD GetMinFaces() ;
    DWORD GetMaxVertices() ;
    DWORD GetMinVertices() ;
    HRESULT Save( void *pStream,  D3DXMATERIAL* pMaterials,  D3DXEFFECTINSTANCE* pEffectInstances, DWORD NumMaterials) ;

    HRESULT Optimize( DWORD Flags, DWORD* pAdjacencyOut,
                     DWORD* pFaceRemap, ID3DXBuffer *ppVertexRemap,
                     ID3DXMesh* ppOptMesh) ;

    HRESULT OptimizeBaseLOD( DWORD Flags, DWORD* pFaceRemap) ;
    HRESULT TrimByFaces( DWORD NewFacesMin, DWORD NewFacesMax, DWORD *rgiFaceRemap, DWORD *rgiVertRemap) ;
    HRESULT TrimByVertices( DWORD NewVerticesMin, DWORD NewVerticesMax, DWORD *rgiFaceRemap, DWORD *rgiVertRemap) ;

    HRESULT GetAdjacency( DWORD* pAdjacency) ;

    //  Used to generate the immediate "ancestor" for each vertex when it is removed by a vsplit.  Allows generation of geomorphs
    //     Vertex buffer must be equal to or greater than the maximum number of vertices in the pmesh
    HRESULT GenerateVertexHistory( DWORD* pVertexHistory) ;
}

interface ID3DXPatchMesh : IUnknown
{
    extern(Windows):

    // ID3DXPatchMesh

    // Return creation parameters
    DWORD GetNumPatches() ;
    DWORD GetNumVertices() ;
    HRESULT GetDeclaration( D3DVERTEXELEMENT9 Declaration[MAX_FVF_DECL_SIZE]) ;
    DWORD GetControlVerticesPerPatch() ;
    DWORD GetOptions() ;
    HRESULT GetDevice( IDirect3DDevice9 *ppDevice) ;
    HRESULT GetPatchInfo( D3DXPATCHINFO* PatchInfo) ;

    // Control mesh access
    HRESULT GetVertexBuffer( IDirect3DVertexBuffer9* ppVB) ;
    HRESULT GetIndexBuffer( IDirect3DIndexBuffer9* ppIB) ;
    HRESULT LockVertexBuffer( DWORD flags, LPVOID *ppData) ;
    HRESULT UnlockVertexBuffer() ;
    HRESULT LockIndexBuffer( DWORD flags, LPVOID *ppData) ;
    HRESULT UnlockIndexBuffer() ;
    HRESULT LockAttributeBuffer( DWORD flags, DWORD** ppData) ;
    HRESULT UnlockAttributeBuffer() ;

    //  function returns the size of the tessellated mesh given a tessellation level.
    //  assumes uniform tessellation. For adaptive tessellation the Adaptive parameter must
    // be set to TRUE and TessellationLevel should be the max tessellation.
    //  will result in the max mesh size necessary for adaptive tessellation.
    HRESULT GetTessSize( FLOAT fTessLevel,DWORD Adaptive, DWORD *NumTriangles,DWORD *NumVertices) ;

    //GenerateAdjacency determines which patches are adjacent with provided tolerance
    // information is used internally to optimize tessellation
    HRESULT GenerateAdjacency( FLOAT Tolerance) ;

    //CloneMesh Creates a new patchmesh with the specified decl, and converts the vertex buffer
    //to the new decl. Entries in the new decl which are new are set to 0. If the current mesh
    //has adjacency, the new mesh will also have adjacency
    HRESULT CloneMesh( DWORD Options,  D3DVERTEXELEMENT9 *pDecl, ID3DXPatchMesh *pMesh) ;

    // Optimizes the patchmesh for efficient tessellation.  function is designed
    // to perform one time optimization for patch meshes that need to be tessellated
    // repeatedly by calling the Tessellate() method. The optimization performed is
    // independent of the actual tessellation level used.
    // Currently Flags is unused.
    // If vertices are changed, Optimize must be called again
    HRESULT Optimize( DWORD flags) ;

    //gets and sets displacement parameters
    //displacement maps can only be 2D textures MIP-MAPPING is ignored for non adapative tessellation
    HRESULT SetDisplaceParam( IDirect3DBaseTexture9 Texture,
                              D3DTEXTUREFILTERTYPE MinFilter,
                              D3DTEXTUREFILTERTYPE MagFilter,
                              D3DTEXTUREFILTERTYPE MipFilter,
                              D3DTEXTUREADDRESS Wrap,
                              DWORD dwLODBias) ;

    HRESULT GetDisplaceParam( IDirect3DBaseTexture9 *Texture,
                                D3DTEXTUREFILTERTYPE *MinFilter,
                                D3DTEXTUREFILTERTYPE *MagFilter,
                                D3DTEXTUREFILTERTYPE *MipFilter,
                                D3DTEXTUREADDRESS *Wrap,
                                DWORD *dwLODBias) ;

    // Performs the uniform tessellation based on the tessellation level.
    //  function will perform more efficiently if the patch mesh has been optimized using the Optimize() call.
    HRESULT Tessellate( FLOAT fTessLevel,ID3DXMesh pMesh) ;

    // Performs adaptive tessellation based on the Z based adaptive tessellation criterion.
    // pTrans specifies a 4D vector that is dotted with the vertices to get the per vertex
    // adaptive tessellation amount. Each edge is tessellated to the average of the criterion
    // at the 2 vertices it connects.
    // MaxTessLevel specifies the upper limit for adaptive tesselation.
    //  function will perform more efficiently if the patch mesh has been optimized using the Optimize() call.
    HRESULT TessellateAdaptive(
         D3DXVECTOR4 *pTrans,
        DWORD dwMaxTessLevel,
        DWORD dwMinTessLevel,
        ID3DXMesh pMesh) ;

}

interface ID3DXFont : IUnknown
{
    extern(Windows):

    // ID3DXFont
    HRESULT GetDevice( IDirect3DDevice9 *ppDevice) ;
    HRESULT GetDescA( D3DXFONT_DESCA *pDesc) ;
    HRESULT GetDescW( D3DXFONT_DESCW *pDesc) ;
    BOOL GetTextMetricsA( TEXTMETRICA *pTextMetrics) ;
    BOOL GetTextMetricsW( TEXTMETRICW *pTextMetrics) ;

    HDC GetDC() ;
    HRESULT GetGlyphData( UINT Glyph, IDirect3DTexture9 *ppTexture, RECT *pBlackBox, POINT *pCellInc) ;

    HRESULT PreloadCharacters( UINT First, UINT Last) ;
    HRESULT PreloadGlyphs( UINT First, UINT Last) ;
    HRESULT PreloadTextA( LPCSTR pString, INT Count) ;
    HRESULT PreloadTextW( LPCWSTR pString, INT Count) ;

    INT DrawTextA( ID3DXSprite pSprite, LPCSTR pString, INT Count, LPRECT pRect, DWORD Format, D3DCOLOR Color) ;
    INT DrawTextW( ID3DXSprite pSprite, LPCWSTR pString, INT Count, LPRECT pRect, DWORD Format, D3DCOLOR Color) ;

    HRESULT OnLostDevice() ;
    HRESULT OnResetDevice() ;
}

interface ID3DXSprite : IUnknown
{
    extern(Windows):

    // ID3DXSprite
    HRESULT GetDevice( IDirect3DDevice9* ppDevice) ;

    HRESULT GetTransform( D3DXMATRIX *pTransform) ;
    HRESULT SetTransform(  D3DXMATRIX *pTransform) ;

    HRESULT SetWorldViewRH(  D3DXMATRIX *pWorld,  D3DXMATRIX *pView) ;
    HRESULT SetWorldViewLH(  D3DXMATRIX *pWorld,  D3DXMATRIX *pView) ;

    HRESULT Begin( DWORD Flags) ;
    HRESULT Draw( IDirect3DTexture9 pTexture,  RECT *pSrcRect,  D3DXVECTOR3 *pCenter,  D3DXVECTOR3 *pPosition, D3DCOLOR Color) ;
    HRESULT Flush() ;
    HRESULT End() ;

    HRESULT OnLostDevice() ;
    HRESULT OnResetDevice() ;
}

interface ID3DXBaseEffect : IUnknown
{
    extern(Windows):

    // Descs
    HRESULT GetDesc( D3DXEFFECT_DESC* pDesc) ;
    HRESULT GetParameterDesc( D3DXHANDLE hParameter, D3DXPARAMETER_DESC* pDesc) ;
    HRESULT GetTechniqueDesc( D3DXHANDLE hTechnique, D3DXTECHNIQUE_DESC* pDesc) ;
    HRESULT GetPassDesc( D3DXHANDLE hPass, D3DXPASS_DESC* pDesc) ;
    HRESULT GetFunctionDesc( D3DXHANDLE hShader, D3DXFUNCTION_DESC* pDesc) ;

    // Handle operations
    D3DXHANDLE GetParameter( D3DXHANDLE hParameter, UINT Index) ;
    D3DXHANDLE GetParameterByName( D3DXHANDLE hParameter, LPCSTR pName) ;
    D3DXHANDLE GetParameterBySemantic( D3DXHANDLE hParameter, LPCSTR pSemantic) ;
    D3DXHANDLE GetParameterElement( D3DXHANDLE hParameter, UINT Index) ;
    D3DXHANDLE GetTechnique( UINT Index) ;
    D3DXHANDLE GetTechniqueByName( LPCSTR pName) ;
    D3DXHANDLE GetPass( D3DXHANDLE hTechnique, UINT Index) ;
    D3DXHANDLE GetPassByName( D3DXHANDLE hTechnique, LPCSTR pName) ;
    D3DXHANDLE GetFunction( UINT Index) ;
    D3DXHANDLE GetFunctionByName( LPCSTR pName) ;
    D3DXHANDLE GetAnnotation( D3DXHANDLE hObject, UINT Index) ;
    D3DXHANDLE GetAnnotationByName( D3DXHANDLE hObject, LPCSTR pName) ;

    // Get/Set Parameters
    HRESULT SetValue( D3DXHANDLE hParameter, LPCVOID pData, UINT Bytes) ;
    HRESULT GetValue( D3DXHANDLE hParameter, LPVOID pData, UINT Bytes) ;
    HRESULT SetBool( D3DXHANDLE hParameter, BOOL b) ;
    HRESULT GetBool( D3DXHANDLE hParameter, BOOL* pb) ;
    HRESULT SetBoolArray( D3DXHANDLE hParameter,  BOOL* pb, UINT Count) ;
    HRESULT GetBoolArray( D3DXHANDLE hParameter, BOOL* pb, UINT Count) ;
    HRESULT SetInt( D3DXHANDLE hParameter, INT n) ;
    HRESULT GetInt( D3DXHANDLE hParameter, INT* pn) ;
    HRESULT SetIntArray( D3DXHANDLE hParameter,  INT* pn, UINT Count) ;
    HRESULT GetIntArray( D3DXHANDLE hParameter, INT* pn, UINT Count) ;
    HRESULT SetFloat( D3DXHANDLE hParameter, FLOAT f) ;
    HRESULT GetFloat( D3DXHANDLE hParameter, FLOAT* pf) ;
    HRESULT SetFloatArray( D3DXHANDLE hParameter,  FLOAT* pf, UINT Count) ;
    HRESULT GetFloatArray( D3DXHANDLE hParameter, FLOAT* pf, UINT Count) ;
    HRESULT SetVector( D3DXHANDLE hParameter,  D3DXVECTOR4* pVector) ;
    HRESULT GetVector( D3DXHANDLE hParameter, D3DXVECTOR4* pVector) ;
    HRESULT SetVectorArray( D3DXHANDLE hParameter,  D3DXVECTOR4* pVector, UINT Count) ;
    HRESULT GetVectorArray( D3DXHANDLE hParameter, D3DXVECTOR4* pVector, UINT Count) ;
    HRESULT SetMatrix( D3DXHANDLE hParameter,  D3DXMATRIX* pMatrix) ;
    HRESULT GetMatrix( D3DXHANDLE hParameter, D3DXMATRIX* pMatrix) ;
    HRESULT SetMatrixArray( D3DXHANDLE hParameter,  D3DXMATRIX* pMatrix, UINT Count) ;
    HRESULT GetMatrixArray( D3DXHANDLE hParameter, D3DXMATRIX* pMatrix, UINT Count) ;
    HRESULT SetMatrixPointerArray( D3DXHANDLE hParameter,  D3DXMATRIX** ppMatrix, UINT Count) ;
    HRESULT GetMatrixPointerArray( D3DXHANDLE hParameter, D3DXMATRIX** ppMatrix, UINT Count) ;
    HRESULT SetMatrixTranspose( D3DXHANDLE hParameter,  D3DXMATRIX* pMatrix) ;
    HRESULT GetMatrixTranspose( D3DXHANDLE hParameter, D3DXMATRIX* pMatrix) ;
    HRESULT SetMatrixTransposeArray( D3DXHANDLE hParameter,  D3DXMATRIX* pMatrix, UINT Count) ;
    HRESULT GetMatrixTransposeArray( D3DXHANDLE hParameter, D3DXMATRIX* pMatrix, UINT Count) ;
    HRESULT SetMatrixTransposePointerArray( D3DXHANDLE hParameter,  D3DXMATRIX** ppMatrix, UINT Count) ;
    HRESULT GetMatrixTransposePointerArray( D3DXHANDLE hParameter, D3DXMATRIX** ppMatrix, UINT Count) ;
    HRESULT SetString( D3DXHANDLE hParameter, LPCSTR pString) ;
    HRESULT GetString( D3DXHANDLE hParameter, LPCSTR* ppString) ;
    HRESULT SetTexture( D3DXHANDLE hParameter, IDirect3DBaseTexture9 pTexture) ;
    HRESULT GetTexture( D3DXHANDLE hParameter, IDirect3DBaseTexture9 *ppTexture) ;
    HRESULT GetPixelShader( D3DXHANDLE hParameter, IDirect3DPixelShader9 *ppPShader) ;
    HRESULT GetVertexShader( D3DXHANDLE hParameter, IDirect3DVertexShader9 *ppVShader) ;

    //Set Range of an Array to pass to device
    //Useful for sending only a subrange of an array down to the device
    HRESULT SetArrayRange( D3DXHANDLE hParameter, UINT uStart, UINT uEnd) ;

}

interface ID3DXEffect : ID3DXBaseEffect
{
    extern(Windows):

    // Pool
    HRESULT GetPool( ID3DXEffectPool* ppPool) ;

    // Selecting and setting a technique
    HRESULT SetTechnique( D3DXHANDLE hTechnique) ;
    D3DXHANDLE GetCurrentTechnique() ;
    HRESULT ValidateTechnique( D3DXHANDLE hTechnique) ;
    HRESULT FindNextValidTechnique( D3DXHANDLE hTechnique, D3DXHANDLE *pTechnique) ;
    BOOL IsParameterUsed( D3DXHANDLE hParameter, D3DXHANDLE hTechnique) ;

    // Using current technique
    // Begin           starts active technique
    // BeginPass       begins a pass
    // CommitChanges   updates changes to any set calls in the pass.  should be called before
    //                 any DrawPrimitive call to d3d
    // EndPass         ends a pass
    // End             ends active technique
    HRESULT Begin( UINT *pPasses, DWORD Flags) ;
    HRESULT BeginPass( UINT Pass) ;
    HRESULT CommitChanges() ;
    HRESULT EndPass() ;
    HRESULT End() ;

    // Managing D3D Device
    HRESULT GetDevice( IDirect3DDevice9* ppDevice) ;
    HRESULT OnLostDevice() ;
    HRESULT OnResetDevice() ;

    // Logging device calls
    HRESULT SetStateManager( ID3DXEffectStateManager pManager) ;
    HRESULT GetStateManager( ID3DXEffectStateManager *ppManager) ;

    // Parameter blocks
    HRESULT BeginParameterBlock() ;
    D3DXHANDLE EndParameterBlock() ;
    HRESULT ApplyParameterBlock( D3DXHANDLE hParameterBlock) ;
    HRESULT DeleteParameterBlock( D3DXHANDLE hParameterBlock) ;

    // Cloning
    HRESULT CloneEffect( IDirect3DDevice9 pDevice, ID3DXEffect* ppEffect) ;
}

interface ID3DXEffectPool : IUnknown
{
    extern(Windows):

    // No public methods
}

interface ID3DXEffectStateManager : IUnknown
{
    extern(Windows):

    // The following methods are called by the Effect when it wants to make
    // the corresponding device call.  Note that:
    // 1. Users manage the state and are therefore responsible for making the
    //    the corresponding device calls themselves inside their callbacks.
    // 2. Effects pay attention to the return values of the callbacks, and so
    //    users must pay attention to what they return in their callbacks.

    HRESULT SetTransform( D3DTRANSFORMSTATETYPE State,  D3DMATRIX *pMatrix) ;
    HRESULT SetMaterial(  D3DMATERIAL9 *pMaterial) ;
    HRESULT SetLight( DWORD Index,  D3DLIGHT9 *pLight) ;
    HRESULT LightEnable( DWORD Index, BOOL Enable) ;
    HRESULT SetRenderState( D3DRENDERSTATETYPE State, DWORD Value) ;
    HRESULT SetTexture( DWORD Stage, IDirect3DBaseTexture9 pTexture) ;
    HRESULT SetTextureStageState( DWORD Stage, D3DTEXTURESTAGESTATETYPE Type, DWORD Value) ;
    HRESULT SetSamplerState( DWORD Sampler, D3DSAMPLERSTATETYPE Type, DWORD Value) ;
    HRESULT SetNPatchMode( FLOAT NumSegments) ;
    HRESULT SetFVF( DWORD FVF) ;
    HRESULT SetVertexShader( IDirect3DVertexShader9 pShader) ;
    HRESULT SetVertexShaderConstantF( UINT RegisterIndex,  FLOAT *pConstantData, UINT RegisterCount) ;
    HRESULT SetVertexShaderConstantI( UINT RegisterIndex,  INT *pConstantData, UINT RegisterCount) ;
    HRESULT SetVertexShaderConstantB( UINT RegisterIndex,  BOOL *pConstantData, UINT RegisterCount) ;
    HRESULT SetPixelShader( IDirect3DPixelShader9 pShader) ;
    HRESULT SetPixelShaderConstantF( UINT RegisterIndex,  FLOAT *pConstantData, UINT RegisterCount) ;
    HRESULT SetPixelShaderConstantI( UINT RegisterIndex,  INT *pConstantData, UINT RegisterCount) ;
    HRESULT SetPixelShaderConstantB( UINT RegisterIndex,  BOOL *pConstantData, UINT RegisterCount) ;
}

interface ID3DXInclude
{
    HRESULT Open(D3DXINCLUDE_TYPE IncludeType, LPCSTR pFileName, LPCVOID pParentData, LPCVOID *ppData, UINT *pBytes);
    HRESULT Close(LPCVOID pData);
}

// D3DX Functions ---------------------------------------------------------------------------------------
extern(Windows)
{
	uint D3DXGetShaderVersion(uint* pFunction);

	HRESULT D3DXCheckTextureRequirements(
	        IDirect3DDevice9         pDevice,
	        UINT*                     pWidth,
	        UINT*                     pHeight,
	        UINT*                     pNumMipLevels,
	        DWORD                     Usage,
	        D3DFORMAT*                pFormat,
	        D3DPOOL                   Pool) ;

	HRESULT D3DXCreateTexture(
	        IDirect3DDevice9         pDevice,
	        UINT                      Width,
	        UINT                      Height,
	        UINT                      MipLevels,
	        DWORD                     Usage,
	        D3DFORMAT                 Format,
	        D3DPOOL                   Pool,
	        IDirect3DTexture9*       ppTexture);

	HRESULT D3DXCreateCubeTexture(
	        IDirect3DDevice9         pDevice,
	        UINT                      Size,
	        UINT                      MipLevels,
	        DWORD                     Usage,
	        D3DFORMAT                 Format,
	        D3DPOOL                   Pool,
	        IDirect3DCubeTexture9*   ppCubeTexture);
			
	HRESULT D3DXCreateTextureFromFileA(
			LPDIRECT3DDEVICE9 pDevice,
			LPCTSTR pSrcFile,
			LPDIRECT3DTEXTURE9 * ppTexture);

	HRESULT D3DXCreateTextureFromFileExA(
	        IDirect3DDevice9         pDevice,
	        LPCSTR                    pSrcFile,
	        UINT                      Width,
	        UINT                      Height,
	        UINT                      MipLevels,
	        DWORD                     Usage,
	        D3DFORMAT                 Format,
	        D3DPOOL                   Pool,
	        DWORD                     Filter,
	        DWORD                     MipFilter,
	        D3DCOLOR                  ColorKey,
	        D3DXIMAGE_INFO*           pSrcInfo,
	        PALETTEENTRY*             pPalette,
	        IDirect3DTexture9*       ppTexture);

	HRESULT D3DXCreateCubeTextureFromFileExA(
	        IDirect3DDevice9         pDevice,
	        LPCSTR                    pSrcFile,
	        UINT                      Size,
	        UINT                      MipLevels,
	        DWORD                     Usage,
	        D3DFORMAT                 Format,
	        D3DPOOL                   Pool,
	        DWORD                     Filter,
	        DWORD                     MipFilter,
	        D3DCOLOR                  ColorKey,
	        D3DXIMAGE_INFO*           pSrcInfo,
	        PALETTEENTRY*             pPalette,
	        IDirect3DCubeTexture9*   ppCubeTexture);

	HRESULT D3DXSimplifyMesh(
	        ID3DXMesh pMesh,
	         DWORD* pAdjacency,
	         D3DXATTRIBUTEWEIGHTS *pVertexAttributeWeights,
	         FLOAT *pVertexWeights,
	        DWORD MinValue,
	        DWORD Options,
	        ID3DXMesh* ppMesh);

	HRESULT D3DXCreateSkinInfoFVF(
	        DWORD NumVertices,
	        DWORD FVF,
	        DWORD NumBones,
	        ID3DXSkinInfo* ppSkinInfo);

	D3DXVECTOR2* D3DXVec2TransformCoord( D3DXVECTOR2 *pOut, D3DXVECTOR2 *pV, D3DXMATRIX *pM );

	D3DXVECTOR4* D3DXVec3Transform( D3DXVECTOR4 *pOut, D3DXVECTOR3 *pV, D3DXMATRIX *pM );

	D3DXVECTOR3* D3DXVec3TransformCoord( D3DXVECTOR3 *pOut, D3DXVECTOR3 *pV, D3DXMATRIX *pM );

	D3DXVECTOR4* D3DXVec4Transform( D3DXVECTOR4 *pOut, D3DXVECTOR4 *pV, D3DXMATRIX *pM );

	D3DXMATRIX* D3DXMatrixTranspose( D3DXMATRIX *pOut, D3DXMATRIX *pM );

	D3DXMATRIX* D3DXMatrixMultiply( D3DXMATRIX *pOut, D3DXMATRIX *pM1, D3DXMATRIX *pM2 );

	D3DXMATRIX* D3DXMatrixInverse( D3DXMATRIX *pOut, FLOAT *pDeterminant, D3DXMATRIX *pM );

	D3DXMATRIX* D3DXMatrixScaling( D3DXMATRIX *pOut, FLOAT sx, FLOAT sy, FLOAT sz );

	D3DXMATRIX* D3DXMatrixTranslation( D3DXMATRIX *pOut, FLOAT x, FLOAT y, FLOAT z );

	D3DXMATRIX* D3DXMatrixRotationX( D3DXMATRIX *pOut, FLOAT Angle );

	D3DXMATRIX* D3DXMatrixRotationY( D3DXMATRIX *pOut, FLOAT Angle );

	D3DXMATRIX* D3DXMatrixRotationZ( D3DXMATRIX *pOut, FLOAT Angle );

	D3DXMATRIX* D3DXMatrixRotationQuaternion( D3DXMATRIX *pOut, D3DXQUATERNION *pQ);

	D3DXMATRIX* D3DXMatrixRotationYawPitchRoll( D3DXMATRIX *pOut, FLOAT Yaw, FLOAT Pitch, FLOAT Roll );

	D3DXMATRIX* D3DXMatrixAffineTransformation2D( D3DXMATRIX *pOut, FLOAT Scaling, D3DXVECTOR2 *pRotationCenter,
	      float Rotation, D3DXVECTOR2 *pTranslation);

	D3DXMATRIX* D3DXMatrixPerspectiveFovLH( D3DXMATRIX *pOut, FLOAT fovy, FLOAT Aspect, FLOAT zn, FLOAT zf );

	D3DXMATRIX* D3DXMatrixOrthoLH( D3DXMATRIX *pOut, FLOAT w, FLOAT h, FLOAT zn, FLOAT zf );

	D3DXMATRIX* D3DXMatrixOrthoOffCenterLH( D3DXMATRIX *pOut, FLOAT l, FLOAT r, FLOAT b, FLOAT t, FLOAT zn,
	      FLOAT zf );

	void D3DXQuaternionToAxisAngle( D3DXQUATERNION *pQ, D3DXVECTOR3 *pAxis, FLOAT *pAngle );

	D3DXQUATERNION* D3DXQuaternionRotationMatrix( D3DXQUATERNION *pOut, D3DXMATRIX *pM);

	D3DXQUATERNION* D3DXQuaternionNormalize( D3DXQUATERNION *pOut, D3DXQUATERNION *pQ );

	D3DXPLANE* D3DXPlaneNormalize( D3DXPLANE *pOut, D3DXPLANE *pP);

	char* DXGetErrorDescription9A(HRESULT hr);

	HRESULT D3DXCreateEffectFromFileA(
	        IDirect3DDevice9               pDevice,
	        LPCSTR                          pSrcFile,
	         D3DXMACRO*                pDefines,
	        ID3DXInclude                   pInclude,
	        DWORD                           Flags,
	        ID3DXEffectPool                pPool,
	        ID3DXEffect*                   ppEffect,
	        ID3DXBuffer*                   ppCompilationErrors);

	D3DXMATRIX* D3DXMatrixTransformation2D( D3DXMATRIX *pOut, D3DXVECTOR2 *pScalingCenter,
      float *pScalingRotation, D3DXVECTOR2 *pScaling,
      D3DXVECTOR2 *pRotationCenter, float Rotation,
      D3DXVECTOR2 *pTranslation);

    HRESULT D3DXLoadMeshFromXA(
        LPCSTR pFilename,
        DWORD Options,
        IDirect3DDevice9 pD3D,
        ID3DXBuffer *ppAdjacency,
        ID3DXBuffer *ppMaterials,
        ID3DXBuffer *ppEffectInstances,
        DWORD *pNumMaterials,
        ID3DXMesh *ppMesh);

    HRESULT D3DXCreatePolygon(
        IDirect3DDevice9   pDevice,
        FLOAT               Length,
        UINT                Sides,
        ID3DXMesh*         ppMesh,
        ID3DXBuffer*       ppAdjacency);

	HRESULT D3DXCreateBox(
	        IDirect3DDevice9   pDevice,
	        FLOAT               Width,
	        FLOAT               Height,
	        FLOAT               Depth,
	        ID3DXMesh*         ppMesh,
	        ID3DXBuffer*       ppAdjacency);

	HRESULT D3DXCreateCylinder(
	        IDirect3DDevice9   pDevice,
	        FLOAT               Radius1,
	        FLOAT               Radius2,
	        FLOAT               Length,
	        UINT                Slices,
	        UINT                Stacks,
	        ID3DXMesh*         ppMesh,
	        ID3DXBuffer*       ppAdjacency);

	HRESULT D3DXCreateSphere(
	        IDirect3DDevice9  pDevice,
	        FLOAT              Radius,
	        UINT               Slices,
	        UINT               Stacks,
	        ID3DXMesh*        ppMesh,
	        ID3DXBuffer*      ppAdjacency);

	HRESULT D3DXCreateTorus(
	        IDirect3DDevice9   pDevice,
	        FLOAT               InnerRadius,
	        FLOAT               OuterRadius,
	        UINT                Sides,
	        UINT                Rings,
	        ID3DXMesh*         ppMesh,
	        ID3DXBuffer*       ppAdjacency);

	HRESULT D3DXCreateTeapot(
	        IDirect3DDevice9   pDevice,
	        ID3DXMesh*         ppMesh,
	        ID3DXBuffer*       ppAdjacency);

	HRESULT D3DXCreateFontA(
        IDirect3DDevice9 pDevice,
		UINT Height,
		UINT Width,
		UINT Weight,
		UINT MipLevels,
		BOOL Italic,
		DWORD CharSet,
		DWORD OutputPrecision,
		DWORD Quality,
		DWORD PitchAndFamily,
		LPCTSTR pFacename,
		ID3DXFont *ppFont);

	HRESULT D3DXCreateSprite(
        IDirect3DDevice9   pDevice,
        ID3DXSprite*       ppSprite) ;

    HRESULT D3DXCreateEffect(
        IDirect3DDevice9                pDevice,
        LPCVOID                         pSrcData,
        UINT                            SrcDataLen,
        D3DXMACRO*                      pDefines,
        ID3DXInclude                    pInclude,
        DWORD                           Flags,
        ID3DXEffectPool                 pPool,
        ID3DXEffect*                    ppEffect,
        ID3DXBuffer*                    ppCompilationErrors);

    HRESULT D3DXCreateEffectPool(
        ID3DXEffectPool* pEffectPool);

    HRESULT D3DXGetShaderInputSemantics(
		DWORD* pFunction,
		D3DXSEMANTIC* pSemantics,
		UINT* pCount);

	HRESULT
    D3DXCreateMeshFVF(
        DWORD NumFaces,
        DWORD NumVertices,
        DWORD Options,
        DWORD FVF,
        IDirect3DDevice9 pD3DDevice,
        ID3DXMesh* ppMesh);

    UINT D3DXGetFVFVertexSize(DWORD FVF);

    HRESULT D3DXFileCreate(ID3DXFile* lplpDirectXFile);

    HRESULT D3DXLoadMeshFromXof(
        ID3DXFileData pxofMesh,
        DWORD Options,
        IDirect3DDevice9 pD3DDevice,
        ID3DXBuffer *ppAdjacency,
        ID3DXBuffer *ppMaterials,
        ID3DXBuffer *ppEffectInstances,
        DWORD *pNumMaterials,
        ID3DXMesh *ppMesh);

    HRESULT D3DXConcatenateMeshes(
		ID3DXMesh * ppMeshes,
	    UINT NumMeshes,
	    DWORD Options,
	    D3DXMATRIX * pGeomXForms,
	    D3DXMATRIX * pTextureXForms,
	    D3DVERTEXELEMENT9 * pDecl,
	    IDirect3DDevice9 pD3DDevice,
	    ID3DXMesh * ppMeshOut);

	HRESULT D3DXDeclaratorFromFVF(DWORD FVF, D3DVERTEXELEMENT9* Declaration);

	D3DXQUATERNION* D3DXQuaternionSlerp(D3DXQUATERNION* pOut, D3DXQUATERNION* pQ1, D3DXQUATERNION* pQ2, float t);

	D3DXVECTOR3* D3DXVec3CatmullRom(D3DXVECTOR3 *pOut, D3DXVECTOR3 *pV0, D3DXVECTOR3 *pV1, D3DXVECTOR3 *pV2, D3DXVECTOR3 *pV3, float s);

	void D3DXQuaternionSquadSetup(  D3DXQUATERNION *pAOut,
								    D3DXQUATERNION *pBOut,
								    D3DXQUATERNION *pCOut,
								    D3DXQUATERNION *pQ0,
								    D3DXQUATERNION *pQ1,
								    D3DXQUATERNION *pQ2,
								    D3DXQUATERNION *pQ3);

	D3DXQUATERNION* D3DXQuaternionSquad(D3DXQUATERNION *pOut,
									    D3DXQUATERNION *pQ1,
									    D3DXQUATERNION *pA,
									    D3DXQUATERNION *pB,
									    D3DXQUATERNION *pC,
									    float t);

	HRESULT D3DXMatrixDecompose(D3DXVECTOR3 *pOutScale,
							    D3DXQUATERNION *pOutRotation,
							    D3DXVECTOR3 *pOutTranslation,
							    D3DXMATRIX *pM
								);

	D3DXQUATERNION* D3DXQuaternionRotationYawPitchRoll(D3DXQUATERNION *pOut,
														    FLOAT Yaw,
														    FLOAT Pitch,
														    FLOAT Roll
														);

	UINT D3DXGetDeclVertexSize(D3DVERTEXELEMENT9 *pDecl, DWORD Stream );
} // extern(Windows)

D3DXMATRIX* D3DXMatrixIdentity( D3DXMATRIX *pOut )
{
    pOut.m[0][1] = pOut.m[0][2] = pOut.m[0][3] =
    pOut.m[1][0] = pOut.m[1][2] = pOut.m[1][3] =
    pOut.m[2][0] = pOut.m[2][1] = pOut.m[2][3] =
    pOut.m[3][0] = pOut.m[3][1] = pOut.m[3][2] = 0.0f;

    pOut.m[0][0] = pOut.m[1][1] = pOut.m[2][2] = pOut.m[3][3] = 1.0f;
    return pOut;
}

FLOAT D3DXVec3LengthSq(D3DXVECTOR3* v)
{
	return (v.x * v.x) + (v.y * v.y) + (v.z * v.z);
}

template DEFINE_GUID(uint d1, ushort d2, ushort d3, ubyte d4, ubyte d5, ubyte d6, ubyte d7, ubyte d8, ubyte d9, ubyte d10, ubyte d11)
{
	const GUID DEFINE_GUID = {d1, d2, d3, [d4, d5, d6, d7, d8, d9, d10, d11]};
}

const GUID TID_D3DRMInfo = DEFINE_GUID!(0x2b957100, 0x9e9a, 0x11cf, 0xab, 0x39, 0x0, 0x20, 0xaf, 0x71, 0xe4, 0x33);
const GUID TID_D3DRMMesh = DEFINE_GUID!(0x3d82ab44, 0x62da, 0x11cf, 0xab, 0x39, 0x0, 0x20, 0xaf, 0x71, 0xe4, 0x33);
const GUID TID_D3DRMVector = DEFINE_GUID!(0x3d82ab5e, 0x62da, 0x11cf, 0xab, 0x39, 0x0, 0x20, 0xaf, 0x71, 0xe4, 0x33);
const GUID TID_D3DRMMeshFace = DEFINE_GUID!(0x3d82ab5f, 0x62da, 0x11cf, 0xab, 0x39, 0x0, 0x20, 0xaf, 0x71, 0xe4, 0x33);
const GUID TID_D3DRMMaterial = DEFINE_GUID!(0x3d82ab4d, 0x62da, 0x11cf, 0xab, 0x39, 0x0, 0x20, 0xaf, 0x71, 0xe4, 0x33);
const GUID TID_D3DRMMaterialArray = DEFINE_GUID!(0x35ff44e1, 0x6c7c, 0x11cf, 0x8F, 0x52, 0x0, 0x40, 0x33, 0x35, 0x94, 0xa3);
const GUID TID_D3DRMFrame = DEFINE_GUID!(0x3d82ab46, 0x62da, 0x11cf, 0xab, 0x39, 0x0, 0x20, 0xaf, 0x71, 0xe4, 0x33);
const GUID TID_D3DRMFrameTransformMatrix = DEFINE_GUID!(0xf6f23f41, 0x7686, 0x11cf, 0x8f, 0x52, 0x0, 0x40, 0x33, 0x35, 0x94, 0xa3);
const GUID TID_D3DRMMeshMaterialList = DEFINE_GUID!(0xf6f23f42, 0x7686, 0x11cf, 0x8f, 0x52, 0x0, 0x40, 0x33, 0x35, 0x94, 0xa3);
const GUID TID_D3DRMMeshTextureCoords = DEFINE_GUID!(0xf6f23f40, 0x7686, 0x11cf, 0x8f, 0x52, 0x0, 0x40, 0x33, 0x35, 0x94, 0xa3);
const GUID TID_D3DRMMeshNormals = DEFINE_GUID!(0xf6f23f43, 0x7686, 0x11cf, 0x8f, 0x52, 0x0, 0x40, 0x33, 0x35, 0x94, 0xa3);
const GUID TID_D3DRMCoords2d = DEFINE_GUID!(0xf6f23f44, 0x7686, 0x11cf, 0x8f, 0x52, 0x0, 0x40, 0x33, 0x35, 0x94, 0xa3);
const GUID TID_D3DRMMatrix4x4 = DEFINE_GUID!(0xf6f23f45, 0x7686, 0x11cf, 0x8f, 0x52, 0x0, 0x40, 0x33, 0x35, 0x94, 0xa3);
const GUID TID_D3DRMAnimation = DEFINE_GUID!(0x3d82ab4f, 0x62da, 0x11cf, 0xab, 0x39, 0x0, 0x20, 0xaf, 0x71, 0xe4, 0x33);
const GUID TID_D3DRMAnimationSet = DEFINE_GUID!(0x3d82ab50, 0x62da, 0x11cf, 0xab, 0x39, 0x0, 0x20, 0xaf, 0x71, 0xe4, 0x33);
const GUID TID_D3DRMAnimationKey = DEFINE_GUID!(0x10dd46a8, 0x775b, 0x11cf, 0x8f, 0x52, 0x0, 0x40, 0x33, 0x35, 0x94, 0xA3);
const GUID TID_D3DRMFloatKeys = DEFINE_GUID!(0x10dd46a9, 0x775b, 0x11cf, 0x8f, 0x52, 0x0, 0x40, 0x33, 0x35, 0x94, 0xA3);
const GUID TID_D3DRMMaterialAmbientColor = DEFINE_GUID!(0x01411840, 0x7786, 0x11cf, 0x8f, 0x52, 0x0, 0x40, 0x33, 0x35, 0x94, 0xA3);
const GUID TID_D3DRMMaterialDiffuseColor = DEFINE_GUID!(0x01411841, 0x7786, 0x11cf, 0x8f, 0x52, 0x0, 0x40, 0x33, 0x35, 0x94, 0xA3);
const GUID TID_D3DRMMaterialSpecularColor = DEFINE_GUID!(0x01411842, 0x7786, 0x11cf, 0x8f, 0x52, 0x0, 0x40, 0x33, 0x35, 0x94, 0xA3);
const GUID TID_D3DRMMaterialEmissiveColor = DEFINE_GUID!(0xd3e16e80, 0x7835, 0x11cf, 0x8f, 0x52, 0x0, 0x40, 0x33, 0x35, 0x94, 0xa3);
const GUID TID_D3DRMMaterialPower = DEFINE_GUID!(0x01411843, 0x7786, 0x11cf, 0x8f, 0x52, 0x0, 0x40, 0x33, 0x35, 0x94, 0xA3);
const GUID TID_D3DRMColorRGBA = DEFINE_GUID!(0x35ff44e0, 0x6c7c, 0x11cf, 0x8f, 0x52, 0x0, 0x40, 0x33, 0x35, 0x94, 0xA3);
const GUID TID_D3DRMColorRGB = DEFINE_GUID!(0xd3e16e81, 0x7835, 0x11cf, 0x8f, 0x52, 0x0, 0x40, 0x33, 0x35, 0x94, 0xa3);
const GUID TID_D3DRMGuid = DEFINE_GUID!(0xa42790e0, 0x7810, 0x11cf, 0x8f, 0x52, 0x0, 0x40, 0x33, 0x35, 0x94, 0xa3);
const GUID TID_D3DRMTextureFilename = DEFINE_GUID!(0xa42790e1, 0x7810, 0x11cf, 0x8f, 0x52, 0x0, 0x40, 0x33, 0x35, 0x94, 0xa3);
const GUID TID_D3DRMTextureReference = DEFINE_GUID!(0xa42790e2, 0x7810, 0x11cf, 0x8f, 0x52, 0x0, 0x40, 0x33, 0x35, 0x94, 0xa3);
const GUID TID_D3DRMIndexedColor = DEFINE_GUID!(0x1630b820, 0x7842, 0x11cf, 0x8f, 0x52, 0x0, 0x40, 0x33, 0x35, 0x94, 0xa3);
const GUID TID_D3DRMMeshVertexColors = DEFINE_GUID!(0x1630b821, 0x7842, 0x11cf, 0x8f, 0x52, 0x0, 0x40, 0x33, 0x35, 0x94, 0xa3);
const GUID TID_D3DRMMaterialWrap = DEFINE_GUID!(0x4885ae60, 0x78e8, 0x11cf, 0x8f, 0x52, 0x0, 0x40, 0x33, 0x35, 0x94, 0xa3);
const GUID TID_D3DRMBoolean = DEFINE_GUID!(0x537da6a0, 0xca37, 0x11d0, 0x94, 0x1c, 0x0, 0x80, 0xc8, 0xc, 0xfa, 0x7b);
const GUID TID_D3DRMMeshFaceWraps = DEFINE_GUID!(0xed1ec5c0, 0xc0a8, 0x11d0, 0x94, 0x1c, 0x0, 0x80, 0xc8, 0xc, 0xfa, 0x7b);
const GUID TID_D3DRMBoolean2d = DEFINE_GUID!(0x4885ae63, 0x78e8, 0x11cf, 0x8f, 0x52, 0x0, 0x40, 0x33, 0x35, 0x94, 0xa3);
const GUID TID_D3DRMTimedFloatKeys = DEFINE_GUID!(0xf406b180, 0x7b3b, 0x11cf, 0x8f, 0x52, 0x0, 0x40, 0x33, 0x35, 0x94, 0xa3);
const GUID TID_D3DRMAnimationOptions = DEFINE_GUID!(0xe2bf56c0, 0x840f, 0x11cf, 0x8f, 0x52, 0x0, 0x40, 0x33, 0x35, 0x94, 0xa3);
const GUID TID_D3DRMFramePosition = DEFINE_GUID!(0xe2bf56c1, 0x840f, 0x11cf, 0x8f, 0x52, 0x0, 0x40, 0x33, 0x35, 0x94, 0xa3);
const GUID TID_D3DRMFrameVelocity = DEFINE_GUID!(0xe2bf56c2, 0x840f, 0x11cf, 0x8f, 0x52, 0x0, 0x40, 0x33, 0x35, 0x94, 0xa3);
const GUID TID_D3DRMFrameRotation = DEFINE_GUID!(0xe2bf56c3, 0x840f, 0x11cf, 0x8f, 0x52, 0x0, 0x40, 0x33, 0x35, 0x94, 0xa3);
const GUID TID_D3DRMLight = DEFINE_GUID!(0x3d82ab4a, 0x62da, 0x11cf, 0xab, 0x39, 0x0, 0x20, 0xaf, 0x71, 0xe4, 0x33);
const GUID TID_D3DRMCamera = DEFINE_GUID!(0x3d82ab51, 0x62da, 0x11cf, 0xab, 0x39, 0x0, 0x20, 0xaf, 0x71, 0xe4, 0x33);
const GUID TID_D3DRMAppData = DEFINE_GUID!(0xe5745280, 0xb24f, 0x11cf, 0x9d, 0xd5, 0x0, 0xaa, 0x0, 0xa7, 0x1a, 0x2f);
const GUID TID_D3DRMLightUmbra = DEFINE_GUID!(0xaed22740, 0xb31f, 0x11cf, 0x9d, 0xd5, 0x0, 0xaa, 0x0, 0xa7, 0x1a, 0x2f);
const GUID TID_D3DRMLightRange = DEFINE_GUID!(0xaed22742, 0xb31f, 0x11cf, 0x9d, 0xd5, 0x0, 0xaa, 0x0, 0xa7, 0x1a, 0x2f);
const GUID TID_D3DRMLightPenumbra = DEFINE_GUID!(0xaed22741, 0xb31f, 0x11cf, 0x9d, 0xd5, 0x0, 0xaa, 0x0, 0xa7, 0x1a, 0x2f);
const GUID TID_D3DRMLightAttenuation = DEFINE_GUID!(0xa8a98ba0, 0xc5e5, 0x11cf, 0xb9, 0x41, 0x0, 0x80, 0xc8, 0xc, 0xfa, 0x7b);
const GUID TID_D3DRMInlineData = DEFINE_GUID!(0x3a23eea0, 0x94b1, 0x11d0, 0xab, 0x39, 0x0, 0x20, 0xaf, 0x71, 0xe4, 0x33);
const GUID TID_D3DRMUrl = DEFINE_GUID!(0x3a23eea1, 0x94b1, 0x11d0, 0xab, 0x39, 0x0, 0x20, 0xaf, 0x71, 0xe4, 0x33);
const GUID TID_D3DRMProgressiveMesh = DEFINE_GUID!(0x8A63C360, 0x997D, 0x11d0, 0x94, 0x1C, 0x0, 0x80, 0xC8, 0x0C, 0xFA, 0x7B);
const GUID TID_D3DRMExternalVisual = DEFINE_GUID!(0x98116AA0, 0xBDBA, 0x11d1, 0x82, 0xC0, 0x00, 0xA0, 0xC9, 0x69, 0x72, 0x71);
const GUID TID_D3DRMStringProperty = DEFINE_GUID!(0x7f0f21e0, 0xbfe1, 0x11d1, 0x82, 0xc0, 0x0, 0xa0, 0xc9, 0x69, 0x72, 0x71);
const GUID TID_D3DRMPropertyBag = DEFINE_GUID!(0x7f0f21e1, 0xbfe1, 0x11d1, 0x82, 0xc0, 0x0, 0xa0, 0xc9, 0x69, 0x72, 0x71);
const GUID TID_D3DRMRightHanded = DEFINE_GUID!(0x7f5d5ea0, 0xd53a, 0x11d1, 0x82, 0xc0, 0x0, 0xa0, 0xc9, 0x69, 0x72, 0x71);

ubyte D3DRM_XTEMPLATES[] =
[
	0x78, 0x6f, 0x66, 0x20, 0x30, 0x33, 0x30, 0x32, 0x62,
	0x69, 0x6e, 0x20, 0x30, 0x30, 0x36, 0x34, 0x1f, 0, 0x1,
	0, 0x6, 0, 0, 0, 0x48, 0x65, 0x61, 0x64, 0x65,
	0x72, 0xa, 0, 0x5, 0, 0x43, 0xab, 0x82, 0x3d, 0xda,
	0x62, 0xcf, 0x11, 0xab, 0x39, 0, 0x20, 0xaf, 0x71, 0xe4,
	0x33, 0x28, 0, 0x1, 0, 0x5, 0, 0, 0, 0x6d,
	0x61, 0x6a, 0x6f, 0x72, 0x14, 0, 0x28, 0, 0x1, 0,
	0x5, 0, 0, 0, 0x6d, 0x69, 0x6e, 0x6f, 0x72, 0x14,
	0, 0x29, 0, 0x1, 0, 0x5, 0, 0, 0, 0x66,
	0x6c, 0x61, 0x67, 0x73, 0x14, 0, 0xb, 0, 0x1f, 0,
	0x1, 0, 0x6, 0, 0, 0, 0x56, 0x65, 0x63, 0x74,
	0x6f, 0x72, 0xa, 0, 0x5, 0, 0x5e, 0xab, 0x82, 0x3d,
	0xda, 0x62, 0xcf, 0x11, 0xab, 0x39, 0, 0x20, 0xaf, 0x71,
	0xe4, 0x33, 0x2a, 0, 0x1, 0, 0x1, 0, 0, 0,
	0x78, 0x14, 0, 0x2a, 0, 0x1, 0, 0x1, 0, 0,
	0, 0x79, 0x14, 0, 0x2a, 0, 0x1, 0, 0x1, 0,
	0, 0, 0x7a, 0x14, 0, 0xb, 0, 0x1f, 0, 0x1,
	0, 0x8, 0, 0, 0, 0x43, 0x6f, 0x6f, 0x72, 0x64,
	0x73, 0x32, 0x64, 0xa, 0, 0x5, 0, 0x44, 0x3f, 0xf2,
	0xf6, 0x86, 0x76, 0xcf, 0x11, 0x8f, 0x52, 0, 0x40, 0x33,
	0x35, 0x94, 0xa3, 0x2a, 0, 0x1, 0, 0x1, 0, 0,
	0, 0x75, 0x14, 0, 0x2a, 0, 0x1, 0, 0x1, 0,
	0, 0, 0x76, 0x14, 0, 0xb, 0, 0x1f, 0, 0x1,
	0, 0x9, 0, 0, 0, 0x4d, 0x61, 0x74, 0x72, 0x69,
	0x78, 0x34, 0x78, 0x34, 0xa, 0, 0x5, 0, 0x45, 0x3f,
	0xf2, 0xf6, 0x86, 0x76, 0xcf, 0x11, 0x8f, 0x52, 0, 0x40,
	0x33, 0x35, 0x94, 0xa3, 0x34, 0, 0x2a, 0, 0x1, 0,
	0x6, 0, 0, 0, 0x6d, 0x61, 0x74, 0x72, 0x69, 0x78,
	0xe, 0, 0x3, 0, 0x10, 0, 0, 0, 0xf, 0,
	0x14, 0, 0xb, 0, 0x1f, 0, 0x1, 0, 0x9, 0,
	0, 0, 0x43, 0x6f, 0x6c, 0x6f, 0x72, 0x52, 0x47, 0x42,
	0x41, 0xa, 0, 0x5, 0, 0xe0, 0x44, 0xff, 0x35, 0x7c,
	0x6c, 0xcf, 0x11, 0x8f, 0x52, 0, 0x40, 0x33, 0x35, 0x94,
	0xa3, 0x2a, 0, 0x1, 0, 0x3, 0, 0, 0, 0x72,
	0x65, 0x64, 0x14, 0, 0x2a, 0, 0x1, 0, 0x5, 0,
	0, 0, 0x67, 0x72, 0x65, 0x65, 0x6e, 0x14, 0, 0x2a,
	0, 0x1, 0, 0x4, 0, 0, 0, 0x62, 0x6c, 0x75,
	0x65, 0x14, 0, 0x2a, 0, 0x1, 0, 0x5, 0, 0,
	0, 0x61, 0x6c, 0x70, 0x68, 0x61, 0x14, 0, 0xb, 0,
	0x1f, 0, 0x1, 0, 0x8, 0, 0, 0, 0x43, 0x6f,
	0x6c, 0x6f, 0x72, 0x52, 0x47, 0x42, 0xa, 0, 0x5, 0,
	0x81, 0x6e, 0xe1, 0xd3, 0x35, 0x78, 0xcf, 0x11, 0x8f, 0x52,
	0, 0x40, 0x33, 0x35, 0x94, 0xa3, 0x2a, 0, 0x1, 0,
	0x3, 0, 0, 0, 0x72, 0x65, 0x64, 0x14, 0, 0x2a,
	0, 0x1, 0, 0x5, 0, 0, 0, 0x67, 0x72, 0x65,
	0x65, 0x6e, 0x14, 0, 0x2a, 0, 0x1, 0, 0x4, 0,
	0, 0, 0x62, 0x6c, 0x75, 0x65, 0x14, 0, 0xb, 0,
	0x1f, 0, 0x1, 0, 0xc, 0, 0, 0, 0x49, 0x6e,
	0x64, 0x65, 0x78, 0x65, 0x64, 0x43, 0x6f, 0x6c, 0x6f, 0x72,
	0xa, 0, 0x5, 0, 0x20, 0xb8, 0x30, 0x16, 0x42, 0x78,
	0xcf, 0x11, 0x8f, 0x52, 0, 0x40, 0x33, 0x35, 0x94, 0xa3,
	0x29, 0, 0x1, 0, 0x5, 0, 0, 0, 0x69, 0x6e,
	0x64, 0x65, 0x78, 0x14, 0, 0x1, 0, 0x9, 0, 0,
	0, 0x43, 0x6f, 0x6c, 0x6f, 0x72, 0x52, 0x47, 0x42, 0x41,
	0x1, 0, 0xa, 0, 0, 0, 0x69, 0x6e, 0x64, 0x65,
	0x78, 0x43, 0x6f, 0x6c, 0x6f, 0x72, 0x14, 0, 0xb, 0,
	0x1f, 0, 0x1, 0, 0x7, 0, 0, 0, 0x42, 0x6f,
	0x6f, 0x6c, 0x65, 0x61, 0x6e, 0xa, 0, 0x5, 0, 0xa0,
	0xa6, 0x7d, 0x53, 0x37, 0xca, 0xd0, 0x11, 0x94, 0x1c, 0,
	0x80, 0xc8, 0xc, 0xfa, 0x7b, 0x29, 0, 0x1, 0, 0x9,
	0, 0, 0, 0x74, 0x72, 0x75, 0x65, 0x66, 0x61, 0x6c,
	0x73, 0x65, 0x14, 0, 0xb, 0, 0x1f, 0, 0x1, 0,
	0x9, 0, 0, 0, 0x42, 0x6f, 0x6f, 0x6c, 0x65, 0x61,
	0x6e, 0x32, 0x64, 0xa, 0, 0x5, 0, 0x63, 0xae, 0x85,
	0x48, 0xe8, 0x78, 0xcf, 0x11, 0x8f, 0x52, 0, 0x40, 0x33,
	0x35, 0x94, 0xa3, 0x1, 0, 0x7, 0, 0, 0, 0x42,
	0x6f, 0x6f, 0x6c, 0x65, 0x61, 0x6e, 0x1, 0, 0x1, 0,
	0, 0, 0x75, 0x14, 0, 0x1, 0, 0x7, 0, 0,
	0, 0x42, 0x6f, 0x6f, 0x6c, 0x65, 0x61, 0x6e, 0x1, 0,
	0x1, 0, 0, 0, 0x76, 0x14, 0, 0xb, 0, 0x1f,
	0, 0x1, 0, 0xc, 0, 0, 0, 0x4d, 0x61, 0x74,
	0x65, 0x72, 0x69, 0x61, 0x6c, 0x57, 0x72, 0x61, 0x70, 0xa,
	0, 0x5, 0, 0x60, 0xae, 0x85, 0x48, 0xe8, 0x78, 0xcf,
	0x11, 0x8f, 0x52, 0, 0x40, 0x33, 0x35, 0x94, 0xa3, 0x1,
	0, 0x7, 0, 0, 0, 0x42, 0x6f, 0x6f, 0x6c, 0x65,
	0x61, 0x6e, 0x1, 0, 0x1, 0, 0, 0, 0x75, 0x14,
	0, 0x1, 0, 0x7, 0, 0, 0, 0x42, 0x6f, 0x6f,
	0x6c, 0x65, 0x61, 0x6e, 0x1, 0, 0x1, 0, 0, 0,
	0x76, 0x14, 0, 0xb, 0, 0x1f, 0, 0x1, 0, 0xf,
	0, 0, 0, 0x54, 0x65, 0x78, 0x74, 0x75, 0x72, 0x65,
	0x46, 0x69, 0x6c, 0x65, 0x6e, 0x61, 0x6d, 0x65, 0xa, 0,
	0x5, 0, 0xe1, 0x90, 0x27, 0xa4, 0x10, 0x78, 0xcf, 0x11,
	0x8f, 0x52, 0, 0x40, 0x33, 0x35, 0x94, 0xa3, 0x31, 0,
	0x1, 0, 0x8, 0, 0, 0, 0x66, 0x69, 0x6c, 0x65,
	0x6e, 0x61, 0x6d, 0x65, 0x14, 0, 0xb, 0, 0x1f, 0,
	0x1, 0, 0x8, 0, 0, 0, 0x4d, 0x61, 0x74, 0x65,
	0x72, 0x69, 0x61, 0x6c, 0xa, 0, 0x5, 0, 0x4d, 0xab,
	0x82, 0x3d, 0xda, 0x62, 0xcf, 0x11, 0xab, 0x39, 0, 0x20,
	0xaf, 0x71, 0xe4, 0x33, 0x1, 0, 0x9, 0, 0, 0,
	0x43, 0x6f, 0x6c, 0x6f, 0x72, 0x52, 0x47, 0x42, 0x41, 0x1,
	0, 0x9, 0, 0, 0, 0x66, 0x61, 0x63, 0x65, 0x43,
	0x6f, 0x6c, 0x6f, 0x72, 0x14, 0, 0x2a, 0, 0x1, 0,
	0x5, 0, 0, 0, 0x70, 0x6f, 0x77, 0x65, 0x72, 0x14,
	0, 0x1, 0, 0x8, 0, 0, 0, 0x43, 0x6f, 0x6c,
	0x6f, 0x72, 0x52, 0x47, 0x42, 0x1, 0, 0xd, 0, 0,
	0, 0x73, 0x70, 0x65, 0x63, 0x75, 0x6c, 0x61, 0x72, 0x43,
	0x6f, 0x6c, 0x6f, 0x72, 0x14, 0, 0x1, 0, 0x8, 0,
	0, 0, 0x43, 0x6f, 0x6c, 0x6f, 0x72, 0x52, 0x47, 0x42,
	0x1, 0, 0xd, 0, 0, 0, 0x65, 0x6d, 0x69, 0x73,
	0x73, 0x69, 0x76, 0x65, 0x43, 0x6f, 0x6c, 0x6f, 0x72, 0x14,
	0, 0xe, 0, 0x12, 0, 0x12, 0, 0x12, 0, 0xf,
	0, 0xb, 0, 0x1f, 0, 0x1, 0, 0x8, 0, 0,
	0, 0x4d, 0x65, 0x73, 0x68, 0x46, 0x61, 0x63, 0x65, 0xa,
	0, 0x5, 0, 0x5f, 0xab, 0x82, 0x3d, 0xda, 0x62, 0xcf,
	0x11, 0xab, 0x39, 0, 0x20, 0xaf, 0x71, 0xe4, 0x33, 0x29,
	0, 0x1, 0, 0x12, 0, 0, 0, 0x6e, 0x46, 0x61,
	0x63, 0x65, 0x56, 0x65, 0x72, 0x74, 0x65, 0x78, 0x49, 0x6e,
	0x64, 0x69, 0x63, 0x65, 0x73, 0x14, 0, 0x34, 0, 0x29,
	0, 0x1, 0, 0x11, 0, 0, 0, 0x66, 0x61, 0x63,
	0x65, 0x56, 0x65, 0x72, 0x74, 0x65, 0x78, 0x49, 0x6e, 0x64,
	0x69, 0x63, 0x65, 0x73, 0xe, 0, 0x1, 0, 0x12, 0,
	0, 0, 0x6e, 0x46, 0x61, 0x63, 0x65, 0x56, 0x65, 0x72,
	0x74, 0x65, 0x78, 0x49, 0x6e, 0x64, 0x69, 0x63, 0x65, 0x73,
	0xf, 0, 0x14, 0, 0xb, 0, 0x1f, 0, 0x1, 0,
	0xd, 0, 0, 0, 0x4d, 0x65, 0x73, 0x68, 0x46, 0x61,
	0x63, 0x65, 0x57, 0x72, 0x61, 0x70, 0x73, 0xa, 0, 0x5,
	0, 0xc0, 0xc5, 0x1e, 0xed, 0xa8, 0xc0, 0xd0, 0x11, 0x94,
	0x1c, 0, 0x80, 0xc8, 0xc, 0xfa, 0x7b, 0x29, 0, 0x1,
	0, 0xf, 0, 0, 0, 0x6e, 0x46, 0x61, 0x63, 0x65,
	0x57, 0x72, 0x61, 0x70, 0x56, 0x61, 0x6c, 0x75, 0x65, 0x73,
	0x14, 0, 0x34, 0, 0x1, 0, 0x9, 0, 0, 0,
	0x42, 0x6f, 0x6f, 0x6c, 0x65, 0x61, 0x6e, 0x32, 0x64, 0x1,
	0, 0xe, 0, 0, 0, 0x66, 0x61, 0x63, 0x65, 0x57,
	0x72, 0x61, 0x70, 0x56, 0x61, 0x6c, 0x75, 0x65, 0x73, 0xe,
	0, 0x1, 0, 0xf, 0, 0, 0, 0x6e, 0x46, 0x61,
	0x63, 0x65, 0x57, 0x72, 0x61, 0x70, 0x56, 0x61, 0x6c, 0x75,
	0x65, 0x73, 0xf, 0, 0x14, 0, 0xb, 0, 0x1f, 0,
	0x1, 0, 0x11, 0, 0, 0, 0x4d, 0x65, 0x73, 0x68,
	0x54, 0x65, 0x78, 0x74, 0x75, 0x72, 0x65, 0x43, 0x6f, 0x6f,
	0x72, 0x64, 0x73, 0xa, 0, 0x5, 0, 0x40, 0x3f, 0xf2,
	0xf6, 0x86, 0x76, 0xcf, 0x11, 0x8f, 0x52, 0, 0x40, 0x33,
	0x35, 0x94, 0xa3, 0x29, 0, 0x1, 0, 0xe, 0, 0,
	0, 0x6e, 0x54, 0x65, 0x78, 0x74, 0x75, 0x72, 0x65, 0x43,
	0x6f, 0x6f, 0x72, 0x64, 0x73, 0x14, 0, 0x34, 0, 0x1,
	0, 0x8, 0, 0, 0, 0x43, 0x6f, 0x6f, 0x72, 0x64,
	0x73, 0x32, 0x64, 0x1, 0, 0xd, 0, 0, 0, 0x74,
	0x65, 0x78, 0x74, 0x75, 0x72, 0x65, 0x43, 0x6f, 0x6f, 0x72,
	0x64, 0x73, 0xe, 0, 0x1, 0, 0xe, 0, 0, 0,
	0x6e, 0x54, 0x65, 0x78, 0x74, 0x75, 0x72, 0x65, 0x43, 0x6f,
	0x6f, 0x72, 0x64, 0x73, 0xf, 0, 0x14, 0, 0xb, 0,
	0x1f, 0, 0x1, 0, 0x10, 0, 0, 0, 0x4d, 0x65,
	0x73, 0x68, 0x4d, 0x61, 0x74, 0x65, 0x72, 0x69, 0x61, 0x6c,
	0x4c, 0x69, 0x73, 0x74, 0xa, 0, 0x5, 0, 0x42, 0x3f,
	0xf2, 0xf6, 0x86, 0x76, 0xcf, 0x11, 0x8f, 0x52, 0, 0x40,
	0x33, 0x35, 0x94, 0xa3, 0x29, 0, 0x1, 0, 0xa, 0,
	0, 0, 0x6e, 0x4d, 0x61, 0x74, 0x65, 0x72, 0x69, 0x61,
	0x6c, 0x73, 0x14, 0, 0x29, 0, 0x1, 0, 0xc, 0,
	0, 0, 0x6e, 0x46, 0x61, 0x63, 0x65, 0x49, 0x6e, 0x64,
	0x65, 0x78, 0x65, 0x73, 0x14, 0, 0x34, 0, 0x29, 0,
	0x1, 0, 0xb, 0, 0, 0, 0x66, 0x61, 0x63, 0x65,
	0x49, 0x6e, 0x64, 0x65, 0x78, 0x65, 0x73, 0xe, 0, 0x1,
	0, 0xc, 0, 0, 0, 0x6e, 0x46, 0x61, 0x63, 0x65,
	0x49, 0x6e, 0x64, 0x65, 0x78, 0x65, 0x73, 0xf, 0, 0x14,
	0, 0xe, 0, 0x1, 0, 0x8, 0, 0, 0, 0x4d,
	0x61, 0x74, 0x65, 0x72, 0x69, 0x61, 0x6c, 0xf, 0, 0xb,
	0, 0x1f, 0, 0x1, 0, 0xb, 0, 0, 0, 0x4d,
	0x65, 0x73, 0x68, 0x4e, 0x6f, 0x72, 0x6d, 0x61, 0x6c, 0x73,
	0xa, 0, 0x5, 0, 0x43, 0x3f, 0xf2, 0xf6, 0x86, 0x76,
	0xcf, 0x11, 0x8f, 0x52, 0, 0x40, 0x33, 0x35, 0x94, 0xa3,
	0x29, 0, 0x1, 0, 0x8, 0, 0, 0, 0x6e, 0x4e,
	0x6f, 0x72, 0x6d, 0x61, 0x6c, 0x73, 0x14, 0, 0x34, 0,
	0x1, 0, 0x6, 0, 0, 0, 0x56, 0x65, 0x63, 0x74,
	0x6f, 0x72, 0x1, 0, 0x7, 0, 0, 0, 0x6e, 0x6f,
	0x72, 0x6d, 0x61, 0x6c, 0x73, 0xe, 0, 0x1, 0, 0x8,
	0, 0, 0, 0x6e, 0x4e, 0x6f, 0x72, 0x6d, 0x61, 0x6c,
	0x73, 0xf, 0, 0x14, 0, 0x29, 0, 0x1, 0, 0xc,
	0, 0, 0, 0x6e, 0x46, 0x61, 0x63, 0x65, 0x4e, 0x6f,
	0x72, 0x6d, 0x61, 0x6c, 0x73, 0x14, 0, 0x34, 0, 0x1,
	0, 0x8, 0, 0, 0, 0x4d, 0x65, 0x73, 0x68, 0x46,
	0x61, 0x63, 0x65, 0x1, 0, 0xb, 0, 0, 0, 0x66,
	0x61, 0x63, 0x65, 0x4e, 0x6f, 0x72, 0x6d, 0x61, 0x6c, 0x73,
	0xe, 0, 0x1, 0, 0xc, 0, 0, 0, 0x6e, 0x46,
	0x61, 0x63, 0x65, 0x4e, 0x6f, 0x72, 0x6d, 0x61, 0x6c, 0x73,
	0xf, 0, 0x14, 0, 0xb, 0, 0x1f, 0, 0x1, 0,
	0x10, 0, 0, 0, 0x4d, 0x65, 0x73, 0x68, 0x56, 0x65,
	0x72, 0x74, 0x65, 0x78, 0x43, 0x6f, 0x6c, 0x6f, 0x72, 0x73,
	0xa, 0, 0x5, 0, 0x21, 0xb8, 0x30, 0x16, 0x42, 0x78,
	0xcf, 0x11, 0x8f, 0x52, 0, 0x40, 0x33, 0x35, 0x94, 0xa3,
	0x29, 0, 0x1, 0, 0xd, 0, 0, 0, 0x6e, 0x56,
	0x65, 0x72, 0x74, 0x65, 0x78, 0x43, 0x6f, 0x6c, 0x6f, 0x72,
	0x73, 0x14, 0, 0x34, 0, 0x1, 0, 0xc, 0, 0,
	0, 0x49, 0x6e, 0x64, 0x65, 0x78, 0x65, 0x64, 0x43, 0x6f,
	0x6c, 0x6f, 0x72, 0x1, 0, 0xc, 0, 0, 0, 0x76,
	0x65, 0x72, 0x74, 0x65, 0x78, 0x43, 0x6f, 0x6c, 0x6f, 0x72,
	0x73, 0xe, 0, 0x1, 0, 0xd, 0, 0, 0, 0x6e,
	0x56, 0x65, 0x72, 0x74, 0x65, 0x78, 0x43, 0x6f, 0x6c, 0x6f,
	0x72, 0x73, 0xf, 0, 0x14, 0, 0xb, 0, 0x1f, 0,
	0x1, 0, 0x4, 0, 0, 0, 0x4d, 0x65, 0x73, 0x68,
	0xa, 0, 0x5, 0, 0x44, 0xab, 0x82, 0x3d, 0xda, 0x62,
	0xcf, 0x11, 0xab, 0x39, 0, 0x20, 0xaf, 0x71, 0xe4, 0x33,
	0x29, 0, 0x1, 0, 0x9, 0, 0, 0, 0x6e, 0x56,
	0x65, 0x72, 0x74, 0x69, 0x63, 0x65, 0x73, 0x14, 0, 0x34,
	0, 0x1, 0, 0x6, 0, 0, 0, 0x56, 0x65, 0x63,
	0x74, 0x6f, 0x72, 0x1, 0, 0x8, 0, 0, 0, 0x76,
	0x65, 0x72, 0x74, 0x69, 0x63, 0x65, 0x73, 0xe, 0, 0x1,
	0, 0x9, 0, 0, 0, 0x6e, 0x56, 0x65, 0x72, 0x74,
	0x69, 0x63, 0x65, 0x73, 0xf, 0, 0x14, 0, 0x29, 0,
	0x1, 0, 0x6, 0, 0, 0, 0x6e, 0x46, 0x61, 0x63,
	0x65, 0x73, 0x14, 0, 0x34, 0, 0x1, 0, 0x8, 0,
	0, 0, 0x4d, 0x65, 0x73, 0x68, 0x46, 0x61, 0x63, 0x65,
	0x1, 0, 0x5, 0, 0, 0, 0x66, 0x61, 0x63, 0x65,
	0x73, 0xe, 0, 0x1, 0, 0x6, 0, 0, 0, 0x6e,
	0x46, 0x61, 0x63, 0x65, 0x73, 0xf, 0, 0x14, 0, 0xe,
	0, 0x12, 0, 0x12, 0, 0x12, 0, 0xf, 0, 0xb,
	0, 0x1f, 0, 0x1, 0, 0x14, 0, 0, 0, 0x46,
	0x72, 0x61, 0x6d, 0x65, 0x54, 0x72, 0x61, 0x6e, 0x73, 0x66,
	0x6f, 0x72, 0x6d, 0x4d, 0x61, 0x74, 0x72, 0x69, 0x78, 0xa,
	0, 0x5, 0, 0x41, 0x3f, 0xf2, 0xf6, 0x86, 0x76, 0xcf,
	0x11, 0x8f, 0x52, 0, 0x40, 0x33, 0x35, 0x94, 0xa3, 0x1,
	0, 0x9, 0, 0, 0, 0x4d, 0x61, 0x74, 0x72, 0x69,
	0x78, 0x34, 0x78, 0x34, 0x1, 0, 0xb, 0, 0, 0,
	0x66, 0x72, 0x61, 0x6d, 0x65, 0x4d, 0x61, 0x74, 0x72, 0x69,
	0x78, 0x14, 0, 0xb, 0, 0x1f, 0, 0x1, 0, 0x5,
	0, 0, 0, 0x46, 0x72, 0x61, 0x6d, 0x65, 0xa, 0,
	0x5, 0, 0x46, 0xab, 0x82, 0x3d, 0xda, 0x62, 0xcf, 0x11,
	0xab, 0x39, 0, 0x20, 0xaf, 0x71, 0xe4, 0x33, 0xe, 0,
	0x12, 0, 0x12, 0, 0x12, 0, 0xf, 0, 0xb, 0,
	0x1f, 0, 0x1, 0, 0x9, 0, 0, 0, 0x46, 0x6c,
	0x6f, 0x61, 0x74, 0x4b, 0x65, 0x79, 0x73, 0xa, 0, 0x5,
	0, 0xa9, 0x46, 0xdd, 0x10, 0x5b, 0x77, 0xcf, 0x11, 0x8f,
	0x52, 0, 0x40, 0x33, 0x35, 0x94, 0xa3, 0x29, 0, 0x1,
	0, 0x7, 0, 0, 0, 0x6e, 0x56, 0x61, 0x6c, 0x75,
	0x65, 0x73, 0x14, 0, 0x34, 0, 0x2a, 0, 0x1, 0,
	0x6, 0, 0, 0, 0x76, 0x61, 0x6c, 0x75, 0x65, 0x73,
	0xe, 0, 0x1, 0, 0x7, 0, 0, 0, 0x6e, 0x56,
	0x61, 0x6c, 0x75, 0x65, 0x73, 0xf, 0, 0x14, 0, 0xb,
	0, 0x1f, 0, 0x1, 0, 0xe, 0, 0, 0, 0x54,
	0x69, 0x6d, 0x65, 0x64, 0x46, 0x6c, 0x6f, 0x61, 0x74, 0x4b,
	0x65, 0x79, 0x73, 0xa, 0, 0x5, 0, 0x80, 0xb1, 0x6,
	0xf4, 0x3b, 0x7b, 0xcf, 0x11, 0x8f, 0x52, 0, 0x40, 0x33,
	0x35, 0x94, 0xa3, 0x29, 0, 0x1, 0, 0x4, 0, 0,
	0, 0x74, 0x69, 0x6d, 0x65, 0x14, 0, 0x1, 0, 0x9,
	0, 0, 0, 0x46, 0x6c, 0x6f, 0x61, 0x74, 0x4b, 0x65,
	0x79, 0x73, 0x1, 0, 0x6, 0, 0, 0, 0x74, 0x66,
	0x6b, 0x65, 0x79, 0x73, 0x14, 0, 0xb, 0, 0x1f, 0,
	0x1, 0, 0xc, 0, 0, 0, 0x41, 0x6e, 0x69, 0x6d,
	0x61, 0x74, 0x69, 0x6f, 0x6e, 0x4b, 0x65, 0x79, 0xa, 0,
	0x5, 0, 0xa8, 0x46, 0xdd, 0x10, 0x5b, 0x77, 0xcf, 0x11,
	0x8f, 0x52, 0, 0x40, 0x33, 0x35, 0x94, 0xa3, 0x29, 0,
	0x1, 0, 0x7, 0, 0, 0, 0x6b, 0x65, 0x79, 0x54,
	0x79, 0x70, 0x65, 0x14, 0, 0x29, 0, 0x1, 0, 0x5,
	0, 0, 0, 0x6e, 0x4b, 0x65, 0x79, 0x73, 0x14, 0,
	0x34, 0, 0x1, 0, 0xe, 0, 0, 0, 0x54, 0x69,
	0x6d, 0x65, 0x64, 0x46, 0x6c, 0x6f, 0x61, 0x74, 0x4b, 0x65,
	0x79, 0x73, 0x1, 0, 0x4, 0, 0, 0, 0x6b, 0x65,
	0x79, 0x73, 0xe, 0, 0x1, 0, 0x5, 0, 0, 0,
	0x6e, 0x4b, 0x65, 0x79, 0x73, 0xf, 0, 0x14, 0, 0xb,
	0, 0x1f, 0, 0x1, 0, 0x10, 0, 0, 0, 0x41,
	0x6e, 0x69, 0x6d, 0x61, 0x74, 0x69, 0x6f, 0x6e, 0x4f, 0x70,
	0x74, 0x69, 0x6f, 0x6e, 0x73, 0xa, 0, 0x5, 0, 0xc0,
	0x56, 0xbf, 0xe2, 0xf, 0x84, 0xcf, 0x11, 0x8f, 0x52, 0,
	0x40, 0x33, 0x35, 0x94, 0xa3, 0x29, 0, 0x1, 0, 0xa,
	0, 0, 0, 0x6f, 0x70, 0x65, 0x6e, 0x63, 0x6c, 0x6f,
	0x73, 0x65, 0x64, 0x14, 0, 0x29, 0, 0x1, 0, 0xf,
	0, 0, 0, 0x70, 0x6f, 0x73, 0x69, 0x74, 0x69, 0x6f,
	0x6e, 0x71, 0x75, 0x61, 0x6c, 0x69, 0x74, 0x79, 0x14, 0,
	0xb, 0, 0x1f, 0, 0x1, 0, 0x9, 0, 0, 0,
	0x41, 0x6e, 0x69, 0x6d, 0x61, 0x74, 0x69, 0x6f, 0x6e, 0xa,
	0, 0x5, 0, 0x4f, 0xab, 0x82, 0x3d, 0xda, 0x62, 0xcf,
	0x11, 0xab, 0x39, 0, 0x20, 0xaf, 0x71, 0xe4, 0x33, 0xe,
	0, 0x12, 0, 0x12, 0, 0x12, 0, 0xf, 0, 0xb,
	0, 0x1f, 0, 0x1, 0, 0xc, 0, 0, 0, 0x41,
	0x6e, 0x69, 0x6d, 0x61, 0x74, 0x69, 0x6f, 0x6e, 0x53, 0x65,
	0x74, 0xa, 0, 0x5, 0, 0x50, 0xab, 0x82, 0x3d, 0xda,
	0x62, 0xcf, 0x11, 0xab, 0x39, 0, 0x20, 0xaf, 0x71, 0xe4,
	0x33, 0xe, 0, 0x1, 0, 0x9, 0, 0, 0, 0x41,
	0x6e, 0x69, 0x6d, 0x61, 0x74, 0x69, 0x6f, 0x6e, 0xf, 0,
	0xb, 0, 0x1f, 0, 0x1, 0, 0xa, 0, 0, 0,
	0x49, 0x6e, 0x6c, 0x69, 0x6e, 0x65, 0x44, 0x61, 0x74, 0x61,
	0xa, 0, 0x5, 0, 0xa0, 0xee, 0x23, 0x3a, 0xb1, 0x94,
	0xd0, 0x11, 0xab, 0x39, 0, 0x20, 0xaf, 0x71, 0xe4, 0x33,
	0xe, 0, 0x1, 0, 0x6, 0, 0, 0, 0x42, 0x49,
	0x4e, 0x41, 0x52, 0x59, 0xf, 0, 0xb, 0, 0x1f, 0,
	0x1, 0, 0x3, 0, 0, 0, 0x55, 0x72, 0x6c, 0xa,
	0, 0x5, 0, 0xa1, 0xee, 0x23, 0x3a, 0xb1, 0x94, 0xd0,
	0x11, 0xab, 0x39, 0, 0x20, 0xaf, 0x71, 0xe4, 0x33, 0x29,
	0, 0x1, 0, 0x5, 0, 0, 0, 0x6e, 0x55, 0x72,
	0x6c, 0x73, 0x14, 0, 0x34, 0, 0x31, 0, 0x1, 0,
	0x4, 0, 0, 0, 0x75, 0x72, 0x6c, 0x73, 0xe, 0,
	0x1, 0, 0x5, 0, 0, 0, 0x6e, 0x55, 0x72, 0x6c,
	0x73, 0xf, 0, 0x14, 0, 0xb, 0, 0x1f, 0, 0x1,
	0, 0xf, 0, 0, 0, 0x50, 0x72, 0x6f, 0x67, 0x72,
	0x65, 0x73, 0x73, 0x69, 0x76, 0x65, 0x4d, 0x65, 0x73, 0x68,
	0xa, 0, 0x5, 0, 0x60, 0xc3, 0x63, 0x8a, 0x7d, 0x99,
	0xd0, 0x11, 0x94, 0x1c, 0, 0x80, 0xc8, 0xc, 0xfa, 0x7b,
	0xe, 0, 0x1, 0, 0x3, 0, 0, 0, 0x55, 0x72,
	0x6c, 0x13, 0, 0x1, 0, 0xa, 0, 0, 0, 0x49,
	0x6e, 0x6c, 0x69, 0x6e, 0x65, 0x44, 0x61, 0x74, 0x61, 0xf,
	0, 0xb, 0, 0x1f, 0, 0x1, 0, 0x4, 0, 0,
	0, 0x47, 0x75, 0x69, 0x64, 0xa, 0, 0x5, 0, 0xe0,
	0x90, 0x27, 0xa4, 0x10, 0x78, 0xcf, 0x11, 0x8f, 0x52, 0,
	0x40, 0x33, 0x35, 0x94, 0xa3, 0x29, 0, 0x1, 0, 0x5,
	0, 0, 0, 0x64, 0x61, 0x74, 0x61, 0x31, 0x14, 0,
	0x28, 0, 0x1, 0, 0x5, 0, 0, 0, 0x64, 0x61,
	0x74, 0x61, 0x32, 0x14, 0, 0x28, 0, 0x1, 0, 0x5,
	0, 0, 0, 0x64, 0x61, 0x74, 0x61, 0x33, 0x14, 0,
	0x34, 0, 0x2d, 0, 0x1, 0, 0x5, 0, 0, 0,
	0x64, 0x61, 0x74, 0x61, 0x34, 0xe, 0, 0x3, 0, 0x8,
	0, 0, 0, 0xf, 0, 0x14, 0, 0xb, 0, 0x1f,
	0, 0x1, 0, 0xe, 0, 0, 0, 0x53, 0x74, 0x72,
	0x69, 0x6e, 0x67, 0x50, 0x72, 0x6f, 0x70, 0x65, 0x72, 0x74,
	0x79, 0xa, 0, 0x5, 0, 0xe0, 0x21, 0xf, 0x7f, 0xe1,
	0xbf, 0xd1, 0x11, 0x82, 0xc0, 0, 0xa0, 0xc9, 0x69, 0x72,
	0x71, 0x31, 0, 0x1, 0, 0x3, 0, 0, 0, 0x6b,
	0x65, 0x79, 0x14, 0, 0x31, 0, 0x1, 0, 0x5, 0,
	0, 0, 0x76, 0x61, 0x6c, 0x75, 0x65, 0x14, 0, 0xb,
	0, 0x1f, 0, 0x1, 0, 0xb, 0, 0, 0, 0x50,
	0x72, 0x6f, 0x70, 0x65, 0x72, 0x74, 0x79, 0x42, 0x61, 0x67,
	0xa, 0, 0x5, 0, 0xe1, 0x21, 0xf, 0x7f, 0xe1, 0xbf,
	0xd1, 0x11, 0x82, 0xc0, 0, 0xa0, 0xc9, 0x69, 0x72, 0x71,
	0xe, 0, 0x1, 0, 0xe, 0, 0, 0, 0x53, 0x74,
	0x72, 0x69, 0x6e, 0x67, 0x50, 0x72, 0x6f, 0x70, 0x65, 0x72,
	0x74, 0x79, 0xf, 0, 0xb, 0, 0x1f, 0, 0x1, 0,
	0xe, 0, 0, 0, 0x45, 0x78, 0x74, 0x65, 0x72, 0x6e,
	0x61, 0x6c, 0x56, 0x69, 0x73, 0x75, 0x61, 0x6c, 0xa, 0,
	0x5, 0, 0xa0, 0x6a, 0x11, 0x98, 0xba, 0xbd, 0xd1, 0x11,
	0x82, 0xc0, 0, 0xa0, 0xc9, 0x69, 0x72, 0x71, 0x1, 0,
	0x4, 0, 0, 0, 0x47, 0x75, 0x69, 0x64, 0x1, 0,
	0x12, 0, 0, 0, 0x67, 0x75, 0x69, 0x64, 0x45, 0x78,
	0x74, 0x65, 0x72, 0x6e, 0x61, 0x6c, 0x56, 0x69, 0x73, 0x75,
	0x61, 0x6c, 0x14, 0, 0xe, 0, 0x12, 0, 0x12, 0,
	0x12, 0, 0xf, 0, 0xb, 0, 0x1f, 0, 0x1, 0,
	0xb, 0, 0, 0, 0x52, 0x69, 0x67, 0x68, 0x74, 0x48,
	0x61, 0x6e, 0x64, 0x65, 0x64, 0xa, 0, 0x5, 0, 0xa0,
	0x5e, 0x5d, 0x7f, 0x3a, 0xd5, 0xd1, 0x11, 0x82, 0xc0, 0,
	0xa0, 0xc9, 0x69, 0x72, 0x71, 0x29, 0, 0x1, 0, 0xc,
	0, 0, 0, 0x62, 0x52, 0x69, 0x67, 0x68, 0x74, 0x48,
	0x61, 0x6e, 0x64, 0x65, 0x64, 0x14, 0, 0xb, 0
];

const GUID DXFILEOBJ_XSkinMeshHeader = DEFINE_GUID!(0x3cf169ce, 0xff7c, 0x44ab, 0x93, 0xc0, 0xf7, 0x8f, 0x62, 0xd1, 0x72, 0xe2);
const GUID DXFILEOBJ_VertexDuplicationIndices = DEFINE_GUID!(0xb8d65549, 0xd7c9, 0x4995, 0x89, 0xcf, 0x53, 0xa9, 0xa8, 0xb0, 0x31, 0xe3);
const GUID DXFILEOBJ_FaceAdjacency = DEFINE_GUID!(0xa64c844a, 0xe282, 0x4756, 0x8b, 0x80, 0x25, 0xc, 0xde, 0x4, 0x39, 0x8c);
const GUID DXFILEOBJ_SkinWeights = DEFINE_GUID!(0x6f0d123b, 0xbad2, 0x4167, 0xa0, 0xd0, 0x80, 0x22, 0x4f, 0x25, 0xfa, 0xbb);
const GUID DXFILEOBJ_Patch = DEFINE_GUID!(0xa3eb5d44, 0xfc22, 0x429d, 0x9a, 0xfb, 0x32, 0x21, 0xcb, 0x97, 0x19, 0xa6);
const GUID DXFILEOBJ_PatchMesh = DEFINE_GUID!(0xd02c95cc, 0xedba, 0x4305, 0x9b, 0x5d, 0x18, 0x20, 0xd7, 0x70, 0x4b, 0xbf);
const GUID DXFILEOBJ_PatchMesh9 = DEFINE_GUID!(0xb9ec94e1, 0xb9a6, 0x4251, 0xba, 0x18, 0x94, 0x89, 0x3f, 0x2, 0xc0, 0xea);
const GUID DXFILEOBJ_PMInfo = DEFINE_GUID!(0xb6c3e656, 0xec8b, 0x4b92, 0x9b, 0x62, 0x68, 0x16, 0x59, 0x52, 0x29, 0x47);
const GUID DXFILEOBJ_PMAttributeRange = DEFINE_GUID!(0x917e0427, 0xc61e, 0x4a14, 0x9c, 0x64, 0xaf, 0xe6, 0x5f, 0x9e, 0x98, 0x44);
const GUID DXFILEOBJ_PMVSplitRecord = DEFINE_GUID!(0x574ccc14, 0xf0b3, 0x4333, 0x82, 0x2d, 0x93, 0xe8, 0xa8, 0xa0, 0x8e, 0x4c);
const GUID DXFILEOBJ_FVFData = DEFINE_GUID!(0xb6e70a0e, 0x8ef9, 0x4e83, 0x94, 0xad, 0xec, 0xc8, 0xb0, 0xc0, 0x48, 0x97);
const GUID DXFILEOBJ_VertexElement = DEFINE_GUID!(0xf752461c, 0x1e23, 0x48f6, 0xb9, 0xf8, 0x83, 0x50, 0x85, 0xf, 0x33, 0x6f);
const GUID DXFILEOBJ_DeclData = DEFINE_GUID!(0xbf22e553, 0x292c, 0x4781, 0x9f, 0xea, 0x62, 0xbd, 0x55, 0x4b, 0xdd, 0x93);
const GUID DXFILEOBJ_EffectFloats = DEFINE_GUID!(0xf1cfe2b3, 0xde3, 0x4e28, 0xaf, 0xa1, 0x15, 0x5a, 0x75, 0xa, 0x28, 0x2d);
const GUID DXFILEOBJ_EffectString = DEFINE_GUID!(0xd55b097e, 0xbdb6, 0x4c52, 0xb0, 0x3d, 0x60, 0x51, 0xc8, 0x9d, 0xe, 0x42);
const GUID DXFILEOBJ_EffectDWord = DEFINE_GUID!(0x622c0ed0, 0x956e, 0x4da9, 0x90, 0x8a, 0x2a, 0xf9, 0x4f, 0x3c, 0xe7, 0x16);
const GUID DXFILEOBJ_EffectParamFloats = DEFINE_GUID!(0x3014b9a0, 0x62f5, 0x478c, 0x9b, 0x86, 0xe4, 0xac, 0x9f, 0x4e, 0x41, 0x8b);
const GUID DXFILEOBJ_EffectParamString = DEFINE_GUID!(0x1dbc4c88, 0x94c1, 0x46ee, 0x90, 0x76, 0x2c, 0x28, 0x81, 0x8c, 0x94, 0x81);
const GUID DXFILEOBJ_EffectParamDWord = DEFINE_GUID!(0xe13963bc, 0xae51, 0x4c5d, 0xb0, 0xf, 0xcf, 0xa3, 0xa9, 0xd9, 0x7c, 0xe5);
const GUID DXFILEOBJ_EffectInstance = DEFINE_GUID!(0xe331f7e4, 0x559, 0x4cc2, 0x8e, 0x99, 0x1c, 0xec, 0x16, 0x57, 0x92, 0x8f);
const GUID DXFILEOBJ_AnimTicksPerSecond = DEFINE_GUID!(0x9e415a43, 0x7ba6, 0x4a73, 0x87, 0x43, 0xb7, 0x3d, 0x47, 0xe8, 0x84, 0x76);
const GUID DXFILEOBJ_CompressedAnimationSet = DEFINE_GUID!(0x7f9b00b3, 0xf125, 0x4890, 0x87, 0x6e, 0x1c, 0x42, 0xbf, 0x69, 0x7c, 0x4d);

align(1) struct XFILECOMPRESSEDANIMATIONSET
{
    DWORD CompressedBlockSize;
    FLOAT TicksPerSec;
    DWORD PlaybackType;
    DWORD BufferLength;
}

const char[] XSKINEXP_TEMPLATES =
        "xof 0303txt 0032
        template XSkinMeshHeader
        {
            <3CF169CE-FF7C-44ab-93C0-F78F62D172E2>
            WORD nMaxSkinWeightsPerVertex;
            WORD nMaxSkinWeightsPerFace;
            WORD nBones;
        }
        template VertexDuplicationIndices
        {
            <B8D65549-D7C9-4995-89CF-53A9A8B031E3>
            DWORD nIndices;
            DWORD nOriginalVertices;
            array DWORD indices[nIndices];
        }
        template FaceAdjacency
        {
            <A64C844A-E282-4756-8B80-250CDE04398C>
            DWORD nIndices;
            array DWORD indices[nIndices];
        }
        template SkinWeights
        {
            <6F0D123B-BAD2-4167-A0D0-80224F25FABB>
            STRING transformNodeName;
            DWORD nWeights;
            array DWORD vertexIndices[nWeights];
            array float weights[nWeights];
            Matrix4x4 matrixOffset;
        }
        template Patch
        {
            <A3EB5D44-FC22-429D-9AFB-3221CB9719A6>
            DWORD nControlIndices;
            array DWORD controlIndices[nControlIndices];
        }
        template PatchMesh
        {
            <D02C95CC-EDBA-4305-9B5D-1820D7704BBF>
            DWORD nVertices;
            array Vector vertices[nVertices];
            DWORD nPatches;
            array Patch patches[nPatches];
            [ ... ]
        }
        template PatchMesh9
        {
            <B9EC94E1-B9A6-4251-BA18-94893F02C0EA>
            DWORD Type;
            DWORD Degree;
            DWORD Basis;
            DWORD nVertices;
            array Vector vertices[nVertices];
            DWORD nPatches;
            array Patch patches[nPatches];
            [ ... ]
        } "
        "template EffectFloats
        {
            <F1CFE2B3-0DE3-4e28-AFA1-155A750A282D>
            DWORD nFloats;
            array float Floats[nFloats];
        }
        template EffectString
        {
            <D55B097E-BDB6-4c52-B03D-6051C89D0E42>
            STRING Value;
        }
        template EffectDWord
        {
            <622C0ED0-956E-4da9-908A-2AF94F3CE716>
            DWORD Value;
        } "
        "template EffectParamFloats
        {
            <3014B9A0-62F5-478c-9B86-E4AC9F4E418B>
            STRING ParamName;
            DWORD nFloats;
            array float Floats[nFloats];
        } "
        "template EffectParamString
        {
            <1DBC4C88-94C1-46ee-9076-2C28818C9481>
            STRING ParamName;
            STRING Value;
        }
        template EffectParamDWord
        {
            <E13963BC-AE51-4c5d-B00F-CFA3A9D97CE5>
            STRING ParamName;
            DWORD Value;
        }
        template EffectInstance
        {
            <E331F7E4-0559-4cc2-8E99-1CEC1657928F>
            STRING EffectFilename;
            [ ... ]
        } "
        "template AnimTicksPerSecond
        {
            <9E415A43-7BA6-4a73-8743-B73D47E88476>
            DWORD AnimTicksPerSecond;
        }
        template CompressedAnimationSet
        {
            <7F9B00B3-F125-4890-876E-1C42BF697C4D>
            DWORD CompressedBlockSize;
            FLOAT TicksPerSec;
            DWORD PlaybackType;
            DWORD BufferLength;
            array DWORD CompressedData[BufferLength];
        } ";

const char[] XEXTENSIONS_TEMPLATES =
        "xof 0303txt 0032
        template FVFData
        {
            <B6E70A0E-8EF9-4e83-94AD-ECC8B0C04897>
            DWORD dwFVF;
            DWORD nDWords;
            array DWORD data[nDWords];
        }
        template VertexElement
        {
            <F752461C-1E23-48f6-B9F8-8350850F336F>
            DWORD Type;
            DWORD Method;
            DWORD Usage;
            DWORD UsageIndex;
        }
        template DeclData
        {
            <BF22E553-292C-4781-9FEA-62BD554BDD93>
            DWORD nElements;
            array VertexElement Elements[nElements];
            DWORD nDWords;
            array DWORD data[nDWords];
        }
        template PMAttributeRange
        {
            <917E0427-C61E-4a14-9C64-AFE65F9E9844>
            DWORD iFaceOffset;
            DWORD nFacesMin;
            DWORD nFacesMax;
            DWORD iVertexOffset;
            DWORD nVerticesMin;
            DWORD nVerticesMax;
        }
        template PMVSplitRecord
        {
            <574CCC14-F0B3-4333-822D-93E8A8A08E4C>
            DWORD iFaceCLW;
            DWORD iVlrOffset;
            DWORD iCode;
        }
        template PMInfo
        {
            <B6C3E656-EC8B-4b92-9B62-681659522947>
            DWORD nAttributes;
            array PMAttributeRange attributeRanges[nAttributes];
            DWORD nMaxValence;
            DWORD nMinLogicalVertices;
            DWORD nMaxLogicalVertices;
            DWORD nVSplits;
            array PMVSplitRecord splitRecords[nVSplits];
            DWORD nAttributeMispredicts;
            array DWORD attributeMispredicts[nAttributeMispredicts];
        } ";

enum : uint
{
	D3DXF_FILEFORMAT_BINARY          = 0,
	D3DXF_FILEFORMAT_TEXT            = 1,
	D3DXF_FILEFORMAT_COMPRESSED      = 2
}
alias uint D3DXF_FILEFORMAT;

enum : uint
{
	D3DXF_FILESAVE_TOFILE     = 0x00L,
	D3DXF_FILESAVE_TOWFILE    = 0x01L
}
alias uint D3DXF_FILESAVEOPTIONS;

enum : uint
{
	D3DXF_FILELOAD_FROMFILE     = 0x00L,
	D3DXF_FILELOAD_FROMWFILE    = 0x01L,
	D3DXF_FILELOAD_FROMRESOURCE = 0x02L,
	D3DXF_FILELOAD_FROMMEMORY   = 0x03L
}
alias uint D3DXF_FILELOADOPTIONS;

struct D3DXF_FILELOADRESOURCE
{
    HMODULE hModule; // Desc
    LPCSTR lpName;  // Desc
    LPCSTR lpType;  // Desc
}

struct D3DXF_FILELOADMEMORY
{
    LPCVOID lpMemory; // Desc
    size_t  dSize;     // Desc
}

const GUID IID_ID3DXFile = DEFINE_GUID!(0xcef08cf9, 0x7b4f, 0x4429, 0x96, 0x24, 0x2a, 0x69, 0x0a, 0x93, 0x32, 0x01 );
const GUID IID_ID3DXFileSaveObject = DEFINE_GUID!(0xcef08cfa, 0x7b4f, 0x4429, 0x96, 0x24, 0x2a, 0x69, 0x0a, 0x93, 0x32, 0x01 );
const GUID IID_ID3DXFileSaveData = DEFINE_GUID!(0xcef08cfb, 0x7b4f, 0x4429, 0x96, 0x24, 0x2a, 0x69, 0x0a, 0x93, 0x32, 0x01 );
const GUID IID_ID3DXFileEnumObject = DEFINE_GUID!(0xcef08cfc, 0x7b4f, 0x4429, 0x96, 0x24, 0x2a, 0x69, 0x0a, 0x93, 0x32, 0x01 );
const GUID IID_ID3DXFileData = DEFINE_GUID!(0xcef08cfd, 0x7b4f, 0x4429, 0x96, 0x24, 0x2a, 0x69, 0x0a, 0x93, 0x32, 0x01 );

interface ID3DXFile : IUnknown
{
    HRESULT CreateEnumObject(LPCVOID, D3DXF_FILELOADOPTIONS, ID3DXFileEnumObject*);
    HRESULT CreateSaveObject(LPCVOID, D3DXF_FILESAVEOPTIONS, D3DXF_FILEFORMAT, ID3DXFileSaveObject*);
    HRESULT RegisterTemplates(LPCVOID, size_t);
    HRESULT RegisterEnumTemplates(ID3DXFileEnumObject);
}

interface ID3DXFileSaveObject : IUnknown
{
    HRESULT GetFile(ID3DXFile*);
    HRESULT AddDataObject(GUID*, LPCSTR, GUID*, size_t, LPCVOID, ID3DXFileSaveData*);
    HRESULT Save();
}

interface ID3DXFileSaveData : IUnknown
{
    HRESULT GetSave(ID3DXFileSaveObject*);
    HRESULT GetName(LPSTR, size_t*);
    HRESULT GetId(GUID*);
    HRESULT GetType(GUID*);
    HRESULT AddDataObject(GUID*, LPCSTR, GUID*, size_t, LPCVOID, ID3DXFileSaveData*);
    HRESULT AddDataReference(LPCSTR, GUID* );
}

interface ID3DXFileEnumObject : IUnknown
{
    HRESULT GetFile(ID3DXFile*);
    HRESULT GetChildren(size_t*);
    HRESULT GetChild(size_t, ID3DXFileData*);
    HRESULT GetDataObjectById(REFGUID, ID3DXFileData*);
    HRESULT GetDataObjectByName(LPCSTR, ID3DXFileData*);
}

interface ID3DXFileData : IUnknown
{
    HRESULT GetEnum(ID3DXFileEnumObject*);
    HRESULT GetName(LPSTR, size_t*);
    HRESULT GetId(GUID*);
    HRESULT Lock(size_t*, LPCVOID*);
    HRESULT Unlock();
    HRESULT GetType(GUID*);
    BOOL IsReference();
    HRESULT GetChildren(size_t*);
    HRESULT GetChild(size_t, ID3DXFileData*);
}
