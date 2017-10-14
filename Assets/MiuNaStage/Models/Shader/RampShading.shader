Shader "Custom/RampShading"
{
	Properties
	{
		_Color ("Inherent", Color) = (1, 1, 1, 1)
		_DiffuseRampTex ("Diffuse Ramp", 2D) = "white" {}
		_SpecularRampTex ("Specular Ramp", 2D) = "white" {}
		_Gloss ("Gloss", Range(8, 256)) = 20
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100

		Pass
		{
			Tags { "LightMode" = "ForwardBase" }

			CGPROGRAM
			// for forwardBase
			// see https://docs.unity3d.com/Manual/SL-MultipleProgramVariants.html
			#pragma multi_compile_fwdbase

			#pragma vertex vert
			#pragma fragment frag

			#include "AnimeRender.cg"

			fixed4 frag (v2f i) : SV_Target {
				// ambient, in UnityShaderVariables.cginc
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
				fixed4 col = fragds(i);
				col.xyz += ambient;
				col = col + frac(voronoi(i.pos.xy));

				return col;
			}

			ENDCG
		}
		// deal with other each-frag lights
		Pass {
			Tags { "LightMode" = "ForwardAdd" }

			Blend one one

			CGPROGRAM

			#pragma multi_compile_fwdadd

			#pragma vertex vert
			#pragma fragment fragds

			#include "AnimeRender.cg"

			ENDCG
		}
	} 
	// include Pass to cast shadow
	FallBack "Diffuse"
}
