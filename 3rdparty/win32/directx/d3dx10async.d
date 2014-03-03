/***********************************************************************\
*                             d3dx10async.d                             *
*                                                                       *
*                       Windows API header module                       *
*                                                                       *
*                       Placed into public domain                       *
\***********************************************************************/
module win32.directx.d3dx10async;

private import win32.windows;
private import win32.directx.d3d10;
private import win32.directx.d3d10shader;
private import win32.directx.d3d10effect;
private import win32.directx.d3dx10;
private import win32.directx.d3dx10async;

extern(Windows) {
	HRESULT D3DX10CompileFromFileA(LPCSTR pSrcFile, D3D10_SHADER_MACRO* pDefines, ID3D10Include pInclude, LPCSTR pFunctionName, LPCSTR pProfile, UINT Flags1, UINT Flags2, ID3DX10ThreadPump pPump, ID3D10Blob* ppShader, ID3D10Blob* ppErrorMsgs, HRESULT* pHResult);
	HRESULT D3DX10CompileFromFileW(LPCWSTR pSrcFile, D3D10_SHADER_MACRO* pDefines, ID3D10Include pInclude, LPCSTR pFunctionName, LPCSTR pProfile, UINT Flags1, UINT Flags2, ID3DX10ThreadPump pPump, ID3D10Blob* ppShader, ID3D10Blob* ppErrorMsgs, HRESULT* pHResult);
}

version(Unicode) {
	alias D3DX10CompileFromFileW D3DX10CompileFromFile;
} else {
	alias D3DX10CompileFromFileA D3DX10CompileFromFile;
}

extern(Windows) {
	HRESULT D3DX10CompileFromResourceA(HMODULE hSrcModule, LPCSTR pSrcResource, LPCSTR pSrcFileName, D3D10_SHADER_MACRO* pDefines, ID3D10Include pInclude, LPCSTR pFunctionName, LPCSTR pProfile, UINT Flags1, UINT Flags2, ID3DX10ThreadPump pPump, ID3D10Blob* ppShader, ID3D10Blob* ppErrorMsgs, HRESULT* pHResult);
	HRESULT D3DX10CompileFromResourceW(HMODULE hSrcModule, LPCWSTR pSrcResource, LPCWSTR pSrcFileName, D3D10_SHADER_MACRO* pDefines, ID3D10Include pInclude, LPCSTR pFunctionName, LPCSTR pProfile, UINT Flags1, UINT Flags2, ID3DX10ThreadPump pPump, ID3D10Blob* ppShader, ID3D10Blob* ppErrorMsgs, HRESULT* pHResult);
}

version(Unicode) {
	alias D3DX10CompileFromResourceW D3DX10CompileFromResource;
} else {
	alias D3DX10CompileFromResourceA D3DX10CompileFromResource;
}

extern(Windows) {
	HRESULT D3DX10CompileFromMemory(LPCSTR pSrcData, SIZE_T SrcDataLen, LPCSTR pFileName, D3D10_SHADER_MACRO* pDefines, ID3D10Include pInclude, LPCSTR pFunctionName, LPCSTR pProfile, UINT Flags1, UINT Flags2, ID3DX10ThreadPump pPump, ID3D10Blob* ppShader, ID3D10Blob* ppErrorMsgs, HRESULT* pHResult);
	HRESULT D3DX10CreateEffectFromFileA(LPCSTR pFileName, D3D10_SHADER_MACRO* pDefines, ID3D10Include pInclude, LPCSTR pProfile, UINT HLSLFlags, UINT FXFlags, ID3D10Device pDevice, ID3D10EffectPool pEffectPool, ID3DX10ThreadPump pPump, ID3D10Effect* ppEffect, ID3D10Blob* ppErrors, HRESULT* pHResult);
	HRESULT D3DX10CreateEffectFromFileW(LPCWSTR pFileName, D3D10_SHADER_MACRO* pDefines, ID3D10Include pInclude, LPCSTR pProfile, UINT HLSLFlags, UINT FXFlags, ID3D10Device pDevice, ID3D10EffectPool pEffectPool, ID3DX10ThreadPump pPump, ID3D10Effect* ppEffect, ID3D10Blob* ppErrors, HRESULT* pHResult);
	HRESULT D3DX10CreateEffectFromMemory(LPCVOID pData, SIZE_T DataLength, LPCSTR pSrcFileName, D3D10_SHADER_MACRO* pDefines, ID3D10Include pInclude, LPCSTR pProfile, UINT HLSLFlags, UINT FXFlags, ID3D10Device pDevice, ID3D10EffectPool pEffectPool, ID3DX10ThreadPump pPump, ID3D10Effect* ppEffect, ID3D10Blob* ppErrors, HRESULT* pHResult);
	HRESULT D3DX10CreateEffectFromResourceA(HMODULE hModule, LPCSTR pResourceName, LPCSTR pSrcFileName, D3D10_SHADER_MACRO* pDefines, ID3D10Include pInclude, LPCSTR pProfile, UINT HLSLFlags, UINT FXFlags, ID3D10Device pDevice, ID3D10EffectPool pEffectPool, ID3DX10ThreadPump pPump, ID3D10Effect* ppEffect, ID3D10Blob* ppErrors, HRESULT* pHResult);
	HRESULT D3DX10CreateEffectFromResourceW(HMODULE hModule, LPCWSTR pResourceName, LPCWSTR pSrcFileName, D3D10_SHADER_MACRO* pDefines, ID3D10Include pInclude, LPCSTR pProfile, UINT HLSLFlags, UINT FXFlags, ID3D10Device pDevice, ID3D10EffectPool pEffectPool, ID3DX10ThreadPump pPump, ID3D10Effect* ppEffect, ID3D10Blob* ppErrors, HRESULT* pHResult);
}

