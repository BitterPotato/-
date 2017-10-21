Shader "Miuna/Skin"
{
	Properties
	{
		_DiffuseTex("Diffuse", 2D) = "white" {}

		_DiffuseRamp("Diffuse Ramp", 2D) = "white" {}
		_DiffuseVert("Diffuse Vertical V", Range(0.0, 1.0)) = 0.25

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

		#include "MiunaRamp.cg"
		ENDCG
	}
	}
}
