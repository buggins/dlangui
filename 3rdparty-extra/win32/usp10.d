/* USP - Unicode Complex Script processor
 * http://msdn2.microsoft.com/library/ms776488 */


module win32.usp10;
version(Windows):
import win32.windows;



/* Uniscribe Enumeration Types
 * http://msdn2.microsoft.com/library/ms776518 */

enum : WORD {
	SCRIPT_UNDEFINED = 0,
}

enum : DWORD {
	SGCM_RTL = 0x00000001,
}

enum : DWORD {
	SSA_PASSWORD        = 0x00000001,
	SSA_TAB             = 0x00000002,
	SSA_CLIP            = 0x00000004,
	SSA_FIT             = 0x00000008,
	SSA_DZWG            = 0x00000010,
	SSA_FALLBACK        = 0x00000020,
	SSA_BREAK           = 0x00000040,
	SSA_GLYPHS          = 0x00000080,
	SSA_RTL             = 0x00000100,
	SSA_GCP             = 0x00000200,
	SSA_HOTKEY          = 0x00000400,
	SSA_METAFILE        = 0x00000800,
	SSA_LINK            = 0x00001000,
	SSA_HIDEHOTKEY      = 0x00002000,
	SSA_HOTKEYONLY      = 0x00002400,
	SSA_FULLMEASURE     = 0x04000000,
	SSA_LPKANSIFALLBACK = 0x08000000,
	SSA_PIDX            = 0x10000000,
	SSA_LAYOUTRTL       = 0x20000000,
	SSA_DONTGLYPH       = 0x40000000,
	SSA_NOKASHIDA       = 0x80000000,
}

enum : DWORD {
	SIC_COMPLEX    = 1,
	SIC_ASCIIDIGIT = 2,
	SIC_NEUTRAL    = 4,
}

enum : DWORD {
	SCRIPT_DIGITSUBSTITUTE_CONTEXT,
	SCRIPT_DIGITSUBSTITUTE_NONE,
	SCRIPT_DIGITSUBSTITUTE_NATIONAL,
	SCRIPT_DIGITSUBSTITUTE_TRADITIONAL,
}

enum SCRIPT_JUSTIFY : WORD {
    SCRIPT_JUSTIFY_NONE,
    SCRIPT_JUSTIFY_ARABIC_BLANK,
    SCRIPT_JUSTIFY_CHARACTER,
    SCRIPT_JUSTIFY_RESERVED1,
    SCRIPT_JUSTIFY_BLANK,
    SCRIPT_JUSTIFY_RESERVED2,
    SCRIPT_JUSTIFY_RESERVED3,
    SCRIPT_JUSTIFY_ARABIC_NORMAL,
    SCRIPT_JUSTIFY_ARABIC_KASHIDA,
    SCRIPT_JUSTIFY_ARABIC_ALEF,
    SCRIPT_JUSTIFY_ARABIC_HA,
    SCRIPT_JUSTIFY_ARABIC_RA,
    SCRIPT_JUSTIFY_ARABIC_BA,
    SCRIPT_JUSTIFY_ARABIC_BARA,
    SCRIPT_JUSTIFY_ARABIC_SEEN,
    SCRIPT_JUSTIFY_ARABIC_SEEN_M,
}



/* Uniscribe Structures
 * http://msdn2.microsoft.com/library/ms776479 */

alias void* SCRIPT_CACHE;
alias void* SCRIPT_STRING_ANALYSIS;

