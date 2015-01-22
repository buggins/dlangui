<?xml version="1.0" encoding="utf-8"?>
<!--
Copyright (C) 2004 Josh Triplett.  All Rights Reserved.

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

Except as contained in this notice, the names of the authors or their
institutions shall not be used in advertising or otherwise to promote the
sale, use or other dealings in this Software without prior written
authorization from the authors.
-->
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
               version="1.0"
               xmlns:e="http://exslt.org/common"
               xmlns:func="http://exslt.org/functions"
               xmlns:str="http://exslt.org/strings"
               xmlns:xcb="http://xcb.freedesktop.org"
               extension-element-prefixes="func str xcb">
  
  <xsl:output method="text" />

  <xsl:strip-space elements="*" />

  <!-- "header" or "source" -->
  <xsl:param name="mode" />

  <!-- Path to the core protocol descriptions. -->
  <xsl:param name="base-path" />

  <!-- Path to the extension protocol descriptions. -->
  <xsl:param name="extension-path" select="$base-path" />

  <xsl:variable name="h" select="$mode = 'header'" />
  <xsl:variable name="c" select="$mode = 'source'" />

  <xsl:variable name="need-string-h" select="//request/pad[@bytes != 1]" />
  
  <!-- String used to indent lines of code. -->
  <xsl:variable name="indent-string" select="'    '" />

  <xsl:variable name="ucase" select="'ABCDEFGHIJKLMNOPQRSTUVWXYZ'" />
  <xsl:variable name="lcase" select="'abcdefghijklmnopqrstuvwxyz'" />
  <xsl:variable name="letters" select="concat($ucase, $lcase)" />
  <xsl:variable name="digits" select="'0123456789'" />

  <xsl:variable name="header" select="/xcb/@header" />
  <xsl:variable name="ucase-header"
                select="translate($header,$lcase,$ucase)" />

  <xsl:variable name="ext" select="/xcb/@extension-name" />

  <!-- Other protocol descriptions to search for types in, after checking the
       current protocol description. -->
  <xsl:variable name="search-path-rtf">
    <xsl:for-each select="/xcb/import">
      <path><xsl:value-of select="concat($extension-path, ., '.xml')" /></path>
    </xsl:for-each>
  </xsl:variable>
  <xsl:variable name="search-path" select="e:node-set($search-path-rtf)/path"/>

  <xsl:variable name="root" select="/" />
  
  <!-- First pass: Store everything in a variable. -->
  <xsl:variable name="pass1-rtf">
    <xsl:apply-templates select="/" mode="pass1" />
  </xsl:variable>
  <xsl:variable name="pass1" select="e:node-set($pass1-rtf)" />
  
  <xsl:template match="xcb" mode="pass1">
    <xcb>
      <xsl:copy-of select="@*" />
      <xsl:if test="$ext">
        <constant type="xcb_extension_t" name="{xcb:xcb-prefix()}_id">
          <xsl:attribute name="value">{ "<xsl:value-of select="@extension-xname" />" }</xsl:attribute>
        </constant>
      </xsl:if>
      <xsl:apply-templates mode="pass1" />
    </xcb>
  </xsl:template>

  <func:function name="xcb:xcb-prefix">
    <xsl:param name="name" />
    <func:result>
      <xsl:text>xcb</xsl:text>
      <xsl:choose>
        <xsl:when test="/xcb/@extension-name = 'RandR'">
          <xsl:text>_randr</xsl:text>
        </xsl:when>
        <xsl:when test="/xcb/@extension-name = 'ScreenSaver'">
          <xsl:text>_screensaver</xsl:text>
        </xsl:when>
        <xsl:when test="/xcb/@extension-name = 'XF86Dri'">
          <xsl:text>_xf86dri</xsl:text>
        </xsl:when>
        <xsl:when test="/xcb/@extension-name = 'XFixes'">
          <xsl:text>_xfixes</xsl:text>
        </xsl:when>
        <xsl:when test="/xcb/@extension-name = 'XvMC'">
          <xsl:text>_xvmc</xsl:text>
        </xsl:when>
        <xsl:when test="/xcb/@extension-name">
          <xsl:text>_</xsl:text>
          <xsl:call-template name="camelcase-to-underscore">
            <xsl:with-param name="camelcase" select="/xcb/@extension-name" />
          </xsl:call-template>
        </xsl:when>
        <xsl:otherwise>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:if test="$name">
        <xsl:text>_</xsl:text>
        <xsl:call-template name="camelcase-to-underscore">
          <xsl:with-param name="camelcase" select="$name" />
        </xsl:call-template>
      </xsl:if>
    </func:result>
  </func:function>

  <func:function name="xcb:lowercase">
    <xsl:param name="name" />
    <func:result>
      <xsl:call-template name="camelcase-to-underscore">
        <xsl:with-param name="camelcase" select="$name" />
      </xsl:call-template>
    </func:result>
  </func:function>

  <func:function name="xcb:get-char-void">
    <xsl:param name="name" />
    <xsl:variable name="ctype" select="substring-before($name, '_t')" />
    <func:result>
      <xsl:choose>
        <xsl:when test="$ctype = 'char' or $ctype = 'void' or $ctype = 'float' or $ctype = 'double'">
          <xsl:value-of select="$ctype" />    
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$name" />
        </xsl:otherwise>
      </xsl:choose>
    </func:result>
  </func:function>

  <func:function name="xcb:remove-void">
    <xsl:param name="name" />
    <xsl:variable name="ctype" select="substring-before($name, '_t')" />
    <func:result>
      <xsl:choose>
        <xsl:when test="$ctype = 'char' or $ctype = 'void' or $ctype = 'float' or $ctype = 'double'">
          <xsl:choose>
            <xsl:when test="$ctype = 'void'">
              <xsl:text>char</xsl:text>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="$ctype" />
            </xsl:otherwise>
          </xsl:choose>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$name" />
        </xsl:otherwise>
      </xsl:choose>
    </func:result>
  </func:function>

  <!-- split camel case into words and insert underscore -->
  <xsl:template name="camelcase-to-underscore">
    <xsl:param name="camelcase"/>
    <xsl:choose>
      <xsl:when test="$camelcase='CHAR2B' or $camelcase='INT64'
                      or $camelcase='FLOAT32' or $camelcase='FLOAT64'
                      or $camelcase='BOOL32' or $camelcase='STRING8'
                      or $camelcase='Family_DECnet'">
        <xsl:value-of select="translate($camelcase, $ucase, $lcase)"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:for-each select="str:split($camelcase, '')">
          <xsl:variable name="a" select="."/>
          <xsl:variable name="b" select="following::*[1]"/>
          <xsl:variable name="c" select="following::*[2]"/>
          <xsl:value-of select="translate(., $ucase, $lcase)"/>
          <xsl:if test="($b and contains($lcase, $a) and contains($ucase, $b))
                        or ($b and contains($digits, $a)
                            and contains($letters, $b))
                        or ($b and contains($letters, $a)
                            and contains($digits, $b))
                        or ($c and contains($ucase, $a)
                            and contains($ucase, $b)
                            and contains($lcase, $c))">
            <xsl:text>_</xsl:text>
          </xsl:if>
        </xsl:for-each>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- Modify names that conflict with C++ keywords by prefixing them with an
       underscore.  If the name parameter is not specified, it defaults to the
       value of the name attribute on the context node. -->
  <xsl:template name="canonical-var-name">
    <xsl:param name="name" select="@name" />
    <xsl:if test="$name='new' or $name='delete'
                  or $name='class' or $name='operator'">
      <xsl:text>_</xsl:text>
    </xsl:if>
    <xsl:value-of select="$name" />
  </xsl:template>

  <!-- List of core types, for use in canonical-type-name. -->
  <xsl:variable name="core-types-rtf">
    <type name="BOOL" newname="bool" />
    <type name="BYTE" newname="ubyte" />
    <type name="CARD8" newname="ubyte" />
    <type name="CARD16" newname="ushort" />
    <type name="CARD32" newname="uint" />
    <type name="INT8" newname="byte" />
    <type name="INT16" newname="short" />
    <type name="INT32" newname="int" />

    <type name="char" newname="char" />
    <type name="void" newname="void" />
    <type name="float" newname="float" />
    <type name="double" newname="double" />
  </xsl:variable>
  <xsl:variable name="core-types" select="e:node-set($core-types-rtf)" />

  <!--
    Output the canonical name for a type.  This will be
    xcb_{extension-containing-type-if-any}_type, wherever the type is found in
    the search path, or just type if not found.  If the type parameter is not
    specified, it defaults to the value of the type attribute on the context
    node.
  -->
  <xsl:template name="canonical-type-name">
    <xsl:param name="type" select="string(@type)" />

    <xsl:variable name="is-unqualified" select="not(contains($type, ':'))"/>
    <xsl:variable name="namespace" select="substring-before($type, ':')" />
    <xsl:variable name="unqualified-type">
      <xsl:choose>
        <xsl:when test="$is-unqualified">
          <xsl:value-of select="$type" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="substring-after($type, ':')" />
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:choose>
      <xsl:when test="$is-unqualified and $core-types/type[@name=$type]">
        <xsl:value-of select="$core-types/type[@name=$type]/@newname" />
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="type-definitions"
                      select="(/xcb|document($search-path)/xcb
                              )[$is-unqualified or @header=$namespace]
                               /*[((self::struct or self::union or self::enum
                                    or self::xidtype or self::xidunion
                                    or self::event or self::eventcopy
                                    or self::error or self::errorcopy)
                                   and @name=$unqualified-type)
                                  or (self::typedef
                                      and @newname=$unqualified-type)]" />
        <xsl:choose>
          <xsl:when test="count($type-definitions) = 1">
            <xsl:for-each select="$type-definitions">
              <xsl:value-of select="xcb:xcb-prefix($unqualified-type)" />
            </xsl:for-each>
          </xsl:when>
          <xsl:when test="count($type-definitions) > 1">
            <xsl:message terminate="yes">
              <xsl:text>Multiple definitions of type "</xsl:text>
              <xsl:value-of select="$type" />
              <xsl:text>" found.</xsl:text>
              <xsl:if test="$is-unqualified">
                <xsl:for-each select="$type-definitions">
                  <xsl:text>
    </xsl:text>
                  <xsl:value-of select="concat(/xcb/@header, ':', $type)" />
                </xsl:for-each>
              </xsl:if>
            </xsl:message>
          </xsl:when>
          <xsl:otherwise>
            <xsl:message terminate="yes">
              <xsl:text>No definitions of type "</xsl:text>
              <xsl:value-of select="$type" />
              <xsl:text>" found</xsl:text>
              <xsl:if test="$is-unqualified">
                <xsl:text>, and it is not a known core type</xsl:text>
              </xsl:if>
              <xsl:text>.</xsl:text>
            </xsl:message>
          </xsl:otherwise>
        </xsl:choose> 	
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <!-- Helper template for requests, that outputs the cookie type.  The
       parameter "request" must be the request node, which defaults to the
       context node. -->
  <xsl:template name="cookie-type">
    <xsl:param name="request" select="." />
    <xsl:choose>
      <xsl:when test="$request/reply">
        <xsl:value-of select="xcb:xcb-prefix($request/@name)" />
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>xcb_void</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:text>_cookie_t</xsl:text>
  </xsl:template>

  <xsl:template name="request-function">
    <xsl:param name="checked" />
    <xsl:param name="req" />
    <function>
      <xsl:attribute name="name">
        <xsl:value-of select="xcb:xcb-prefix($req/@name)" />
        <xsl:if test="$checked='true' and not($req/reply)">_checked</xsl:if>
        <xsl:if test="$checked='false' and $req/reply">_unchecked</xsl:if>
      </xsl:attribute>
      <xsl:attribute name="type">
        <xsl:call-template name="cookie-type">
          <xsl:with-param name="request" select="$req" />
        </xsl:call-template>
      </xsl:attribute>
      <field type="xcb_connection_t *" name="c" />
      <xsl:apply-templates select="$req/*[not(self::reply)]" mode="param" />
      <do-request ref="{xcb:xcb-prefix($req/@name)}_request_t" opcode="{translate(xcb:xcb-prefix($req/@name), $lcase, $ucase)}"
                  checked="{$checked}">
        <xsl:if test="$req/reply">
          <xsl:attribute name="has-reply">true</xsl:attribute>
        </xsl:if>
      </do-request>
    </function>
  </xsl:template>
  
  <xsl:template match="request" mode="pass1">
    <xsl:variable name="req" select="." />
    <xsl:if test="reply">
      <struct name="{xcb:xcb-prefix(@name)}_cookie_t">
        <field type="uint" name="sequence" />
      </struct>
    </xsl:if>
    <constant type="number" name="{xcb:xcb-prefix($req/@name)}" value="{$req/@opcode}" />
    <struct name="{xcb:xcb-prefix(@name)}_request_t">
      <field type="ubyte" name="major_opcode" no-assign="true" />
      <xsl:if test="$ext">
        <field type="ubyte" name="minor_opcode" no-assign="true" />
      </xsl:if>
      <xsl:apply-templates select="*[not(self::reply)]" mode="field" />
      <middle>
        <field type="ushort" name="length" no-assign="true" />
      </middle>
    </struct>
    <xsl:call-template name="request-function">
      <xsl:with-param name="checked" select="'true'" />
      <xsl:with-param name="req" select="$req" />
    </xsl:call-template>
    <xsl:call-template name="request-function">
      <xsl:with-param name="checked" select="'false'" />
      <xsl:with-param name="req" select="$req" />
    </xsl:call-template>
    <xsl:if test="reply">
      <struct name="{xcb:xcb-prefix(@name)}_reply_t">
        <field type="ubyte" name="response_type" />
        <xsl:apply-templates select="reply/*" mode="field" />
        <middle>
          <field type="ushort" name="sequence" />
          <field type="uint" name="length" />
        </middle>
      </struct>
      <iterator-functions ref="{xcb:xcb-prefix(@name)}" kind="_reply" />
      <function type="{xcb:xcb-prefix(@name)}_reply_t *" name="{xcb:xcb-prefix(@name)}_reply">
        <field type="xcb_connection_t *" name="c" />
        <field name="cookie">
          <xsl:attribute name="type">
            <xsl:call-template name="cookie-type" />
          </xsl:attribute>
        </field>
        <field type="xcb_generic_error_t **" name="e" />
        <l>return (<xsl:value-of select="xcb:xcb-prefix(@name)" />_reply_t *)<!--
        --> xcb_wait_for_reply(c, cookie.sequence, e);</l>
      </function>
    </xsl:if>
  </xsl:template>

  <xsl:template match="xidtype|xidunion" mode="pass1">
    <typedef oldname="uint" newname="{xcb:xcb-prefix(@name)}_t" />
    <iterator ref="{xcb:xcb-prefix(@name)}" />
    <iterator-functions ref="{xcb:xcb-prefix(@name)}" />
  </xsl:template>

  <xsl:template match="struct|union" mode="pass1">
    <struct name="{xcb:xcb-prefix(@name)}_t">
      <xsl:if test="self::union">
        <xsl:attribute name="kind">union</xsl:attribute>
      </xsl:if>
      <xsl:apply-templates select="*" mode="field" />
    </struct>
    <iterator ref="{xcb:xcb-prefix(@name)}" />
    <iterator-functions ref="{xcb:xcb-prefix(@name)}" />
  </xsl:template>

  <xsl:template match="event|eventcopy|error|errorcopy" mode="pass1">
    <xsl:variable name="suffix">
      <xsl:choose>
        <xsl:when test="self::event|self::eventcopy">
          <xsl:text>_event_t</xsl:text>
        </xsl:when>
        <xsl:when test="self::error|self::errorcopy">
          <xsl:text>_error_t</xsl:text>
        </xsl:when>
      </xsl:choose>
    </xsl:variable>
    <constant type="number" name="{xcb:xcb-prefix(@name)}" value="{@number}" />
    <xsl:choose>
      <xsl:when test="self::event|self::error">
        <struct name="{xcb:xcb-prefix(@name)}{$suffix}">
          <field type="ubyte" name="response_type" />
          <xsl:if test="self::error">
            <field type="ubyte" name="error_code" />
          </xsl:if>
          <xsl:apply-templates select="*" mode="field" />
          <xsl:if test="not(self::event and boolean(@no-sequence-number))">
            <middle>
              <field type="ushort" name="sequence" />
            </middle>
          </xsl:if>
        </struct>
      </xsl:when>
      <xsl:when test="self::eventcopy|self::errorcopy">
        <typedef newname="{xcb:xcb-prefix(@name)}{$suffix}">
          <xsl:attribute name="oldname">
            <xsl:call-template name="canonical-type-name">
              <xsl:with-param name="type" select="@ref" />
            </xsl:call-template>
            <xsl:value-of select="$suffix" />
          </xsl:attribute>
        </typedef>
      </xsl:when>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="typedef" mode="pass1">
    <typedef>
      <xsl:attribute name="oldname">
        <xsl:call-template name="canonical-type-name">
          <xsl:with-param name="type" select="@oldname" />
        </xsl:call-template>
       	  <xsl:if test="not(@oldname='BYTE') and not(@oldname='BOOL')and not(@oldname='CARD8')and not(@oldname='CARD16')and not(@oldname='CARD32')and not(@oldname='INT8')and not(@oldname='INT16')and not(@oldname='INT32')">
        	<xsl:text>_t</xsl:text>
          </xsl:if>
      </xsl:attribute>
      <xsl:attribute name="newname">
        <xsl:call-template name="canonical-type-name">
          <xsl:with-param name="type" select="@newname" />
        </xsl:call-template>
        <xsl:text>_t</xsl:text>
      </xsl:attribute>
    </typedef>
    <iterator ref="{xcb:xcb-prefix(@newname)}" />
    <iterator-functions ref="{xcb:xcb-prefix(@newname)}" />
  </xsl:template>

  <xsl:template match="enum" mode="pass1">
    <enum name="{xcb:xcb-prefix(@name)}_t">
      <xsl:for-each select="item">
        <item name="{translate(xcb:xcb-prefix(concat(../@name, concat('_', @name))), $lcase, $ucase)}">
          <xsl:copy-of select="*" />
        </item>
      </xsl:for-each>
    </enum>
  </xsl:template>

  <!--
    Templates for processing fields.
  -->

  <xsl:template match="pad" mode="field">
    <xsl:copy-of select="." />
  </xsl:template>
  
  <xsl:template match="field|exprfield" mode="field">
    <xsl:copy>
      <xsl:attribute name="type">
        <xsl:call-template name="canonical-type-name" />
        <xsl:if test="not(@type='BYTE') and not(@type='BOOL')and not(@type='CARD8')and not(@type='CARD16')and not(@type='CARD32')and not(@type='INT8')and not(@type='INT16')and not(@type='INT32')">
        	<xsl:text>_t</xsl:text>
        </xsl:if>
      </xsl:attribute>
      <xsl:attribute name="name">
        <xsl:call-template name="canonical-var-name" />
      </xsl:attribute>
      <xsl:copy-of select="*" />
    </xsl:copy>
  </xsl:template>

  <xsl:template match="list" mode="field">
    <xsl:variable name="type"><!--
      --><xsl:call-template name="canonical-type-name" />
        <xsl:if test="not(@type='BYTE') and not(@type='BOOL')and not(@type='CARD8')and not(@type='CARD16')and not(@type='CARD32')and not(@type='INT8')and not(@type='INT16')and not(@type='INT32')">
          <xsl:text>_t</xsl:text><!---->
        </xsl:if>
    </xsl:variable>
    <list type="{$type}">
      <xsl:attribute name="name">
        <xsl:call-template name="canonical-var-name" />
      </xsl:attribute>
      <xsl:if test="not(parent::request) and node()
                    and not(.//*[not(self::value or self::op)])">
        <xsl:attribute name="fixed">true</xsl:attribute>
      </xsl:if>
      <!-- Handle lists with no length expressions. -->
      <xsl:if test="not(node())">
        <xsl:choose>
          <!-- In a request, refer to an implicit localparam for length. -->
          <xsl:when test="parent::request">
            <fieldref>
              <xsl:value-of select="concat(@name, '_len')" />
            </fieldref>
          </xsl:when>
          <!-- In a reply, use the length of the reply to determine the length
               of the list. -->
          <xsl:when test="parent::reply">
            <op op="/">
              <op op="&lt;&lt;">
                <fieldref>length</fieldref>
                <value>2</value>
              </op>
              <function-call name="sizeof">
                <param><xsl:value-of select="$type" /></param>
              </function-call>
            </op>
          </xsl:when>
          <!-- Other cases generate an error. -->
          <xsl:otherwise>
            <xsl:message terminate="yes"><!--
              -->Encountered a list with no length expresssion outside a<!--
              --> request or reply.<!--
            --></xsl:message>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:if>
      <xsl:copy-of select="*" />
    </list>
  </xsl:template>

  <xsl:template match="valueparam" mode="field">
    <field>
      <xsl:attribute name="type">
        <xsl:call-template name="canonical-type-name">
          <xsl:with-param name="type" select="@value-mask-type" />
        </xsl:call-template>
        <xsl:if test="not(@value-mask-type='BYTE') and not(@value-mask-type='BOOL')and not(@value-mask-type='CARD8')and not(@value-mask-type='CARD16')and not(@value-mask-type='CARD32')and not(@value-mask-type='INT8')and not(@value-mask-type='INT16')and not(@value-mask-type='INT32')">
          <xsl:text>_t</xsl:text>
        </xsl:if>
      </xsl:attribute>
      <xsl:attribute name="name">
        <xsl:call-template name="canonical-var-name">
          <xsl:with-param name="name" select="@value-mask-name" />
        </xsl:call-template>
      </xsl:attribute>
    </field>
    <list type="uint">
      <xsl:attribute name="name">
        <xsl:call-template name="canonical-var-name">
          <xsl:with-param name="name" select="@value-list-name" />
        </xsl:call-template>
      </xsl:attribute>
      <function-call name="xcb_popcount">
        <param>
          <fieldref>
            <xsl:call-template name="canonical-var-name">
              <xsl:with-param name="name" select="@value-mask-name" />
            </xsl:call-template>
          </fieldref>
        </param>
      </function-call>
    </list>
  </xsl:template>

  <xsl:template match="field" mode="param">
    <field>
      <xsl:attribute name="type">
        <xsl:call-template name="canonical-type-name" />
        <xsl:if test="not(@type='BYTE') and not(@type='BOOL')and not(@type='CARD8')and not(@type='CARD16')and not(@type='CARD32')and not(@type='INT8')and not(@type='INT16')and not(@type='INT32')">
          <xsl:text>_t</xsl:text>
        </xsl:if>
      </xsl:attribute>
      <xsl:attribute name="name">
        <xsl:call-template name="canonical-var-name" />
      </xsl:attribute>
    </field>
  </xsl:template>

  <xsl:template match="list" mode="param">
    <!-- If no length expression is provided, use a CARD32 localfield. -->
    <xsl:if test="not(node())">
      <field type="uint" name="{@name}_len" />
    </xsl:if>
    <field>
      <xsl:variable name="ctype">
        <xsl:call-template name="canonical-type-name" />
      </xsl:variable>
      <xsl:attribute name="type">
        <xsl:text>/+const+/ </xsl:text>
        <xsl:call-template name="canonical-type-name" />
        <xsl:if test="not($ctype='char') and not($ctype='void') and not(@type='BYTE') and not(@type='BOOL')and not(@type='CARD8')and not(@type='CARD16')and not(@type='CARD32')and not(@type='INT8')and not(@type='INT16')and not(@type='INT32')">
          <xsl:text>_t</xsl:text>
        </xsl:if>
        <xsl:text> *</xsl:text>
      </xsl:attribute>
      <xsl:attribute name="name">
        <xsl:call-template name="canonical-var-name" />
      </xsl:attribute>
    </field>
  </xsl:template>

  <xsl:template match="valueparam" mode="param">
    <field>
      <xsl:attribute name="type">
        <xsl:call-template name="canonical-type-name">
          <xsl:with-param name="type" select="@value-mask-type" />
        </xsl:call-template>
        <xsl:if test="not(@value-mask-type='BYTE') and not(@value-mask-type='BOOL')and not(@value-mask-type='CARD8')and not(@value-mask-type='CARD16')and not(@value-mask-type='CARD32')and not(@value-mask-type='INT8')and not(@value-mask-type='INT16')and not(@value-mask-type='INT32')">
        <xsl:text>_t</xsl:text>
        </xsl:if>
      </xsl:attribute>
      <xsl:attribute name="name">
        <xsl:call-template name="canonical-var-name">
          <xsl:with-param name="name" select="@value-mask-name" />
        </xsl:call-template>
      </xsl:attribute>
    </field>
    <field type="/+const+/ uint *">
      <xsl:attribute name="name">
        <xsl:call-template name="canonical-var-name">
          <xsl:with-param name="name" select="@value-list-name" />
        </xsl:call-template>
      </xsl:attribute>
    </field>
  </xsl:template>

  <!-- Second pass: Process the variable. -->
  <xsl:variable name="result-rtf">
    <xsl:apply-templates select="$pass1/*" mode="pass2" />
  </xsl:variable>
  <xsl:variable name="result" select="e:node-set($result-rtf)" />

  <xsl:template match="xcb" mode="pass2">
    <xcb>
      <xsl:copy-of select="@*" />
      <xsl:apply-templates mode="pass2"
                           select="constant|enum|struct|typedef|iterator" />
      <xsl:apply-templates mode="pass2"
                           select="function|iterator-functions" />
    </xcb>
  </xsl:template>

  <!-- Generic rules for nodes that don't need further processing: copy node
       with attributes, and recursively process the child nodes. -->
  <xsl:template match="*" mode="pass2">
    <xsl:copy>
      <xsl:copy-of select="@*" />
      <xsl:apply-templates mode="pass2" />
    </xsl:copy>
  </xsl:template>

  <xsl:template match="struct" mode="pass2">
    <xsl:if test="@kind='union' and list[not(@fixed)]">
      <xsl:message terminate="yes">Unions must be fixed length.</xsl:message>
    </xsl:if>
    <struct name="{@name}">
      <xsl:if test="@kind">
        <xsl:attribute name="kind">
          <xsl:value-of select="@kind" />
        </xsl:attribute>
      </xsl:if>
      <!-- FIXME: This should go by size, not number of fields. -->
      <xsl:copy-of select="node()[not(self::middle)
                   and position() &lt; 3]" />
      <xsl:if test="middle and (count(*[not(self::middle)]) &lt; 2)">
        <pad bytes="{2 - count(*[not(self::middle)])}" />
      </xsl:if>
      <xsl:copy-of select="middle/*" />
      <xsl:copy-of select="node()[not(self::middle) and (position() > 2)]" />
    </struct>
  </xsl:template>

  <xsl:template match="do-request" mode="pass2">
    <xsl:variable name="struct"
                  select="$pass1/xcb/struct[@name=current()/@ref]" />

    <xsl:variable name="num-parts" select="(1+count($struct/list))*2" />

    <l>static const xcb_protocol_request_t xcb_req = {</l>
    <indent>
      <l>/* count */ <xsl:value-of select="$num-parts" />,</l>
      <l>/* ext */ <xsl:choose>
                     <xsl:when test="$ext">
                       <xsl:text>&amp;</xsl:text>
                       <xsl:value-of select="xcb:xcb-prefix()" />
                       <xsl:text>_id</xsl:text>
                     </xsl:when>
                     <xsl:otherwise>0</xsl:otherwise>
                   </xsl:choose>,</l>
      <l>/* opcode */ <xsl:value-of select="@opcode" />,</l>
      <l>/* isvoid */ <xsl:value-of select="1-boolean(@has-reply)" /></l>
    </indent>
    <l>};</l>

    <l />
    <l>struct iovec xcb_parts[<xsl:value-of select="$num-parts+2" />];</l>
    <l><xsl:value-of select="../@type" /> xcb_ret;</l>
    <l><xsl:value-of select="@ref" /> xcb_out;</l>

    <l />
    <xsl:if test="not ($ext) and not($struct//*[(self::field or self::exprfield or self::pad)
                                                and not(boolean(@no-assign))])">
      <l>xcb_out.pad0 = 0;</l>
    </xsl:if>
    <xsl:apply-templates select="$struct//*[(self::field or self::exprfield or self::pad)
                                            and not(boolean(@no-assign))]"
                         mode="assign" />

    <l />
    <l>xcb_parts[2].iov_base = (char *) &amp;xcb_out;</l>
    <l>xcb_parts[2].iov_len = sizeof(xcb_out);</l>
    <l>xcb_parts[3].iov_base = 0;</l>
    <l>xcb_parts[3].iov_len = -xcb_parts[2].iov_len &amp; 3;</l>

    <xsl:for-each select="$struct/list">
      <l>xcb_parts[<xsl:value-of select="2 + position() * 2"/>].iov_base = (char *) <!--
      --><xsl:value-of select="@name" />;</l>
      <l>xcb_parts[<xsl:value-of select="2 + position() * 2"/>].iov_len = <!--
      --><xsl:apply-templates mode="output-expression" />
      <xsl:if test="not(@type = 'void')">
        <xsl:text> * sizeof(</xsl:text>
          <xsl:choose>
          <xsl:when test="@type='char'">
            <xsl:text>char</xsl:text>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="@type" />
          </xsl:otherwise>
        </xsl:choose>
        <xsl:text>)</xsl:text>
      </xsl:if>;</l>
      <l>xcb_parts[<xsl:value-of select="3 + position() * 2"/>].iov_base = 0;</l>
      <l>xcb_parts[<xsl:value-of select="3 + position() * 2"/>].iov_len = -xcb_parts[<xsl:value-of select="2 + position() * 2"/>].iov_len &amp; 3;</l>
    </xsl:for-each>

    <l>xcb_ret.sequence = xcb_send_request(c, <!--
    --><xsl:choose>
         <xsl:when test="@checked='true'">XCB_REQUEST_CHECKED</xsl:when>
         <xsl:otherwise>0</xsl:otherwise>
       </xsl:choose>, xcb_parts + 2, &amp;xcb_req);</l>
    <l>return xcb_ret;</l>
  </xsl:template>

  <xsl:template match="field" mode="assign">
    <l>
      <xsl:text>xcb_out.</xsl:text>
      <xsl:value-of select="@name" />
      <xsl:text> = </xsl:text>
      <xsl:value-of select="@name" />
      <xsl:text>;</xsl:text>
    </l>
  </xsl:template>

  <xsl:template match="exprfield" mode="assign">
    <l>
      <xsl:text>xcb_out.</xsl:text>
      <xsl:value-of select="@name" />
      <xsl:text> = </xsl:text>
      <xsl:apply-templates mode="output-expression" />
      <xsl:text>;</xsl:text>
    </l>
  </xsl:template>

  <xsl:template match="pad" mode="assign">
    <xsl:variable name="padnum"><xsl:number /></xsl:variable>
    <l><xsl:choose>
        <xsl:when test="@bytes = 1">xcb_out.pad<xsl:value-of select="$padnum - 1" /> = 0;</xsl:when>
        <xsl:otherwise>memset(xcb_out.pad<xsl:value-of select="$padnum - 1" />, 0, <xsl:value-of select="@bytes" />);</xsl:otherwise>
    </xsl:choose></l>
  </xsl:template>

  <xsl:template match="iterator" mode="pass2">
    <struct name="{@ref}_iterator_t">
      <field type="{@ref}_t *" name="data" />
      <field type="int" name="rem" />
      <field type="int" name="index" />
    </struct>
  </xsl:template>

  <xsl:template match="iterator-functions" mode="pass2">
    <xsl:variable name="ref" select="@ref" />
    <xsl:variable name="kind" select="@kind" />
    <xsl:variable name="struct"
                  select="$pass1/xcb/struct[@name=concat($ref, $kind, '_t')]" />
    <xsl:variable name="nextfields-rtf">
      <nextfield>R + 1</nextfield>
      <xsl:for-each select="$struct/list[not(@fixed)]">
        <xsl:choose>
          <xsl:when test="substring(@type, 1, 3) = 'xcb'">
            <nextfield><xsl:value-of select="substring(@type, 1, string-length(@type)-2)" />_end(<!--
            --><xsl:value-of select="$ref" />_<!--
            --><xsl:value-of select="string(@name)" />_iterator(R))</nextfield>
          </xsl:when>
          <xsl:otherwise>
            <nextfield><xsl:value-of select="$ref" />_<!--
            --><xsl:value-of select="string(@name)" />_end(R)</nextfield>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:for-each>
    </xsl:variable>
    <xsl:variable name="nextfields" select="e:node-set($nextfields-rtf)" />
    <xsl:for-each select="$struct/list[not(@fixed)]">
      <xsl:variable name="number"
                    select="1+count(preceding-sibling::list[not(@fixed)])" />
      <xsl:variable name="nextfield" select="$nextfields/nextfield[$number]" />
      <xsl:variable name="is-first"
                    select="not(preceding-sibling::list[not(@fixed)])" />
      <xsl:variable name="field-name" select="@name" />
      <xsl:variable name="is-variable"
                    select="$pass1/xcb/struct[@name=current()/@type]/list
                            or document($search-path)/xcb
                               /struct[concat(xcb:xcb-prefix(@name), '_t')
                                       = current()/@type]
                               /*[self::valueparam
                                  or self::list[.//*[not(self::value
                                                         or self::op)]]]" />
      <xsl:if test="not($is-variable)">
        <function type="{xcb:get-char-void(@type)} *" name="{$ref}_{xcb:lowercase($field-name)}">
          <field type="/+const+/ {$ref}{$kind}_t *" name="R" />
          <xsl:choose>
            <xsl:when test="$is-first">
              <l>return (<xsl:value-of select="xcb:get-char-void(@type)" /> *) <!--
              -->(<xsl:value-of select="$nextfield" />);</l>
            </xsl:when>
            <xsl:otherwise>
              <l>xcb_generic_iterator_t prev = <!--
              --><xsl:value-of select="$nextfield" />;</l>
              <l>return (<xsl:value-of select="xcb:get-char-void(@type)" /> *) <!--
              -->((char *) prev.data + XCB_TYPE_PAD(<!--
              --><xsl:value-of select="xcb:get-char-void(@type)" />, prev.index));</l>
            </xsl:otherwise>
          </xsl:choose>
        </function>
      </xsl:if>
      <function type="int" name="{$ref}_{xcb:lowercase($field-name)}_length">
        <field type="/+const+/ {$ref}{$kind}_t *" name="R" />
        <l>return <xsl:apply-templates mode="output-expression">
                    <xsl:with-param name="field-prefix" select="'R->'" />
                  </xsl:apply-templates>;</l>
      </function>
      <xsl:choose>
        <xsl:when test="substring(@type, 1, 3) = 'xcb'">
          <function type="{substring(@type, 1, string-length(@type)-2)}_iterator_t" name="{$ref}_{xcb:lowercase($field-name)}_iterator">
            <field type="/+const+/ {$ref}{$kind}_t *" name="R" />
            <l><xsl:value-of select="substring(@type, 1, string-length(@type)-2)" />_iterator_t i;</l>
            <xsl:choose>
              <xsl:when test="$is-first">
                <l>i.data = (<xsl:value-of select="@type" /> *) <!--
                -->(<xsl:value-of select="$nextfield" />);</l>
              </xsl:when>
              <xsl:otherwise>
                <l>xcb_generic_iterator_t prev = <!--
                --><xsl:value-of select="$nextfield" />;</l>
                <l>i.data = (<xsl:value-of select="@type" /> *) <!--
                -->((char *) prev.data + XCB_TYPE_PAD(<!--
                --><xsl:value-of select="@type" />, prev.index));</l>
              </xsl:otherwise>
            </xsl:choose>
            <l>i.rem = <xsl:apply-templates mode="output-expression">
                         <xsl:with-param name="field-prefix" select="'R->'" />
                       </xsl:apply-templates>;</l>
            <l>i.index = (char *) i.data - (char *) R;</l>
            <l>return i;</l>
          </function>
        </xsl:when>
        <xsl:otherwise>
          <xsl:variable name="cast">
            <xsl:choose>
              <xsl:when test="@type='void'">char</xsl:when>
              <xsl:otherwise><xsl:value-of select="@type" /></xsl:otherwise>
            </xsl:choose>
          </xsl:variable>
          <function type="xcb_generic_iterator_t" name="{$ref}_{xcb:lowercase($field-name)}_end">
            <field type="/+const+/ {$ref}{$kind}_t *" name="R" />
            <l>xcb_generic_iterator_t i;</l>
            <xsl:choose>
              <xsl:when test="$is-first">
                <l>i.data = ((<xsl:value-of select="xcb:remove-void($cast)" /> *) <!--
                -->(<xsl:value-of select="$nextfield" />)) + (<!--
                --><xsl:apply-templates mode="output-expression">
                     <xsl:with-param name="field-prefix" select="'R->'" />
                   </xsl:apply-templates>);</l>
              </xsl:when>
              <xsl:otherwise>
                <l>xcb_generic_iterator_t child = <!--
                --><xsl:value-of select="$nextfield" />;</l>
                <l>i.data = ((<xsl:value-of select="xcb:get-char-void($cast)" /> *) <!--
                -->child.data) + (<!--
                --><xsl:apply-templates mode="output-expression">
                     <xsl:with-param name="field-prefix" select="'R->'" />
                   </xsl:apply-templates>);</l>
              </xsl:otherwise>
            </xsl:choose>
            <l>i.rem = 0;</l>
            <l>i.index = (char *) i.data - (char *) R;</l>
            <l>return i;</l>
          </function>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:for-each>
    <xsl:if test="not($kind)">
      <function type="void" name="{$ref}_next">
        <field type="{$ref}_iterator_t *" name="i" />
        <xsl:choose>
          <xsl:when test="$struct/list[not(@fixed)]">
            <l><xsl:value-of select="$ref" />_t *R = i->data;</l>
            <l>xcb_generic_iterator_t child = <!--
            --><xsl:value-of select="$nextfields/nextfield[last()]" />;</l>
            <l>--i->rem;</l>
            <l>i->data = (<xsl:value-of select="$ref" />_t *) child.data;</l>
            <l>i->index = child.index;</l>
          </xsl:when>
          <xsl:otherwise>
            <l>--i->rem;</l>
            <l>++i->data;</l>
            <l>i->index += sizeof(<xsl:value-of select="$ref" />_t);</l>
          </xsl:otherwise>
        </xsl:choose>
      </function>
      <function type="xcb_generic_iterator_t" name="{$ref}_end">
        <field type="{$ref}_iterator_t" name="i" />
        <l>xcb_generic_iterator_t ret;</l>
        <xsl:choose>
          <xsl:when test="$struct/list[not(@fixed)]">
            <l>while(i.rem > 0)</l>
            <indent>
              <l><xsl:value-of select="$ref" />_next(&amp;i);</l>
            </indent>
            <l>ret.data = i.data;</l>
            <l>ret.rem = i.rem;</l>
            <l>ret.index = i.index;</l>
          </xsl:when>
          <xsl:otherwise>
            <l>ret.data = i.data + i.rem;</l>
            <l>ret.index = i.index + ((char *) ret.data - (char *) i.data);</l>
            <l>ret.rem = 0;</l>
          </xsl:otherwise>
        </xsl:choose>
        <l>return ret;</l>
      </function>
    </xsl:if>
  </xsl:template>

  <!-- Output the results. -->
  <xsl:template match="/">
    <xsl:if test="not(function-available('e:node-set'))">
      <xsl:message terminate="yes"><!--
        -->Error: This stylesheet requires the EXSL node-set extension.<!--
      --></xsl:message>
    </xsl:if>

    <xsl:if test="not($h) and not($c)">
      <xsl:message terminate="yes"><!--
        -->Error: Parameter "mode" must be "header" or "source".<!--
      --></xsl:message>
    </xsl:if>

    <xsl:apply-templates select="$result/*" mode="output" />
  </xsl:template>

  <xsl:template match="xcb" mode="output">
    <xsl:variable name="guard"><!--
      -->__<xsl:value-of select="$ucase-header" />_H<!--
    --></xsl:variable>

<xsl:text>/*
 * This file generated automatically from </xsl:text>
<xsl:value-of select="$header" /><xsl:text>.xml by c-client.xsl using XSLT.
 * Edit at your peril.
 */
