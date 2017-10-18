Shader "Custom/GaussianBlur"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_BlurSize ("BlurSize", Float) = 1.0
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100

		CGINCLUDE

		#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float4 pos : SV_POSITION;
				// TODO: the TEXCOORD space is enough?
				half2 uv[5] : TEXCOORD0;
			};

			sampler2D _MainTex;
			half4 _MainTex_TexelSize;
			float _BlurSize;

			fixed weight[3] = {0.4026, 0.2442,  0.0545};
			
			v2f vertVertical (appdata v)
			{
				half2 uv = v.uv;

				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);

				o.uv[0] = uv;
				o.uv[1] = uv + half2(0.0, _MainTex_TexelSize.y*1.0) * _BlurSize;
				o.uv[2] = uv - half2(0.0, _MainTex_TexelSize.y*1.0) * _BlurSize;
				o.uv[3] = uv + half2(0.0, _MainTex_TexelSize.y*2.0) * _BlurSize;
				o.uv[4] = uv - half2(0.0, _MainTex_TexelSize.y*2.0) * _BlurSize;

				return o;
			}

			v2f vertHorizontal (appdata v)
			{
				half2 uv = v.uv;

				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);

				o.uv[0] = uv;
				o.uv[1] = uv + half2(_MainTex_TexelSize.x*1.0, 0.0) * _BlurSize;
				o.uv[2] = uv - half2(_MainTex_TexelSize.x*1.0, 0.0) * _BlurSize;
				o.uv[3] = uv + half2(_MainTex_TexelSize.x*2.0, 0.0) * _BlurSize;
				o.uv[4] = uv - half2(_MainTex_TexelSize.x*2.0, 0.0) * _BlurSize;

				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				fixed3 sum = 0.0;
				sum += tex2D(_MainTex, i.uv[0])*weight[0];
				for(int iter = 1; iter < 3; iter++) {
					sum += tex2D(_MainTex, i.uv[2*iter-1])*weight[iter];
					sum += tex2D(_MainTex, i.uv[2*iter])*weight[iter];
				}

				return fixed4(sum, 1.0);
			}

		ENDCG
		Pass
		{
			Name "GaussianVertical"
			CGPROGRAM
			#pragma vertex vertVertical
			#pragma fragment frag

			ENDCG
		}
		Pass {
			Name "GaussianHorizontal"
			CGPROGRAM
			#pragma vertex vertHorizontal
			#pragma fragment frag

			ENDCG
		}
	}
}