extern (C)
{
	struct SCRIPT_CONTROL
	{
		private DWORD _bitfield;
		DWORD uDefaultLanguage()             { return (_bitfield >> 0) & 0xFFFF; }
		DWORD uDefaultLanguage(DWORD val)    { _bitfield = cast(DWORD)((_bitfield & 0xFFFFFFFFFFFF0000) | (val << 0)); return val; }
		DWORD fContextDigits()               { return (_bitfield >> 16) & 0x1; }
		DWORD fContextDigits(DWORD val)      { _bitfield = cast(DWORD)((_bitfield & 0xFFFFFFFFFFFEFFFF) | (val << 16)); return val; }
		DWORD fInvertPreBoundDir()           { return (_bitfield >> 17) & 0x1; }
		DWORD fInvertPreBoundDir(DWORD val)  { _bitfield = cast(DWORD)((_bitfield & 0xFFFFFFFFFFFDFFFF) | (val << 17)); return val; }
		DWORD fInvertPostBoundDir()          { return (_bitfield >> 18) & 0x1; }
		DWORD fInvertPostBoundDir(DWORD val) { _bitfield = cast(DWORD)((_bitfield & 0xFFFFFFFFFFFBFFFF) | (val << 18)); return val; }
		DWORD fLinkStringBefore()            { return (_bitfield >> 19) & 0x1; }
		DWORD fLinkStringBefore(DWORD val)   { _bitfield = cast(DWORD)((_bitfield & 0xFFFFFFFFFFF7FFFF) | (val << 19)); return val; }
		DWORD fLinkStringAfter()             { return (_bitfield >> 20) & 0x1; }
		DWORD fLinkStringAfter(DWORD val)    { _bitfield = cast(DWORD)((_bitfield & 0xFFFFFFFFFFEFFFFF) | (val << 20)); return val; }
		DWORD fNeutralOverride()             { return (_bitfield >> 21) & 0x1; }
		DWORD fNeutralOverride(DWORD val)    { _bitfield = cast(DWORD)((_bitfield & 0xFFFFFFFFFFDFFFFF) | (val << 21)); return val; }
		DWORD fNumericOverride()             { return (_bitfield >> 22) & 0x1; }
		DWORD fNumericOverride(DWORD val)    { _bitfield = cast(DWORD)((_bitfield & 0xFFFFFFFFFFBFFFFF) | (val << 22)); return val; }
		DWORD fLegacyBidiClass()             { return (_bitfield >> 23) & 0x1; }
		DWORD fLegacyBidiClass(DWORD val)    { _bitfield = cast(DWORD)((_bitfield & 0xFFFFFFFFFF7FFFFF) | (val << 23)); return val; }
		DWORD fReserved()                    { return (_bitfield >> 24) & 0xFF; }
		DWORD fReserved(DWORD val)           { _bitfield = cast(DWORD)((_bitfield & 0xFFFFFFFF00FFFFFF) | (val << 24)); return val; }
	}

	struct SCRIPT_STATE
	{
		private WORD _bitfield;
		WORD uBidiLevel()                 { return cast(WORD)((_bitfield >> 0) & 0x1F); }
		WORD uBidiLevel(WORD val)         { _bitfield = cast(WORD)((_bitfield & 0xFFFFFFFFFFFFFFE0) | (val << 0)); return val; }
		WORD fOverrideDirection()         { return cast(WORD)((_bitfield >> 5) & 0x1); }
		WORD fOverrideDirection(WORD val) { _bitfield = cast(WORD)((_bitfield & 0xFFFFFFFFFFFFFFDF) | (val << 5)); return val; }
		WORD fInhibitSymSwap()            { return cast(WORD)((_bitfield >> 6) & 0x1); }
		WORD fInhibitSymSwap(WORD val)    { _bitfield = cast(WORD)((_bitfield & 0xFFFFFFFFFFFFFFBF) | (val << 6)); return val; }
		WORD fCharShape()                 { return cast(WORD)((_bitfield >> 7) & 0x1); }
		WORD fCharShape(WORD val)         { _bitfield = cast(WORD)((_bitfield & 0xFFFFFFFFFFFFFF7F) | (val << 7)); return val; }
		WORD fDigitSubstitute()           { return cast(WORD)((_bitfield >> 8) & 0x1); }
		WORD fDigitSubstitute(WORD val)   { _bitfield = cast(WORD)((_bitfield & 0xFFFFFFFFFFFFFEFF) | (val << 8)); return val; }
		WORD fInhibitLigate()             { return cast(WORD)((_bitfield >> 9) & 0x1); }
		WORD fInhibitLigate(WORD val)     { _bitfield = cast(WORD)((_bitfield & 0xFFFFFFFFFFFFFDFF) | (val << 9)); return val; }
		WORD fDisplayZWG()                { return cast(WORD)((_bitfield >> 10) & 0x1); }
		WORD fDisplayZWG(WORD val)        { _bitfield = cast(WORD)((_bitfield & 0xFFFFFFFFFFFFFBFF) | (val << 10)); return val; }
		WORD fArabicNumContext()          { return cast(WORD)((_bitfield >> 11) & 0x1); }
		WORD fArabicNumContext(WORD val)  { _bitfield = cast(WORD)((_bitfield & 0xFFFFFFFFFFFFF7FF) | (val << 11)); return val; }
		WORD fGcpClusters()               { return cast(WORD)((_bitfield >> 12) & 0x1); }
		WORD fGcpClusters(WORD val)       { _bitfield = cast(WORD)((_bitfield & 0xFFFFFFFFFFFFEFFF) | (val << 12)); return val; }
		WORD fReserved()                  { return cast(WORD)((_bitfield >> 13) & 0x1); }
		WORD fReserved(WORD val)          { _bitfield = cast(WORD)((_bitfield & 0xFFFFFFFFFFFFDFFF) | (val << 13)); return val; }
		WORD fEngineReserved()            { return cast(WORD)((_bitfield >> 14) & 0x3); }
		WORD fEngineReserved(WORD val)    { _bitfield = cast(WORD)((_bitfield & 0xFFFFFFFFFFFF3FFF) | (val << 14)); return val; }
	}


	struct SCRIPT_ANALYSIS
	{
		private WORD _bitfield;
		WORD eScript()               { return cast(WORD)((_bitfield >> 0) & 0x3FF); }
		WORD eScript(WORD val)       { _bitfield = cast(WORD)((_bitfield & 0xFFFFFFFFFFFFFC00) | (val << 0)); return val; }
		WORD fRTL()                  { return cast(WORD)((_bitfield >> 10) & 0x1); }
		WORD fRTL(WORD val)          { _bitfield = cast(WORD)((_bitfield & 0xFFFFFFFFFFFFFBFF) | (val << 10)); return val; }
		WORD fLayoutRTL()            { return cast(WORD)((_bitfield >> 11) & 0x1); }
		WORD fLayoutRTL(WORD val)    { _bitfield = cast(WORD)((_bitfield & 0xFFFFFFFFFFFFF7FF) | (val << 11)); return val; }
		WORD fLinkBefore()           { return cast(WORD)((_bitfield >> 12) & 0x1); }
		WORD fLinkBefore(WORD val)   { _bitfield = cast(WORD)((_bitfield & 0xFFFFFFFFFFFFEFFF) | (val << 12)); return val; }
		WORD fLinkAfter()            { return cast(WORD)((_bitfield >> 13) & 0x1); }
		WORD fLinkAfter(WORD val)    { _bitfield = cast(WORD)((_bitfield & 0xFFFFFFFFFFFFDFFF) | (val << 13)); return val; }
		WORD fLogicalOrder()         { return cast(WORD)((_bitfield >> 14) & 0x1); }
		WORD fLogicalOrder(WORD val) { _bitfield = cast(WORD)((_bitfield & 0xFFFFFFFFFFFFBFFF) | (val << 14)); return val; }
		WORD fNoGlyphIndex()         { return cast(WORD)((_bitfield >> 15) & 0x1); }
		WORD fNoGlyphIndex(WORD val) { _bitfield = cast(WORD)((_bitfield & 0xFFFFFFFFFFFF7FFF) | (val << 15)); return val; }
		SCRIPT_STATE s;
	}


	struct SCRIPT_ITEM
	{
		int iCharPos;
		SCRIPT_ANALYSIS a;
	}

	struct SCRIPT_VISATTR
	{
		private WORD _bitfield;
		WORD uJustification()         { return cast(WORD)((_bitfield >> 0) & 0xF); }
		WORD uJustification(WORD val) { _bitfield = cast(WORD)((_bitfield & 0xFFFFFFFFFFFFFFF0) | (val << 0)); return val; }
		WORD fClusterStart()          { return cast(WORD)((_bitfield >> 4) & 0x1); }
		WORD fClusterStart(WORD val)  { _bitfield = cast(WORD)((_bitfield & 0xFFFFFFFFFFFFFFEF) | (val << 4)); return val; }
		WORD fDiacritic()             { return cast(WORD)((_bitfield >> 5) & 0x1); }
		WORD fDiacritic(WORD val)     { _bitfield = cast(WORD)((_bitfield & 0xFFFFFFFFFFFFFFDF) | (val << 5)); return val; }
		WORD fZeroWidth()             { return cast(WORD)((_bitfield >> 6) & 0x1); }
		WORD fZeroWidth(WORD val)     { _bitfield = cast(WORD)((_bitfield & 0xFFFFFFFFFFFFFFBF) | (val << 6)); return val; }
		WORD fReserved()              { return cast(WORD)((_bitfield >> 7) & 0x1); }
		WORD fReserved(WORD val)      { _bitfield = cast(WORD)((_bitfield & 0xFFFFFFFFFFFFFF7F) | (val << 7)); return val; }
		WORD fShapeReserved()         { return cast(WORD)((_bitfield >> 8) & 0xFF); }
		WORD fShapeReserved(WORD val) { _bitfield = cast(WORD)((_bitfield & 0xFFFFFFFFFFFF00FF) | (val << 8)); return val; }
	}

	struct GOFFSET
	{
		LONG du;
		LONG dv;
	}

	struct SCRIPT_LOGATTR
	{
		BYTE _bitfield;
		BYTE fSoftBreak()          { return cast(BYTE)((_bitfield >> 0) & 0x1); }
		BYTE fSoftBreak(BYTE val)  { _bitfield = cast(BYTE)((_bitfield & 0xFFFFFFFFFFFFFFFE) | (val << 0)); return val; }
		BYTE fWhiteSpace()         { return cast(BYTE)((_bitfield >> 1) & 0x1); }
		BYTE fWhiteSpace(BYTE val) { _bitfield = cast(BYTE)((_bitfield & 0xFFFFFFFFFFFFFFFD) | (val << 1)); return val; }
		BYTE fCharStop()           { return cast(BYTE)((_bitfield >> 2) & 0x1); }
		BYTE fCharStop(BYTE val)   { _bitfield = cast(BYTE)((_bitfield & 0xFFFFFFFFFFFFFFFB) | (val << 2)); return val; }
		BYTE fWordStop()           { return cast(BYTE)((_bitfield >> 3) & 0x1); }
		BYTE fWordStop(BYTE val)   { _bitfield = cast(BYTE)((_bitfield & 0xFFFFFFFFFFFFFFF7) | (val << 3)); return val; }
		BYTE fInvalid()            { return cast(BYTE)((_bitfield >> 4) & 0x1); }
		BYTE fInvalid(BYTE val)    { _bitfield = cast(BYTE)((_bitfield & 0xFFFFFFFFFFFFFFEF) | (val << 4)); return val; }
		BYTE fReserved()           { return cast(BYTE)((_bitfield >> 5) & 0x7); }
		BYTE fReserved(BYTE val)   { _bitfield = cast(BYTE)((_bitfield & 0xFFFFFFFFFFFFFF1F) | (val << 5)); return val; }
	}

	struct SCRIPT_PROPERTIES
	{
		private DWORD _bitfield1;
		DWORD langid()                          { return (_bitfield1 >> 0) & 0xFFFF; }
		DWORD langid(DWORD val)                 { _bitfield1 = cast(DWORD)((_bitfield1 & 0xFFFFFFFFFFFF0000) | (val << 0)); return val; }
		DWORD fNumeric()                        { return (_bitfield1 >> 16) & 0x1; }
		DWORD fNumeric(DWORD val)               { _bitfield1 = cast(DWORD)((_bitfield1 & 0xFFFFFFFFFFFEFFFF) | (val << 16)); return val; }
		DWORD fComplex()                        { return (_bitfield1 >> 17) & 0x1; }
		DWORD fComplex(DWORD val)               { _bitfield1 = cast(DWORD)((_bitfield1 & 0xFFFFFFFFFFFDFFFF) | (val << 17)); return val; }
		DWORD fNeedsWordBreaking()              { return (_bitfield1 >> 18) & 0x1; }
		DWORD fNeedsWordBreaking(DWORD val)     { _bitfield1 = cast(DWORD)((_bitfield1 & 0xFFFFFFFFFFFBFFFF) | (val << 18)); return val; }
		DWORD fNeedsCaretInfo()                 { return (_bitfield1 >> 19) & 0x1; }
		DWORD fNeedsCaretInfo(DWORD val)        { _bitfield1 = cast(DWORD)((_bitfield1 & 0xFFFFFFFFFFF7FFFF) | (val << 19)); return val; }
		DWORD bCharSet()                        { return (_bitfield1 >> 20) & 0xFF; }
		DWORD bCharSet(DWORD val)               { _bitfield1 = cast(DWORD)((_bitfield1 & 0xFFFFFFFFF00FFFFF) | (val << 20)); return val; }
		DWORD fControl()                        { return (_bitfield1 >> 28) & 0x1; }
		DWORD fControl(DWORD val)               { _bitfield1 = cast(DWORD)((_bitfield1 & 0xFFFFFFFFEFFFFFFF) | (val << 28)); return val; }
		DWORD fPrivateUseArea()                 { return (_bitfield1 >> 29) & 0x1; }
		DWORD fPrivateUseArea(DWORD val)        { _bitfield1 = cast(DWORD)((_bitfield1 & 0xFFFFFFFFDFFFFFFF) | (val << 29)); return val; }
		DWORD fNeedsCharacterJustify()          { return (_bitfield1 >> 30) & 0x1; }
		DWORD fNeedsCharacterJustify(DWORD val) { _bitfield1 = cast(DWORD)((_bitfield1 & 0xFFFFFFFFBFFFFFFF) | (val << 30)); return val; }
		DWORD fInvalidGlyph()                   { return (_bitfield1 >> 31) & 0x1; }
		DWORD fInvalidGlyph(DWORD val)          { _bitfield1 = cast(DWORD)((_bitfield1 & 0xFFFFFFFF7FFFFFFF) | (val << 31)); return val; }
		private DWORD _bitfield2;
		DWORD fInvalidLogAttr()                 { return (_bitfield2 >> 0) & 0x1; }
		DWORD fInvalidLogAttr(DWORD val)        { _bitfield2 = cast(DWORD)((_bitfield2 & 0xFFFFFFFFFFFFFFFE) | (val << 0)); return val; }
		DWORD fCDM()                            { return (_bitfield2 >> 1) & 0x1; }
		DWORD fCDM(DWORD val)                   { _bitfield2 = cast(DWORD)((_bitfield2 & 0xFFFFFFFFFFFFFFFD) | (val << 1)); return val; }
		DWORD fAmbiguousCharSet()               { return (_bitfield2 >> 2) & 0x1; }
		DWORD fAmbiguousCharSet(DWORD val)      { _bitfield2 = cast(DWORD)((_bitfield2 & 0xFFFFFFFFFFFFFFFB) | (val << 2)); return val; }
		DWORD fClusterSizeVaries()              { return (_bitfield2 >> 3) & 0x1; }
		DWORD fClusterSizeVaries(DWORD val)     { _bitfield2 = cast(DWORD)((_bitfield2 & 0xFFFFFFFFFFFFFFF7) | (val << 3)); return val; }
		DWORD fRejectInvalid()                  { return (_bitfield2 >> 4) & 0x1; }
		DWORD fRejectInvalid(DWORD val)         { _bitfield2 = cast(DWORD)((_bitfield2 & 0xFFFFFFFFFFFFFFEF) | (val << 4)); return val; }
	}

	struct SCRIPT_FONTPROPERTIES
	{
		int cBytes = SCRIPT_FONTPROPERTIES.sizeof;
		WORD wgBlank;
		WORD wgDefault;
		WORD wgInvalid;
		WORD wgKashida;
		int iKashidaWidth;
	}

	struct SCRIPT_TABDEF
	{
		int cTabStops;
		int iScale;
		int* pTabStops;
		int iTabOrigin;
	}

	struct SCRIPT_DIGITSUBSTITUTE
	{
		private DWORD _bitfield1;
		DWORD NationalDigitLanguage()             { return (_bitfield1 >> 0) & 0xFFFF; }
		DWORD NationalDigitLanguage(DWORD val)    { _bitfield1 = cast(DWORD)((_bitfield1 & 0xFFFFFFFFFFFF0000) | (val << 0)); return val; }
		DWORD TraditionalDigitLanguage()          { return (_bitfield1 >> 16) & 0xFFFF; }
		DWORD TraditionalDigitLanguage(DWORD val) { _bitfield1 = cast(DWORD)((_bitfield1 & 0xFFFFFFFF0000FFFF) | (val << 16)); return val; }
		private DWORD _bitfield2;
		DWORD DigitSubstitute()                   { return (_bitfield2 >> 0) & 0xFF; }
		DWORD DigitSubstitute(DWORD val)          { _bitfield2 = cast(DWORD)((_bitfield2 & 0xFFFFFFFFFFFFFF00) | (val << 0)); return val; }
		DWORD dwReserved;
	}

	/* TODO: Windows Vista fearured structs
	OPENTYPE_FEATURE_RECORD
	OPENTYPE_TAG
	SCRIPT_CHARPROP
	SCRIPT_GLYPHPROP
	TEXTRANGE_PROPERTIES
	*/
}


