/***********************************************************************\
*                               d3dx10tex.d                             *
*                                                                       *
*                       Windows API header module                       *
*                                                                       *
*                       Placed into public domain                       *
\***********************************************************************/
module win32.directx.d3dx10tex;

private import win32.windows;
private import win32.directx.d3d10;
private import win32.directx.d3dx10core;

enum D3DX10_FILTER_FLAG {
	D3DX10_FILTER_NONE             = 0x000001,
	D3DX10_FILTER_POINT            = 0x000002,
	D3DX10_FILTER_LINEAR           = 0x000003,
	D3DX10_FILTER_TRIANGLE         = 0x000004,
	D3DX10_FILTER_BOX              = 0x000005,
	D3DX10_FILTER_MIRROR_U         = 0x010000,
	D3DX10_FILTER_MIRROR_V         = 0x020000,
	D3DX10_FILTER_MIRROR_W         = 0x040000,
	D3DX10_FILTER_MIRROR           = 0x070000,
	D3DX10_FILTER_DITHER           = 0x080000,
	D3DX10_FILTER_DITHER_DIFFUSION = 0x100000,
	D3DX10_FILTER_SRGB_IN          = 0x200000,
	D3DX10_FILTER_SRGB_OUT         = 0x400000,
	D3DX10_FILTER_SRGB             = 0x600000
}

enum D3DX10_NORMALMAP_FLAG {
	D3DX10_NORMALMAP_MIRROR_U          = 0x010000,
	D3DX10_NORMALMAP_MIRROR_V          = 0x020000,
	D3DX10_NORMALMAP_MIRROR            = 0x030000,
	D3DX10_NORMALMAP_INVERTSIGN        = 0x080000,
	D3DX10_NORMALMAP_COMPUTE_OCCLUSION = 0x100000
}

enum D3DX10_CHANNEL_FLAG {
	D3DX10_CHANNEL_RED       =  1,
	D3DX10_CHANNEL_BLUE      =  2,
	D3DX10_CHANNEL_GREEN     =  4,
	D3DX10_CHANNEL_ALPHA     =  8,
	D3DX10_CHANNEL_LUMINANCE = 16
}

enum D3DX10_IMAGE_FILE_FORMAT {
	D3DX10_IFF_BMP         =  0,
	D3DX10_IFF_JPG         =  1,
	D3DX10_IFF_PNG         =  3,
	D3DX10_IFF_DDS         =  4,
	D3DX10_IFF_TIFF        = 10,
	D3DX10_IFF_GIF         = 11,
	D3DX10_IFF_WMP         = 12,
	D3DX10_IFF_FORCE_DWORD = 0x7fffffff
}

enum D3DX10_SAVE_TEXTURE_FLAG {
	D3DX10_STF_USEINPUTBLOB = 1
}

struct D3DX10_IMAGE_INFO {
	UINT        Width;
	UINT        Height;
	UINT        Depth;
	UINT        ArraySize;
	UINT        MipLevels;
	UINT        MiscFlags;
	DXGI_FORMAT Format;
	D3D10_RESOURCE_DIMENSION ResourceDimension;
	D3DX10_IMAGE_FILE_FORMAT ImageFileFormat;
}

struct D3DX10_IMAGE_LOAD_INFO {
	UINT               Width;
	UINT               Height;
	UINT               Depth;
	UINT               FirstMipLevel;
	UINT               MipLevels;
	D3D10_USAGE        Usage;
	UINT               BindFlags;
	UINT               CpuAccessFlags;
	UINT               MiscFlags;
	DXGI_FORMAT        Format;
	UINT               Filter;
	UINT               MipFilter;
	D3DX10_IMAGE_INFO* pSrcInfo;
}

HRESULT D3DX10GetImageInfoFromFileA(LPCSTR pSrcFile, ID3DX10ThreadPump pPump,
  D3DX10_IMAGE_INFO* pSrcInfo, HRESULT* pHResult);
