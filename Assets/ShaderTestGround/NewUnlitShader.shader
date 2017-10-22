Shader "Test/NewUnlitShader"
{
	Properties
	{
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"

			struct v2f
			{
				float4 vertex : SV_POSITION;
				
			};
			
			float StrandSpecular(float3 T, float3 V, float3 L, float exponent, float strength) {
				float3 H = normalize(L + V);
				float dotTH = dot(T, H);
				float sinTH = sqrt(1.0 - dotTH*dotTH);
				float dirAtten = smoothstep(-1.0, 0.0, dotTH);
				return dirAtten*pow(sinTH, exponent)*strength;
			}

			v2f vert (appdata_tan v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);

				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				return fixed4(0.8, 0.8, 1.0, 1.0);
			}
			ENDCG
		}
	}
}
