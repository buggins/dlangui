/***********************************************************************\
*                                dxerr8.d                               *
*                                                                       *
*                       Windows API header module                       *
*                                                                       *
*                 Translated from MinGW Windows headers                 *
*                                                                       *
*                       Placed into public domain                       *
\***********************************************************************/
module win32.directx.dxerr8;

/*
	dxerr8.d - Header file for the DirectX 8 Error API

	Written by Filip Navara <xnavara@volny.cz>
	Ported to D by James Pelcis <jpelcis@gmail.com>

	This library is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
*/

private import win32.windef;

extern (Windows) {
	char* DXGetErrorString8A (HRESULT);
	WCHAR* DXGetErrorString8W (HRESULT);
	char* DXGetErrorDescription8A (HRESULT);
	WCHAR* DXGetErrorDescription8W (HRESULT);
	HRESULT DXTraceA (char*, DWORD, HRESULT, char*, BOOL);
	HRESULT DXTraceW (char*, DWORD, HRESULT, WCHAR*, BOOL);
}

version (Unicode) {
	alias DXGetErrorString8W DXGetErrorString8;
	alias DXGetErrorDescription8W DXGetErrorDescription8;
	alias DXTraceW DXTrace;
} else {
	alias DXGetErrorString8A DXGetErrorString8;
	alias DXGetErrorDescription8A DXGetErrorDescription8;
	alias DXTraceA DXTrace;
}

debug (dxerr) {
	HRESULT DXTRACE_MSG(TCHAR* str) {
		return DXTrace(__FILE__, __LINE__, 0, str, FALSE);
	}

	HRESULT DXTRACE_ERR(TCHAR* str, HRESULT hr) {
		return DXTrace(__FILE__, __LINE__, hr, str, TRUE);
	}

	HRESULT DXTRACE_ERR_NOMSGBOX (WCHAR* str, HRESULT hr) {
		return DXTrace(__FILE__, __LINE__, hr, str, FALSE);
	}
} else {
	HRESULT DXTRACE_MSG(TCHAR* str) {
		return 0;
	}

	HRESULT DXTRACE_ERR(TCHAR* str, HRESULT hr) {
		return hr;
	}

	HRESULT DXTRACE_ERR_NOMSGBOX(TCHAR* str, HRESULT hr) {
		return hr;
	}
}
