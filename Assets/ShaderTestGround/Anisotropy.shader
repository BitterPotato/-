Shader "Test/Anisotropy"
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
			Tags{ "LightMode" = "ForwardBase" }

			CGPROGRAM
			#pragma multi_compile_fwdbase
			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "AutoLight.cginc"

			struct v2f
			{
				float4 vertex : SV_POSITION;
				float3 worldPos : TEXCOORD0;
				float3 worldTan : TEXCOORD1;
				float3 worldNormal : TEXCOORD2;
			};
			
			// exponent upper : spread lower； strength upper : light upper 
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
				
				o.worldPos = mul(unity_ObjectToWorld, v.vertex);
				o.worldTan = mul(unity_ObjectToWorld, v.tangent.xyz);
				o.worldNormal = mul(unity_ObjectToWorld, v.normal);

				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{		
				fixed3 worldViewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));
				fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));
				fixed3 worldTan = normalize(i.worldTan);
				fixed3 worldNormal = normalize(i.worldNormal);
				fixed3 worldEffect = worldTan;

				fixed3 combinedColor = fixed3(0.0, 0.0, 0.0);
				fixed3 inherent = fixed3(84.0/255.0, 91.0/255.0, 133.0/255.0);
				float atten = StrandSpecular(worldEffect, worldViewDir, worldLightDir, 150.0, 2.0);
				float attens = StrandSpecular(worldEffect, worldViewDir, worldLightDir, 10.0, 1.0);
				combinedColor += inherent * atten;
				combinedColor += inherent * attens;
				return fixed4(combinedColor, 1.0);
				// return fixed4(1.0, 1.0, 1.0, 1.0);
			}
			ENDCG
		}
	}
}
