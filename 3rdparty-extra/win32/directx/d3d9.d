/*==========================================================================;
 *
 *  Copyright (C) Microsoft Corporation.  All Rights Reserved.
 *
 *  File:   d3d9.h
 *  Content:    Direct3D include file
 *
 ****************************************************************************/
module win32.directx.d3d9;
version(Windows):

import win32.windows;
public import win32.directx.d3d9types;
public import win32.directx.d3d9caps;

const DIRECT3D_VERSION = 0x0900;

/**This identifier is passed to Direct3DCreate9 in order to ensure that an
 * application was built against the correct header files. This number is
 * incremented whenever a header (or other) change would require applications
 * to be rebuilt. If the version doesn't match, Direct3DCreate9 will fail.
 * (The number itself has no meaning.)*/

debug {
    const D3D_SDK_VERSION = (32 | 0x80000000);
    const D3D9b_SDK_VERSION = (31 | 0x80000000);
}
else {
    const D3D_SDK_VERSION = 32;
    const D3D9b_SDK_VERSION = 31;
}

/* IID_IDirect3D9 */
/* {81BDCBCA-64D4-426d-AE8D-AD0147F4275C} */
extern (C) const GUID IID_IDirect3D9 = { 0x81bdcbca, 0x64d4, 0x426d, [0xae, 0x8d, 0xad, 0x1, 0x47, 0xf4, 0x27, 0x5c] };

/* IID_IDirect3DDevice9 */
// {D0223B96-BF7A-43fd-92BD-A43B0D82B9EB} */
extern (C) const GUID IID_IDirect3DDevice9 = { 0xd0223b96, 0xbf7a, 0x43fd, [0x92, 0xbd, 0xa4, 0x3b, 0xd, 0x82, 0xb9, 0xeb] };

/* IID_IDirect3DResource9 */
// {05EEC05D-8F7D-4362-B999-D1BAF357C704}
extern (C) const GUID IID_IDirect3DResource9 = { 0x05eec05d, 0x8f7d, 0x4362, [0xb9, 0x99, 0xd1, 0xba, 0xf3, 0x57, 0xc7, 0x04] };

/* IID_IDirect3DBaseTexture9 */
/* {580CA87E-1D3C-4d54-991D-B7D3E3C298CE} */
extern (C) const GUID IID_IDirect3DBaseTexture9 = { 0x580ca87e, 0x1d3c, 0x4d54, [0x99, 0x1d, 0xb7, 0xd3, 0xe3, 0xc2, 0x98, 0xce] };

/* IID_IDirect3DTexture9 */
/* {85C31227-3DE5-4f00-9B3A-F11AC38C18B5} */
extern (C) const GUID IID_IDirect3DTexture9 = { 0x85c31227, 0x3de5, 0x4f00, [0x9b, 0x3a, 0xf1, 0x1a, 0xc3, 0x8c, 0x18, 0xb5] };

/* IID_IDirect3DCubeTexture9 */
/* {FFF32F81-D953-473a-9223-93D652ABA93F} */
extern (C) const GUID IID_IDirect3DCubeTexture9 = { 0xfff32f81, 0xd953, 0x473a, [0x92, 0x23, 0x93, 0xd6, 0x52, 0xab, 0xa9, 0x3f] };

/* IID_IDirect3DVolumeTexture9 */
/* {2518526C-E789-4111-A7B9-47EF328D13E6} */
extern (C) const GUID IID_IDirect3DVolumeTexture9 = { 0x2518526c, 0xe789, 0x4111, [0xa7, 0xb9, 0x47, 0xef, 0x32, 0x8d, 0x13, 0xe6] };

/* IID_IDirect3DVertexBuffer9 */
/* {B64BB1B5-FD70-4df6-BF91-19D0A12455E3} */
extern (C) const GUID IID_IDirect3DVertexBuffer9 = { 0xb64bb1b5, 0xfd70, 0x4df6, [0xbf, 0x91, 0x19, 0xd0, 0xa1, 0x24, 0x55, 0xe3] };

/* IID_IDirect3DIndexBuffer9 */
/* {7C9DD65E-D3F7-4529-ACEE-785830ACDE35} */
extern (C) const GUID IID_IDirect3DIndexBuffer9 = { 0x7c9dd65e, 0xd3f7, 0x4529, [0xac, 0xee, 0x78, 0x58, 0x30, 0xac, 0xde, 0x35] };

/* IID_IDirect3DSurface9 */
/* {0CFBAF3A-9FF6-429a-99B3-A2796AF8B89B} */
extern (C) const GUID IID_IDirect3DSurface9 = { 0xcfbaf3a, 0x9ff6, 0x429a, [0x99, 0xb3, 0xa2, 0x79, 0x6a, 0xf8, 0xb8, 0x9b] };

/* IID_IDirect3DVolume9 */
/* {24F416E6-1F67-4aa7-B88E-D33F6F3128A1} */
extern (C) const GUID IID_IDirect3DVolume9 = { 0x24f416e6, 0x1f67, 0x4aa7, [0xb8, 0x8e, 0xd3, 0x3f, 0x6f, 0x31, 0x28, 0xa1] };

/* IID_IDirect3DSwapChain9 */
/* {794950F2-ADFC-458a-905E-10A10B0B503B} */
extern (C) const GUID IID_IDirect3DSwapChain9 = { 0x794950f2, 0xadfc, 0x458a, [0x90, 0x5e, 0x10, 0xa1, 0xb, 0xb, 0x50, 0x3b] };

/* IID_IDirect3DVertexDeclaration9 */
/* {DD13C59C-36FA-4098-A8FB-C7ED39DC8546} */
extern (C) const GUID IID_IDirect3DVertexDeclaration9 = { 0xdd13c59c, 0x36fa, 0x4098, [0xa8, 0xfb, 0xc7, 0xed, 0x39, 0xdc, 0x85, 0x46] };

/* IID_IDirect3DVertexShader9 */
/* {EFC5557E-6265-4613-8A94-43857889EB36} */
extern (C) const GUID IID_IDirect3DVertexShader9 = { 0xefc5557e, 0x6265, 0x4613, [0x8a, 0x94, 0x43, 0x85, 0x78, 0x89, 0xeb, 0x36] };

/* IID_IDirect3DPixelShader9 */
/* {6D3BDBDC-5B02-4415-B852-CE5E8BCCB289} */
extern (C) const GUID IID_IDirect3DPixelShader9 = { 0x6d3bdbdc, 0x5b02, 0x4415, [0xb8, 0x52, 0xce, 0x5e, 0x8b, 0xcc, 0xb2, 0x89] };