HRESULT D3DX10GetImageInfoFromFileW(LPCWSTR pSrcFile, ID3DX10ThreadPump pPump,
  D3DX10_IMAGE_INFO* pSrcInfo, HRESULT* pHResult);

HRESULT D3DX10GetImageInfoFromResourceA(HMODULE hSrcModule,
  LPCSTR pSrcResource, ID3DX10ThreadPump pPump, D3DX10_IMAGE_INFO* pSrcInfo,
  HRESULT* pHResult);
HRESULT D3DX10GetImageInfoFromResourceW(HMODULE hSrcModule,
  LPCWSTR pSrcResource, ID3DX10ThreadPump pPump, D3DX10_IMAGE_INFO* pSrcInfo,
  HRESULT* pHResult);

HRESULT D3DX10GetImageInfoFromMemory(LPCVOID pSrcData, SIZE_T SrcDataSize,
  ID3DX10ThreadPump pPump, D3DX10_IMAGE_INFO* pSrcInfo, HRESULT* pHResult);

HRESULT D3DX10CreateShaderResourceViewFromFileA(ID3D10Device pDevice,
  LPCSTR pSrcFile, D3DX10_IMAGE_LOAD_INFO* pLoadInfo, ID3DX10ThreadPump pPump,
  ID3D10ShaderResourceView* ppShaderResourceView, HRESULT* pHResult);
HRESULT D3DX10CreateShaderResourceViewFromFileW(ID3D10Device pDevice,
  LPCWSTR pSrcFile, D3DX10_IMAGE_LOAD_INFO* pLoadInfo, ID3DX10ThreadPump pPump,
  ID3D10ShaderResourceView* ppShaderResourceView, HRESULT* pHResult);

HRESULT D3DX10CreateTextureFromFileA(ID3D10Device pDevice, LPCSTR pSrcFile,
  D3DX10_IMAGE_LOAD_INFO* pLoadInfo, ID3DX10ThreadPump pPump,
  ID3D10Resource* ppTexture, HRESULT* pHResult);
HRESULT D3DX10CreateTextureFromFileW(ID3D10Device pDevice, LPCWSTR pSrcFile,
  D3DX10_IMAGE_LOAD_INFO* pLoadInfo, ID3DX10ThreadPump pPump,
  ID3D10Resource* ppTexture, HRESULT* pHResult);

HRESULT D3DX10CreateShaderResourceViewFromResourceA(ID3D10Device pDevice,
  HMODULE hSrcModule, LPCSTR pSrcResource, D3DX10_IMAGE_LOAD_INFO* pLoadInfo,
  ID3DX10ThreadPump pPump, ID3D10ShaderResourceView* ppShaderResourceView,
  HRESULT* pHResult);
HRESULT D3DX10CreateShaderResourceViewFromResourceW(ID3D10Device pDevice,
  HMODULE hSrcModule, LPCWSTR pSrcResource, D3DX10_IMAGE_LOAD_INFO* pLoadInfo,
  ID3DX10ThreadPump pPump, ID3D10ShaderResourceView* ppShaderResourceView,
  HRESULT* pHResult);

HRESULT D3DX10CreateTextureFromResourceA(ID3D10Device pDevice,
  HMODULE hSrcModule, LPCSTR pSrcResource, D3DX10_IMAGE_LOAD_INFO* pLoadInfo,
  ID3DX10ThreadPump pPump, ID3D10Resource* ppTexture, HRESULT* pHResult);
HRESULT D3DX10CreateTextureFromResourceW(ID3D10Device pDevice,
  HMODULE hSrcModule, LPCWSTR pSrcResource, D3DX10_IMAGE_LOAD_INFO* pLoadInfo,
  ID3DX10ThreadPump pPump, ID3D10Resource* ppTexture, HRESULT* pHResult);