</xsl:text>
<xsl:if test="$h"><xsl:text>
/**
 * @defgroup XCB_</xsl:text><xsl:value-of select="$ext" /><xsl:text>_API XCB </xsl:text><xsl:value-of select="$ext" /><xsl:text> API
 * @brief </xsl:text><xsl:value-of select="$ext" /><xsl:text> XCB Protocol Implementation.</xsl:text>
<xsl:text>
 * @{
 **/
</xsl:text>

<xsl:text>
<!--#ifndef </xsl:text><xsl:value-of select="$guard" /><xsl:text>-->
module std.c.linux.X11.xcb.</xsl:text><xsl:value-of select="$header" /><xsl:text>;
</xsl:text>
import std.c.linux.X11.xcb.xcb;
<xsl:for-each select="$root/xcb/import">
<xsl:text>import std.c.linux.X11.xcb.</xsl:text><xsl:value-of select="." /><xsl:text>;
</xsl:text>
</xsl:for-each>
<xsl:text>
</xsl:text>
</xsl:if>
<xsl:if test="$h">
    <xsl:choose>
        <xsl:when test="string($ext)">
  <xsl:text>const int XCB_</xsl:text><xsl:value-of select="translate($ext, $lcase, $ucase)"/><xsl:text>_MAJOR_VERSION =</xsl:text><xsl:value-of select="/xcb/@major-version" /><xsl:text>;