/* IID_IDirect3DStateBlock9 */
/* {B07C4FE5-310D-4ba8-A23C-4F0F206F218B} */
extern (C) const GUID IID_IDirect3DStateBlock9 = { 0xb07c4fe5, 0x310d, 0x4ba8, [0xa2, 0x3c, 0x4f, 0xf, 0x20, 0x6f, 0x21, 0x8b] };

/* IID_IDirect3DQuery9 */
/* {d9771460-a695-4f26-bbd3-27b840b541cc} */
extern (C) const GUID IID_IDirect3DQuery9 = { 0xd9771460, 0xa695, 0x4f26, [0xbb, 0xd3, 0x27, 0xb8, 0x40, 0xb5, 0x41, 0xcc] };


/* IID_HelperName */
/* {E4A36723-FDFE-4b22-B146-3C04C07F4CC8} */
extern (C) const GUID IID_HelperName = { 0xe4a36723, 0xfdfe, 0x4b22, [0xb1, 0x46, 0x3c, 0x4, 0xc0, 0x7f, 0x4c, 0xc8] };

/* IID_IDirect3D9Ex */
/* {02177241-69FC-400C-8FF1-93A44DF6861D} */
extern (C) const GUID IID_IDirect3D9Ex = { 0x02177241, 0x69FC, 0x400C, [0x8F, 0xF1, 0x93, 0xA4, 0x4D, 0xF6, 0x86, 0x1D] };

/* IID_IDirect3DDevice9Ex */
// {B18B10CE-2649-405a-870F-95F777D4313A}
extern (C) const GUID IID_IDirect3DDevice9Ex = { 0xb18b10ce, 0x2649, 0x405a, [0x87, 0xf, 0x95, 0xf7, 0x77, 0xd4, 0x31, 0x3a] };

/* IID_IDirect3DSwapChain9Ex */
/* {91886CAF-1C3D-4d2e-A0AB-3E4C7D8D3303} */
extern (C) const GUID IID_IDirect3DSwapChain9Ex = { 0x91886caf, 0x1c3d, 0x4d2e, [0xa0, 0xab, 0x3e, 0x4c, 0x7d, 0x8d, 0x33, 0x03] };



extern (C):
/**
 * DLL Function for creating a Direct3D9 object. This object supports
 * enumeration and allows the creation of Direct3DDevice9 objects.
 * Pass the value of the constant D3D_SDK_VERSION to this function, so
 * that the run-time can validate that your application was compiled
 * against the right headers.
 */

extern (Windows) LPDIRECT3D9 Direct3DCreate9(UINT SDKVersion);

/**
 * Stubs for graphics profiling.
 */
extern (Windows) int D3DPERF_BeginEvent( D3DCOLOR col, LPCWSTR wszName );
extern (Windows) int D3DPERF_EndEvent();
extern (Windows) void D3DPERF_SetMarker( D3DCOLOR col, LPCWSTR wszName );
extern (Windows) void D3DPERF_SetRegion( D3DCOLOR col, LPCWSTR wszName );
extern (Windows) BOOL D3DPERF_QueryRepeatFrame();

extern (Windows) void D3DPERF_SetOptions( DWORD dwOptions );
extern (Windows) DWORD D3DPERF_GetStatus();


interface LPDIRECT3D9 : IUnknown
{
    HRESULT RegisterSoftwareDevice(void* pInitializeFunction);
    UINT GetAdapterCount();
    HRESULT GetAdapterIdentifier( UINT Adapter,DWORD Flags,D3DADAPTER_IDENTIFIER9* pIdentifier);
    UINT GetAdapterModeCount(UINT Adapter,D3DFORMAT Format);
    HRESULT EnumAdapterModes( UINT Adapter,D3DFORMAT Format,UINT Mode,D3DDISPLAYMODE* pMode);
    HRESULT GetAdapterDisplayMode( UINT Adapter,D3DDISPLAYMODE* pMode);
    HRESULT CheckDeviceType( UINT Adapter,D3DDEVTYPE DevType,D3DFORMAT AdapterFormat,D3DFORMAT BackBufferFormat,BOOL bWindowed);
    HRESULT CheckDeviceFormat( UINT Adapter,D3DDEVTYPE DeviceType,D3DFORMAT AdapterFormat,DWORD Usage,D3DRESOURCETYPE RType,D3DFORMAT CheckFormat);
    HRESULT CheckDeviceMultiSampleType( UINT Adapter,D3DDEVTYPE DeviceType,D3DFORMAT SurfaceFormat,BOOL Windowed,D3DMULTISAMPLE_TYPE MultiSampleType,DWORD* pQualityLevels);
    HRESULT CheckDepthStencilMatch( UINT Adapter,D3DDEVTYPE DeviceType,D3DFORMAT AdapterFormat,D3DFORMAT RenderTargetFormat,D3DFORMAT DepthStencilFormat);
    HRESULT CheckDeviceFormatConversion( UINT Adapter,D3DDEVTYPE DeviceType,D3DFORMAT SourceFormat,D3DFORMAT TargetFormat);
    HRESULT GetDeviceCaps( UINT Adapter,D3DDEVTYPE DeviceType,D3DCAPS9* pCaps);
    HMONITOR GetAdapterMonitor(UINT Adapter);
    HRESULT CreateDevice( UINT Adapter,D3DDEVTYPE DeviceType,HWND hFocusWindow,DWORD BehaviorFlags,D3DPRESENT_PARAMETERS* pPresentationParameters,LPDIRECT3DDEVICE9* ppReturnedDeviceInterface);
/*
    debug {
        LPCWSTR Version;
    }
*/
}
alias LPDIRECT3D9 IDirect3D9;

