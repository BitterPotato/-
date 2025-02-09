﻿Shader "Miuna/Skin"
{
	Properties
	{
		_DiffuseTex("Diffuse", 2D) = "white" {}

		_DiffuseRamp("Diffuse Ramp", 2D) = "white" {}
		_DiffuseVert("Diffuse Vertical V", Range(0.0, 1.0)) = 0.25

		_FresnelScale("Fresnel Scale", Range(0.0, 1.0)) = 0.5
		_EnvMap("Environment Cubemap", Cube) = "_Skybox" {}

		_AOTex("AO", 2D) = "white" {}
		_AORatio("AO Ratio", Range(0.0, 1.0)) = 0.3
	}
		SubShader
	{
		Tags{ "RenderType" = "Opaque" }
		LOD 100

		Pass
	{
		Cull Back
		ZTest LEqual

		CGPROGRAM
		#pragma vertex vert_base
		#pragma fragment frag_base_base

		#define ENVRIMLIGHT
		#define CAST_SHADOW
		#define AO
		#include "MiunaRamp.cg"
		ENDCG
	}
	}
	Fallback "VertexLit"
}
