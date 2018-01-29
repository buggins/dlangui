#ifdef OPENGL_ES
#ifdef GL_FRAGMENT_PRECISION_HIGH
precision highp float;
#else
precision mediump float;
#endif
#endif

#ifndef DIRECTIONAL_LIGHT_COUNT
#define DIRECTIONAL_LIGHT_COUNT 0
#endif
#ifndef SPOT_LIGHT_COUNT
#define SPOT_LIGHT_COUNT 0
#endif
#ifndef POINT_LIGHT_COUNT
#define POINT_LIGHT_COUNT 0
#endif
#if (DIRECTIONAL_LIGHT_COUNT > 0) || (POINT_LIGHT_COUNT > 0) || (SPOT_LIGHT_COUNT > 0)
#define LIGHTING
#endif

///////////////////////////////////////////////////////////
// Uniforms
uniform vec3 u_ambientColor;

uniform sampler2D u_diffuseTexture;

#if defined(LIGHTMAP)
uniform sampler2D u_lightmapTexture;
#endif

#if defined(LIGHTING)

#if defined(BUMPED)
uniform sampler2D u_normalmapTexture;
#endif

#if (DIRECTIONAL_LIGHT_COUNT > 0)
uniform vec3 u_directionalLightColor[DIRECTIONAL_LIGHT_COUNT];
#if !defined(BUMPED)
uniform vec3 u_directionalLightDirection[DIRECTIONAL_LIGHT_COUNT];
#endif
#endif

#if (POINT_LIGHT_COUNT > 0)
uniform vec3 u_pointLightColor[POINT_LIGHT_COUNT];
uniform vec3 u_pointLightPosition[POINT_LIGHT_COUNT];
uniform float u_pointLightRangeInverse[POINT_LIGHT_COUNT];
#endif

#if (SPOT_LIGHT_COUNT > 0)
uniform vec3 u_spotLightColor[SPOT_LIGHT_COUNT];
uniform float u_spotLightRangeInverse[SPOT_LIGHT_COUNT];
uniform float u_spotLightInnerAngleCos[SPOT_LIGHT_COUNT];
uniform float u_spotLightOuterAngleCos[SPOT_LIGHT_COUNT];
#if !defined(BUMPED)
uniform vec3 u_spotLightDirection[SPOT_LIGHT_COUNT];
#endif
#endif

#if defined(SPECULAR)
uniform float u_specularExponent;
#endif

#endif

#if defined(MODULATE_COLOR)
uniform vec4 u_modulateColor;
#endif

#if defined(MODULATE_ALPHA)
uniform float u_modulateAlpha;
#endif

#if defined(FOG)
uniform vec4 u_fogColor;
uniform float u_fogMinDistance;
uniform float u_fogMaxDistance;
#endif

///////////////////////////////////////////////////////////
// Variables
vec4 _baseColor;
out vec4 _fragColor;
///////////////////////////////////////////////////////////
// Varyings
varying vec2 v_texCoord;

#if defined(LIGHTMAP)
varying vec2 v_texCoord1;
#endif

#if defined(LIGHTING)

#if !defined(BUMPED)
varying vec3 v_normalVector;
#endif

#if defined(BUMPED) && (DIRECTIONAL_LIGHT_COUNT > 0)
varying vec3 v_directionalLightDirection[DIRECTIONAL_LIGHT_COUNT];
#endif

#if (POINT_LIGHT_COUNT > 0)
varying vec3 v_vertexToPointLightDirection[POINT_LIGHT_COUNT];
#endif

#if (SPOT_LIGHT_COUNT > 0)
varying vec3 v_vertexToSpotLightDirection[SPOT_LIGHT_COUNT];
#if defined(BUMPED)
varying vec3 v_spotLightDirection[SPOT_LIGHT_COUNT];
#endif
#endif

#if defined(SPECULAR)
varying vec3 v_cameraDirection; 
#endif

#include "lighting.frag"

#endif

#if defined(CLIP_PLANE)
varying float v_clipDistance;
#endif

#if defined(FOG)
varying vec4 viewSpace;
#endif

void main()
{
    #if defined(CLIP_PLANE)
    if(v_clipDistance < 0.0) discard;
    #endif

    _baseColor = texture2D(u_diffuseTexture, v_texCoord);

#if defined(FOG)
    float dist = 0.0;
    float fogFactor = 0.0;
    //range based
    dist = length(viewSpace);
    // linear fog: u_fogMinDistance .. u_fogMaxDistance
    fogFactor = (u_fogMaxDistance - dist) / (u_fogMaxDistance - u_fogMinDistance);
    fogFactor = clamp( fogFactor, 0.0, 1.0 );
    _baseColor = mix(u_fogColor, _baseColor, fogFactor);
#endif
 
    _fragColor.a = _baseColor.a;

    #if defined(TEXTURE_DISCARD_ALPHA)
    if (_fragColor.a < 0.5)
        discard;
    #endif

    #if defined(LIGHTING)

    _fragColor.rgb = getLitPixel();
    #else
    _fragColor.rgb = _baseColor.rgb;
    #endif

	#if defined(LIGHTMAP)
	vec4 lightColor = texture2D(u_lightmapTexture, v_texCoord1);
	_fragColor.rgb *= lightColor.rgb;
	#endif

    #if defined(MODULATE_COLOR)
    _fragColor *= u_modulateColor;
    #endif

    #if defined(MODULATE_ALPHA)
    _fragColor.a *= u_modulateAlpha;
    #endif
}