</xsl:text>
  <xsl:text>const int XCB_</xsl:text><xsl:value-of select="translate($ext, $lcase, $ucase)"/><xsl:text>_MINOR_VERSION =</xsl:text><xsl:value-of select="/xcb/@minor-version" />
  <xsl:text>;
  
</xsl:text>
    </xsl:when>
  </xsl:choose>
</xsl:if>

<!--<xsl:if test="$c">
<xsl:if test="$need-string-h">
#include &lt;string.h&gt;</xsl:if>
<xsl:text>
#include &lt;assert.h&gt;
#include "xcbext.h"
#include "</xsl:text><xsl:value-of select="$header" /><xsl:text>.h"

</xsl:text></xsl:if>-->

    <xsl:apply-templates mode="output" />

<xsl:if test="$h">
<xsl:text>

/**
 * @}
 */
</xsl:text>
</xsl:if>
  </xsl:template>

  <xsl:template match="constant" mode="output">
    <xsl:choose>
      <xsl:when test="@type = 'number'">
        <xsl:if test="$h">
          <xsl:text>/** Opcode for </xsl:text><xsl:value-of select="@name"/><xsl:text>. */
</xsl:text>
          <xsl:text>const uint </xsl:text>
          <xsl:value-of select="translate(@name, $lcase, $ucase)" />
          <xsl:text> = </xsl:text>
          <xsl:value-of select="@value" />
          <xsl:text>;

