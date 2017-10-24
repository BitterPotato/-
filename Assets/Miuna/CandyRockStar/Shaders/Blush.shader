Shader "Miuna/Blush"
{
	Properties
	{
		_MainTex("Diffuse", 2D) = "white" {}
		_Atten ("Attenuation", float) = 0.3
	}
		SubShader
	{
		Tags{ 
			// let the blush be rendered after face
			"Queue" = "Transparent"
			"IgnoreProjector" = "True"
		}
		LOD 100

		Pass
	{
		Blend SrcAlpha OneMinusSrcAlpha, One One
		Cull Back
		// ZTest OFF
		ZTest LEqual
		// Notice: to avoid the cheek accidently cull part of eye
		ZWrite Off

		CGPROGRAM
#pragma vertex vert
#pragma fragment frag

#include "UnityCG.cginc"

		struct appdata
	{
		float4 vertex : POSITION;
		float2 uv : TEXCOORD0;
	};

	struct v2f
	{
		float2 uv : TEXCOORD0;
		float4 vertex : SV_POSITION;
	};

	sampler2D _MainTex;
	float4 _MainTex_ST;

	float _Atten;

	v2f vert(appdata v)
	{
		v2f o;
		o.vertex = UnityObjectToClipPos(v.vertex);
		o.uv = TRANSFORM_TEX(v.uv, _MainTex);
		return o;
	}

	fixed4 frag(v2f i) : SV_Target
	{
		// sample the texture
		fixed4 col = tex2D(_MainTex, i.uv);
		col.a *= _Atten;
		return col;
	}
		ENDCG
	}
	}
}