interface LPDIRECT3DDEVICE9 : IUnknown
{
    HRESULT TestCooperativeLevel();
    UINT GetAvailableTextureMem();
    HRESULT EvictManagedResources();
    HRESULT GetDirect3D( LPDIRECT3D9* ppD3D9);
    HRESULT GetDeviceCaps( D3DCAPS9* pCaps);
    HRESULT GetDisplayMode( UINT iSwapChain,D3DDISPLAYMODE* pMode);
    HRESULT GetCreationParameters( D3DDEVICE_CREATION_PARAMETERS *pParameters);
    HRESULT SetCursorProperties( UINT XHotSpot,UINT YHotSpot,LPDIRECT3DSURFACE9 pCursorBitmap);
    void SetCursorPosition(int X,int Y,DWORD Flags);
    BOOL ShowCursor(BOOL bShow);
    HRESULT CreateAdditionalSwapChain( D3DPRESENT_PARAMETERS* pPresentationParameters,LPDIRECT3DSWAPCHAIN9* pSwapChain);
    HRESULT GetSwapChain( UINT iSwapChain,LPDIRECT3DSWAPCHAIN9* pSwapChain);
    UINT GetNumberOfSwapChains();
    HRESULT Reset( D3DPRESENT_PARAMETERS* pPresentationParameters);
    HRESULT Present(RECT* pSourceRect,RECT* pDestRect,HWND hDestWindowOverride, RGNDATA* pDirtyRegion);
    HRESULT GetBackBuffer( UINT iSwapChain,UINT iBackBuffer,D3DBACKBUFFER_TYPE Type,LPDIRECT3DSURFACE9* ppBackBuffer);
    HRESULT GetRasterStatus( UINT iSwapChain,D3DRASTER_STATUS* pRasterStatus);
    HRESULT SetDialogBoxMode( BOOL bEnableDialogs);
    void SetGammaRamp(UINT iSwapChain,DWORD Flags, D3DGAMMARAMP* pRamp);
    void GetGammaRamp(UINT iSwapChain,D3DGAMMARAMP* pRamp);
    HRESULT CreateTexture( UINT Width,UINT Height,UINT Levels,DWORD Usage,D3DFORMAT Format,D3DPOOL Pool,LPDIRECT3DTEXTURE9* ppTexture,HANDLE* pSharedHandle);
    HRESULT CreateVolumeTexture( UINT Width,UINT Height,UINT Depth,UINT Levels,DWORD Usage,D3DFORMAT Format,D3DPOOL Pool,LPDIRECT3DVOLUMETEXTURE9* ppVolumeTexture,HANDLE* pSharedHandle);
    HRESULT CreateCubeTexture( UINT EdgeLength,UINT Levels,DWORD Usage,D3DFORMAT Format,D3DPOOL Pool,LPDIRECT3DCUBETEXTURE9* ppCubeTexture,HANDLE* pSharedHandle);
    HRESULT CreateVertexBuffer( UINT Length,DWORD Usage,DWORD FVF,D3DPOOL Pool,LPDIRECT3DVERTEXBUFFER9* ppVertexBuffer,HANDLE* pSharedHandle);
    HRESULT CreateIndexBuffer( UINT Length,DWORD Usage,D3DFORMAT Format,D3DPOOL Pool,LPDIRECT3DINDEXBUFFER9* ppIndexBuffer,HANDLE* pSharedHandle);
    HRESULT CreateRenderTarget( UINT Width,UINT Height,D3DFORMAT Format,D3DMULTISAMPLE_TYPE MultiSample,DWORD MultisampleQuality,BOOL Lockable,LPDIRECT3DSURFACE9* ppSurface,HANDLE* pSharedHandle);
    HRESULT CreateDepthStencilSurface( UINT Width,UINT Height,D3DFORMAT Format,D3DMULTISAMPLE_TYPE MultiSample,DWORD MultisampleQuality,BOOL Discard,LPDIRECT3DSURFACE9* ppSurface,HANDLE* pSharedHandle);
    HRESULT UpdateSurface( LPDIRECT3DSURFACE9 pSourceSurface, RECT* pSourceRect,LPDIRECT3DSURFACE9 pDestinationSurface, POINT* pDestPoint);
    HRESULT UpdateTexture( LPDIRECT3DBASETEXTURE9 pSourceTexture,LPDIRECT3DBASETEXTURE9 pDestinationTexture);
    HRESULT GetRenderTargetData( LPDIRECT3DSURFACE9 pRenderTarget,LPDIRECT3DSURFACE9 pDestSurface);
    HRESULT GetFrontBufferData( UINT iSwapChain,LPDIRECT3DSURFACE9 pDestSurface);
    HRESULT StretchRect( LPDIRECT3DSURFACE9 pSourceSurface, RECT* pSourceRect,LPDIRECT3DSURFACE9 pDestSurface, RECT* pDestRect,D3DTEXTUREFILTERTYPE Filter);
    HRESULT ColorFill( LPDIRECT3DSURFACE9 pSurface, RECT* pRect,D3DCOLOR color);
    HRESULT CreateOffscreenPlainSurface( UINT Width,UINT Height,D3DFORMAT Format,D3DPOOL Pool,LPDIRECT3DSURFACE9* ppSurface,HANDLE* pSharedHandle);
    HRESULT SetRenderTarget( DWORD RenderTargetIndex,LPDIRECT3DSURFACE9 pRenderTarget);
    HRESULT GetRenderTarget( DWORD RenderTargetIndex,LPDIRECT3DSURFACE9* ppRenderTarget);
    HRESULT SetDepthStencilSurface( LPDIRECT3DSURFACE9 pNewZStencil);
    HRESULT GetDepthStencilSurface( LPDIRECT3DSURFACE9* ppZStencilSurface);
    HRESULT BeginScene();
    HRESULT EndScene();
    HRESULT Clear( DWORD Count, D3DRECT* pRects,DWORD Flags,D3DCOLOR Color,float Z,DWORD Stencil);
    HRESULT SetTransform( D3DTRANSFORMSTATETYPE State, D3DMATRIX* pMatrix);
    HRESULT GetTransform( D3DTRANSFORMSTATETYPE State,D3DMATRIX* pMatrix);
    HRESULT MultiplyTransform( D3DTRANSFORMSTATETYPE, D3DMATRIX*);
    HRESULT SetViewport( D3DVIEWPORT9* pViewport);
    HRESULT GetViewport( D3DVIEWPORT9* pViewport);
    HRESULT SetMaterial( D3DMATERIAL9* pMaterial);
    HRESULT GetMaterial( D3DMATERIAL9* pMaterial);
    HRESULT SetLight( DWORD Index, D3DLIGHT9*);
    HRESULT GetLight( DWORD Index,D3DLIGHT9*);
    HRESULT LightEnable( DWORD Index,BOOL Enable);
    HRESULT GetLightEnable( DWORD Index,BOOL* pEnable);
    HRESULT SetClipPlane( DWORD Index, float* pPlane);
    HRESULT GetClipPlane( DWORD Index,float* pPlane);
    HRESULT SetRenderState( D3DRENDERSTATETYPE State,DWORD Value);
    HRESULT GetRenderState( D3DRENDERSTATETYPE State,DWORD* pValue);
    HRESULT CreateStateBlock( D3DSTATEBLOCKTYPE Type,LPDIRECT3DSTATEBLOCK9* ppSB);
    HRESULT BeginStateBlock();
    HRESULT EndStateBlock( LPDIRECT3DSTATEBLOCK9* ppSB);
    HRESULT SetClipStatus( D3DCLIPSTATUS9* pClipStatus);
    HRESULT GetClipStatus( D3DCLIPSTATUS9* pClipStatus);
    HRESULT GetTexture( DWORD Stage,LPDIRECT3DBASETEXTURE9* ppTexture);
    HRESULT SetTexture( DWORD Stage,LPDIRECT3DBASETEXTURE9 pTexture);
    HRESULT GetTextureStageState( DWORD Stage,D3DTEXTURESTAGESTATETYPE Type,DWORD* pValue);
    HRESULT SetTextureStageState( DWORD Stage,D3DTEXTURESTAGESTATETYPE Type,DWORD Value);
    HRESULT GetSamplerState( DWORD Sampler,D3DSAMPLERSTATETYPE Type,DWORD* pValue);
    HRESULT SetSamplerState( DWORD Sampler,D3DSAMPLERSTATETYPE Type,DWORD Value);
    HRESULT ValidateDevice( DWORD* pNumPasses);
    HRESULT SetPaletteEntries( UINT PaletteNumber, PALETTEENTRY* pEntries);
    HRESULT GetPaletteEntries( UINT PaletteNumber,PALETTEENTRY* pEntries);
    HRESULT SetCurrentTexturePalette( UINT PaletteNumber);
    HRESULT GetCurrentTexturePalette( UINT *PaletteNumber);
    HRESULT SetScissorRect( RECT* pRect);
    HRESULT GetScissorRect( RECT* pRect);
    HRESULT SetSoftwareVertexProcessing( BOOL bSoftware);
    BOOL GetSoftwareVertexProcessing();
    HRESULT SetNPatchMode( float nSegments);
    float GetNPatchMode();
    HRESULT DrawPrimitive( D3DPRIMITIVETYPE PrimitiveType,UINT StartVertex,UINT PrimitiveCount);
    HRESULT DrawIndexedPrimitive( D3DPRIMITIVETYPE,INT BaseVertexIndex,UINT MinVertexIndex,UINT NumVertices,UINT startIndex,UINT primCount);
    HRESULT DrawPrimitiveUP( D3DPRIMITIVETYPE PrimitiveType,UINT PrimitiveCount, void* pVertexStreamZeroData,UINT VertexStreamZeroStride);
    HRESULT DrawIndexedPrimitiveUP( D3DPRIMITIVETYPE PrimitiveType,UINT MinVertexIndex,UINT NumVertices,UINT PrimitiveCount, void* pIndexData,D3DFORMAT IndexDataFormat, void* pVertexStreamZeroData,UINT VertexStreamZeroStride);
    HRESULT ProcessVertices( UINT SrcStartIndex,UINT DestIndex,UINT VertexCount,LPDIRECT3DVERTEXBUFFER9 pDestBuffer,LPDIRECT3DVERTEXDECLARATION9 pVertexDecl,DWORD Flags);
    HRESULT CreateVertexDeclaration( D3DVERTEXELEMENT9* pVertexElements,LPDIRECT3DVERTEXDECLARATION9* ppDecl);
    HRESULT SetVertexDeclaration(LPDIRECT3DVERTEXDECLARATION9 pDecl);
    HRESULT GetVertexDeclaration(LPDIRECT3DVERTEXDECLARATION9* ppDecl);
    HRESULT SetFVF( DWORD FVF);
    HRESULT GetFVF( DWORD* pFVF);
    HRESULT CreateVertexShader( DWORD* pFunction,LPDIRECT3DVERTEXSHADER9* ppShader);
    HRESULT SetVertexShader( LPDIRECT3DVERTEXSHADER9 pShader);
    HRESULT GetVertexShader( LPDIRECT3DVERTEXSHADER9* ppShader);
    HRESULT SetVertexShaderConstantF( UINT StartRegister, float* pConstantData,UINT Vector4fCount);
    HRESULT GetVertexShaderConstantF( UINT StartRegister,float* pConstantData,UINT Vector4fCount);
    HRESULT SetVertexShaderConstantI( UINT StartRegister, int* pConstantData,UINT Vector4iCount);
    HRESULT GetVertexShaderConstantI( UINT StartRegister,int* pConstantData,UINT Vector4iCount);
    HRESULT SetVertexShaderConstantB( UINT StartRegister, BOOL* pConstantData,UINT  BoolCount);
    HRESULT GetVertexShaderConstantB( UINT StartRegister,BOOL* pConstantData,UINT BoolCount);
    HRESULT SetStreamSource( UINT StreamNumber,LPDIRECT3DVERTEXBUFFER9 pStreamData,UINT OffsetInBytes,UINT Stride);
    HRESULT GetStreamSource( UINT StreamNumber,LPDIRECT3DVERTEXBUFFER9* ppStreamData,UINT* pOffsetInBytes,UINT* pStride);
    HRESULT SetStreamSourceFreq( UINT StreamNumber,UINT Setting);
    HRESULT GetStreamSourceFreq( UINT StreamNumber,UINT* pSetting);
    HRESULT SetIndices( LPDIRECT3DINDEXBUFFER9 pIndexData);
    HRESULT GetIndices( LPDIRECT3DINDEXBUFFER9* ppIndexData);
    HRESULT CreatePixelShader( DWORD* pFunction,LPDIRECT3DPIXELSHADER9* ppShader);
    HRESULT SetPixelShader(LPDIRECT3DPIXELSHADER9 pShader);
    HRESULT GetPixelShader(LPDIRECT3DPIXELSHADER9* ppShader);
    HRESULT SetPixelShaderConstantF( UINT StartRegister, float* pConstantData,UINT Vector4fCount);
    HRESULT GetPixelShaderConstantF( UINT StartRegister,float* pConstantData,UINT Vector4fCount);
    HRESULT SetPixelShaderConstantI( UINT StartRegister, int* pConstantData,UINT Vector4iCount);
    HRESULT GetPixelShaderConstantI( UINT StartRegister,int* pConstantData,UINT Vector4iCount);
    HRESULT SetPixelShaderConstantB( UINT StartRegister, BOOL* pConstantData,UINT  BoolCount);
    HRESULT GetPixelShaderConstantB( UINT StartRegister,BOOL* pConstantData,UINT BoolCount);
    HRESULT DrawRectPatch( UINT Handle, float* pNumSegs, D3DRECTPATCH_INFO* pRectPatchInfo);
    HRESULT DrawTriPatch( UINT Handle, float* pNumSegs, D3DTRIPATCH_INFO* pTriPatchInfo);
    HRESULT DeletePatch( UINT Handle);
    HRESULT CreateQuery( D3DQUERYTYPE Type,LPDIRECT3DQUERY9* ppQuery);
/*
    debug {
        D3DDEVICE_CREATION_PARAMETERS CreationParameters;
        D3DPRESENT_PARAMETERS PresentParameters;
        D3DDISPLAYMODE DisplayMode;
        D3DCAPS9 Caps;

        UINT AvailableTextureMem;
        UINT SwapChains;
        UINT Textures;
        UINT VertexBuffers;
        UINT IndexBuffers;
        UINT VertexShaders;
        UINT PixelShaders;

        D3DVIEWPORT9 Viewport;
        D3DMATRIX ProjectionMatrix;
        D3DMATRIX ViewMatrix;
        D3DMATRIX WorldMatrix;
        D3DMATRIX[8] TextureMatrices;

        DWORD FVF;
        UINT VertexSize;
        DWORD VertexShaderVersion;
        DWORD PixelShaderVersion;
        BOOL SoftwareVertexProcessing;

        D3DMATERIAL9 Material;
        D3DLIGHT9[16] Lights;
        BOOL[16] LightsEnabled;

        D3DGAMMARAMP GammaRamp;
        RECT ScissorRect;
        BOOL DialogBoxMode;
    }
*/
}

