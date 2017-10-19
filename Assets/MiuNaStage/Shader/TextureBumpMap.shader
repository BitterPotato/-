Shader "Custom/TextureBumpMap"
{
	Properties
	{
		_DiffuseTex("Diffuse Tex", 2D) = "white" {}
		_SpecularColor("Specular Color", Color) = (1, 1, 1, 1)
		_Gloss("Gloss", float) = 1
		_Multiplier("Multiplier", float) = 2

		_NormalTex("Normal", 2D) = "normal" {}
		_NormalBumpScale("BumpScale", float) = 1.2
	}
		SubShader
	{
		Tags{ "RenderType" = "Opaque" }
		LOD 100

		Pass
	{
		CGPROGRAM
#pragma multi_compile_fwdbase
// #pragma enable_d3d11_debug_symbols

#pragma vertex vert_tan
#pragma fragment frag_tan_base

#define DIFFUSE_TEX
#define SPECULAR_COLOR
#define MULTI
#include "BasicLight.cg"
	
		ENDCG
	}
			Pass{
		Tags{ "LightMode" = "ForwardAdd" }

		Blend one one

		CGPROGRAM

#pragma multi_compile_fwdadd

#pragma vertex vert_tan
#pragma fragment frag_tan_add

#define BP_SPECULAR
#define DIFFUSE_TEX
#define SPECULAR_COLOR
#define MULTI
#include "BasicLight.cg"


		ENDCG
	}
	}
			FallBack "VertexLit"
}
