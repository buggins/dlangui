/***********************************************************************\
*                                d3dx10.d                               *
*                                                                       *
*                       Windows API header module                       *
*                                                                       *
*                       Placed into public domain                       *
\***********************************************************************/
module win32.directx.d3dx10;

private import win32.windows;

public import win32.directx.d3d10;
public import win32.directx.d3dx10math;
public import win32.directx.d3dx10core;
public import win32.directx.d3dx10tex;
public import win32.directx.d3dx10mesh;
public import win32.directx.d3dx10async;

pragma(lib, "d3dx10.lib");

const UINT D3DX10_DEFAULT = -1;
const UINT D3DX10_FROM_FILE = -3;
const DXGI_FORMAT DXGI_FORMAT_FROM_FILE = cast(DXGI_FORMAT)-3;

const _FACDD = 0x876;
HRESULT MAKE_DDHRESULT(T)(T code) {
	return MAKE_HRESULT(1, _FACDD, code);
}

alias HRESULT _D3DX10_ERR;
_D3DX10_ERR D3DX10_ERR_CANNOT_MODIFY_INDEX_BUFFER	= MAKE_DDHRESULT(2900);
_D3DX10_ERR D3DX10_ERR_INVALID_MESH					= MAKE_DDHRESULT(2901);
_D3DX10_ERR D3DX10_ERR_CANNOT_ATTR_SORT				= MAKE_DDHRESULT(2902);
_D3DX10_ERR D3DX10_ERR_SKINNING_NOT_SUPPORTED		= MAKE_DDHRESULT(2903);
_D3DX10_ERR D3DX10_ERR_TOO_MANY_INFLUENCES			= MAKE_DDHRESULT(2904);
_D3DX10_ERR D3DX10_ERR_INVALID_DATA					= MAKE_DDHRESULT(2905);
_D3DX10_ERR D3DX10_ERR_LOADED_MESH_HAS_NO_DATA		= MAKE_DDHRESULT(2906);
_D3DX10_ERR D3DX10_ERR_DUPLICATE_NAMED_FRAGMENT		= MAKE_DDHRESULT(2907);
_D3DX10_ERR D3DX10_ERR_CANNOT_REMOVE_LAST_ITEM		= MAKE_DDHRESULT(2908);