alias LPDIRECT3DDEVICE9 IDirect3DDevice9;


interface LPDIRECT3DSTATEBLOCK9 : IUnknown
{
    HRESULT GetDevice(LPDIRECT3DDEVICE9* ppDevice);
    HRESULT Capture();
    HRESULT Apply();
/*
    debug {
        LPCWSTR CreationCallStack;
    }
*/
}

alias LPDIRECT3DSTATEBLOCK9 IDirect3DStateBlock9;

interface LPDIRECT3DSWAPCHAIN9 : IUnknown
{
    HRESULT Present( RECT* pSourceRect, RECT* pDestRect,HWND hDestWindowOverride, RGNDATA* pDirtyRegion,DWORD dwFlags);
    HRESULT GetFrontBufferData( LPDIRECT3DSURFACE9 pDestSurface);
    HRESULT GetBackBuffer( UINT iBackBuffer,D3DBACKBUFFER_TYPE Type,LPDIRECT3DSURFACE9* ppBackBuffer);
    HRESULT GetRasterStatus( D3DRASTER_STATUS* pRasterStatus);
    HRESULT GetDisplayMode( D3DDISPLAYMODE* pMode);
    HRESULT GetDevice( LPDIRECT3DDEVICE9 * ppDevice);
    HRESULT GetPresentParameters( D3DPRESENT_PARAMETERS* pPresentationParameters);
/*
    debug {
        D3DPRESENT_PARAMETERS PresentParameters;
        D3DDISPLAYMODE DisplayMode;
        LPCWSTR CreationCallStack;
    }
*/
}

