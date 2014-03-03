/***********************************************************************\
*                              d3dx10core.d                             *
*                                                                       *
*                       Windows API header module                       *
*                                                                       *
*                       Placed into public domain                       *
\***********************************************************************/
module win32.directx.d3dx10core;

private import win32.windows;

private import win32.directx.d3d10;
private import win32.directx.d3d10effect;
private import win32.directx.d3dx10math;

const D3DX10_DLL_W = "d3dx10_36.dll";
const D3DX10_DLL_A = "d3dx10_36.dll";

version(Unicode) {
	alias D3DX10_DLL_W D3DX10_DLL;
} else {
	alias D3DX10_DLL_A D3DX10_DLL;
}

const D3DX10_SDK_VERSION = 36;

extern(Windows) {
	HRESULT D3DX10CreateDevice(IDXGIAdapter pAdapter, D3D10_DRIVER_TYPE DriverType,
		HMODULE Software, UINT Flags, ID3D10Device* ppDevice);
	HRESULT D3DX10CreateDeviceAndSwapChain(IDXGIAdapter pAdapter, D3D10_DRIVER_TYPE DriverType,
		HMODULE Software, UINT Flags, DXGI_SWAP_CHAIN_DESC* pSwapChainDesc, IDXGISwapChain* ppSwapChain,    
		ID3D10Device* ppDevice);
//TODO	HRESULT D3DX10GetFeatureLevel1(ID3D10Device pDevice, ID3D10Device1* ppDevice1);

	debug(D3D10_DEBUG) {
		BOOL D3DX10DebugMute(BOOL Mute);
	}

	HRESULT D3DX10CheckVersion(UINT D3DSdkVersion, UINT D3DX10SdkVersion);
	UINT D3DX10GetDriverLevel(ID3D10Device pDevice);
}

enum D3DX10_SPRITE_FLAG {
	D3DX10_SPRITE_SORT_TEXTURE				= 0x01,
	D3DX10_SPRITE_SORT_DEPTH_BACK_TO_FRONT	= 0x02,
	D3DX10_SPRITE_SORT_DEPTH_FRONT_TO_BACK	= 0x04,
	D3DX10_SPRITE_SAVE_STATE				= 0x08,
	D3DX10_SPRITE_ADDREF_TEXTURES			= 0x10
}

struct D3DX10_SPRITE {
	D3DXMATRIX					matWorld;
	D3DXVECTOR2					TexCoord;
	D3DXVECTOR2					TexSize;
	D3DXCOLOR					ColorModulate;
	ID3D10ShaderResourceView	pTexture;
	UINT						TextureIndex;
}

extern(C) const GUID IID_ID3DX10Sprite = {0xba0b762d, 0x8d28, 0x43ec, [0xb9, 0xdc, 0x2f, 0x84, 0x44, 0x3b, 0x06, 0x14]};

interface ID3DX10Sprite : IUnknown {
	extern(Windows) :
	HRESULT Begin(UINT flags);
	HRESULT DrawSpritesBuffered(D3DX10_SPRITE* pSprites, UINT cSprites);
	HRESULT Flush();
	HRESULT DrawSpritesImmediate(D3DX10_SPRITE* pSprites, UINT cSprites, UINT cbSprite, UINT flags);
	HRESULT End();
	HRESULT GetViewTransform(D3DXMATRIX* pViewTransform);
	HRESULT SetViewTransform(D3DXMATRIX* pViewTransform);
	HRESULT GetProjectionTransform(D3DXMATRIX* pProjectionTransform);
	HRESULT SetProjectionTransform(D3DXMATRIX* pProjectionTransform);
	HRESULT GetDevice(ID3D10Device* ppDevice);
}

extern(Windows) HRESULT D3DX10CreateSprite(ID3D10Device pDevice, UINT cDeviceBufferSize, ID3DX10Sprite* ppSprite);

interface ID3DX10DataLoader {
/* TODO: fix vtbl[0] bug
	extern(Windows) :
	HRESULT Load();
	HRESULT Decompress(void** ppData, SIZE_T* pcBytes);
	HRESULT Destroy();
	*/
}

interface ID3DX10DataProcessor {
/* TODO: fix vtbl[0] bug
	extern(Windows) :
	HRESULT Process(void* pData, SIZE_T cBytes);
	HRESULT CreateDeviceObject(void** ppDataObject);
	HRESULT Destroy();
	*/
}

extern(C) const GUID IID_ID3DX10ThreadPump = {0xc93fecfa, 0x6967, 0x478a, [0xab, 0xbc, 0x40, 0x2d, 0x90, 0x62, 0x1f, 0xcb]};

interface ID3DX10ThreadPump : IUnknown {
	extern(Windows) :
	HRESULT AddWorkItem(ID3DX10DataLoader pDataLoader, ID3DX10DataProcessor pDataProcessor, HRESULT *pHResult, void **ppDeviceObject);
	UINT GetWorkItemCount();
	HRESULT WaitForAllItems();
	HRESULT ProcessDeviceWorkItems(UINT iWorkItemCount);
	HRESULT PurgeAllItems();
	HRESULT GetQueueStatus(UINT* pIoQueue, UINT* pProcessQueue, UINT* pDeviceQueue);
}

extern(Windows) HRESULT D3DX10CreateThreadPump(UINT cIoThreads, UINT cProcThreads,
	ID3DX10ThreadPump *ppThreadPump);