HRESULT D3DX10CreateShaderResourceViewFromMemory(ID3D10Device pDevice,
  LPCVOID pSrcData, SIZE_T SrcDataSize, D3DX10_IMAGE_LOAD_INFO* pLoadInfo,
  ID3DX10ThreadPump pPump, ID3D10ShaderResourceView* ppShaderResourceView,
  HRESULT* pHResult);

HRESULT D3DX10CreateTextureFromMemory(ID3D10Device pDevice, LPCVOID pSrcData,
  SIZE_T SrcDataSize, D3DX10_IMAGE_LOAD_INFO* pLoadInfo,
  ID3DX10ThreadPump pPump, ID3D10Resource* ppTexture, HRESULT* pHResult);

struct D3DX10_TEXTURE_LOAD_INFO {
	D3D10_BOX* pSrcBox;
	D3D10_BOX* pDstBox;
	UINT       SrcFirstMip;
	UINT       DstFirstMip;
	UINT       NumMips;
	UINT       SrcFirstElement;
	UINT       DstFirstElement;
	UINT       NumElements;
	UINT       Filter;
	UINT       MipFilter;
}

HRESULT D3DX10LoadTextureFromTexture(ID3D10Resource pSrcTexture,
  D3DX10_TEXTURE_LOAD_INFO* pLoadInfo, ID3D10Resource pDstTexture);

HRESULT D3DX10FilterTexture(ID3D10Resource pTexture, UINT SrcLevel, UINT MipFilter);

HRESULT D3DX10SaveTextureToFileA(ID3D10Resource pSrcTexture,
  D3DX10_IMAGE_FILE_FORMAT DestFormat, LPCSTR pDestFile);
HRESULT D3DX10SaveTextureToFileW(ID3D10Resource pSrcTexture,
  D3DX10_IMAGE_FILE_FORMAT DestFormat, LPCWSTR pDestFile);

HRESULT D3DX10SaveTextureToMemory(ID3D10Resource pSrcTexture,
  D3DX10_IMAGE_FILE_FORMAT DestFormat, ID3D10Blob* ppDestBuf, UINT Flags);

HRESULT D3DX10ComputeNormalMap(ID3D10Texture2D pSrcTexture, UINT Flags,
  UINT Channel, FLOAT Amplitude, ID3D10Texture2D pDestTexture);

HRESULT D3DX10SHProjectCubeMap(UINT Order, ID3D10Texture2D pCubeMap,
  FLOAT* pROut, FLOAT* pGOut, FLOAT* pBOut);

version(Unicode) {
	alias D3DX10GetImageInfoFromFileW D3DX10GetImageInfoFromFile;
	alias D3DX10GetImageInfoFromResourceW D3DX10GetImageInfoFromResource;
	alias D3DX10CreateShaderResourceViewFromFileW D3DX10CreateShaderResourceViewFromFile;
	alias D3DX10CreateTextureFromFileW D3DX10CreateTextureFromFile;
	alias D3DX10CreateShaderResourceViewFromResourceW D3DX10CreateShaderResourceViewFromResource;
	alias D3DX10CreateTextureFromResourceW D3DX10CreateTextureFromResource;
	alias D3DX10SaveTextureToFileW D3DX10SaveTextureToFile;
} else {
	alias D3DX10GetImageInfoFromFileA D3DX10GetImageInfoFromFile;
	alias D3DX10GetImageInfoFromResourceA D3DX10GetImageInfoFromResource;
	alias D3DX10CreateShaderResourceViewFromFileA D3DX10CreateShaderResourceViewFromFile;
	alias D3DX10CreateTextureFromFileA D3DX10CreateTextureFromFile;
	alias D3DX10CreateShaderResourceViewFromResourceA D3DX10CreateShaderResourceViewFromResource;
	alias D3DX10CreateTextureFromResourceA D3DX10CreateTextureFromResource;
	alias D3DX10SaveTextureToFileA D3DX10SaveTextureToFile;
}
