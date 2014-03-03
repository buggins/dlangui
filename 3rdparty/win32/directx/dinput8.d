module win32.directx.dinput8;

//import tango.sys.win32.Types;
//alias char CHAR;

import win32.windows;

enum {
	CLASS_E_NOAGGREGATION = cast(int) 0x80040110,
}

interface IUnknown {
    HRESULT QueryInterface(IID* riid, void** pvObject);
    ULONG AddRef();
    ULONG Release();
}

extern(C):

struct DIDEVICEINSTANCEA
{
    DWORD   dwSize;
    GUID    guidInstance;
    GUID    guidProduct;
    DWORD   dwDevType;
    CHAR    tszInstanceName[MAX_PATH];
    CHAR    tszProductName[MAX_PATH];
    GUID    guidFFDriver;
    WORD    wUsagePage;
    WORD    wUsage;
}
alias DIDEVICEINSTANCEA DIDEVICEINSTANCE;

struct DIDEVICEOBJECTINSTANCEA
{
    DWORD   dwSize;
    GUID    guidType;
    DWORD   dwOfs;
    DWORD   dwType;
    DWORD   dwFlags;
    CHAR    tszName[MAX_PATH];
    DWORD   dwFFMaxForce;
    DWORD   dwFFForceResolution;
    WORD    wCollectionNumber;
    WORD    wDesignatorIndex;
    WORD    wUsagePage;
    WORD    wUsage;
    DWORD   dwDimension;
    WORD    wExponent;
    WORD    wReportId;
}

struct DIOBJECTDATAFORMAT
{
	const   GUID *pguid;
	DWORD   dwOfs;
	DWORD   dwType;
	DWORD   dwFlags;
}

struct DIDATAFORMAT
{
	DWORD   dwSize;
	DWORD   dwObjSize;
	DWORD   dwFlags;
	DWORD   dwDataSize;
	DWORD   dwNumObjs;
	DIOBJECTDATAFORMAT* rgodf;
}

extern DIDATAFORMAT c_dfDIKeyboard;
extern DIDATAFORMAT c_dfDIMouse2;
extern DIDATAFORMAT c_dfDIJoystick;

struct DIACTIONA
{
	UINT*    uAppData;
	DWORD       dwSemantic;
	DWORD       dwFlags;
	union
	{
		LPCSTR      lptszActionName;
		UINT        uResIdString;
	}
	GUID        guidInstance;
	DWORD       dwObjID;
	DWORD       dwHow;
}

struct DIACTIONFORMATA
{
	DWORD       dwSize;
	DWORD       dwActionSize;
	DWORD       dwDataSize;
	DWORD       dwNumActions;
	DIACTIONA*  rgoAction;
	GUID        guidActionMap;
	DWORD       dwGenre;
	DWORD       dwBufferSize;
	LONG        lAxisMin;
	LONG        lAxisMax;
	HINSTANCE   hInstString;
	FILETIME    ftTimeStamp;
	DWORD       dwCRC;
	CHAR        tszActionMap[MAX_PATH];
}

struct DIDEVCAPS
{
    DWORD   dwSize;
    DWORD   dwFlags;
    DWORD   dwDevType;
    DWORD   dwAxes;
    DWORD   dwButtons;
    DWORD   dwPOVs;
    DWORD   dwFFSamplePeriod;
    DWORD   dwFFMinTimeResolution;
    DWORD   dwFirmwareRevision;
    DWORD   dwHardwareRevision;
    DWORD   dwFFDriverVersion;
}

struct DIPROPHEADER
{
    DWORD   dwSize;
    DWORD   dwHeaderSize;
    DWORD   dwObj;
    DWORD   dwHow;
}

struct DIDEVICEOBJECTDATA
{
    DWORD       dwOfs;
    DWORD       dwData;
    DWORD       dwTimeStamp;
    DWORD       dwSequence;
    UINT*    uAppData;
}

struct DIENVELOPE
{
    DWORD dwSize = DIENVELOPE.sizeof;
    DWORD dwAttackLevel;
    DWORD dwAttackTime;             // Microseconds
    DWORD dwFadeLevel;
    DWORD dwFadeTime;               // Microseconds
}

