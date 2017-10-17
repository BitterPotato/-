Shader "Custom-Utils/Normal"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_NormalTex("Normal", 2D) = "normal" {}
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
#pragma enable_d3d11_debug_symbols
			
			#include "UnityCG.cginc"
#include "MiunaCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float4 tangent : TANGENT;
				float4 texcoord : TEXCOORD0;
			};
			struct v2f
			{
				float4 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
				float3 lightDir : TEXCOORD2;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;

			sampler2D _NormalTex;
			float4 _NormalTex_ST;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				//o.uv.xy = TRANSFORM_TEX(v.texcoord, _MainTex);
				o.uv.zw = TRANSFORM_TEX(v.texcoord, _NormalTex);

				// transform light to object space, then to tangent space
				// the normal there as one specific axis
				TANGENT_SPACE_ROTATION;
				o.lightDir = normalize(mul(rotation, ObjSpaceLightDir(v.vertex)).xyz);
				float3 lightDir = o.lightDir;
				
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				float3 lightDir = i.lightDir;

				fixed4 ambient = fixed4(40, 78, 178, 255) / 255;
			float _BumpScale = 1.2;
				
			// since unity might optimize the storage of normal map,
			// so we can not directly access the coordinate
			fixed3 tangentNormal = UnpackNormal(tex2D(_NormalTex, i.uv.zw));
			tangentNormal.xy *= _BumpScale;
			tangentNormal.z = sqrt(1.0 - saturate(dot(tangentNormal.xy, tangentNormal.xy)));

			fixed nl = halfLambert(dot(tangentNormal, i.lightDir));
			//fixed4 normalCol = fixed4(tangentNormal.xyz, 1.0);

			//return normalCol;

			ambient.r *= nl;
			ambient.g *= nl;
			ambient.b *= nl;
				return ambient;
			//return fixed4(i.lightDir.xyz + 0.5, 1.0);
			}
			ENDCG
		}
	}
}
