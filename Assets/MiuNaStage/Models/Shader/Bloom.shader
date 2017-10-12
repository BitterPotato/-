// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/Bloom"
{
	Properties {
		_MainTex ("MainTex", 2D) = "white" {}
		_BloomTex ("Bloom", 2D) = "white" {}
		_LuminanceThreshold ("Threshold", Float) = 0.5
		_BlurSize ("Blur Size", Float) = 1.0
	}
	SubShader{
//		CGINCLUDE

//		ENDCG

		ZTest Always Cull Off ZWrite Off

		Pass {
			Name "ExtractBright"
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"

		sampler2D _MainTex;
		half4 _MainTex_TexelSize;
		sampler2D _BloomTex;
		float _LuminanceThreshold;
		float _BlurSize;

			struct v2f {
				float4 pos : SV_POSITION;
				half2 uv 			: TEXCOORD0;
			};

	//		struct appdata_img
	//		{
	//		    float4 vertex : POSITION;
	//		    half2 texcoord : TEXCOORD0;
	//		};
			v2f vert (appdata_img v) {
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.uv = v.texcoord;
				return o;
			}
			// extract the bright areas: brighter areas still exist, other areas —> 0.0
			fixed4 frag(v2f i) : SV_Target {
				fixed4 col = tex2D(_MainTex, i.uv);
				fixed val = clamp(LinearRgbToLuminance(col.rgb) - _LuminanceThreshold, 0.0, 1.0);

				return col*val;
			}
			ENDCG
		}

		UsePass "Custom/GaussianBlur/GaussianVertical"
		UsePass "Custom/GaussianBlur/GaussianHorizontal"

		Pass {
			Name "Blend"
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

						#include "UnityCG.cginc"

		sampler2D _MainTex;
		half4 _MainTex_TexelSize;
		sampler2D _BloomTex;
		float _LuminanceThreshold;
		float _BlurSize;

			struct v2f {
				float4 pos : SV_POSITION;
				half4 uv : TEXCOORD0;
			};

			v2f vert(appdata_img v) {
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.uv.xy = v.texcoord;
				o.uv.zw = v.texcoord;

				// in case of DX platform and anti-aliasing
				#if UNITY_UV_STARTS_AT_TOP
				if(_MainTex_TexelSize.y < 0.0)
					o.uv.w = 1.0 - o.uv.w;
				#endif

				return o;
			}

			fixed4 frag(v2f i) : SV_Target {
				return tex2D(_MainTex, i.uv.xy) + tex2D(_BloomTex, i.uv.zw);
			}
			ENDCG
		}
	}
	FallBack Off
}