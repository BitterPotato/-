Shader "Miuna/Clothing"
{
	Properties
	{
		_DiffuseTex("Diffuse", 2D) = "white" {}
		_SpecularTex("Specular", 2D) = "white" {}

		_DiffuseRamp("Diffuse Ramp", 2D) = "white" {}
		_DiffuseVert("Diffuse Vertical V", Range(0.0, 1.0)) = 0.25

		_SpecularRamp("Specular Ramp", 2D) = "white" {}
		_SpecularVert("Specular Vertical V", Range(0.0, 1.0)) = 0.25

		_FresnelScale ("Fresnel Scale", Range(0.0, 1.0)) = 0.5
		_EnvMap("Environment Cubemap", Cube) = "_Skybox" {}

		_AOTex("AO", 2D) = "white" {}
		_AORatio("AO Ratio", Range(0.0, 1.0)) = 0.3 

		// ==== for outline ====
		_EdgeThickness ("Edge Thickness", float) = 0.001
		_DeltaEdge ("Delta Edge", float) = 0.001
		_NearEdgeDepth ("Near Depth(Edge)", float) = 2.0
		_FarEdgeDepth ("Far Depth(Edge)", float) = 4.0
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100

		Pass
		{
			Cull Back
			ZTest LEqual

			CGPROGRAM
			#pragma vertex vert_base
			#pragma fragment frag_base_base
			
			#define SPECULAR
			#define ENVRIMLIGHT
			#define CAST_SHADOW
			#define AO
			#include "MiunaRamp.cg"

			ENDCG
		}
		// TODO: outline is not in balance
		//Pass {
		//	Name "Outline"

		//	Cull Front
		//	ZTest Less

		//	CGPROGRAM

		//	#pragma vertex outlineVert
		//	#pragma fragment outlineFrag

		//	#include "MiunaCharacter.cg"

		//	ENDCG
		//}
	}
	Fallback "VertexLit"
}