</xsl:text>
        </xsl:if>
      </xsl:when>
      <xsl:when test="@type = 'string'">
        <xsl:if test="$h">
          <xsl:text>extern(C) extern </xsl:text>
        </xsl:if>
        <xsl:text>/+const+/ char </xsl:text>
        <xsl:value-of select="@name" />
        <xsl:text>[]</xsl:text>
        <xsl:if test="$c">
          <xsl:text> = "</xsl:text>
          <xsl:value-of select="@value" />
          <xsl:text>"</xsl:text>
        </xsl:if>
        <xsl:text>;

</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:if test="$h">
          <xsl:text>extern(C) extern </xsl:text>
        </xsl:if>
        <xsl:call-template name="type-and-name" />
        <xsl:if test="$c">
          <xsl:text> = </xsl:text>
          <xsl:value-of select="@value" />
        </xsl:if>
        <xsl:text>;

</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="typedef" mode="output">
    <xsl:if test="$h">
      <xsl:text>alias </xsl:text>
      <xsl:value-of select="xcb:get-char-void(@oldname)" />
      <xsl:text> </xsl:text>
      <xsl:value-of select="@newname" />
      <xsl:text>;

</xsl:text>
    </xsl:if>
  </xsl:template>

  <xsl:template match="struct" mode="output">
    <xsl:if test="$h">
      <xsl:variable name="type-lengths">
        <xsl:call-template name="type-lengths">
          <xsl:with-param name="items" select="field/@type" />
        </xsl:call-template>
      </xsl:variable>
      <xsl:text>/**
 * @brief </xsl:text><xsl:value-of select="@name" /><xsl:text>
 **/
