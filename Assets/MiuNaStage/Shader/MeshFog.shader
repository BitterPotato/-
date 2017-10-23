// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'


Shader "Custom/MeshFog" {

Properties {
	_MainTex ("Base texture", 2D) = "white" {}
	_Multiplier("Multiplier", float) = 1
	_ScrollX("X Scroll Speed", float) = 1
	_ScrollY("Y Scroll Speed", float) = 1
	_Threshold("Threshold", float) = 0.6
	
	_BlendRatio ("Blend Ratio", Range(0.0, 1.0)) = 0.4
}

	
SubShader {
	
	
	Tags { "Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent" }
	
	LOD 100

	Pass {
		Blend SrcAlpha OneMinusSrcAlpha
		Cull Off Lighting Off ZWrite Off

		CGPROGRAM
		#pragma vertex vert
		#pragma fragment frag
		#pragma enable_d3d11_debug_symbols

		#include "MiunaCG.cginc"
		#include "UnityCG.cginc"

		sampler2D _MainTex;

		float _Multiplier;
		float _ScrollX;
		float _ScrollY;
		float _Threshold;

		fixed _BlendRatio;

		sampler2D _GrabBlurTexture;
		float4 _GrabBlurTexture_TexelSize;

		struct v2f 
			float4 pos	: SV_POSITION;
			float2 uv	: TEXCOORD0;
			fixed4 color : TEXCOORD1;
			float3 worldPos : TEXCOORD2;
			float3 worldNormal : TEXCOORD3;
			float4 uvgrab : TEXCOORD4;
		};

		v2f vert(appdata_base v)
		{
			v2f o;

			//o.uv = v.texcoord.xy + frac(float2(_ScrollX, _ScrollY) * _Time.y);
			o.uv = v.texcoord.xy;
			o.pos = UnityObjectToClipPos(v.vertex);
			o.worldPos = mul(unity_ObjectToWorld, v.vertex);
			o.worldNormal = mul(unity_ObjectToWorld, v.normal);

			#if UNITY_UV_STARTS_AT_TOP
			float scale = -1.0;
			#else
			float scale = 1.0;
			#endif
			o.uvgrab.xy = (float2(o.pos.x, o.pos.y*scale) + o.pos.w) * 0.5;
			o.uvgrab.zw = o.pos.zw;

			return o;
		}
		fixed4 frag (v2f i) : SV_Target
		{			
			fixed4 col = fixed4(tex2D (_MainTex, i.uv.xy).xyz, 1.0);
			noise_color(col, perlin_noise(4.0*i.uv.xy));
			col *= _Multiplier;

			// add blur
			// fixed2 offset = fixed2(0.2, 0.0);
			// i.uvgrab.xy += offset;
			col = col + tex2Dproj(_GrabBlurTexture, UNITY_PROJ_COORD(i.uvgrab));

			float3 worldViewDir = UnityWorldSpaceViewDir(i.worldPos);
			float nv = dot(normalize(worldViewDir), normalize(i.worldNormal));
			float falloff = max(abs(nv) - _Threshold, 0.0);
			// col.a = falloff;
			col.a = _BlendRatio;

			return col;
		}
		ENDCG 
	}	
}


}

