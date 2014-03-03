module win32.directx.dsound8;

//import tango.sys.win32.Types;
import win32.windows;

alias GUID* LPCGUID;

interface IUnknown
{
	HRESULT QueryInterface(IID* riid, void** pvObject);
	ULONG AddRef();
	ULONG Release();
}

alias IUnknown LPUNKNOWN;

interface IDirectSound : IUnknown
{
	extern(Windows):

    // IDirectSound methods
    HRESULT CreateSoundBuffer    (LPCDSBUFFERDESC pcDSBufferDesc, LPDIRECTSOUNDBUFFER *ppDSBuffer, LPUNKNOWN pUnkOuter);
    HRESULT GetCaps              (LPDSCAPS pDSCaps);
    HRESULT DuplicateSoundBuffer (LPDIRECTSOUNDBUFFER pDSBufferOriginal, LPDIRECTSOUNDBUFFER *ppDSBufferDuplicate);
    HRESULT SetCooperativeLevel  (HWND hwnd, DWORD dwLevel);
    HRESULT Compact              ();
    HRESULT GetSpeakerConfig     (LPDWORD pdwSpeakerConfig);
    HRESULT SetSpeakerConfig     (DWORD dwSpeakerConfig);
    HRESULT Initialize           (LPCGUID pcGuidDevice);
}

alias IDirectSound LPDIRECTSOUND;

interface IDirectSound8 : IDirectSound
{
	extern(Windows):

    // IDirectSound8 methods
    HRESULT VerifyCertification  (LPDWORD pdwCertified);
}

alias IDirectSound8 LPDIRECTSOUND8;

interface IDirectSoundBuffer : IUnknown
{
	extern(Windows):

    // IDirectSoundBuffer methods
    HRESULT GetCaps              (LPDSBCAPS pDSBufferCaps);
    HRESULT GetCurrentPosition   (LPDWORD pdwCurrentPlayCursor, LPDWORD pdwCurrentWriteCursor);
    HRESULT GetFormat            (LPWAVEFORMATEX pwfxFormat, DWORD dwSizeAllocated, LPDWORD pdwSizeWritten);
    HRESULT GetVolume            (LPLONG plVolume);
    HRESULT GetPan               (LPLONG plPan);
    HRESULT GetFrequency         (LPDWORD pdwFrequency);
    HRESULT GetStatus            (LPDWORD pdwStatus);
    HRESULT Initialize           (LPDIRECTSOUND pDirectSound, LPCDSBUFFERDESC pcDSBufferDesc);
    HRESULT Lock                 (DWORD dwOffset, DWORD dwBytes, LPVOID *ppvAudioPtr1, LPDWORD pdwAudioBytes1,
                                           LPVOID *ppvAudioPtr2, LPDWORD pdwAudioBytes2, DWORD dwFlags);
    HRESULT Play                 (DWORD dwReserved1, DWORD dwPriority, DWORD dwFlags);
    HRESULT SetCurrentPosition   (DWORD dwNewPosition);
    HRESULT SetFormat            (LPCWAVEFORMATEX pcfxFormat);
    HRESULT SetVolume            (LONG lVolume);
    HRESULT SetPan               (LONG lPan);
    HRESULT SetFrequency         (DWORD dwFrequency);
    HRESULT Stop                 ();
    HRESULT Unlock               (LPVOID pvAudioPtr1, DWORD dwAudioBytes1, LPVOID pvAudioPtr2, DWORD dwAudioBytes2);
    HRESULT Restore              ();
}

alias IDirectSoundBuffer LPDIRECTSOUNDBUFFER;

interface IDirectSound3DListener : IUnknown
{
	extern(Windows):

    // IDirectSound3DListener methods
    HRESULT GetAllParameters         (LPDS3DLISTENER pListener);
    HRESULT GetDistanceFactor        (D3DVALUE* pflDistanceFactor);
    HRESULT GetDopplerFactor         (D3DVALUE* pflDopplerFactor);
    HRESULT GetOrientation           (D3DVECTOR* pvOrientFront, D3DVECTOR* pvOrientTop);
    HRESULT GetPosition              (D3DVECTOR* pvPosition);
    HRESULT GetRolloffFactor         (D3DVALUE* pflRolloffFactor);
    HRESULT GetVelocity              (D3DVECTOR* pvVelocity);
    HRESULT SetAllParameters         (LPCDS3DLISTENER pcListener, DWORD dwApply);
    HRESULT SetDistanceFactor        (D3DVALUE flDistanceFactor, DWORD dwApply);
    HRESULT SetDopplerFactor         (D3DVALUE flDopplerFactor, DWORD dwApply);
    HRESULT SetOrientation           (D3DVALUE xFront, D3DVALUE yFront, D3DVALUE zFront,
                                               D3DVALUE xTop, D3DVALUE yTop, D3DVALUE zTop, DWORD dwApply);
    HRESULT SetPosition              (D3DVALUE x, D3DVALUE y, D3DVALUE z, DWORD dwApply);
    HRESULT SetRolloffFactor         (D3DVALUE flRolloffFactor, DWORD dwApply);
    HRESULT SetVelocity              (D3DVALUE x, D3DVALUE y, D3DVALUE z, DWORD dwApply);
    HRESULT CommitDeferredSettings   ();
}