alias LPDIRECT3DSWAPCHAIN9 IDirect3DSwapChain9;

interface LPDIRECT3DRESOURCE9 : IUnknown
{
    HRESULT GetDevice( LPDIRECT3DDEVICE9* ppDevice);
    HRESULT SetPrivateData( REFGUID refguid, void* pData,DWORD SizeOfData,DWORD Flags);
    HRESULT GetPrivateData( REFGUID refguid,void* pData,DWORD* pSizeOfData);
    HRESULT FreePrivateData( REFGUID refguid);
    DWORD SetPriority(DWORD PriorityNew);
    DWORD GetPriority();
    void PreLoad();
    D3DRESOURCETYPE GetType();
}

alias LPDIRECT3DRESOURCE9 IDirect3DResource9;

interface LPDIRECT3DVERTEXDECLARATION9 : IUnknown
{
    HRESULT GetDevice( LPDIRECT3DDEVICE9* ppDevice);
    HRESULT GetDeclaration( D3DVERTEXELEMENT9* pElement,UINT* pNumElements);
/*
    debug {
        LPCWSTR CreationCallStack;
    }
*/
}

alias LPDIRECT3DVERTEXDECLARATION9 IDirect3DVertexDeclaration9;

interface LPDIRECT3DVERTEXSHADER9 : IUnknown
{
    HRESULT GetDevice( LPDIRECT3DDEVICE9 * ppDevice);
    HRESULT GetFunction( void*,UINT* pSizeOfData);
/*
    debug {
        DWORD Version;
        LPCWSTR CreationCallStack;
    }
*/
}

alias LPDIRECT3DVERTEXSHADER9 IDirect3DVertexShader9;

interface LPDIRECT3DPIXELSHADER9 : IUnknown
{
    HRESULT GetDevice( LPDIRECT3DDEVICE9 * ppDevice);
    HRESULT GetFunction( void*,UINT* pSizeOfData);
/*
    debug {
        DWORD Version;
        LPCWSTR CreationCallStack;
    }
*/
}

alias LPDIRECT3DPIXELSHADER9 IDirect3DPixelShader9;

interface LPDIRECT3DBASETEXTURE9 : LPDIRECT3DRESOURCE9
{
    DWORD SetLOD(DWORD LODNew);
    DWORD GetLOD();
    DWORD GetLevelCount();
    HRESULT SetAutoGenFilterType( D3DTEXTUREFILTERTYPE FilterType);
    D3DTEXTUREFILTERTYPE GetAutoGenFilterType();
    void GenerateMipSubLevels();
}

alias LPDIRECT3DBASETEXTURE9 IDirect3DBaseTexture9;

interface LPDIRECT3DTEXTURE9 : LPDIRECT3DBASETEXTURE9
{
    HRESULT GetLevelDesc( UINT Level,D3DSURFACE_DESC *pDesc);
    HRESULT GetSurfaceLevel( UINT Level,LPDIRECT3DSURFACE9* ppSurfaceLevel);
    HRESULT LockRect( UINT Level,D3DLOCKED_RECT* pLockedRect,RECT* pRect,DWORD Flags);
    HRESULT UnlockRect( UINT Level);
    HRESULT AddDirtyRect(RECT* pDirtyRect);
/*
    debug {
        LPCWSTR Name;
        UINT Width;
        UINT Height;
        UINT Levels;
        DWORD Usage;
        D3DFORMAT Format;
        D3DPOOL Pool;
        DWORD Priority;
        DWORD LOD;
        D3DTEXTUREFILTERTYPE FilterType;
        UINT LockCount;
        LPCWSTR CreationCallStack;
    }
*/
}