struct DIEFFECT
{
    DWORD dwSize = DIEFFECT.sizeof;
    DWORD dwFlags;                  // DIEFF_*
    DWORD dwDuration;               // Microseconds
    DWORD dwSamplePeriod;           // Microseconds
    DWORD dwGain;
    DWORD dwTriggerButton;          // or DIEB_NOTRIGGER
    DWORD dwTriggerRepeatInterval;  // Microseconds
    DWORD cAxes;                    // Number of axes
    LPDWORD rgdwAxes;               // Array of axes
    LPLONG rglDirection;            // Array of directions
    DIENVELOPE* lpEnvelope;         // Optional
    DWORD cbTypeSpecificParams;     // Size of params
    LPVOID lpvTypeSpecificParams;   // Pointer to params
    DWORD  dwStartDelay;            // Microseconds
}

struct DIEFFESCAPE
{
    DWORD   dwSize;
    DWORD   dwCommand;
    LPVOID  lpvInBuffer;
    DWORD   cbInBuffer;
    LPVOID  lpvOutBuffer;
    DWORD   cbOutBuffer;
}

struct DIEFFECTINFOA
{
    DWORD   dwSize;
    GUID    guid;
    DWORD   dwEffType;
    DWORD   dwStaticParams;
    DWORD   dwDynamicParams;
    CHAR    tszName[MAX_PATH];
}

struct DIFILEEFFECT
{
    DWORD       dwSize;
    GUID        GuidEffect;
    DIEFFECT* lpDiEffect;
    CHAR        szFriendlyName[MAX_PATH];
}

struct DIDEVICEIMAGEINFOA
{
    CHAR        tszImagePath[MAX_PATH];
    DWORD       dwFlags;
    // These are valid if DIDIFT_OVERLAY is present in dwFlags.
    DWORD       dwViewID;
    RECT        rcOverlay;
    DWORD       dwObjID;
    DWORD       dwcValidPts;
    POINT       rgptCalloutLine[5];
    RECT        rcCalloutRect;
    DWORD       dwTextAlign;
}

struct DIDEVICEIMAGEINFOHEADERA
{
    DWORD       dwSize;
    DWORD       dwSizeImageInfo;
    DWORD       dwcViews;
    DWORD       dwcButtons;
    DWORD       dwcAxes;
    DWORD       dwcPOVs;
    DWORD       dwBufferSize;
    DWORD       dwBufferUsed;
    DIDEVICEIMAGEINFOA* lprgImageInfoArray;
}

struct DICONFIGUREDEVICESPARAMSA
{
	 DWORD            dwSize;
	 DWORD            dwcUsers;
	 LPSTR            lptszUserNames;
	 DWORD            dwcFormats;
	 DIACTIONFORMATA* lprgFormats;
	 HWND             hwnd;
	 DICOLORSET       dics;
	 IUnknown         lpUnkDDSTarget;
}

struct DICOLORSET
{
    DWORD dwSize;
    DWORD cTextFore;
    DWORD cTextHighlight;
    DWORD cCalloutLine;
    DWORD cCalloutHighlight;
    DWORD cBorder;
    DWORD cControlFill;
    DWORD cHighlightFill;
    DWORD cAreaFill;
}

struct DIMOUSESTATE2
{
    LONG    lX;
    LONG    lY;
    LONG    lZ;
    BYTE    rgbButtons[8];
}

struct DIJOYSTATE
{
    LONG    lX;                     /* x-axis position              */
    LONG    lY;                     /* y-axis position              */
    LONG    lZ;                     /* z-axis position              */
    LONG    lRx;                    /* x-axis rotation              */
    LONG    lRy;                    /* y-axis rotation              */
    LONG    lRz;                    /* z-axis rotation              */
    LONG    rglSlider[2];           /* extra axes positions         */
    DWORD   rgdwPOV[4];             /* POV directions               */
    BYTE    rgbButtons[32];         /* 32 buttons                   */
}

struct DIPROPRANGE
{
    DIPROPHEADER diph;
    LONG    lMin;
    LONG    lMax;
}