struct WAVEFORMATEX
{
	ushort wFormatTag;
	ushort nChannels;
	uint nSamplesPerSec;
	uint nAvgBytesPerSec;
	ushort nBlockAlign;
	ushort wBitsPerSample;
	ushort cbSize;
}

alias WAVEFORMATEX* LPWAVEFORMATEX, LPCWAVEFORMATEX;

enum : uint
{
	WAVE_FORMAT_PCM = 1
}

struct DSCBUFFERDESC
{
    DWORD           dwSize;
    DWORD           dwFlags;
    DWORD           dwBufferBytes;
    DWORD           dwReserved;
    LPWAVEFORMATEX  lpwfxFormat;
    DWORD           dwFXCount;
    LPDSCEFFECTDESC lpDSCFXDesc;
}

alias DSCBUFFERDESC* LPDSCBUFFERDESC;

struct DSBUFFERDESC
{
    DWORD           dwSize;
    DWORD           dwFlags;
    DWORD           dwBufferBytes;
    DWORD           dwReserved;
    LPWAVEFORMATEX  lpwfxFormat;
    GUID            guid3DAlgorithm;
}

alias DSBUFFERDESC* LPCDSBUFFERDESC;

struct DSCAPS
{
    DWORD           dwSize;
    DWORD           dwFlags;
    DWORD           dwMinSecondarySampleRate;
    DWORD           dwMaxSecondarySampleRate;
    DWORD           dwPrimaryBuffers;
    DWORD           dwMaxHwMixingAllBuffers;
    DWORD           dwMaxHwMixingStaticBuffers;
    DWORD           dwMaxHwMixingStreamingBuffers;
    DWORD           dwFreeHwMixingAllBuffers;
    DWORD           dwFreeHwMixingStaticBuffers;
    DWORD           dwFreeHwMixingStreamingBuffers;
    DWORD           dwMaxHw3DAllBuffers;
    DWORD           dwMaxHw3DStaticBuffers;
    DWORD           dwMaxHw3DStreamingBuffers;
    DWORD           dwFreeHw3DAllBuffers;
    DWORD           dwFreeHw3DStaticBuffers;
    DWORD           dwFreeHw3DStreamingBuffers;
    DWORD           dwTotalHwMemBytes;
    DWORD           dwFreeHwMemBytes;
    DWORD           dwMaxContigFreeHwMemBytes;
    DWORD           dwUnlockTransferRateHwBuffers;
    DWORD           dwPlayCpuOverheadSwBuffers;
    DWORD           dwReserved1;
    DWORD           dwReserved2;
}

alias DSCAPS* LPDSCAPS;

struct DSBCAPS
{
    DWORD           dwSize;
    DWORD           dwFlags;
    DWORD           dwBufferBytes;
    DWORD           dwUnlockTransferRate;
    DWORD           dwPlayCpuOverhead;
}

alias DSBCAPS *LPDSBCAPS;

struct DSCEFFECTDESC
{
    DWORD       dwSize;
    DWORD       dwFlags;
    GUID        guidDSCFXClass;
    GUID        guidDSCFXInstance;
    DWORD       dwReserved1;
    DWORD       dwReserved2;
}

alias DSCEFFECTDESC *LPDSCEFFECTDESC;

struct DS3DLISTENER
{
    DWORD           dwSize;
    D3DVECTOR       vPosition;
    D3DVECTOR       vVelocity;
    D3DVECTOR       vOrientFront;
    D3DVECTOR       vOrientTop;
    D3DVALUE        flDistanceFactor;
    D3DVALUE        flRolloffFactor;
    D3DVALUE        flDopplerFactor;
}

alias DS3DLISTENER *LPDS3DLISTENER, LPCDS3DLISTENER;

alias float D3DVALUE;

struct D3DVECTOR
{
    float x;
    float y;
    float z;
}

extern(Windows) export HRESULT DirectSoundCreate8(LPCGUID pcGuidDevice, LPDIRECTSOUND8 *ppDS8, LPUNKNOWN pUnkOuter);

const DSSCL_PRIORITY = 0x00000002;
const DSBCAPS_PRIMARYBUFFER = 0x00000001;
const DSBCAPS_CTRL3D = 0x00000010;
const DSBCAPS_GETCURRENTPOSITION2 = 0x00010000;
const DSBCAPS_LOCDEFER = 0x00040000;
const DSBPLAY_LOOPING = 0x00000001;
const DSBSTATUS_PLAYING = 0x00000001;
const DSBCAPS_CTRLFREQUENCY = 0x00000020;
const DSBCAPS_CTRLPAN = 0x00000040;
const DSBCAPS_CTRLVOLUME = 0x00000080;
const DSBLOCK_ENTIREBUFFER = 0x00000002;

const GUID IID_IDirectSound3DListener8 = {0x279AFA84,0x4981,0x11CE,[0xA5, 0x21, 0x00, 0x20, 0xAF, 0x0B, 0xE5, 0x60]};