</xsl:text>
      <xsl:if test="not(@kind)">struct</xsl:if><xsl:value-of select="@kind" />
      <xsl:text> </xsl:text>
      <xsl:value-of select="@name" />
      <xsl:text> {
</xsl:text>
      <xsl:for-each select="exprfield|field|list[@fixed]|pad">
        <xsl:text>    </xsl:text>
        <xsl:apply-templates select=".">
          <xsl:with-param name="type-lengths" select="$type-lengths" />
        </xsl:apply-templates>
        <xsl:text>; /**&lt; </xsl:text><xsl:text> */
</xsl:text>
      </xsl:for-each>
      <xsl:text>} </xsl:text>
      <xsl:text>;

</xsl:text>
    </xsl:if>
  </xsl:template>

  <xsl:template match="enum" mode="output">
    <xsl:if test="$h">
      <xsl:text>enum </xsl:text>
      <!--<xsl:value-of select="@name" />-->
      <xsl:text>:int{
    </xsl:text>
      <xsl:call-template name="list">
        <xsl:with-param name="separator"><xsl:text>,
    </xsl:text></xsl:with-param>
        <xsl:with-param name="items">
          <xsl:for-each select="item">
            <item>
              <xsl:value-of select="@name" />
              <xsl:if test="node()"> <!-- If there is an expression -->
                <xsl:text> = </xsl:text>
                <xsl:apply-templates mode="output-expression" />
              </xsl:if>
            </item>
          </xsl:for-each>
        </xsl:with-param>
      </xsl:call-template>
      <xsl:text>
};