interface IDirectInputEffect : IUnknown
{
    HRESULT Initialize(HINSTANCE, DWORD, GUID*);
    HRESULT GetEffectGuid(GUID*);
    HRESULT GetParameters(DIEFFECT*, DWORD);
    HRESULT SetParameters(DIEFFECT*, DWORD);
    HRESULT Start(DWORD, DWORD);
    HRESULT Stop();
    HRESULT GetEffectStatus(LPDWORD);
    HRESULT Download();
    HRESULT Unload();
    HRESULT Escape(DIEFFESCAPE*);
}

extern(Windows) alias bool function(DIDEVICEINSTANCEA*, LPVOID) LPDIENUMDEVICESCALLBACKA;
extern(Windows) alias bool function(DIDEVICEINSTANCEA*, IDirectInputDevice8A*, DWORD, DWORD, LPVOID) LPDIENUMDEVICESBYSEMANTICSCBA;

extern(Windows) alias bool function(DIDEVICEOBJECTINSTANCEA *didoi, void* pContext) LPDIENUMDEVICEOBJECTSCALLBACKA;

extern(Windows) alias bool function(DIEFFECTINFOA*, LPVOID) LPDIENUMEFFECTSCALLBACKA;
extern(Windows) alias bool function(IDirectInputEffect, LPVOID) LPDIENUMCREATEDEFFECTOBJECTSCALLBACK;
extern(Windows) alias bool function(DIFILEEFFECT* , LPVOID) LPDIENUMEFFECTSINFILECALLBACK;
extern(Windows) alias bool function(IUnknown, LPVOID) LPDICONFIGUREDEVICESCALLBACK;

interface IDirectInputDevice8A : IUnknown
{
    HRESULT GetCapabilities(DIDEVCAPS*);
    HRESULT EnumObjects(LPDIENUMDEVICEOBJECTSCALLBACKA, VOID*, DWORD);
    HRESULT GetProperty(GUID*, DIPROPHEADER*);
    HRESULT SetProperty(GUID*, DIPROPHEADER*);
    HRESULT Acquire();
    HRESULT Unacquire();
    HRESULT GetDeviceState(DWORD, LPVOID);
    HRESULT GetDeviceData(DWORD, DIDEVICEOBJECTDATA*, LPDWORD, DWORD);
    HRESULT SetDataFormat(DIDATAFORMAT*);
    HRESULT SetEventNotification(HANDLE);
    HRESULT SetCooperativeLevel(HWND, DWORD);
    HRESULT GetObjectInfo(DIDEVICEOBJECTINSTANCEA*, DWORD, DWORD);
    HRESULT GetDeviceInfo(DIDEVICEINSTANCEA*);
    HRESULT RunControlPanel(HWND, DWORD);
    HRESULT Initialize(HINSTANCE, DWORD, GUID*);
    HRESULT CreateEffect(GUID*, DIEFFECT*, IDirectInputEffect*, IUnknown);
    HRESULT EnumEffects(LPDIENUMEFFECTSCALLBACKA, LPVOID, DWORD);
    HRESULT GetEffectInfo(DIEFFECTINFOA*, GUID*);
    HRESULT GetForceFeedbackState(LPDWORD);
    HRESULT SendForceFeedbackCommand(DWORD);
    HRESULT EnumCreatedEffectObjects(LPDIENUMCREATEDEFFECTOBJECTSCALLBACK, LPVOID, DWORD);
    HRESULT Escape(DIEFFESCAPE*);
    HRESULT Poll();
    HRESULT SendDeviceData(DWORD, DIDEVICEOBJECTDATA*, LPDWORD, DWORD);
    HRESULT EnumEffectsInFile(LPCSTR, LPDIENUMEFFECTSINFILECALLBACK, LPVOID, DWORD);
    HRESULT WriteEffectToFile(LPCSTR, DWORD, DIFILEEFFECT*, DWORD);
    HRESULT BuildActionMap(DIACTIONFORMATA*, LPCSTR, DWORD);
    HRESULT SetActionMap(DIACTIONFORMATA*, LPCSTR, DWORD);
    HRESULT GetImageInfo(DIDEVICEIMAGEINFOHEADERA*);
}
alias IDirectInputDevice8A IDirectInputDevice8;

