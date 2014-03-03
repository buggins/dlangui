/***********************************************************************\
*                                 dxgi.d                                *
*                                                                       *
*                       Windows API header module                       *
*                                                                       *
*                       Placed into public domain                       *
\***********************************************************************/
module win32.directx.dxgi;

private import win32.windows;

private import win32.directx.dxgitype;

enum {
	DXGI_CPU_ACCESS_NONE		=  0,
	DXGI_CPU_ACCESS_DYNAMIC		=  1,
	DXGI_CPU_ACCESS_READ_WRITE	=  2,
	DXGI_CPU_ACCESS_SCRATCH		=  3,
	DXGI_CPU_ACCESS_FIELD		= 15
}

enum {
	DXGI_USAGE_SHADER_INPUT			= 0b00_00010000,
	DXGI_USAGE_RENDER_TARGET_OUTPUT	= 0b00_00100000,
	DXGI_USAGE_BACK_BUFFER			= 0b00_01000000,
	DXGI_USAGE_SHARED				= 0b00_10000000,
	DXGI_USAGE_READ_ONLY			= 0b01_00000000,
	DXGI_USAGE_DISCARD_ON_PRESENT	= 0b10_00000000,
}
alias UINT DXGI_USAGE;

struct DXGI_FRAME_STATISTICS {
	UINT PresentCount;
	UINT PresentRefreshCount;
	UINT SyncRefreshCount;
	LARGE_INTEGER SyncQPCTime;
	LARGE_INTEGER SyncGPUTime;
}

struct DXGI_MAPPED_RECT {
	INT Pitch;
	BYTE* pBits;
}

struct DXGI_ADAPTER_DESC {
	WCHAR[128] Description;
	UINT VendorId;
	UINT DeviceId;
	UINT SubSysId;
	UINT Revision;
	SIZE_T DedicatedVideoMemory;
	SIZE_T DedicatedSystemMemory;
	SIZE_T SharedSystemMemory;
	LUID AdapterLuid;
}

struct DXGI_OUTPUT_DESC {
	WCHAR[32] DeviceName;
	RECT DesktopCoordinates;
	BOOL AttachedToDesktop;
	DXGI_MODE_ROTATION Rotation;
	HMONITOR Monitor;
}

struct DXGI_SHARED_RESOURCE {
	HANDLE Handle;
}

enum {
	DXGI_RESOURCE_PRIORITY_MINIMUM	= 0x28000000,
	DXGI_RESOURCE_PRIORITY_LOW		= 0x50000000,
	DXGI_RESOURCE_PRIORITY_NORMAL	= 0x78000000,
	DXGI_RESOURCE_PRIORITY_HIGH		= 0xa0000000,
	DXGI_RESOURCE_PRIORITY_MAXIMUM	= 0xc8000000
}

enum DXGI_RESIDENCY {
	DXGI_RESIDENCY_FULLY_RESIDENT				= 1,
	DXGI_RESIDENCY_RESIDENT_IN_SHARED_MEMORY	= 2,
	DXGI_RESIDENCY_EVICTED_TO_DISK				= 3
}

struct DXGI_SURFACE_DESC {
	UINT Width;
	UINT Height;
	DXGI_FORMAT Format;
	DXGI_SAMPLE_DESC SampleDesc;
}

enum DXGI_SWAP_EFFECT {
	DXGI_SWAP_EFFECT_DISCARD	= 0,
	DXGI_SWAP_EFFECT_SEQUENTIAL	= 1
}

enum DXGI_SWAP_CHAIN_FLAG {
	DXGI_SWAP_CHAIN_FLAG_NONPREROTATED		= 1,
	DXGI_SWAP_CHAIN_FLAG_ALLOW_MODE_SWITCH	= 2
}

struct DXGI_SWAP_CHAIN_DESC {
	DXGI_MODE_DESC BufferDesc;
	DXGI_SAMPLE_DESC SampleDesc;
	DXGI_USAGE BufferUsage;
	UINT BufferCount;
	HWND OutputWindow;
	BOOL Windowed;
	DXGI_SWAP_EFFECT SwapEffect;
	UINT Flags;
}