alias LPDIRECT3DTEXTURE9 IDirect3DTexture9;

interface LPDIRECT3DVOLUMETEXTURE9 : LPDIRECT3DBASETEXTURE9
{
    HRESULT GetLevelDesc( UINT Level,D3DVOLUME_DESC *pDesc);
    HRESULT GetVolumeLevel( UINT Level,LPDIRECT3DVOLUME9* ppVolumeLevel);
    HRESULT LockBox( UINT Level,D3DLOCKED_BOX* pLockedVolume, D3DBOX* pBox,DWORD Flags);
    HRESULT UnlockBox( UINT Level);
    HRESULT AddDirtyBox( D3DBOX* pDirtyBox);
/*
    debug {
        LPCWSTR Name;
        UINT Width;
        UINT Height;
        UINT Depth;
        UINT Levels;
        DWORD Usage;
        D3DFORMAT Format;
        D3DPOOL Pool;
        DWORD Priority;
        DWORD LOD;
        D3DTEXTUREFILTERTYPE FilterType;
        UINT LockCount;
        LPCWSTR CreationCallStack;
    }
*/
}

alias LPDIRECT3DVOLUMETEXTURE9 IDirect3DVolumeTexture9;

interface LPDIRECT3DCUBETEXTURE9 : LPDIRECT3DBASETEXTURE9
{
    HRESULT GetLevelDesc( UINT Level,D3DSURFACE_DESC *pDesc);
    HRESULT GetCubeMapSurface( D3DCUBEMAP_FACES FaceType,UINT Level,LPDIRECT3DSURFACE9* ppCubeMapSurface);
    HRESULT LockRect( D3DCUBEMAP_FACES FaceType,UINT Level,D3DLOCKED_RECT* pLockedRect, RECT* pRect,DWORD Flags);
    HRESULT UnlockRect( D3DCUBEMAP_FACES FaceType,UINT Level);
    HRESULT AddDirtyRect( D3DCUBEMAP_FACES FaceType, RECT* pDirtyRect);
/*
    debug {
        LPCWSTR Name;
        UINT Width;
        UINT Height;
        UINT Levels;
        DWORD Usage;
        D3DFORMAT Format;
        D3DPOOL Pool;
        DWORD Priority;
        DWORD LOD;
        D3DTEXTUREFILTERTYPE FilterType;
        UINT LockCount;
        LPCWSTR CreationCallStack;
    }
*/
}

alias LPDIRECT3DCUBETEXTURE9 IDirect3DCubeTexture9;

interface LPDIRECT3DVERTEXBUFFER9 : LPDIRECT3DRESOURCE9
{
    HRESULT Lock( UINT OffsetToLock,UINT SizeToLock,void** ppbData,DWORD Flags);
    HRESULT Unlock();
    HRESULT GetDesc( D3DVERTEXBUFFER_DESC *pDesc);
/*
    debug {
        LPCWSTR Name;
        UINT Length;
        DWORD Usage;
        DWORD FVF;
        D3DPOOL Pool;
        DWORD Priority;
        UINT LockCount;
        LPCWSTR CreationCallStack;
    }
*/
}

alias LPDIRECT3DVERTEXBUFFER9 IDirect3DVertexBuffer9;

interface LPDIRECT3DINDEXBUFFER9 : LPDIRECT3DRESOURCE9
{
    HRESULT Lock( UINT OffsetToLock,UINT SizeToLock,void** ppbData,DWORD Flags);
    HRESULT Unlock();
    HRESULT GetDesc( D3DINDEXBUFFER_DESC *pDesc);
/*
    debug {
        LPCWSTR Name;
        UINT Length;
        DWORD Usage;
        D3DFORMAT Format;
        D3DPOOL Pool;
        DWORD Priority;
        UINT LockCount;
        LPCWSTR CreationCallStack;
    }
*/
}

alias LPDIRECT3DINDEXBUFFER9 IDirect3DIndexBuffer9;

interface LPDIRECT3DSURFACE9 : LPDIRECT3DRESOURCE9
{
    HRESULT GetContainer( REFIID riid,void** ppContainer);
    HRESULT GetDesc( D3DSURFACE_DESC *pDesc);
    HRESULT LockRect( D3DLOCKED_RECT* pLockedRect, RECT* pRect,DWORD Flags);
    HRESULT UnlockRect();
    HRESULT GetDC( HDC *phdc);
    HRESULT ReleaseDC( HDC hdc);
/*
    debug {
        LPCWSTR Name;
        UINT Width;
        UINT Height;
        DWORD Usage;
        D3DFORMAT Format;
        D3DPOOL Pool;
        D3DMULTISAMPLE_TYPE MultiSampleType;
        DWORD MultiSampleQuality;
        DWORD Priority;
        UINT LockCount;
        UINT DCCount;
        LPCWSTR CreationCallStack;
    }
*/
}

alias LPDIRECT3DSURFACE9 IDirect3DSurface9;

interface LPDIRECT3DVOLUME9 : IUnknown
{
    HRESULT GetDevice( LPDIRECT3DDEVICE9 * ppDevice);
    HRESULT SetPrivateData( REFGUID refguid, void* pData,DWORD SizeOfData,DWORD Flags);
    HRESULT GetPrivateData( REFGUID refguid,void* pData,DWORD* pSizeOfData);
    HRESULT FreePrivateData( REFGUID refguid);
    HRESULT GetContainer( REFIID riid,void** ppContainer);
    HRESULT GetDesc( D3DVOLUME_DESC *pDesc);
    HRESULT LockBox( D3DLOCKED_BOX * pLockedVolume, D3DBOX* pBox,DWORD Flags);
    HRESULT UnlockBox();
/*
    debug {
        LPCWSTR Name;
        UINT Width;
        UINT Height;
        UINT Depth;
        DWORD Usage;
        D3DFORMAT Format;
        D3DPOOL Pool;
        UINT LockCount;
        LPCWSTR CreationCallStack;
    }
*/
}

alias LPDIRECT3DVOLUME9 IDirect3DVolume9;

interface LPDIRECT3DQUERY9 : IUnknown
{
    HRESULT GetDevice( LPDIRECT3DDEVICE9* ppDevice);
    D3DQUERYTYPE GetType();
    DWORD GetDataSize();
    HRESULT Issue( DWORD dwIssueFlags);
    HRESULT GetData( void* pData,DWORD dwSize,DWORD dwGetDataFlags);
/*
    debug {
        D3DQUERYTYPE Type;
        DWORD DataSize;
        LPCWSTR CreationCallStack;
    }
*/
}