</xsl:text>
    </xsl:if>
  </xsl:template>

  <xsl:template match="function" mode="output">
    <xsl:variable name="decl-open" select="concat(@name, ' (')" />
    <xsl:variable name="type-lengths">
      <xsl:call-template name="type-lengths">
        <xsl:with-param name="items" select="field/@type" />
      </xsl:call-template>
  </xsl:variable>
  <!-- Doxygen for functions in header. -->
/*****************************************************************************
 **
 ** <xsl:value-of select="@type" />
 <xsl:text> </xsl:text>
 <xsl:value-of select="@name" />
 ** <xsl:call-template name="list">
     <xsl:with-param name="items">
         <xsl:for-each select="field">
             <item>
                 <xsl:text>
 ** @param </xsl:text>
                 <xsl:apply-templates select=".">
                     <xsl:with-param name="type-lengths" select="$type-lengths" />
                 </xsl:apply-templates>
             </item>
         </xsl:for-each>
     </xsl:with-param>
 </xsl:call-template>
 ** @returns <xsl:value-of select="@type" />
 **
 *****************************************************************************/
 
extern(C) <xsl:value-of select="@type" />
    <xsl:text>
</xsl:text>
    <xsl:value-of select="$decl-open" />
    <xsl:call-template name="list">
      <xsl:with-param name="separator">
        <xsl:text>,