interface IDXGIObject : IUnknown {
	extern(Windows) :
	HRESULT SetPrivateData(REFGUID Name, UINT DataSize, void* pData);
	HRESULT SetPrivateDataInterface(REFGUID Name, IUnknown pUnknown);
	HRESULT GetPrivateData(REFGUID Name, UINT* pDataSize, void* pData);
	HRESULT GetParent(REFIID riid, void** ppParent);
}

interface IDXGIDeviceSubObject : IDXGIObject {
	extern(Windows) :
	HRESULT GetDevice(REFIID riid, void** ppDevice);
}

interface IDXGIResource : IDXGIDeviceSubObject {
	extern(Windows) :
	HRESULT GetSharedHandle(HANDLE* pSharedHandle);
	HRESULT GetUsage(DXGI_USAGE* pUsage);
	HRESULT SetEvictionPriority(UINT EvictionPriority);
	HRESULT GetEvictionPriority(UINT* pEvictionPriority);
}

interface IDXGISurface : IDXGIDeviceSubObject {
	extern(Windows) :
	HRESULT GetDesc(DXGI_SURFACE_DESC* pDesc);
	HRESULT Map(DXGI_MAPPED_RECT* pLockedRect, UINT MapFlags);
	HRESULT Unmap();
}

interface IDXGIAdapter : IDXGIObject {
	extern(Windows) :
	HRESULT EnumOutputs(UINT Output, IDXGIOutput* ppOutput);
	HRESULT GetDesc(DXGI_ADAPTER_DESC* pDesc);
	HRESULT CheckInterfaceSupport(REFGUID InterfaceName, LARGE_INTEGER* pUMDVersion);
}

interface IDXGIOutput : IDXGIObject {
	extern(Windows) :
	HRESULT GetDesc(DXGI_OUTPUT_DESC* pDesc);
	HRESULT GetDisplayModeList(DXGI_FORMAT EnumFormat, UINT Flags, UINT* pNumModes, DXGI_MODE_DESC* pDesc);
	HRESULT FindClosestMatchingMode(DXGI_MODE_DESC* pModeToMatch, DXGI_MODE_DESC* pClosestMatch, IUnknown pConcernedDevice);
	HRESULT WaitForVBlank();
	HRESULT TakeOwnership(IUnknown pDevice, BOOL Exclusive);
	void ReleaseOwnership();
	HRESULT GetGammaControlCapabilities(DXGI_GAMMA_CONTROL_CAPABILITIES* pGammaCaps);
	HRESULT SetGammaControl(DXGI_GAMMA_CONTROL* pArray);
	HRESULT GetGammaControl(DXGI_GAMMA_CONTROL* pArray);
	HRESULT SetDisplaySurface(IDXGISurface pScanoutSurface);
	HRESULT GetDisplaySurfaceData(IDXGISurface pDestination);
	HRESULT GetFrameStatistics(DXGI_FRAME_STATISTICS* pStats);
}

const DXGI_MAX_SWAP_CHAIN_BUFFERS = 16;

enum {
	DXGI_PRESENT_TEST				= 0x00000001,
	DXGI_PRESENT_DO_NOT_SEQUENCE	= 0x00000002,
	DXGI_PRESENT_RESTART			= 0x00000004
}