version(Unicode) {
	alias D3DX10CreateEffectFromFileW D3DX10CreateEffectFromFile;
	alias D3DX10CreateEffectFromResourceW D3DX10CreateEffectFromResource;
} else {
	alias D3DX10CreateEffectFromFileA D3DX10CreateEffectFromFile;
	alias D3DX10CreateEffectFromResourceA D3DX10CreateEffectFromResource;
}

extern(Windows) {
	HRESULT D3DX10CreateEffectPoolFromFileA(LPCSTR pFileName, D3D10_SHADER_MACRO* pDefines, ID3D10Include pInclude, LPCSTR pProfile, UINT HLSLFlags, UINT FXFlags, ID3D10Device pDevice, ID3DX10ThreadPump pPump, ID3D10EffectPool* ppEffectPool, ID3D10Blob* ppErrors, HRESULT* pHResult);
	HRESULT D3DX10CreateEffectPoolFromFileW(LPCWSTR pFileName, D3D10_SHADER_MACRO* pDefines, ID3D10Include pInclude, LPCSTR pProfile, UINT HLSLFlags, UINT FXFlags, ID3D10Device pDevice, ID3DX10ThreadPump pPump, ID3D10EffectPool* ppEffectPool, ID3D10Blob* ppErrors, HRESULT* pHResult);
	HRESULT D3DX10CreateEffectPoolFromMemory(LPCVOID pData, SIZE_T DataLength, LPCSTR pSrcFileName, D3D10_SHADER_MACRO* pDefines, ID3D10Include pInclude, LPCSTR pProfile, UINT HLSLFlags, UINT FXFlags, ID3D10Device pDevice, ID3DX10ThreadPump pPump, ID3D10EffectPool* ppEffectPool, ID3D10Blob* ppErrors, HRESULT* pHResult);
	HRESULT D3DX10CreateEffectPoolFromResourceA(HMODULE hModule, LPCSTR pResourceName, LPCSTR pSrcFileName, D3D10_SHADER_MACRO* pDefines, ID3D10Include pInclude, LPCSTR pProfile, UINT HLSLFlags, UINT FXFlags, ID3D10Device pDevice, ID3DX10ThreadPump pPump, ID3D10EffectPool* ppEffectPool, ID3D10Blob* ppErrors, HRESULT* pHResult);
	HRESULT D3DX10CreateEffectPoolFromResourceW(HMODULE hModule, LPCWSTR pResourceName, LPCWSTR pSrcFileName, D3D10_SHADER_MACRO* pDefines, ID3D10Include pInclude, LPCSTR pProfile, UINT HLSLFlags, UINT FXFlags, ID3D10Device pDevice, ID3DX10ThreadPump pPump, ID3D10EffectPool* ppEffectPool, ID3D10Blob* ppErrors, HRESULT* pHResult);
}

version(Unicode) {
	alias D3DX10CreateEffectPoolFromFileW D3DX10CreateEffectPoolFromFile;
	alias D3DX10CreateEffectPoolFromResourceW D3DX10CreateEffectPoolFromResource;
} else {
	alias D3DX10CreateEffectPoolFromFileA D3DX10CreateEffectPoolFromFile;
	alias D3DX10CreateEffectPoolFromResourceA D3DX10CreateEffectPoolFromResource;
}

