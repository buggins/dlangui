/***********************************************************************\
*                                 dxerr.d                               *
*                                                                       *
*                       Windows API header module                       *
*                                                                       *
*                       Placed into public domain                       *
\***********************************************************************/
module win32.directx.dxerr;

import win32.windows;

pragma(lib, "dxerr.lib");

extern (Windows) {
	CHAR*  DXGetErrorStringA(HRESULT hr);
	WCHAR* DXGetErrorStringW(HRESULT hr);
	CHAR*  DXGetErrorDescriptionA(HRESULT hr);
	WCHAR* DXGetErrorDescriptionW(HRESULT hr);
	HRESULT DXTraceA(CHAR* strFile, DWORD dwLine, HRESULT hr, CHAR* strMsg,
	  BOOL bPopMsgBox);
	HRESULT DXTraceW(CHAR* strFile, DWORD dwLine, HRESULT hr, WCHAR* strMsg,
	  BOOL bPopMsgBox);
}

version (Unicode) {
	alias DXGetErrorStringW DXGetErrorString;
	alias DXGetErrorDescriptionW DXGetErrorDescription;
	alias DXTraceW DXTrace;
} else {
	alias DXGetErrorStringA DXGetErrorString;
	alias DXGetErrorDescriptionA DXGetErrorDescription;
	alias DXTraceA DXTrace;
}

debug (dxerr) {
	HRESULT DXTRACE_MSG(TCHAR* str) {
		return DXTrace(__FILE__, __LINE__, 0, str, false);
	}
	HRESULT DXTRACE_ERR(TCHAR* str, HRESULT hr) {
		return DXTrace(__FILE__, __LINE__, hr, str, false);
	}
	HRESULT DXTRACE_ERR_MSGBOX(TCHAR* str, HRESULT hr) {
		return DXTrace(__FILE__, __LINE__, hr, str, true);
	}
} else {
	HRESULT DXTRACE_MSG(TCHAR* str) {
		return 0;
	}
	HRESULT DXTRACE_ERR(TCHAR* str, HRESULT hr) {
		return hr;
	}
	HRESULT DXTRACE_ERR_MSGBOX(TCHAR* str, HRESULT hr) {
		return hr;
	}
}