interface IDXGISwapChain : IDXGIDeviceSubObject {
	extern(Windows) :
	HRESULT Present(UINT SyncInterval, UINT Flags);
	HRESULT GetBuffer(UINT Buffer, REFIID riid, void** ppSurface);
	HRESULT SetFullscreenState(BOOL Fullscreen, IDXGIOutput pTarget);
	HRESULT GetFullscreenState(BOOL* pFullscreen, IDXGIOutput* ppTarget);
	HRESULT GetDesc(DXGI_SWAP_CHAIN_DESC* pDesc);
	HRESULT ResizeBuffers(UINT BufferCount, UINT Width, UINT Height, DXGI_FORMAT NewFormat, UINT SwapChainFlags);
	HRESULT ResizeTarget(DXGI_MODE_DESC* pNewTargetParameters);
	HRESULT GetContainingOutput(IDXGIOutput* ppOutput);
	HRESULT GetFrameStatistics(DXGI_FRAME_STATISTICS* pStats);
	HRESULT GetLastPresentCount(UINT* pLastPresentCount);
}

interface IDXGIFactory : IDXGIObject {
	extern(Windows) :
	HRESULT EnumAdapters(UINT Adapter, IDXGIAdapter* ppAdapter);
	HRESULT MakeWindowAssociation(HWND WindowHandle, UINT Flags);
	HRESULT GetWindowAssociation(HWND* pWindowHandle);
	HRESULT CreateSwapChain(IUnknown pDevice, DXGI_SWAP_CHAIN_DESC* pDesc, IDXGISwapChain* ppSwapChain);
	HRESULT CreateSoftwareAdapter(HMODULE Module, IDXGIAdapter* ppAdapter);
}

interface IDXGIDevice : IDXGIObject {
	extern(Windows) :
	HRESULT GetAdapter(IDXGIAdapter* pAdapter);
	HRESULT CreateSurface(DXGI_SURFACE_DESC* pDesc, UINT NumSurfaces, DXGI_USAGE Usage, DXGI_SHARED_RESOURCE* pSharedResource, IDXGISurface* ppSurface);
	HRESULT QueryResourceResidency(IUnknown* ppResources, DXGI_RESIDENCY* pResidencyStatus, UINT NumResources);
	HRESULT SetGPUThreadPriority(INT Priority);
	HRESULT GetGPUThreadPriority(INT* pPriority);
}

extern(C) const GUID IID_IDXGIObject			= {0xaec22fb8, 0x76f3, 0x4639, [0x9b, 0xe0, 0x28, 0xeb, 0x43, 0xa6, 0x7a, 0x2e]};
extern(C) const GUID IID_IDXGIDeviceSubObject	= {0x3d3e0379, 0xf9de, 0x4d58, [0xbb, 0x6c, 0x18, 0xd6, 0x29, 0x92, 0xf1, 0xa6]};
extern(C) const GUID IID_IDXGIResource			= {0x035f3ab4, 0x482e, 0x4e50, [0xb4, 0x1f, 0x8a, 0x7f, 0x8b, 0xd8, 0x96, 0x0b]};
extern(C) const GUID IID_IDXGISurface			= {0xcafcb56c, 0x6ac3, 0x4889, [0xbf, 0x47, 0x9e, 0x23, 0xbb, 0xd2, 0x60, 0xec]};
extern(C) const GUID IID_IDXGIAdapter			= {0x2411e7e1, 0x12ac, 0x4ccf, [0xbd, 0x14, 0x97, 0x98, 0xe8, 0x53, 0x4d, 0xc0]};
extern(C) const GUID IID_IDXGIOutput			= {0xae02eedb, 0xc735, 0x4690, [0x8d, 0x52, 0x5a, 0x8d, 0xc2, 0x02, 0x13, 0xaa]};
extern(C) const GUID IID_IDXGISwapChain			= {0x310d36a0, 0xd2e7, 0x4c0a, [0xaa, 0x04, 0x6a, 0x9d, 0x23, 0xb8, 0x88, 0x6a]};
extern(C) const GUID IID_IDXGIFactory			= {0x7b7166ec, 0x21c7, 0x44ae, [0xb2, 0x1a, 0xc9, 0xae, 0x32, 0x1a, 0xe3, 0x69]};
extern(C) const GUID IID_IDXGIDevice			= {0x54ec77fa, 0x1377, 0x44e6, [0x8c, 0x32, 0x88, 0xfd, 0x5f, 0x44, 0xc8, 0x4c]};