interface IDirectInput8A : IUnknown
{
extern(Windows):
    HRESULT CreateDevice(GUID*, IDirectInputDevice8A*, IUnknown);
    HRESULT EnumDevices(DWORD, LPDIENUMDEVICESCALLBACKA, LPVOID, DWORD);
    HRESULT GetDeviceStatus(GUID*);
    HRESULT RunControlPanel(HWND, DWORD);
    HRESULT Initialize(HINSTANCE, DWORD);
    HRESULT FindDevice(GUID*, LPCSTR, GUID*);
    HRESULT EnumDevicesBySemantics(LPCSTR, DIACTIONFORMATA*, LPDIENUMDEVICESBYSEMANTICSCBA, LPVOID, DWORD);
    HRESULT ConfigureDevices(LPDICONFIGUREDEVICESCALLBACK, DICONFIGUREDEVICESPARAMSA*, DWORD, LPVOID);
}
alias IDirectInput8A IDirectInput8;

extern(Windows) HRESULT DirectInput8Create(HINSTANCE hinst, DWORD dwVersion, GUID* riidltf, void** ppvOut, IUnknown punkOuter);

const GUID IID_IDirectInput8A={0xBF798030, 0x483A, 0x4DA2, [0xAA, 0x99, 0x5D, 0x64, 0xED, 0x36, 0x97, 0x00]};
alias IID_IDirectInput8A IID_IDirectInput8;
const GUID GUID_SysKeyboard = {0x6F1D2B61, 0xD5A0, 0x11CF, [0xBF, 0xC7, 0x44, 0x45, 0x53, 0x54, 0x00, 0x00]};
const GUID GUID_SysMouse =    {0x6F1D2B60, 0xD5A0, 0x11CF, [0xBF, 0xC7, 0x44, 0x45, 0x53, 0x54, 0x00, 0x00]};
const GUID GUID_XAxis =       {0xA36D02E0, 0xC9F3, 0x11CF, [0xBF, 0xC7, 0x44, 0x45, 0x53, 0x54, 0x00, 0x00]};
const GUID GUID_YAxis =       {0xA36D02E1, 0xC9F3, 0x11CF, [0xBF, 0xC7, 0x44, 0x45, 0x53, 0x54, 0x00, 0x00]};
const GUID GUID_ZAxis =       {0xA36D02E2, 0xC9F3, 0x11CF, [0xBF, 0xC7, 0x44, 0x45, 0x53, 0x54, 0x00, 0x00]};
const GUID GUID_RxAxis =      {0xA36D02F4, 0xC9F3, 0x11CF, [0xBF, 0xC7, 0x44, 0x45, 0x53, 0x54, 0x00, 0x00]};
const GUID GUID_RyAxis =      {0xA36D02F5, 0xC9F3, 0x11CF, [0xBF, 0xC7, 0x44, 0x45, 0x53, 0x54, 0x00, 0x00]};
const GUID GUID_RzAxis =      {0xA36D02E3, 0xC9F3, 0x11CF, [0xBF, 0xC7, 0x44, 0x45, 0x53, 0x54, 0x00, 0x00]};
const GUID GUID_Slider =      {0xA36D02E4, 0xC9F3, 0x11CF, [0xBF, 0xC7, 0x44, 0x45, 0x53, 0x54, 0x00, 0x00]};
const GUID GUID_Key =         {0x55728220, 0xD33C, 0x11CF, [0xBF, 0xC7, 0x44, 0x45, 0x53, 0x54, 0x00, 0x00]};
const GUID GUID_POV =         {0xA36D02F2, 0xC9F3, 0x11CF, [0xBF, 0xC7, 0x44, 0x45, 0x53, 0x54, 0x00, 0x00]};

enum : uint
{
	DISCL_EXCLUSIVE=     0x00000001,
	DISCL_NONEXCLUSIVE=  0x00000002,
	DISCL_FOREGROUND=    0x00000004,
	DISCL_BACKGROUND=	 0x00000008,
	DISCL_NOWINKEY=      0x00000010,

	DIPH_DEVICE=0,
	DIPH_BYOFFSET=1,

	DI8DEVCLASS_GAMECTRL=4,
	DIEDFL_ATTACHEDONLY=     0x00000001,
	DIDFT_AXIS=          0x00000003
}