alias LPDIRECT3DQUERY9 IDirect3DQuery9;

/****************************************************************************
 * Flags for SetPrivateData method on all D3D9 interfaces
 *
 * The passed pointer is an IUnknown ptr. The SizeOfData argument to SetPrivateData
 * must be set to sizeof(IUnknown*). Direct3D will call AddRef through this
 * pointer and Release when the private data is destroyed. The data will be
 * destroyed when another SetPrivateData with the same GUID is set, when
 * FreePrivateData is called, or when the D3D9 object is freed.
 ****************************************************************************/
const D3DSPD_IUNKNOWN = 0x00000001L;

/****************************************************************************
 *
 * Flags for IDirect3D9::CreateDevice's BehaviorFlags
 *
 ****************************************************************************/

const D3DCREATE_FPU_PRESERVE = 0x00000002L;
const D3DCREATE_MULTITHREADED = 0x00000004L;

const D3DCREATE_PUREDEVICE = 0x00000010L;
const D3DCREATE_SOFTWARE_VERTEXPROCESSING = 0x00000020L;
const D3DCREATE_HARDWARE_VERTEXPROCESSING = 0x00000040L;
const D3DCREATE_MIXED_VERTEXPROCESSING = 0x00000080L;

const D3DCREATE_DISABLE_DRIVER_MANAGEMENT = 0x00000100L;
const D3DCREATE_ADAPTERGROUP_DEVICE = 0x00000200L;
const D3DCREATE_DISABLE_DRIVER_MANAGEMENT_EX = 0x00000400L;

// This flag causes the D3D runtime not to alter the focus
// window in any way. Use with caution- the burden of supporting
// focus management events (alt-tab, etc.) falls on the
// application, and appropriate responses (switching display
// mode, etc.) should be coded.
const D3DCREATE_NOWINDOWCHANGES = 0x00000800L;

// Disable multithreading for software vertex processing
const D3DCREATE_DISABLE_PSGP_THREADING = 0x00002000L;
// This flag enables present statistics on device.
const D3DCREATE_ENABLE_PRESENTSTATS = 0x00004000L;
// This flag disables printscreen support in the runtime for this device
const D3DCREATE_DISABLE_PRINTSCREEN = 0x00008000L;

const D3DCREATE_SCREENSAVER = 0x10000000L;


/****************************************************************************
 *
 * Parameter for IDirect3D9::CreateDevice's Adapter argument
 *
 ****************************************************************************/

const D3DADAPTER_DEFAULT = 0;

/****************************************************************************
 *
 * Flags for IDirect3D9::EnumAdapters
 *
 ****************************************************************************/

/*
 * The D3DENUM_WHQL_LEVEL value has been retired for 9Ex and future versions,
 * but it needs to be defined here for compatibility with DX9 and earlier versions.
 * See the DirectX SDK for sample code on discovering driver signatures.
 */
const D3DENUM_WHQL_LEVEL = 0x00000002L;

/* NO_DRIVERVERSION will not fill out the DriverVersion field, nor will the
   DriverVersion be incorporated into the DeviceIdentifier GUID. WINNT only */
const D3DENUM_NO_DRIVERVERSION = 0x00000004L;


/****************************************************************************
 *
 * Maximum number of back-buffers supported in DX9
 *
 ****************************************************************************/

const D3DPRESENT_BACK_BUFFERS_MAX = 3L;

/****************************************************************************
 *
 * Maximum number of back-buffers supported when apps use CreateDeviceEx
 *
 ****************************************************************************/
const D3DPRESENT_BACK_BUFFERS_MAX_EX = 30L;

/****************************************************************************
 *
 * Flags for IDirect3DDevice9::SetGammaRamp
 *
 ****************************************************************************/

const D3DSGR_NO_CALIBRATION = 0x00000000L;
const D3DSGR_CALIBRATE = 0x00000001L;

/****************************************************************************
 *
 * Flags for IDirect3DDevice9::SetCursorPosition
 *
 ****************************************************************************/

const D3DCURSOR_IMMEDIATE_UPDATE = 0x00000001L;

/****************************************************************************
 *
 * Flags for IDirect3DSwapChain9::Present
 *
 ****************************************************************************/

const D3DPRESENT_DONOTWAIT = 0x00000001L;
const D3DPRESENT_LINEAR_CONTENT = 0x00000002L;
const D3DPRESENT_DONOTFLIP = 0x00000004L;
const D3DPRESENT_FLIPRESTART = 0x00000008L;
const D3DPRESENT_VIDEO_RESTRICT_TO_MONITOR = 0x00000010L;

/****************************************************************************
 *
 * Flags for DrawPrimitive/DrawIndexedPrimitive
 *   Also valid for Begin/BeginIndexed
 *   Also valid for VertexBuffer::CreateVertexBuffer
 ****************************************************************************/


/*
 *  DirectDraw error codes
 */
const _FACD3D = 0x876;
HRESULT MAKE_D3DHRESULT(T)(T code) { return MAKE_HRESULT( 1, _FACD3D, code ); }
HRESULT MAKE_D3DSTATUS(T)(T code) { return MAKE_HRESULT( 0, _FACD3D, code ); }

/*
 * Direct3D Errors
 */
const HRESULT D3D_OK = S_OK;

const HRESULT D3DERR_WRONGTEXTUREFORMAT = MAKE_D3DHRESULT(2072);
const HRESULT D3DERR_UNSUPPORTEDCOLOROPERATION = MAKE_D3DHRESULT(2073);
const HRESULT D3DERR_UNSUPPORTEDCOLORARG = MAKE_D3DHRESULT(2074);
const HRESULT D3DERR_UNSUPPORTEDALPHAOPERATION = MAKE_D3DHRESULT(2075);
const HRESULT D3DERR_UNSUPPORTEDALPHAARG = MAKE_D3DHRESULT(2076);
const HRESULT D3DERR_TOOMANYOPERATIONS = MAKE_D3DHRESULT(2077);
const HRESULT D3DERR_CONFLICTINGTEXTUREFILTER = MAKE_D3DHRESULT(2078);
const HRESULT D3DERR_UNSUPPORTEDFACTORVALUE = MAKE_D3DHRESULT(2079);
const HRESULT D3DERR_CONFLICTINGRENDERSTATE = MAKE_D3DHRESULT(2081);
const HRESULT D3DERR_UNSUPPORTEDTEXTUREFILTER = MAKE_D3DHRESULT(2082);
const HRESULT D3DERR_CONFLICTINGTEXTUREPALETTE = MAKE_D3DHRESULT(2086);
const HRESULT D3DERR_DRIVERINTERNALERROR = MAKE_D3DHRESULT(2087);