/* Uniscribe Functions
 * http://msdn2.microsoft.com/library/ms776469 */
extern (Windows)
{
	HRESULT ScriptFreeCache(SCRIPT_CACHE*);
	HRESULT ScriptItemize(const(WCHAR)*, int, int, const(SCRIPT_CONTROL)*, const(SCRIPT_STATE)*, SCRIPT_ITEM*, int*);
	HRESULT ScriptLayout(int, const(BYTE)*, int*, int*);
	HRESULT ScriptShape(HDC, SCRIPT_CACHE*, const(WCHAR)*, int, int, SCRIPT_ANALYSIS*, WORD*, WORD*, SCRIPT_VISATTR*, int*);
	HRESULT ScriptPlace(HDC, SCRIPT_CACHE*, const(WORD)*, int, const(SCRIPT_VISATTR)*, SCRIPT_ANALYSIS*, int*, GOFFSET*, ABC*);
	HRESULT ScriptTextOut(HDC, SCRIPT_CACHE*, int, int, UINT, const(RECT)*, const(SCRIPT_ANALYSIS)*, const(WCHAR)*, int, const(WORD)*, int, const(int)*, int*, const(GOFFSET)*);
	HRESULT ScriptJustify(const(SCRIPT_VISATTR)*, const(int)*, int, int, int, int*);
	HRESULT ScriptBreak(const(WCHAR)*, int, const(SCRIPT_ANALYSIS)*, const(SCRIPT_LOGATTR)*);
	HRESULT ScriptCPtoX(int, BOOL, int, int, const(WORD)*, const(SCRIPT_VISATTR)*, const(int)*, const(SCRIPT_ANALYSIS)*, int*);
	HRESULT ScriptXtoCP(int, int, int, const(WORD)*, const(SCRIPT_VISATTR)*, const(int)*, const(SCRIPT_ANALYSIS)*, int*, int*);
	HRESULT ScriptGetLogicalWidths(const(SCRIPT_ANALYSIS)*, int, int, const(int)*, const(WORD)*, const(SCRIPT_VISATTR)*, int*);
	HRESULT ScriptApplyLogicalWidth(const(int)*, int, int, const(WORD)*, const(SCRIPT_VISATTR)*, const(int)*, const(SCRIPT_ANALYSIS)*, ABC*, int*);
	HRESULT ScriptGetCMap(HDC, SCRIPT_CACHE*, const(WCHAR)*, int, DWORD, WORD*);
	HRESULT ScriptGetGlyphABCWidth(HDC, SCRIPT_CACHE*, WORD, ABC*);
	HRESULT ScriptGetProperties(const(SCRIPT_PROPERTIES**)*, int*);
	HRESULT ScriptGetFontProperties(HDC, SCRIPT_CACHE*, SCRIPT_FONTPROPERTIES*);
	HRESULT ScriptCacheGetHeight(HDC, SCRIPT_CACHE*, int*);
	HRESULT ScriptIsComplex(const(WCHAR)*, int, DWORD);
	HRESULT ScriptRecordDigitSubstitution(LCID, SCRIPT_DIGITSUBSTITUTE*);
	HRESULT ScriptApplyDigitSubstitution(const(SCRIPT_DIGITSUBSTITUTE)*, SCRIPT_CONTROL*, SCRIPT_STATE*);

	/* ScriptString Functions
	 * http://msdn2.microsoft.com/library/ms776485 */
	HRESULT ScriptStringAnalyse(HDC, const(void)*, int, int, int, DWORD, int, SCRIPT_CONTROL*, SCRIPT_STATE*, const(int)*, SCRIPT_TABDEF*, const(BYTE)*, SCRIPT_STRING_ANALYSIS*);
	HRESULT ScriptStringFree(SCRIPT_STRING_ANALYSIS*);
	const(SIZE)* ScriptString_pSize(SCRIPT_STRING_ANALYSIS);
	const(int)* ScriptString_pcOutChars(SCRIPT_STRING_ANALYSIS);
	const(SCRIPT_LOGATTR)* ScriptString_pLogAttr(SCRIPT_STRING_ANALYSIS);
	HRESULT ScriptStringGetOrder(SCRIPT_STRING_ANALYSIS, UINT*);
	HRESULT ScriptStringCPtoX(SCRIPT_STRING_ANALYSIS, int, BOOL, int*);
	HRESULT ScriptStringXtoCP(SCRIPT_STRING_ANALYSIS, int, int*, int*);
	HRESULT ScriptStringGetLogicalWidths(SCRIPT_STRING_ANALYSIS, int*);
	HRESULT ScriptStringValidate(SCRIPT_STRING_ANALYSIS);
	HRESULT ScriptStringOut(SCRIPT_STRING_ANALYSIS, int, int, UINT, const(RECT)*, int, int, BOOL);

	/* TODO: Windows Vista fearured functions
	ScriptGetFontAlternateGlyphs()
	ScriptGetFontFeatureTags()
	ScriptGetFontLanguageTags()
	ScriptGetFontScriptTags()
	ScriptItemizeOpenType()
	ScriptPlaceOpenType()
	ScriptPositionSingleGlyph()
	ScriptShapeOpenType()
	ScriptSubstituteSingleGlyph()
	*/
}