enum
{
	SEVERITY_SUCCESS=    0,
	SEVERITY_ERROR=      1,
	FACILITY_WIN32=                   7,
	ERROR_READ_FAULT=                 30L,
	DIENUM_CONTINUE=         1,
	DIPH_BYID=               2
}

struct DIPROPDWORD
{
    DIPROPHEADER diph;
    DWORD   dwData;
}

template MAKE_HRESULT(uint sev, uint fac, uint code)
{
	const HRESULT MAKE_HRESULT = cast(HRESULT)((sev << 31) | (fac << 16) | code);
}

const HRESULT DIERR_OLDDIRECTINPUTVERSION             = MAKE_HRESULT!(SEVERITY_ERROR, FACILITY_WIN32, 1150);
const HRESULT DIERR_BETADIRECTINPUTVERSION            = MAKE_HRESULT!(SEVERITY_ERROR, FACILITY_WIN32, 1153);
const HRESULT DIERR_BADDRIVERVER                      = MAKE_HRESULT!(SEVERITY_ERROR, FACILITY_WIN32, 119);
const HRESULT DIERR_DEVICENOTREG                      = 0x80040154;
const HRESULT DIERR_NOTFOUND                          = MAKE_HRESULT!(SEVERITY_ERROR, FACILITY_WIN32, ERROR_FILE_NOT_FOUND);
const HRESULT DIERR_OBJECTNOTFOUND                    = MAKE_HRESULT!(SEVERITY_ERROR, FACILITY_WIN32, ERROR_FILE_NOT_FOUND);
const HRESULT DIERR_INVALIDPARAM                      = E_INVALIDARG;
const HRESULT DIERR_NOINTERFACE                       = E_NOINTERFACE;
const HRESULT DIERR_GENERIC                           = E_FAIL;
const HRESULT DIERR_OUTOFMEMORY                       = E_OUTOFMEMORY;
const HRESULT DIERR_UNSUPPORTED                       = E_NOTIMPL;
const HRESULT DIERR_NOTINITIALIZED                    = MAKE_HRESULT!(SEVERITY_ERROR, FACILITY_WIN32, 21);
const HRESULT DIERR_ALREADYINITIALIZED                = MAKE_HRESULT!(SEVERITY_ERROR, FACILITY_WIN32, 1247);
const HRESULT DIERR_NOAGGREGATION                     = CLASS_E_NOAGGREGATION;
const HRESULT DIERR_OTHERAPPHASPRIO                   = 0x80070005;
const HRESULT DIERR_INPUTLOST                         = MAKE_HRESULT!(SEVERITY_ERROR, FACILITY_WIN32, ERROR_READ_FAULT);
const HRESULT DIERR_ACQUIRED                          = MAKE_HRESULT!(SEVERITY_ERROR, FACILITY_WIN32, 170);
const HRESULT DIERR_NOTACQUIRED                       = MAKE_HRESULT!(SEVERITY_ERROR, FACILITY_WIN32, 12);
const HRESULT DIERR_READONLY                          = 0x80070005;
const HRESULT DIERR_HANDLEEXISTS                      = 0x80070005;
const HRESULT DIERR_INSUFFICIENTPRIVS                 = 0x80040200;
const HRESULT DIERR_DEVICEFULL                        = 0x80040201;
const HRESULT DIERR_MOREDATA                          = 0x80040202;
const HRESULT DIERR_NOTDOWNLOADED                     = 0x80040203;
const HRESULT DIERR_HASEFFECTS                        = 0x80040204;
const HRESULT DIERR_NOTEXCLUSIVEACQUIRED              = 0x80040205;
const HRESULT DIERR_INCOMPLETEEFFECT                  = 0x80040206;
const HRESULT DIERR_NOTBUFFERED                       = 0x80040207;
const HRESULT DIERR_EFFECTPLAYING                     = 0x80040208;
const HRESULT DIERR_UNPLUGGED                         = 0x80040209;
const HRESULT DIERR_REPORTFULL                        = 0x8004020A;
const HRESULT DIERR_MAPFILEFAIL                       = 0x8004020B;