const HRESULT D3DERR_NOTFOUND = MAKE_D3DHRESULT(2150);
const HRESULT D3DERR_MOREDATA = MAKE_D3DHRESULT(2151);
const HRESULT D3DERR_DEVICELOST = MAKE_D3DHRESULT(2152);
const HRESULT D3DERR_DEVICENOTRESET = MAKE_D3DHRESULT(2153);
const HRESULT D3DERR_NOTAVAILABLE = MAKE_D3DHRESULT(2154);
const HRESULT D3DERR_OUTOFVIDEOMEMORY = MAKE_D3DHRESULT(380);
const HRESULT D3DERR_INVALIDDEVICE = MAKE_D3DHRESULT(2155);
const HRESULT D3DERR_INVALIDCALL = MAKE_D3DHRESULT(2156);
const HRESULT D3DERR_DRIVERINVALIDCALL = MAKE_D3DHRESULT(2157);
const HRESULT D3DERR_WASSTILLDRAWING = MAKE_D3DHRESULT(540);
const HRESULT D3DOK_NOAUTOGEN = MAKE_D3DSTATUS(2159);
const HRESULT D3DERR_DEVICEREMOVED = MAKE_D3DHRESULT(2160);
const HRESULT S_NOT_RESIDENT = MAKE_D3DSTATUS(2165);
const HRESULT S_RESIDENT_IN_SHARED_MEMORY = MAKE_D3DSTATUS(2166);
const HRESULT S_PRESENT_MODE_CHANGED = MAKE_D3DSTATUS(2167);
const HRESULT S_PRESENT_OCCLUDED = MAKE_D3DSTATUS(2168);
const HRESULT D3DERR_DEVICEHUNG = MAKE_D3DHRESULT(2164);


/*********************
/* D3D9Ex interfaces
/*********************/

extern (Windows) HRESULT Direct3DCreate9Ex(UINT SDKVersion, LPDIRECT3D9EX*);

interface LPDIRECT3D9EX : LPDIRECT3D9
{
    UINT GetAdapterModeCountEx(UINT Adapter, D3DDISPLAYMODEFILTER* pFilter );
    HRESULT EnumAdapterModesEx( UINT Adapter, D3DDISPLAYMODEFILTER* pFilter,UINT Mode,D3DDISPLAYMODEEX* pMode);
    HRESULT GetAdapterDisplayModeEx( UINT Adapter,D3DDISPLAYMODEEX* pMode,D3DDISPLAYROTATION* pRotation);
    HRESULT CreateDeviceEx( UINT Adapter,D3DDEVTYPE DeviceType,HWND hFocusWindow,DWORD BehaviorFlags,D3DPRESENT_PARAMETERS* pPresentationParameters,D3DDISPLAYMODEEX* pFullscreenDisplayMode,LPDIRECT3DDEVICE9EX* ppReturnedDeviceInterface);
    HRESULT GetAdapterLUID( UINT Adapter,LUID * pLUID);
}

alias LPDIRECT3D9EX IDirect3D9Ex;

interface LPDIRECT3DDEVICE9EX : LPDIRECT3DDEVICE9
{
    HRESULT SetConvolutionMonoKernel( UINT width,UINT height,float* rows,float* columns);
    HRESULT ComposeRects( LPDIRECT3DSURFACE9 pSrc,LPDIRECT3DSURFACE9 pDst,LPDIRECT3DVERTEXBUFFER9 pSrcRectDescs,UINT NumRects,LPDIRECT3DVERTEXBUFFER9 pDstRectDescs,D3DCOMPOSERECTSOP Operation,int Xoffset,int Yoffset);
    HRESULT PresentEx( RECT* pSourceRect, RECT* pDestRect,HWND hDestWindowOverride, RGNDATA* pDirtyRegion,DWORD dwFlags);
    HRESULT GetGPUThreadPriority( INT* pPriority);
    HRESULT SetGPUThreadPriority( INT Priority);
    HRESULT WaitForVBlank( UINT iSwapChain);
    HRESULT CheckResourceResidency( LPDIRECT3DRESOURCE9* pResourceArray,UINT32 NumResources);
    HRESULT SetMaximumFrameLatency( UINT MaxLatency);
    HRESULT GetMaximumFrameLatency( UINT* pMaxLatency);
    HRESULT CheckDeviceState( HWND hDestinationWindow);
    HRESULT CreateRenderTargetEx( UINT Width,UINT Height,D3DFORMAT Format,D3DMULTISAMPLE_TYPE MultiSample,DWORD MultisampleQuality,BOOL Lockable,LPDIRECT3DSURFACE9* ppSurface,HANDLE* pSharedHandle,DWORD Usage);
    HRESULT CreateOffscreenPlainSurfaceEx( UINT Width,UINT Height,D3DFORMAT Format,D3DPOOL Pool,LPDIRECT3DSURFACE9* ppSurface,HANDLE* pSharedHandle,DWORD Usage);
    HRESULT CreateDepthStencilSurfaceEx( UINT Width,UINT Height,D3DFORMAT Format,D3DMULTISAMPLE_TYPE MultiSample,DWORD MultisampleQuality,BOOL Discard,LPDIRECT3DSURFACE9* ppSurface,HANDLE* pSharedHandle,DWORD Usage);
    HRESULT ResetEx( D3DPRESENT_PARAMETERS* pPresentationParameters,D3DDISPLAYMODEEX *pFullscreenDisplayMode);
    HRESULT GetDisplayModeEx( UINT iSwapChain,D3DDISPLAYMODEEX* pMode,D3DDISPLAYROTATION* pRotation);
}

alias LPDIRECT3DDEVICE9EX IDirect3DDevice9Ex;

interface LPDIRECT3DSWAPCHAIN9EX : LPDIRECT3DSWAPCHAIN9
{
    HRESULT GetLastPresentCount( UINT* pLastPresentCount);
    HRESULT GetPresentStats( D3DPRESENTSTATS* pPresentationStatistics);
    HRESULT GetDisplayModeEx( D3DDISPLAYMODEEX* pMode,D3DDISPLAYROTATION* pRotation);
}

alias LPDIRECT3DSWAPCHAIN9EX IDirect3DSwapChain9Ex;