struct D3DX10_FONT_DESCA {
	INT Height;
	UINT Width;
	UINT Weight;
	UINT MipLevels;
	BOOL Italic;
	BYTE CharSet;
	BYTE OutputPrecision;
	BYTE Quality;
	BYTE PitchAndFamily;
	CHAR[LF_FACESIZE] FaceName;
}

struct D3DX10_FONT_DESCW {
	INT Height;
	UINT Width;
	UINT Weight;
	UINT MipLevels;
	BOOL Italic;
	BYTE CharSet;
	BYTE OutputPrecision;
	BYTE Quality;
	BYTE PitchAndFamily;
	WCHAR[LF_FACESIZE] FaceName;
}

version(Unicode) {
	alias D3DX10_FONT_DESCW D3DX10_FONT_DESC;
} else {
	alias D3DX10_FONT_DESCA D3DX10_FONT_DESC;
}

extern(C) const GUID IID_ID3DX10Font = {0xd79dbb70, 0x5f21, 0x4d36, [0xbb, 0xc2, 0xff, 0x52, 0x5c, 0x21, 0x3c, 0xdc]};

interface ID3DX10Font : IUnknown {
	extern(Windows) :
	HRESULT GetDevice(ID3D10Device* ppDevice);
	HRESULT GetDescA(D3DX10_FONT_DESCA* pDesc);
	HRESULT GetDescW(D3DX10_FONT_DESCW* pDesc);
	BOOL GetTextMetricsA(TEXTMETRICA* pTextMetrics);
	BOOL GetTextMetricsW(TEXTMETRICW* pTextMetrics);
	HDC GetDC();
	HRESULT GetGlyphData(UINT Glyph, ID3D10ShaderResourceView* ppTexture, RECT* pBlackBox, POINT* pCellInc);
	HRESULT PreloadCharacters(UINT First, UINT Last);
	HRESULT PreloadGlyphs(UINT First, UINT Last);
	HRESULT PreloadTextA(LPCSTR pString, INT Count);
	HRESULT PreloadTextW(LPCWSTR pString, INT Count);
	INT DrawTextA(ID3DX10Sprite pSprite, LPCSTR pString, INT Count, LPRECT pRect, UINT Format, D3DXCOLOR Color);
	INT DrawTextW(ID3DX10Sprite pSprite, LPCWSTR pString, INT Count, LPRECT pRect, UINT Format, D3DXCOLOR Color);
	version(Unicode) {
		alias GetTextMetricsW GetTextMetrics;
		alias DrawTextW DrawText;
	} else {
		alias GetTextMetricsA GetTextMetrics;
		alias DrawTextA DrawText;
	}
}

extern(Windows) {
	HRESULT D3DX10CreateFontA(ID3D10Device pDevice, INT Height, UINT Width, UINT Weight,
		UINT MipLevels, BOOL Italic, UINT CharSet, UINT OutputPrecision, UINT Quality,
		UINT PitchAndFamily, LPCSTR pFaceName, ID3DX10Font* ppFont);
	HRESULT D3DX10CreateFontW(ID3D10Device pDevice, INT Height, UINT Width, UINT Weight,
		UINT MipLevels, BOOL Italic, UINT CharSet, UINT OutputPrecision, UINT Quality,
		UINT PitchAndFamily, LPCWSTR pFaceName, ID3DX10Font* ppFont);
}

version(Unicode) {
	alias D3DX10CreateFontW D3DX10CreateFont;
} else {
	alias D3DX10CreateFontA D3DX10CreateFont;
}

extern(Windows) {
	HRESULT D3DX10CreateFontIndirectA(ID3D10Device pDevice, D3DX10_FONT_DESCA* pDesc, ID3DX10Font* ppFont);
	HRESULT D3DX10CreateFontIndirectW(ID3D10Device pDevice, D3DX10_FONT_DESCW* pDesc, ID3DX10Font* ppFont);
}

version(Unicode) {
	alias D3DX10CreateFontIndirectW D3DX10CreateFontIndirect;
} else {
	alias D3DX10CreateFontIndirectA D3DX10CreateFontIndirect;
}

extern(Windows) {
	HRESULT D3DX10UnsetAllDeviceObjects(ID3D10Device pDevice);
//TODO 	HRESULT D3DX10ReflectShader(void *pShaderBytecode, SIZE_T BytecodeLength, ID3D10ShaderReflection1 *ppReflector);
	HRESULT D3DX10DisassembleShader(void *pShader, SIZE_T BytecodeLength, BOOL EnableColorCode,
		LPCSTR pComments, ID3D10Blob* ppDisassembly);
	HRESULT D3DX10DisassembleEffect(ID3D10Effect pEffect, BOOL EnableColorCode, ID3D10Blob* ppDisassembly);
}

const _FACD3D = 0x876;

HRESULT MAKE_D3DHRESULT(T)(T code) {
	return MAKE_HRESULT(1, _FACD3D, code);
}

HRESULT MAKE_D3DSTATUS(T)(T code) {
	return MAKE_HRESULT(0, _FACD3D, code);
}

const D3DERR_INVALIDCALL = MAKE_D3DHRESULT(2156);
const D3DERR_WASSTILLDRAWING = MAKE_D3DHRESULT(540);