</xsl:text>
        <xsl:call-template name="repeat">
          <xsl:with-param name="count" select="string-length($decl-open)" />
        </xsl:call-template>
      </xsl:with-param>
      <xsl:with-param name="items">
        <xsl:for-each select="field">
          <item>
            <xsl:apply-templates select=".">
              <xsl:with-param name="type-lengths" select="$type-lengths" />
            </xsl:apply-templates>
            <xsl:text>  /**&lt; */</xsl:text>
          </item>
        </xsl:for-each>
      </xsl:with-param>
    </xsl:call-template>
    <xsl:text>)</xsl:text>

    <xsl:if test="$h"><xsl:text>;

</xsl:text></xsl:if>

    <xsl:if test="$c">
      <xsl:text>
{
</xsl:text>
      <xsl:apply-templates select="l|indent" mode="function-body">
        <xsl:with-param name="indent" select="$indent-string" />
      </xsl:apply-templates>
      <xsl:text>}

</xsl:text>
    </xsl:if>
  </xsl:template>

  <xsl:template match="l" mode="function-body">
    <xsl:param name="indent" />
    <xsl:value-of select="concat($indent, .)" /><xsl:text>
</xsl:text>
  </xsl:template>

  <xsl:template match="indent" mode="function-body">
    <xsl:param name="indent" />
    <xsl:apply-templates select="l|indent" mode="function-body">
      <xsl:with-param name="indent" select="concat($indent, $indent-string)" />
    </xsl:apply-templates>
  </xsl:template>

  <xsl:template match="value" mode="output-expression">
    <xsl:value-of select="." />
  </xsl:template>

  <xsl:template match="fieldref" mode="output-expression">
    <xsl:param name="field-prefix" />
    <xsl:value-of select="concat($field-prefix, .)" />
  </xsl:template>

  <xsl:template match="op" mode="output-expression">
    <xsl:param name="field-prefix" />
    <xsl:text>(</xsl:text>
    <xsl:apply-templates select="node()[1]" mode="output-expression">
      <xsl:with-param name="field-prefix" select="$field-prefix" />
    </xsl:apply-templates>
    <xsl:text> </xsl:text>
    <xsl:value-of select="@op" />
    <xsl:text> </xsl:text>
    <xsl:apply-templates select="node()[2]" mode="output-expression">
      <xsl:with-param name="field-prefix" select="$field-prefix" />
    </xsl:apply-templates>
    <xsl:text>)</xsl:text>
  </xsl:template>

  <xsl:template match="bit" mode="output-expression">
    <xsl:text>(1 &lt;&lt; </xsl:text>
    <xsl:value-of select="." />
    <xsl:text>)</xsl:text>
  </xsl:template>

  <xsl:template match="function-call" mode="output-expression">
    <xsl:param name="field-prefix" />
    <xsl:value-of select="@name" />
    <xsl:text>(</xsl:text>
    <xsl:call-template name="list">
      <xsl:with-param name="separator" select="', '" />
      <xsl:with-param name="items">
        <xsl:for-each select="param">
          <item><xsl:apply-templates mode="output-expression">
            <xsl:with-param name="field-prefix" select="$field-prefix" />
          </xsl:apply-templates></item>
        </xsl:for-each>
      </xsl:with-param>
    </xsl:call-template>
    <xsl:text>)</xsl:text>
  </xsl:template>

  <!-- Catch invalid elements in expressions. -->
  <xsl:template match="*" mode="output-expression">
    <xsl:message terminate="yes">
      <xsl:text>Invalid element in expression: </xsl:text>
      <xsl:value-of select="name()" />
    </xsl:message>
  </xsl:template>

  <xsl:template match="field|exprfield">
    <xsl:param name="type-lengths" select="0" />
    <xsl:call-template name="type-and-name">
      <xsl:with-param name="type-lengths" select="$type-lengths" />
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="list[@fixed]">
    <xsl:param name="type-lengths" select="0" />
    <xsl:call-template name="type-and-name">
      <xsl:with-param name="type-lengths" select="$type-lengths" />
    </xsl:call-template>
    <xsl:text>[</xsl:text>
    <xsl:apply-templates mode="output-expression" />
    <xsl:text>]</xsl:text>
  </xsl:template>

  <xsl:template match="pad">
    <xsl:param name="type-lengths" select="0" />

    <xsl:variable name="padnum"><xsl:number /></xsl:variable>

    <xsl:call-template name="type-and-name">
      <xsl:with-param name="type" select="'ubyte'" />
      <xsl:with-param name="name">
        <xsl:text>pad</xsl:text>
        <xsl:value-of select="$padnum - 1" />
      </xsl:with-param>
      <xsl:with-param name="type-lengths" select="$type-lengths" />
    </xsl:call-template>
    <xsl:if test="@bytes > 1">
      <xsl:text>[</xsl:text>
      <xsl:value-of select="@bytes" />
      <xsl:text>]</xsl:text>
    </xsl:if>
  </xsl:template>

  <!-- Output the given type and name (defaulting to the corresponding
       attributes of the context node), with the appropriate spacing.  The
       type must consist of a base type (which may contain spaces), then
       optionally a single space and a suffix of one or more '*' characters.
       If the type-lengths parameter is provided, use it to line up the base
       types and suffixs of the type declarations. -->
  <xsl:template name="type-and-name">
    <xsl:param name="type" select="@type" />
    <xsl:param name="name" select="@name" />
    <xsl:param name="type-lengths">
      <max-type-length>0</max-type-length>
      <max-suffix-length>0</max-suffix-length>
    </xsl:param>
    
    <xsl:variable name="type-lengths-ns" select="e:node-set($type-lengths)" />
    <xsl:variable name="min-type-length"
                  select="$type-lengths-ns/max-type-length" />
    <xsl:variable name="min-suffix-length"
                  select="$type-lengths-ns/max-suffix-length" />

    <xsl:variable name="base-type">
      <xsl:choose>
        <xsl:when test="contains($type, ' *')">
          <xsl:value-of select="substring-before($type, ' *')" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$type" />
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="suffix">
      <xsl:if test="contains($type, ' *')">
        <xsl:text>*</xsl:text>
        <xsl:value-of select="substring-after($type, ' *')" />
      </xsl:if>
    </xsl:variable>

    <xsl:value-of select="$base-type" />
    <xsl:if test="string-length($base-type) &lt; $min-type-length">
      <xsl:call-template name="repeat">
        <xsl:with-param name="count" select="$min-type-length
                                             - string-length($base-type)" />
      </xsl:call-template>
    </xsl:if>
    <xsl:text> </xsl:text>
    <xsl:if test="string-length($suffix) &lt; $min-suffix-length">
      <xsl:call-template name="repeat">
        <xsl:with-param name="count" select="$min-suffix-length
                                             - string-length($suffix)" />
      </xsl:call-template>
    </xsl:if>
    <xsl:value-of select="$suffix" />
    <xsl:value-of select="$name" />
  </xsl:template>

  <!-- Output a list with a given separator.  Empty items are skipped. -->
  <xsl:template name="list">
    <xsl:param name="separator" />
    <xsl:param name="items" />

    <xsl:for-each select="e:node-set($items)/*">
      <xsl:value-of select="." />
      <xsl:if test="not(position() = last())">
        <xsl:value-of select="$separator" />
      </xsl:if>
    </xsl:for-each>
  </xsl:template>

  <!-- Repeat a string (space by default) a given number of times. -->
  <xsl:template name="repeat">
    <xsl:param name="str" select="' '" />
    <xsl:param name="count" />

    <xsl:if test="$count &gt; 0">
      <xsl:value-of select="$str" />
      <xsl:call-template name="repeat">
        <xsl:with-param name="str"   select="$str" />
        <xsl:with-param name="count" select="$count - 1" />
      </xsl:call-template>
    </xsl:if>
  </xsl:template>

  <!-- Record the maximum type lengths of a set of types for use as the
       max-type-lengths parameter of type-and-name. -->
  <xsl:template name="type-lengths">
    <xsl:param name="items" />
    <xsl:variable name="type-lengths-rtf">
      <xsl:for-each select="$items">
        <item>
          <xsl:choose>
            <xsl:when test="contains(., ' *')">
              <xsl:value-of select="string-length(
                                    substring-before(., ' *'))" />
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="string-length(.)" />
            </xsl:otherwise>
          </xsl:choose>
        </item>
      </xsl:for-each>
    </xsl:variable>
    <xsl:variable name="suffix-lengths-rtf">
      <xsl:for-each select="$items">
        <item>
          <xsl:choose>
            <xsl:when test="contains(., ' *')">
              <xsl:value-of select="string-length(substring-after(., ' *'))
                                    + 1" />
            </xsl:when>
            <xsl:otherwise>
              <xsl:text>0</xsl:text>
            </xsl:otherwise>
          </xsl:choose>
        </item>
      </xsl:for-each>
    </xsl:variable>
    <max-type-length>
      <xsl:call-template name="max">
        <xsl:with-param name="items"
                        select="e:node-set($type-lengths-rtf)/*" />
      </xsl:call-template>
    </max-type-length>
    <max-suffix-length>
      <xsl:call-template name="max">
        <xsl:with-param name="items"
                        select="e:node-set($suffix-lengths-rtf)/*" />
      </xsl:call-template>
    </max-suffix-length>
  </xsl:template>

  <!-- Return the maximum number in a set of numbers. -->
  <xsl:template name="max">
    <xsl:param name="items" />
    <xsl:choose>
      <xsl:when test="count($items) = 0">
        <xsl:text>0</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="head" select="number($items[1])" />
        <xsl:variable name="tail-max">
          <xsl:call-template name="max">
            <xsl:with-param name="items" select="$items[position() > 1]" />
          </xsl:call-template>
        </xsl:variable>
        <xsl:choose>
          <xsl:when test="$head > number($tail-max)">
            <xsl:value-of select="$head" />
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="$tail-max" />
          </xsl:otherwise>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
</xsl:transform>