extern(Windows) {
	HRESULT D3DX10PreprocessShaderFromFileA(LPCSTR pFileName, D3D10_SHADER_MACRO* pDefines, ID3D10Include pInclude, ID3DX10ThreadPump pPump, ID3D10Blob* ppShaderText, ID3D10Blob* ppErrorMsgs, HRESULT* pHResult);
	HRESULT D3DX10PreprocessShaderFromFileW(LPCWSTR pFileName, D3D10_SHADER_MACRO* pDefines, ID3D10Include pInclude, ID3DX10ThreadPump pPump, ID3D10Blob* ppShaderText, ID3D10Blob* ppErrorMsgs, HRESULT* pHResult);
	HRESULT D3DX10PreprocessShaderFromMemory(LPCSTR pSrcData, SIZE_T SrcDataSize, LPCSTR pFileName, D3D10_SHADER_MACRO* pDefines, ID3D10Include pInclude, ID3DX10ThreadPump pPump, ID3D10Blob* ppShaderText, ID3D10Blob* ppErrorMsgs, HRESULT* pHResult);
	HRESULT D3DX10PreprocessShaderFromResourceA(HMODULE hModule, LPCSTR pResourceName, LPCSTR pSrcFileName, D3D10_SHADER_MACRO* pDefines, ID3D10Include pInclude, ID3DX10ThreadPump pPump, ID3D10Blob* ppShaderText, ID3D10Blob* ppErrorMsgs, HRESULT* pHResult);
	HRESULT D3DX10PreprocessShaderFromResourceW(HMODULE hModule, LPCWSTR pResourceName, LPCWSTR pSrcFileName, D3D10_SHADER_MACRO* pDefines, ID3D10Include pInclude, ID3DX10ThreadPump pPump, ID3D10Blob* ppShaderText, ID3D10Blob* ppErrorMsgs, HRESULT* pHResult);
}

version(Unicode) {
	alias D3DX10PreprocessShaderFromFileW D3DX10PreprocessShaderFromFile;
	alias D3DX10PreprocessShaderFromResourceW D3DX10PreprocessShaderFromResource;
} else {
	alias D3DX10PreprocessShaderFromFileA D3DX10PreprocessShaderFromFile;
	alias D3DX10PreprocessShaderFromResourceA D3DX10PreprocessShaderFromResource;
}

extern(Windows) {
	HRESULT D3DX10CreateAsyncCompilerProcessor(LPCSTR pFileName, D3D10_SHADER_MACRO* pDefines, ID3D10Include pInclude, LPCSTR pFunctionName, LPCSTR pProfile, UINT Flags1, UINT Flags2, ID3D10Blob* ppCompiledShader, ID3D10Blob* ppErrorBuffer, ID3DX10DataProcessor* ppProcessor);
	HRESULT D3DX10CreateAsyncEffectCreateProcessor(LPCSTR pFileName, D3D10_SHADER_MACRO* pDefines, ID3D10Include pInclude, LPCSTR pProfile, UINT Flags, UINT FXFlags, ID3D10Device pDevice, ID3D10EffectPool pPool, ID3D10Blob* ppErrorBuffer, ID3DX10DataProcessor* ppProcessor);
	HRESULT D3DX10CreateAsyncEffectPoolCreateProcessor(LPCSTR pFileName, D3D10_SHADER_MACRO* pDefines, ID3D10Include pInclude, LPCSTR pProfile, UINT Flags, UINT FXFlags, ID3D10Device pDevice, ID3D10Blob* ppErrorBuffer, ID3DX10DataProcessor* ppProcessor);
	HRESULT D3DX10CreateAsyncShaderPreprocessProcessor(LPCSTR pFileName, D3D10_SHADER_MACRO* pDefines, ID3D10Include pInclude, ID3D10Blob* ppShaderText, ID3D10Blob* ppErrorBuffer, ID3DX10DataProcessor* ppProcessor);
	HRESULT D3DX10CreateAsyncFileLoaderW(LPCWSTR pFileName, ID3DX10DataLoader* ppDataLoader);
	HRESULT D3DX10CreateAsyncFileLoaderA(LPCSTR pFileName, ID3DX10DataLoader* ppDataLoader);
	HRESULT D3DX10CreateAsyncMemoryLoader(LPCVOID pData, SIZE_T cbData, ID3DX10DataLoader* ppDataLoader);
	HRESULT D3DX10CreateAsyncResourceLoaderW(HMODULE hSrcModule, LPCWSTR pSrcResource, ID3DX10DataLoader* ppDataLoader);
	HRESULT D3DX10CreateAsyncResourceLoaderA(HMODULE hSrcModule, LPCSTR pSrcResource, ID3DX10DataLoader* ppDataLoader);
}

version(Unicode) {
	alias D3DX10CreateAsyncFileLoaderW D3DX10CreateAsyncFileLoader;
	alias D3DX10CreateAsyncResourceLoaderW D3DX10CreateAsyncResourceLoader;
} else {
	alias D3DX10CreateAsyncFileLoaderA D3DX10CreateAsyncFileLoader;
	alias D3DX10CreateAsyncResourceLoaderA D3DX10CreateAsyncResourceLoader;
}

extern(Windows) {
	HRESULT D3DX10CreateAsyncTextureProcessor(ID3D10Device pDevice, D3DX10_IMAGE_LOAD_INFO* pLoadInfo, ID3DX10DataProcessor* ppDataProcessor);
	HRESULT D3DX10CreateAsyncTextureInfoProcessor(D3DX10_IMAGE_INFO* pImageInfo, ID3DX10DataProcessor* ppDataProcessor);
	HRESULT D3DX10CreateAsyncShaderResourceViewProcessor(ID3D10Device pDevice, D3DX10_IMAGE_LOAD_INFO* pLoadInfo, ID3DX10DataProcessor* ppDataProcessor);
}
